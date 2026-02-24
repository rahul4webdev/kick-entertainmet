import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/user_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/live/livestream_events.dart';
import 'package:shortzz/common/service/live/livestream_socket_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/livestream/livestream.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/host/livestream_host_screen.dart';

class CreateLiveStreamScreenController extends BaseController {
  RxBool isRestricted = false.obs;
  bool isFrontCamera = true;

  Rx<User?> get myUser => SessionManager.instance.getUser().obs;

  Setting? get _setting => SessionManager.instance.getSettings();
  Rx<Widget?> localView = Rx(null);
  LocalVideoTrack? _previewTrack;
  TextEditingController titleController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  @override
  void onClose() {
    super.onClose();
    stopPreview();
  }

  Future<bool> requestPermission() async {
    Loggers.info("requestPermission...");
    try {
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        Loggers.error('Error: Microphone permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request microphone permission exception, $error");
      return false;
    }

    try {
      PermissionStatus cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        Loggers.error('[Error]: Camera permission not granted!!!');
        return false;
      }
    } on Exception catch (error) {
      Loggers.error("[ERROR], request camera permission exception, $error");
      return false;
    }

    return true;
  }

  void _initCamera() async {
    bool isPermissionGranted = await requestPermission();
    if (isPermissionGranted) {
      await initializeCameraPreview();
    } else {
      Get.bottomSheet(ConfirmationSheet(
          title: LKey.cameraMicrophonePermissionTitle.tr,
          description: LKey.cameraMicrophonePermissionDescription.tr,
          onTap: openAppSettings));
    }
  }

  Future<void> initializeCameraPreview() async {
    try {
      showLoader();
      _previewTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(
          cameraPosition: CameraPosition.front,
        ),
      );
      localView.value = VideoTrackRenderer(
        _previewTrack!,
        fit: VideoViewFit.cover,
        mirrorMode: VideoViewMirrorMode.mirror,
      );
    } catch (e, stackTrace) {
      Loggers.error('Failed to initialize camera preview: $e\n$stackTrace');
    } finally {
      stopLoader();
    }
  }

  void toggleCamera() async {
    isFrontCamera = !isFrontCamera;
    if (_previewTrack != null) {
      try {
        await _previewTrack!.setCameraPosition(
          isFrontCamera ? CameraPosition.front : CameraPosition.back,
        );
      } catch (e) {
        Loggers.error('Toggle camera error: $e');
      }
    }
  }

  void onCloseTap() {
    Get.back();
    stopPreview();
  }

  Future<void> stopPreview() async {
    await _previewTrack?.stop();
    _previewTrack = null;
    localView.value = null;
  }

  Future<void> onStartLive() async {
    if ((myUser.value?.followerCount ?? 0) <
        (_setting?.minFollowersForLive ?? 0)) {
      showSnackBar(LKey.minFollowersNeededToGoLive
          .trParams({'count': '${_setting?.minFollowersForLive}'}));
      return;
    }

    if (titleController.text.trim().isEmpty) {
      return showSnackBar(LKey.enterLiveStreamTitle.tr);
    }

    User? user = myUser.value;
    if (user == null) {
      Loggers.error('User Not found. Cannot start live stream.');
      return;
    }
    int userId = user.id ?? -1;

    if (userId == -1) {
      Loggers.error('Wrong User ID is $userId');
      return;
    }

    if (localView.value == null) {
      showSnackBar('Local View not found');
      return;
    }

    // Create Livestream model
    int time = DateTime.now().millisecondsSinceEpoch;

    Livestream livestream = user.livestream(
        type: LivestreamType.livestream,
        time: time,
        description: titleController.text.trim(),
        restrictToJoin: isRestricted.value ? 1 : 0,
        hostViewId: -1);

    Loggers.info('Starting live stream...');
    Loggers.info('Livestream Model: ${livestream.toJson()}');

    showLoader();

    try {
      // Listen for server confirmation before navigating
      LivestreamSocketService.instance.on(LivestreamEvents.sLiveStarted, (data) {
        LivestreamSocketService.instance.off(LivestreamEvents.sLiveStarted);
        Loggers.success('Livestream started successfully!');

        Widget? hostPreview = localView.value;
        stopLoader();
        Get.to(() => LivestreamHostScreen(hostPreview: hostPreview, livestream: livestream, isHost: true));
      });

      // Emit start event via Socket.IO
      LivestreamSocketService.instance.startLivestream({
        'room_id': '$userId',
        'type': livestream.type?.value ?? 'LIVESTREAM',
        'description': titleController.text.trim(),
        'is_restrict_to_join': isRestricted.value ? 1 : 0,
        'host_view_id': -1,
      });

      // Timeout — if server doesn't respond in 5 seconds, navigate anyway
      Future.delayed(const Duration(seconds: 5), () {
        if (Get.isDialogOpen == true) return; // Already navigated
        LivestreamSocketService.instance.off(LivestreamEvents.sLiveStarted);
        Widget? hostPreview = localView.value;
        stopLoader();
        Get.to(() => LivestreamHostScreen(hostPreview: hostPreview, livestream: livestream, isHost: true));
      });
    } catch (e, stackTrace) {
      stopLoader();
      Loggers.error('Failed to start live stream: $e');
      Loggers.error('StackTrace: $stackTrace');
    }
  }
}
