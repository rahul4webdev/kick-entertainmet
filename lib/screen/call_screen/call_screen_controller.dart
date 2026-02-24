import 'dart:async';

import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/call_service.dart';
import 'package:shortzz/common/service/chat/chat_events.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum CallState { idle, outgoing, incoming, connected, ended }

class CallScreenController extends BaseController {
  final IncomingCallData callData;
  final bool isOutgoing;

  CallScreenController({required this.callData, required this.isOutgoing});

  int get myUserId => SessionManager.instance.getUserID();

  Rx<CallState> callState = CallState.idle.obs;
  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;
  RxBool isCameraOn = true.obs;
  RxBool isFrontCamera = true.obs;
  RxString callDuration = '00:00'.obs;

  Timer? _durationTimer;
  Timer? _ringTimeout;
  int _durationSeconds = 0;

  // LiveKit
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  Rx<VideoTrack?> localVideoTrack = Rx<VideoTrack?>(null);
  Rx<VideoTrack?> remoteVideoTrack = Rx<VideoTrack?>(null);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    WakelockPlus.enable();

    if (callData.isVideoCall) {
      await _requestPermissions([Permission.camera, Permission.microphone]);
    } else {
      await _requestPermissions([Permission.microphone]);
    }

    // Create call signal via Socket.IO
    _createCallSignal();

    if (isOutgoing) {
      callState.value = CallState.outgoing;
      await _connectToRoom();
      _startRingTimeout();
    } else {
      callState.value = CallState.incoming;
    }

