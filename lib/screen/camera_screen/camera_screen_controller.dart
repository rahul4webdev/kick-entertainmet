import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:retrytech_plugin/retrytech_plugin.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/beat_sync/beat_detection_service.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/color_filter_screen/widget/color_filtered.dart';
import 'package:shortzz/screen/music_sheet/music_sheet.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:shortzz/screen/camera_screen/widget/green_screen_sheet.dart';
import 'package:shortzz/screen/slideshow_screen/slideshow_screen.dart';
import 'package:shortzz/screen/template_screen/template_gallery_screen.dart';
import 'package:shortzz/utilities/app_res.dart';

class CameraScreenController extends BaseController
    with GetSingleTickerProviderStateMixin {
  // Constants
  static const _progressUpdateInterval = 10; // milliseconds
  RxList<int> secondsList = AppRes.secondList.obs;

  // Dependencies
  final CameraScreenType cameraType;
  final PlayerController audioPlayer = PlayerController();
  RxBool isSecondListShow = true.obs;

  // State variables
  RxInt selectedSecond = AppRes.secondList.first.obs;
  RxBool isTorchOn = false.obs;
  RxBool isRecording = false.obs;
  RxBool isStartingRecording = false.obs;
  RxBool isEffectShow = false.obs;
  Rx<SelectedMusic?> selectedMusic = Rx(null);
  RxDouble progress = 0.0.obs;

  // Color filter
  Rx<ColorFilterPreset?> selectedColorFilter = Rx(null);

  // Green screen
  RxBool isGreenScreenEnabled = false.obs;
  Rx<String?> greenScreenBgPath = Rx(null);

  // Speed control
  static const List<double> speedOptions = [0.3, 0.5, 1.0, 2.0, 3.0];
  RxDouble selectedSpeed = 1.0.obs;

  // Beat sync
  RxList<int> beatMarkers = <int>[].obs;

  // Countdown timer
  RxInt countdownSetting = 0.obs; // 0=off, 3, 10
  RxInt countdownValue = 0.obs;
  RxBool isCountingDown = false.obs;
  Timer? _countdownTimer;

  // Ghost/Align overlay
  RxBool ghostEnabled = false.obs;
  Rx<Uint8List?> ghostFrameBytes = Rx(null);
  static const double ghostOpacity = 0.4;

  Setting? get appSetting => SessionManager.instance.getSettings();

  bool get isCameraEffects => appSetting?.isCameraEffects == 1;

  // Private variables
  Timer? _progressTimer;
  Completer<void>? _cameraOperationCompleter;

  final int? replyToCommentId;
  final String? replyToCommentText;

  CameraScreenController(
    this.cameraType,
    this.selectedMusic, {
    this.replyToCommentId,
    this.replyToCommentText,
  });

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _cleanUpResources();
    super.onClose();
  }

  // Initialization methods
  Future<void> _initialize() async {
    _initCamera();
    _initData();
  }

  Future<void> _initData() async {
    if (cameraType == CameraScreenType.story) {
      selectedSecond.value = AppRes.storyVideoDuration;
    }
    await _initializeAudioIfNeeded();
  }

  Future<void> _initializeAudioIfNeeded() async {
    if (selectedMusic.value == null) return;

    try {
      await audioPlayer.preparePlayer(
          path: selectedMusic.value?.downloadedURL ?? '');
      final audioTotalDurationInMs = await audioPlayer.getDuration();
      Loggers.info('Audio Total Duration $audioTotalDurationInMs');
      List<int> newSecondList = [];
      int audioSecond = (audioTotalDurationInMs / 1000).toInt();
      for (var element in secondsList) {
        if (element <= audioSecond) {
          newSecondList.add(element);
        }
      }

      if (newSecondList.isNotEmpty) {
        secondsList.value = newSecondList;
        selectedSecond.value = secondsList.first;
      } else {
        showSnackBar(
            LKey.recordUpToSeconds.trParams({'second': '$audioSecond'}));
        selectedSecond.value = audioSecond;
        isSecondListShow.value = false;
      }
      Loggers.info('Recording Second ${selectedSecond.value}');
      int startAudioMs = selectedMusic.value?.audioStartMS ?? 0;
      if (isStartingRecording.value) {
        await audioPlayer
            .seekTo(startAudioMs + (progress.value * 1000).toInt());
      } else {
        await audioPlayer.seekTo(startAudioMs);
      }
      Loggers.success('Audio Duration: $startAudioMs');

      // Detect beats for beat sync visualization
      _detectBeats(selectedMusic.value?.downloadedURL, audioTotalDurationInMs);
    } catch (e) {
      Loggers.error('Audio initialization error: $e');
    }
  }

  Future<void> _detectBeats(String? audioPath, int durationMs) async {
    if (audioPath == null) return;
    try {
      final beats = await BeatDetectionService.instance.detectBeats(
        audioPath: audioPath,
        durationMs: durationMs,
      );
      beatMarkers.value = beats;
      Loggers.info('Beat sync: detected ${beats.length} beats');
    } catch (e) {
      Loggers.error('Beat detection error: $e');
    }
  }

  Future<void> _initCamera() async {
    Loggers.info('Initialize camera');
    Future.delayed(const Duration(milliseconds: 100), () {
      RetrytechPlugin.shared.initCamera();
    });
  }

  // Countdown timer methods
  void cycleCountdownSetting() {
    switch (countdownSetting.value) {
      case 0:
        countdownSetting.value = 3;
        break;
      case 3:
        countdownSetting.value = 10;
        break;
      case 10:
        countdownSetting.value = 0;
        break;
    }
  }

  void _startCountdownThenRecord() {
    isCountingDown.value = true;
    countdownValue.value = countdownSetting.value;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownValue.value--;
      if (countdownValue.value <= 0) {
        timer.cancel();
        isCountingDown.value = false;
        _actualStartRecording();
      }
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    isCountingDown.value = false;
    countdownValue.value = 0;
  }

  // Cleanup methods
  void _cleanUpResources() {
    _progressTimer?.cancel();
    _countdownTimer?.cancel();
    _cameraOperationCompleter?.complete();
    disposeCamera();

    audioPlayer.release();
    audioPlayer.dispose();
  }

  void disposeCamera() {
    Loggers.info('Dispose camera');
    RetrytechPlugin.shared.disposeCamera;
  }

  // Permission handling
  void showPermissionDeniedSheet() {
    Get.bottomSheet(
      ConfirmationSheet(
        title: LKey.cameraMicrophonePermissionTitle.tr,
        description: LKey.cameraMicrophonePermissionDescription
            .trParams({'app_name': AppRes.appName}),
        onTap: openAppSettings,
        onClose: () => Get.back(),
        positiveText: LKey.openSetting.tr,
        isDismissible: true,
      ),
      enableDrag: false,
      isDismissible: false,
    );
  }

  // Media handling methods
  Future<void> onMediaTap() async {
    try {
      switch (cameraType) {
        case CameraScreenType.post:
          final mediaFile = await MediaPickerHelper.shared
              .pickVideo(source: ImageSource.gallery);
          if (mediaFile != null) await _handleReel(mediaFile);
          break;

        case CameraScreenType.story:
          final mediaFile = await MediaPickerHelper.shared.pickMedia();
          if (mediaFile != null) {
            await (mediaFile.type == MediaType.image
                ? handleImageStory(mediaFile)
                : handleVideoStory(mediaFile));
          }
          break;
      }
    } catch (e) {
      Loggers.error('Media selection error: $e');
    }
  }

  Future<void> onSlideshowTap() async {
    try {
      final images = await MediaPickerHelper.shared.multipleImages(limit: 20);
      if (images.length < 2) {
        if (images.isNotEmpty) {
          showSnackBar('Select at least 2 images for a slideshow');
        }
        return;
      }
      Get.to(() => SlideshowScreen(
            imagePaths: images.map((x) => x.path).toList(),
          ));
    } catch (e) {
      Loggers.error('Slideshow picker error: $e');
    }
  }

  Future<void> handleImageStory(MediaFile file) async {
    String imagePath = file.file.path;
    try {
      final bgColor = await imagePath.getGradientFromImage;

      await _navigateToEditScreen(
          PostStoryContentType.storyImage, imagePath, imagePath, bgColor);
    } catch (e) {
      Loggers.error('Gradient Error $e');
    }
  }

  Future<void> handleVideoStory(MediaFile file) async {
    String thumbnailPath = file.thumbNail.path;
    String videoPath = file.file.path;
    final bgColor = await thumbnailPath.getGradientFromImage;
    await _navigateToEditScreen(
        PostStoryContentType.storyVideo, videoPath, thumbnailPath, bgColor);
  }

  Future<void> _navigateToEditScreen(
    PostStoryContentType type,
    String contentPath,
    String thumbnailPath,
    LinearGradient bgColor,
  ) async {
    final content = PostStoryContent(
      type: type,
      content: contentPath,
      thumbNail: thumbnailPath,
      duration: AppRes.storyImageAndTextDuration,
      bgGradient: bgColor,
      sound: selectedMusic.value,
    );

    navigateCameraEditScreen(content);
  }

  // Camera control methods
  void onToggleFlash() {
    RetrytechPlugin.shared.flashOnOff;
    isTorchOn.toggle();
  }

  Future<void> onToggleCamera() async {
    if (isTorchOn.value) {
      isTorchOn.value = false;
      RetrytechPlugin.shared.flashOnOff;
    }
    RetrytechPlugin.shared.toggleCamera;
  }

  // Video recording methods
  Future<void> onVideoRecordingStart() async {
    if (isRecording.value || isCountingDown.value) return;

    // If countdown is set, start countdown first
    if (countdownSetting.value > 0) {
      _startCountdownThenRecord();
      return;
    }

    _actualStartRecording();
  }

  Future<void> _actualStartRecording() async {
    try {
      RetrytechPlugin.shared.startRecording;
      _startAudioPlayback();
      isRecording.value = true;
      isStartingRecording.value = true;
      _startProgressTimer();
    } catch (e) {
      Loggers.error("Video recording start error: $e");
    }
  }

  Future<void> onVideoRecordingPause() async {
    if (!isRecording.value) return;

    RetrytechPlugin.shared.pauseRecording;
    _pauseAudioPlayback();
    isRecording.value = false;
    _progressTimer?.cancel();
    _captureGhostFrame();
  }

  Future<void> _captureGhostFrame() async {
    if (!ghostEnabled.value) return;
    try {
      final path = await RetrytechPlugin.shared.captureImage();
      if (path != null && path.isNotEmpty) {
        ghostFrameBytes.value = await File(path).readAsBytes();
      }
    } catch (e) {
      Loggers.error('Ghost frame capture error: $e');
    }
  }

  Future<void> onVideoRecordingResume() async {
    if (isRecording.value) return;

    RetrytechPlugin.shared.resumeRecording;
    _resumeAudioPlayback();
    isRecording.value = true;
    _startProgressTimer();
  }

  Future<void> onVideoRecordingStop() async {
    if (!isStartingRecording.value) return;

    try {
      XFile file;

      _stopAudioPlayback();
      _progressTimer?.cancel();
      isRecording.value = false;
      isStartingRecording.value = false;
      progress.value = 0;

      showLoader();
      final String? videoPath = await RetrytechPlugin.shared.stopRecording;
      if (videoPath == null) {
        stopLoader();
        return showSnackBar('Capture File not found');
      }
      file = XFile(videoPath);
      final XFile thumbnailPath =
          await MediaPickerHelper.shared.extractThumbnail(videoPath: file.path);
      MediaFile mediaFile = MediaFile(
          file: file, type: MediaType.video, thumbNail: thumbnailPath);

      stopLoader();

      switch (cameraType) {
        case CameraScreenType.post:
          await _handleReel(mediaFile, isCameraFile: true);
          break;
        case CameraScreenType.story:
          await handleVideoStory(mediaFile);
          break;
      }

      selectedMusic.value = null;
    } catch (e) {
      Loggers.error("Video recording stop error: $e");
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();

    final totalSteps = selectedSecond.value * (1000 ~/ _progressUpdateInterval);
    // Speed affects progress rate: at 0.3x, recording takes longer in real time
    // so the progress bar moves slower. At 3x, it moves faster.
    final increment = (selectedSecond.value / totalSteps) * selectedSpeed.value;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: _progressUpdateInterval),
      (timer) {
        if (progress.value < selectedSecond.value) {
          Loggers.info('Video Recording Second ${progress.value}');
          progress.value = (progress.value + increment)
              .clamp(0.0, selectedSecond.value.toDouble());
        } else {
          timer.cancel();
          onVideoRecordingStop();
        }
      },
    );
  }

  // Audio control methods
  void _startAudioPlayback() {
    if (selectedMusic.value == null) return;
    audioPlayer.seekTo(selectedMusic.value?.audioStartMS ?? 0);
    audioPlayer.startPlayer();
  }

  void _pauseAudioPlayback() => audioPlayer.pausePlayer();

  void _resumeAudioPlayback() => audioPlayer.startPlayer();

  void _stopAudioPlayback() => audioPlayer.stopPlayer();

  // UI interaction methods
  void onPlayPauseToggle({int? type}) {
    if (cameraType == CameraScreenType.post) {
      _toggleReelRecording();
    } else {
      if (type != null) {
        if (type == 1) {
          onVideoRecordingStart();
        } else {
          onVideoRecordingStop();
        }
      } else {
        capturePhoto();
      }
    }
  }

  void _toggleReelRecording() {
    if (!isStartingRecording.value) {
      onVideoRecordingStart();
    } else {
      if (isRecording.value) {
        onVideoRecordingPause();
      } else {
        onVideoRecordingResume();
      }
    }
  }

  Future<void> capturePhoto() async {
    if (isRecording.value) return;

    try {
      XFile file = XFile(await RetrytechPlugin.shared.captureImage() ?? '');
      await handleImageStory(
          MediaFile(file: file, type: MediaType.image, thumbNail: file));
    } catch (e) {
      Loggers.error("Photo capture error: $e");
    }
  }

  Future<void> _handleReel(MediaFile file, {bool isCameraFile = false}) async {
    showLoader();
    try {
      final content = PostStoryContent(
          type: PostStoryContentType.reel,
          content: file.file.path,
          thumbNail: file.thumbNail.path,
          sound: selectedMusic.value);
      stopLoader();
      navigateCameraEditScreen(content);
    } catch (e) {
      Loggers.error('Reel handling error: $e');
      stopLoader();
    }
  }

  Future<void> onMusicTap() async {
    final music = await Get.bottomSheet<SelectedMusic>(
        MusicSheet(videoDurationInSecond: selectedSecond.value),
        isScrollControlled: true,
        enableDrag: false,
        isDismissible: false);

    if (music != null) {
      selectedMusic.value = music;
      await _initializeAudioIfNeeded();
    }
  }

  void onSelectedMusicTap(SelectedMusic? music) async {
    if (music != null && !isStartingRecording.value) {
      final newMusic = await Get.bottomSheet<SelectedMusic>(
        SelectedMusicSheet(
            selectedMusic: music, totalVideoSecond: selectedSecond.value),
        isScrollControlled: true,
      );
      if (newMusic != null) {
        selectedMusic.value = newMusic;
        await _initializeAudioIfNeeded();
      }
    }
  }

  void onDeleteMusic() {
    selectedMusic.value = null;
    audioPlayer.stopPlayer();
  }

  void onEffectToggle() {
    isEffectShow.toggle();
  }

  void onTemplateTap() {
    Get.to(() => const TemplateGalleryScreen());
  }

  void onGreenScreenTap() {
    Get.bottomSheet(
      GreenScreenSheet(
        onBackgroundSelected: (imagePath) {
          if (imagePath != null) {
            greenScreenBgPath.value = imagePath;
            isGreenScreenEnabled.value = true;
          }
        },
        onRemoveBackground: () {
          isGreenScreenEnabled.value = false;
          greenScreenBgPath.value = null;
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> onNavigateTextStory() async {
    final content = PostStoryContent(
      type: PostStoryContentType.storyText,
      content: '',
      thumbNail: '',
      duration: AppRes.storyImageAndTextDuration,
      sound: selectedMusic.value,
    );
    navigateCameraEditScreen(content);
  }

  Future<void> navigateCameraEditScreen(PostStoryContent content) async {
    // Pass through video reply context if present
    if (replyToCommentId != null) {
      content.replyToCommentId = replyToCommentId;
      content.replyToCommentText = replyToCommentText;
    }
    disposeCamera();
    await Get.to(() => CameraEditScreen(content: content));
    _resetAll();
  }

  void onBackFromScreen() {
    if (isStartingRecording.value || selectedMusic.value != null) {
      Get.bottomSheet(
        ConfirmationSheet(
            title: LKey.startAgainTitle.tr,
            description: LKey.startAgainMessage.tr,
            onTap: _resetAll,
            positiveText: LKey.startAgain.tr),
      );
    } else {
      Get.back();
    }
  }

  void _resetAll() {
    isEffectShow.value = false;
    _initCamera();
    progress.value = 0.0;
    selectedMusic.value = null;
    secondsList.value = AppRes.secondList;
    selectedSecond.value = secondsList.first;
    selectedSpeed.value = 1.0;
    beatMarkers.clear();
    isSecondListShow.value = true;
    _progressTimer?.cancel();
    audioPlayer.release();
    isStartingRecording.value = false;
    ghostFrameBytes.value = null;
  }

  void applyColorFilter(ColorFilterPreset? filter) {
    selectedColorFilter.value = filter;
  }
}

enum PostStoryContentType { reel, storyText, storyImage, storyVideo }

class PostStoryContent {
  final PostStoryContentType type;
  String? content;
  String? thumbNail;
  int? duration;
  List<double> filter;
  bool hasAudio;
  SelectedMusic? sound;
  LinearGradient? bgGradient;
  Uint8List? thumbnailBytes;
  int? duetSourcePostId;
  String? duetLayout;
  int? stitchSourcePostId;
  int? stitchStartMs;
  int? stitchEndMs;
  Map<String, dynamic>? stickerData;
  int? replyToCommentId;
  String? replyToCommentText;
  List<Map<String, dynamic>>? captions;
  // Advanced editing features
  List<Map<String, dynamic>>? gifOverlays;
  List<Map<String, dynamic>>? speedSegments;
  List<Map<String, dynamic>>? soundEffects;
  String? audioEffect;
  String? pipVideoPath;
  String? pipPosition;
  String? blendOverlayPath;
  String? blendMode;
  double? blendOpacity;
  bool isStabilized = false;

  PostStoryContent(
      {required this.type,
      this.content,
      this.thumbNail,
      this.duration,
      this.filter = defaultFilter,
      this.sound,
      this.bgGradient,
      this.thumbnailBytes,
      this.hasAudio = true,
      this.duetSourcePostId,
      this.duetLayout,
      this.stitchSourcePostId,
      this.stitchStartMs,
      this.stitchEndMs,
      this.stickerData,
      this.replyToCommentId,
      this.replyToCommentText,
      this.captions,
      this.gifOverlays,
      this.speedSegments,
      this.soundEffects,
      this.audioEffect,
      this.pipVideoPath,
      this.pipPosition,
      this.blendOverlayPath,
      this.blendMode,
      this.blendOpacity,
      this.isStabilized = false});
}