    _listenToCallStatus();
  }

  Future<void> _requestPermissions(List<Permission> permissions) async {
    for (final p in permissions) {
      final status = await p.request();
      if (!status.isGranted) {
        Loggers.warning('Permission ${p.toString()} not granted');
      }
    }
  }

  void _createCallSignal() {
    ChatSocketService.instance.emit(ChatEvents.cCallCreate, {
      'room_id': callData.roomId,
      'caller_id': callData.callerId,
      'call_type': callData.callType,
      'participant_ids': [
        if (isOutgoing) callData.callerId != myUserId ? callData.callerId : null,
        // Add all participants that aren't the caller
      ].whereType<int>().toList(),
    });
  }

  void _listenToCallStatus() {
    ChatSocketService.instance.on(ChatEvents.sCallStatusChanged, _onCallStatusChanged);
  }

  void _onCallStatusChanged(dynamic data) {
    if (data is! Map<String, dynamic>) return;
    final roomId = data['room_id']?.toString() ?? '';
    if (roomId != callData.roomId) return;

    final status = data['status'] as String?;
    if (status == 'ended' || status == 'rejected') {
      _onCallEnded();
    } else if (status == 'answered' && callState.value == CallState.outgoing) {
      callState.value = CallState.connected;
      _startDurationTimer();
      _ringTimeout?.cancel();
    }
  }

  Future<void> _connectToRoom() async {
    try {
      final tokenResponse = await CallService.instance.generateLiveKitToken(
        roomName: callData.roomId,
        canPublish: true,
      );

      if (tokenResponse.status != true || tokenResponse.data == null) {
        Loggers.error('Failed to get LiveKit token: ${tokenResponse.message}');
        showSnackBar('Failed to connect call');
        _onCallEnded();
        return;
      }

      final wsUrl = tokenResponse.data!.wsUrl ?? '';
      final token = tokenResponse.data!.token ?? '';

      if (wsUrl.isEmpty || token.isEmpty) {
        Loggers.error('LiveKit not configured');
        showSnackBar('Call service is not configured');
        _onCallEnded();
        return;
      }

      _room = Room();
      _listener = _room!.createListener();
      _setupRoomListeners();

      await _room!.connect(
        wsUrl,
        token,
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultCameraCaptureOptions: const CameraCaptureOptions(
            cameraPosition: CameraPosition.front,
          ),
          defaultAudioCaptureOptions: const AudioCaptureOptions(
            noiseSuppression: true,
            echoCancellation: true,
          ),
        ),
      );

      // Enable tracks
      if (callData.isVideoCall) {
        await _room!.localParticipant?.setCameraEnabled(true);
      }
      await _room!.localParticipant?.setMicrophoneEnabled(true);

      // Set speaker mode
      if (callData.isVideoCall) {
        await Hardware.instance.setSpeakerphoneOn(true);
        isSpeakerOn.value = true;
      } else {
        await Hardware.instance.setSpeakerphoneOn(false);
        isSpeakerOn.value = false;
      }

      // Get local video track
      _updateLocalVideoTrack();
    } catch (e) {
      Loggers.error('Failed to connect to LiveKit room: $e');
      showSnackBar('Failed to connect call');
      _onCallEnded();
    }
  }

  void _setupRoomListeners() {
    _listener?.on<TrackSubscribedEvent>((event) {
      if (event.track is VideoTrack) {
        remoteVideoTrack.value = event.track as VideoTrack;
      }
    });

    _listener?.on<TrackUnsubscribedEvent>((event) {
      if (event.track is VideoTrack) {
        remoteVideoTrack.value = null;
      }
    });

    _listener?.on<ParticipantDisconnectedEvent>((event) {
      if (callState.value == CallState.connected) {
        endCall();
      }
    });

    _listener?.on<LocalTrackPublishedEvent>((event) {
      _updateLocalVideoTrack();
    });

    _listener?.on<RoomDisconnectedEvent>((event) {
      Loggers.info('Disconnected from call room');
    });
  }

  void _updateLocalVideoTrack() {
    final publications = _room?.localParticipant?.videoTrackPublications;
    if (publications != null && publications.isNotEmpty) {
      final pub = publications.first;
      if (pub.track is VideoTrack) {
        localVideoTrack.value = pub.track as VideoTrack;
      }
    }
  }

  void _startRingTimeout() {
    _ringTimeout = Timer(const Duration(seconds: 45), () {
      if (callState.value == CallState.outgoing || callState.value == CallState.incoming) {
        endCall();
      }
    });
  }

  void _startDurationTimer() {
    _durationSeconds = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _durationSeconds++;
      final min = (_durationSeconds ~/ 60).toString().padLeft(2, '0');
      final sec = (_durationSeconds % 60).toString().padLeft(2, '0');
      callDuration.value = '$min:$sec';
    });
  }

  /// Called when receiver answers the call
  Future<void> answerCall() async {
    callState.value = CallState.connected;

    await CallService.instance.answerCall(callId: callData.callId);

    // Notify via Socket.IO
    ChatSocketService.instance.emit(ChatEvents.cCallUpdateStatus, {
      'room_id': callData.roomId,
      'status': 'answered',
    });

    await _connectToRoom();
    _startDurationTimer();
    _ringTimeout?.cancel();
  }

  /// End or cancel the call
  Future<void> endCall() async {
    await CallService.instance.endCall(callId: callData.callId);
    _updateCallStatus('ended');
    _onCallEnded();
  }

  /// Reject an incoming call
  Future<void> rejectCall() async {
    await CallService.instance.rejectCall(callId: callData.callId);
    _updateCallStatus('rejected');
    _onCallEnded();
  }

  void _updateCallStatus(String status) {
    ChatSocketService.instance.emit(ChatEvents.cCallUpdateStatus, {
      'room_id': callData.roomId,
      'status': status,
    });
  }

  void _onCallEnded() {
    callState.value = CallState.ended;
    _cleanup();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (Get.isDialogOpen == true) Get.back();
      Get.back();
    });
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    _room?.localParticipant?.setMicrophoneEnabled(!isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Hardware.instance.setSpeakerphoneOn(isSpeakerOn.value);
  }

  void toggleCamera() {
    if (!callData.isVideoCall) return;
    isCameraOn.value = !isCameraOn.value;
    _room?.localParticipant?.setCameraEnabled(isCameraOn.value);
  }

  void switchCamera() async {
    if (!callData.isVideoCall) return;
    isFrontCamera.value = !isFrontCamera.value;

    final publications = _room?.localParticipant?.videoTrackPublications;
    if (publications != null && publications.isNotEmpty) {
      final track = publications.first.track;
      if (track is LocalVideoTrack) {
        try {
          await track.setCameraPosition(
            isFrontCamera.value ? CameraPosition.front : CameraPosition.back,
          );
        } catch (e) {
          Loggers.error('Switch camera error: $e');
        }
      }
    }
  }

  void _cleanup() {
    _durationTimer?.cancel();
    _ringTimeout?.cancel();

    // Remove socket listener
    ChatSocketService.instance.off(ChatEvents.sCallStatusChanged);

    localVideoTrack.value = null;
    remoteVideoTrack.value = null;

    _listener?.dispose();
    _listener = null;

    _room?.disconnect();
    _room?.dispose();
    _room = null;

    WakelockPlus.disable();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }
}
