import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retrytech_plugin/retrytech_plugin.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/ai_voice_service.dart';
import 'package:shortzz/utilities/const_res.dart';
import 'package:shortzz/common/service/api/sticker_service.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/generate_color.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/screenshot_manager.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/sight_engin/sight_engine_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/color_filter_screen/widget/color_filtered.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';
import 'package:shortzz/screen/music_sheet/music_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/tts/tts_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/voiceover/voiceover_sheet.dart';
import 'package:shortzz/common/service/video/video_merge_service.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/video_trim_sheet.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:video_player/video_player.dart';

import 'package:shortzz/screen/camera_edit_screen/gif_overlay/gif_overlay_view.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/audio_effect_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/blend_mode_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/sound_effect_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/speed_ramp_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/transition_picker_sheet.dart';
import 'package:shortzz/screen/gif_sheet/gif_sheet.dart';

import 'text_story/story_text_view_controller.dart';

class CameraEditScreenController extends BaseController {
  Rx<PostStoryContent> content;

  CameraEditScreenController(this.content);

  final _dashboardController = Get.find<DashboardScreenController>();
  final _retrytechPlugin = RetrytechPlugin();
  UploadType _lastUploadType = UploadType.none;

  Rx<List<double>> selectedFilter = Rx(defaultFilter.toList());
  Rx<VideoPlayerController?> videoPlayerController =
      Rx<VideoPlayerController?>(null);
  List<LinearGradient> storyGradientColor = GenerateColor.instance.gradientList;

  PlayerController audioPlayer = PlayerController();

  RxInt selectedFilterIndex = 0.obs;
  RxInt currentStoryDurationIndex = 0.obs;
  RxInt selectedBgIndex = 0.obs;
  int selectStorySecond = AppRes.storyDurations.first;

  Timer? _timer;

  RxBool isFilterShow = false.obs;
  RxBool isMergingVideo = false.obs;
  RxBool isEnhancingVideo = false.obs;
  RxBool isStabilizing = false.obs;
  RxBool isProcessingEffect = false.obs;
  RxInt storyVisibility = 0.obs; // 0=public, 1=close_friends, 2=subscribers
  bool hasAudio = true;

  // Advanced editing state
  RxList<GifOverlayData> gifOverlays = <GifOverlayData>[].obs;
  Rx<AudioEffect?> selectedAudioEffect = Rx(null);
  RxList<SoundEffectEntry> soundEffectEntries = <SoundEffectEntry>[].obs;
  RxList<SpeedSegment> speedSegments = <SpeedSegment>[].obs;

  // TODO: Future AR Features Implementation
  // F6:  Face Filters - AR face tracking with masks/effects (requires camera_ar or ARCore/ARKit plugin)
  // F12: Hand Gesture Recognition - detect gestures to trigger effects (requires ML model + tflite)
  // F14: Advanced Chroma Key (Green Screen) - real-time background replacement with edge refinement

  VoidCallback? onNewTexFieldAdd;

  String localPath = '';

  @override
  Future<void> onReady() async {
    super.onReady();
    selectedFilter.value = content.value.filter;
    _initVideoController();
    localPath = await PlatformPathExtension.localPath;
  }

  @override
  void onClose() {
    super.onClose();
    _disposeControllers();
  }

  void changedFilter(List<double> filter) {
    selectedFilter.value = filter;
  }

  Future<void> addStory(
      {required String content,
      String? thumbnail,
      required PostStoryContentType type,
      required int duration,
      int? musicId,
      Map<String, dynamic>? stickerData}) async {
    try {
      StoryModel? response = await PostService.instance.createStory(files: {
        Params.content: [XFile(content)],
        if (type == PostStoryContentType.storyVideo)
          Params.thumbnail: [XFile(thumbnail!)]
      }, param: {
        Params.type: type == PostStoryContentType.storyVideo ? 1 : 0,
        Params.duration: duration,
        'visibility': storyVisibility.value,
        if (musicId != -1) Params.soundID: musicId,
        if (stickerData != null)
          Params.stickerData: StickerService.encodeStickerData(stickerData),
      });
      Loggers.info(response.message);
      if (response.status == true && response.data != null) {
        addStoryResponse(response.data!);
      } else {
        failedResponseSnackBar();
      }
    } catch (e) {
      failedResponseSnackBar();
    }
  }

  void addStoryResponse(Story story) {
    story.user = SessionManager.instance.getUser();
    Get.isRegistered<ProfileScreenController>(tag: ProfileScreenController.tag)
        ? Get.find<ProfileScreenController>(tag: ProfileScreenController.tag)
            .onAddStory(story)
        : null;

    Get.isRegistered<FeedScreenController>()
        ? Get.find<FeedScreenController>().onAddStory(story)
        : null;
    _lastUploadType = UploadType.finish;
    updateUploadingProgress(progress: 100);
  }

  void onDiscard() {
    Get.bottomSheet(ConfirmationSheet(
        title: LKey.discardEditsTitle.tr,
        description: LKey.discardEditsMessage.tr,
        onTap: Get.back));
  }

  void onFilterToggle() {
    isFilterShow.toggle();
  }

  void _initVideoController() async {
    if ([PostStoryContentType.storyImage, PostStoryContentType.storyText]
        .contains(content.value.type)) {
      SelectedMusic? sound = content.value.sound;
      if (sound != null && sound.downloadedURL != null) {
        String audioPath = sound.downloadedURL ?? '';
        await _prepareAudioPlayer(
            audioPath: audioPath, milliSecond: sound.audioStartMS);
        _playAudioOnly();
      }
      return;
    }

    videoPlayerController.value =
        VideoPlayerController.file(File(content.value.content ?? ''));

    await videoPlayerController.value?.initialize();

    hasAudio = await RetrytechPlugin.shared
            .hasAudio(inputPath: content.value.content ?? '') ??
        true;
    videoPlayerController.refresh();
    videoPlayerController.value?.setLooping(true);
    content.update((val) => val?.duration =
        videoPlayerController.value?.value.duration.inSeconds ?? 0);

    SelectedMusic? sound = content.value.sound;

    if (sound?.downloadedURL != null) {
      String audioPath = sound?.downloadedURL ?? '';
      await _prepareAudioPlayer(
          audioPath: audioPath, milliSecond: sound?.audioStartMS);
      videoPlayerController.value?.setVolume(0.0);
    }
    _startPlayback();
    _setVideoController(videoPlayerController.value!);
  }

  void _setVideoController(VideoPlayerController controller) {
    controller
        .removeListener(_handleVideoCompletion); // Remove if already exists
    controller.addListener(_handleVideoCompletion);
  }

  /// Listener to handle video playback completion and restart logic
  void _handleVideoCompletion() {
    final controller = videoPlayerController.value;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    final isVideoComplete = (duration - position).inMilliseconds.abs() <
        500; // Allow small margin (e.g., 500ms)

    if (!isVideoComplete) return;
    Loggers.error('_handleVideoCompletion');
    switch (content.value.type) {
      case PostStoryContentType.reel:
      case PostStoryContentType.storyVideo:
        _restartVideoAndAudio();
        break;
      case PostStoryContentType.storyText:
      case PostStoryContentType.storyImage:
        _playAudioOnly();
        break;
    }
  }

  /// Restarts video and audio from the beginning
  Future<void> _restartVideoAndAudio() async {
    await Future.delayed(const Duration(milliseconds: 150));
    await _pausePlayback(); // Pause first for clean reset
    await _resetPlaybackPositions(); // Seek both to start
    _startPlayback(); // Resume playing
    Loggers.info(
      '▶️ Restarting — Video: ${videoPlayerController.value?.value.duration}, '
      'Audio Start: ${Duration(milliseconds: content.value.sound?.audioStartMS ?? 0)}',
    );
  }

  /// Starts both video and audio playback
  void _startPlayback() {
    videoPlayerController.value?.play();
    audioPlayer.startPlayer(forceRefresh: false);
    Loggers.warning('▶️ Video and Audio Playback Started');
  }

  /// Pauses both video and audio playback
  Future<void> _pausePlayback() async {
    videoPlayerController.value?.pause();
    if (content.value.sound != null) {
      audioPlayer.pausePlayer();
    }
    Loggers.warning('⏸️ Video and Audio Playback Paused');
  }

  /// Resets video and audio position to the beginning
  Future<void> _resetPlaybackPositions() async {
    await videoPlayerController.value?.seekTo(Duration.zero);
    final startMs = content.value.sound?.audioStartMS ?? 0;
    // await audioPlayer.pausePlayer();
    if (content.value.sound != null) {
      audioPlayer.seekTo(startMs);
    }
    Loggers.info('✂️ Reset Play back');
  }

  /// Toggles between playing and pausing
  void onPlayPauseToggle() {
    final isPlaying = videoPlayerController.value?.value.isPlaying ?? false;
    isPlaying ? _pausePlayback() : _startPlayback();
  }

  void _disposeControllers() {
    _timer?.cancel();
    audioPlayer.dispose();
    videoPlayerController.value?.removeListener(_handleVideoCompletion);
    videoPlayerController.value?.dispose();
    videoPlayerController.value = null;
  }

  /// Starts looping audio playback for image/text story types
  void _playAudioOnly() {
    if (content.value.sound?.music == null) return;

    audioPlayer.startPlayer();
    _timer = Timer(
      Duration(seconds: selectStorySecond),
      () async {
        await _pauseAudioOnly();
        _playAudioOnly();
      },
    );
  }

  /// Pauses audio and resets to the defined start position
  Future<void> _pauseAudioOnly() async {
    _timer?.cancel();
    await audioPlayer.pausePlayer();
    await audioPlayer.seekTo(content.value.sound?.audioStartMS ?? 0);
  }

  /// Toggles video player volume between mute and full volume
  void toggleVideoVolume() {
    final controller = videoPlayerController.value;
    if (controller == null) return;

    final isMuted = controller.value.volume == 0.0;
    controller.setVolume(isMuted ? 1.0 : 0.0);
  }

  Future<void> handleContentUpload() async {
    final currentContent = content.value;
    if (currentContent.type == PostStoryContentType.reel) {
      final videoPath = currentContent.content ?? '';
      if (videoPath.isNotEmpty) {
        SightEngineService.shared.checkVideoInSightEngine(
          xFile: XFile(videoPath),
          duration: videoPlayerController.value?.value.duration.inSeconds ?? 0,
          completion: handleReelUpload,
        );
      } else {
        showSnackBar(LKey.videoPathNotFound.tr);
      }
    } else if ([
      PostStoryContentType.storyText,
      PostStoryContentType.storyImage,
      PostStoryContentType.storyVideo,
    ].contains(currentContent.type)) {
      handleStoryUpload();
    }
  }

  /// Entry point for post upload after moderation check
  Future<void> handleReelUpload() async {
    final hasAudio = content.value.sound != null;
    isMergingVideo.value = true;

    if (hasAudio) {
      await _applyFilterAndAudioToReel();
    } else {
      await _applyFilterOnlyToReel();
    }
  }

  /// Applies only filters (no external audio)
  Future<void> _applyFilterOnlyToReel() async {
    Loggers.info('[Reel Upload] Processing video without external audio');

    final post = content.value;
    final inputPath = post.content ?? '';
    final outputPath = '${localPath}filter_video.mp4';
    String finalPath = inputPath;

    if (!listEquals(selectedFilter.value, filters.first.colorFilter)) {
      Loggers.info('Filter Applying..');
      try {
        final result = await _retrytechPlugin.applyFilterAndAudioToVideo(
          inputPath: inputPath,
          outputPath: outputPath,
          filterValues: selectedFilter.value,
          shouldBothMusics: true,
        );

        if (result == true) {
          finalPath = outputPath;
        } else {
          Loggers.error('[Reel Upload] Failed to apply filter');
          return;
        }
      } catch (e) {
        Loggers.error('[Reel Upload] Filter application error: $e');
        return;
      } finally {
        isMergingVideo.value = false;
      }
    } else {
      Loggers.info('Filter not applying..');
      isMergingVideo.value = false;
    }

    _pausePlayback();
    await _goToCreateFeedScreen(finalPath);
    _restartVideoAndAudio();
  }

  /// Applies filter + audio overlay
  Future<void> _applyFilterAndAudioToReel() async {
    Loggers.info('[Reel Upload] Processing video with audio');

    final post = content.value;
    final inputPath = post.content;
    final audioPath = post.sound?.downloadedURL;
    final outputPath = '${localPath}merge_audio_filter_video.mp4';
    String finalPath = inputPath ?? '';
    final List<double> filtersValue =
        listEquals(selectedFilter.value, defaultFilter)
            ? []
            : selectedFilter.value;
    final mixOriginalAudio = videoPlayerController.value?.value.volume != 0.0;
    final audioStartTimeInMS =
        double.tryParse('${post.sound?.audioStartMS ?? 0}') ?? 0.0;

    if (inputPath == null || audioPath == null) {
      Loggers.error('[Reel Upload] Missing input or audio path');
      return;
    }

    try {
      final result = await _retrytechPlugin.applyFilterAndAudioToVideo(
        inputPath: inputPath,
        outputPath: outputPath,
        shouldBothMusics: mixOriginalAudio,
        filterValues: filtersValue,
        audioPath: audioPath,
        audioStartTimeInMS: audioStartTimeInMS,
      );

      if (result == true) {
        finalPath = outputPath;
      } else {
        Loggers.error('[Reel Upload] Filter/audio merge failed');
        return;
      }
    } catch (e) {
      Loggers.error('[Reel Upload] Filter/audio merge error: $e');
      return;
    } finally {
      isMergingVideo.value = false;
    }

    _pausePlayback();
    await _goToCreateFeedScreen(finalPath);
    _restartVideoAndAudio();
  }

  /// Extracts thumbnail and navigates to the CreateFeed screen for reels
  Future<void> _goToCreateFeedScreen(String videoFilePath) async {
    try {
      // Extract thumbnail image and byte data from video
      final Uint8List? thumbnailBytes = await MediaPickerHelper.shared
          .extractThumbnailByte(videoPath: videoFilePath);

      final XFile thumbnailFile = await MediaPickerHelper.shared
          .extractThumbnail(videoPath: videoFilePath);

      // Prepare content model for the next screen
      final PostStoryContent reelContent = PostStoryContent(
          type: PostStoryContentType.reel,
          content: videoFilePath,
          thumbNail: thumbnailFile.path,
          thumbnailBytes: thumbnailBytes,
          filter: selectedFilter.value,
          duration: content.value.duration,
          sound: content.value.sound,
          bgGradient: content.value.bgGradient,
          hasAudio: hasAudio,
          duetSourcePostId: content.value.duetSourcePostId,
          duetLayout: content.value.duetLayout,
          stitchSourcePostId: content.value.stitchSourcePostId,
          stitchStartMs: content.value.stitchStartMs,
          stitchEndMs: content.value.stitchEndMs,
          replyToCommentId: content.value.replyToCommentId,
          replyToCommentText: content.value.replyToCommentText,
          stickerData: content.value.stickerData);

      // Stop any loading indicators
      isMergingVideo.value = false;

      // Navigate to the CreateFeed screen with reel content
      await Get.to(() => CreateFeedScreen(
            createType: CreateFeedType.reel,
            content: reelContent,
          ));
    } catch (e) {
      Loggers.error('Failed to navigate to reel composer: $e');
      isMergingVideo.value = false;
    }
  }

  Future<void> handleStoryUpload() async {
    final story = content.value;
    final filePath = story.content ?? '';
    final isTextOrImage = [
      PostStoryContentType.storyImage,
      PostStoryContentType.storyText
    ].contains(story.type);
    final duration = isTextOrImage ? selectStorySecond : story.duration ?? 0;

    _lastUploadType = UploadType.uploading;
    if (story.type == PostStoryContentType.storyVideo) {
      await _processVideoStory(filePath, duration);
    } else {
      await _processImageOrTextStory(duration);
    }
  }

  /// Handles video story: moderation, filtering, music overlay
  Future<void> _processVideoStory(String inputFile, int storyDuration) async {
    final story = content.value;
    final outputPath = '${localPath}video_story.mp4';

    Loggers.info('[Story Upload] Checking moderation for video...');

    await SightEngineService.shared.checkVideoInSightEngine(
      xFile: XFile(inputFile),
      duration: storyDuration,
      completion: () async {
        Get.back();
        Get.back();
        Get.back();
        Get.back();
        Loggers.info('[Story Upload] Moderation completed.');
        updateUploadingProgress(progress: 20);

        String finalVideoPath = inputFile;
        bool hasUserVoice = videoPlayerController.value?.value.volume != 0.0;
        List<double> filtersValue =
            listEquals(selectedFilter.value, filters.first.colorFilter)
                ? []
                : selectedFilter.value;
        String? audioPath = story.sound?.downloadedURL;
        double audioStartMS =
            double.tryParse('${story.sound?.audioStartMS ?? 0}') ?? 0.0;
        // Apply filters/music if needed
        if (audioPath != null) {
          try {
            bool? result = await _retrytechPlugin.applyFilterAndAudioToVideo(
                inputPath: inputFile,
                outputPath: outputPath,
                shouldBothMusics: hasUserVoice,
                filterValues: filtersValue,
                audioPath: audioPath,
                audioStartTimeInMS: audioStartMS);

            if (result == true) finalVideoPath = outputPath;
          } catch (e) {
            Loggers.error('[Story Upload] Failed to apply filter/audio: $e');
            failedResponseSnackBar();
            return;
          }
        }

        updateUploadingProgress(progress: 90);

        try {
          await addStory(
              content: finalVideoPath,
              duration: storyDuration,
              type: PostStoryContentType.storyVideo,
              musicId: story.sound?.music?.id ?? -1,
              thumbnail: inputFile,
              stickerData: story.stickerData);
        } catch (e) {
          Loggers.error('❌ Error posting image/text story: $e');
        } finally {
          isMergingVideo.value = false;
        }
      },
    );
  }

  /// Handles image/text story: moderation, screenshot, optional music or filter
  Future<void> _processImageOrTextStory(int storyDuration) async {
    final story = content.value;
    final controller = Get.find<StoryTextViewController>();
    showLoader();
    final screenshot =
        await ScreenshotManager.captureScreenshot(controller.previewContainer);
    await Future.delayed(const Duration(seconds: 2));
    if (screenshot == null) {
      stopLoader();
      return Loggers.error('❌ Failed to capture screenshot');
    }

    final imagePath = screenshot.path;
    MediaPickerHelper.shared
        .compressImage(screenshot.path, '${localPath}compress_images.jpg')
        .then((value) async {
      stopLoader();
      if (value == null) {
        return Loggers.error('❌ Failed to compress image');
      }
      await SightEngineService.shared.checkImagesInSightEngine(
        xFiles: [value],
        completion: () async {
          Get.back();
          Get.back();
          Get.back();
          Get.back();
          Loggers.info('[Story Upload] Moderation completed.');
          updateUploadingProgress(progress: 20);

          final audioPath = story.sound?.downloadedURL;
          final audioStartMS =
              double.tryParse('${story.sound?.audioStartMS ?? 0.0}') ?? 0.0;
          final musicId = story.sound?.music?.id ?? -1;
          final videoPath = '${localPath}image_to_video.mp4';

          if (audioPath != null) {
            Loggers.info('🎵 Music found, generating video from image...');

            bool? success = await _retrytechPlugin.createVideoFromImage(
                inputPath: imagePath,
                outputPath: videoPath,
                audioStartTimeInMS: audioStartMS,
                audioPath: audioPath,
                videoTotalDurationInSec: storyDuration.toDouble());

            final contentPath = success == true ? videoPath : imagePath;

            updateUploadingProgress(progress: 90);

            await addStory(
                duration: storyDuration,
                content: contentPath,
                type: PostStoryContentType.storyVideo,
                musicId: musicId,
                thumbnail: imagePath,
                stickerData: story.stickerData);
          } else {
            updateUploadingProgress(progress: 90);
            await addStory(
                duration: storyDuration,
                content: imagePath,
                type: PostStoryContentType.storyImage,
                musicId: -1,
                stickerData: story.stickerData);
          }
        },
      );
    });
  }

  void updateUploadingProgress({required double progress}) {
    _dashboardController.onProgress.call(
      PostUploadingProgress(
        uploadType: _lastUploadType,
        progress: progress,
        type: CameraScreenType.story,
      ),
    );

    if (progress == 100) {
      _resetUploadingProgressAfterDelay();
    }
  }

  void _resetUploadingProgressAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      _dashboardController.onProgress.call(
        PostUploadingProgress(
          uploadType: UploadType.none,
          progress: 0,
          type: CameraScreenType.post, // or use last type if needed
        ),
      );
    });
  }

  Future<void> failedResponseSnackBar() async {
    _lastUploadType = UploadType.error;
    updateUploadingProgress(progress: 100);
    return;
  }

  void onMusicDelete() {
    content.update((val) => val?.sound = null);
    audioPlayer.stopPlayer();
    audioPlayer.release();
    videoPlayerController.value?.setVolume(1);
  }

  /// Opens the music selection sheet and applies the selected music to the story
  Future<void> handleMusicSelection({SelectedMusic? initialMusic}) async {
    final isTextOrImage = [
      PostStoryContentType.storyImage,
      PostStoryContentType.storyText,
    ].contains(content.value.type);

    // Pause appropriate media before opening selection
    isTextOrImage ? _pauseAudioOnly() : _pausePlayback();

    final duration =
        isTextOrImage ? selectStorySecond : content.value.duration ?? 0;

    videoPlayerController.value?.pause();

    final SelectedMusic? selectedMusic = await Get.bottomSheet<SelectedMusic?>(
      initialMusic != null
          ? SelectedMusicSheet(
              selectedMusic: initialMusic, totalVideoSecond: duration)
          : MusicSheet(videoDurationInSecond: duration),
      isScrollControlled: true,
        isDismissible: false,
        enableDrag: false);

    // Handle result
    await _processSelectedMusic(selectedMusic, isTextOrImage);
  }

  /// Shared logic to apply selected music and resume playback
  Future<void> _processSelectedMusic(
      SelectedMusic? selectedMusic, bool isTextOrImage) async {
    if (selectedMusic == null) {
      isTextOrImage ? _playAudioOnly() : _startPlayback();
      return;
    }

    content.update((val) => val?.sound = selectedMusic);

    final audioUrl = selectedMusic.downloadedURL;
    final startMs = selectedMusic.audioStartMS ?? 0;

    if (audioUrl != null) {
      await _prepareAudioPlayer(audioPath: audioUrl, milliSecond: startMs);

      switch (content.value.type) {
        case PostStoryContentType.storyImage:
        case PostStoryContentType.storyText:
          _playAudioOnly();
          break;
        case PostStoryContentType.reel:
        case PostStoryContentType.storyVideo:
          videoPlayerController.value?.setVolume(0.0);
          _restartVideoAndAudio();
          break;
      }
    }
  }

  Future<void> _prepareAudioPlayer(
      {required String audioPath, int? milliSecond}) async {
    await audioPlayer.preparePlayer(path: audioPath);
    await audioPlayer.seekTo(milliSecond ?? 0);
    audioPlayer.setFinishMode(finishMode: FinishMode.pause);
  }

  /// Opens the TTS sheet, generates audio, and applies it as the sound track
  Future<void> handleTtsSelection() async {
    final isTextOrImage = [
      PostStoryContentType.storyImage,
      PostStoryContentType.storyText,
    ].contains(content.value.type);

    // Collect text from text overlays if available
    String initialText = '';
    if (isTextOrImage && Get.isRegistered<StoryTextViewController>()) {
      final textController = Get.find<StoryTextViewController>();
      initialText = textController.textWidgets
          .map((w) => w.text)
          .where((t) => t.isNotEmpty)
          .join('. ');
    }

    // Pause playback before opening sheet
    isTextOrImage ? _pauseAudioOnly() : _pausePlayback();

    final String? ttsFilePath = await Get.bottomSheet<String?>(
      TtsSheet(initialText: initialText),
      isScrollControlled: true,
    );

    if (ttsFilePath == null) {
      isTextOrImage ? _playAudioOnly() : _startPlayback();
      return;
    }

    // Wrap the TTS audio file as a SelectedMusic (reuse existing pipeline)
    final ttsMusic = SelectedMusic(null, 0, ttsFilePath, null);
    await _processSelectedMusic(ttsMusic, isTextOrImage);
  }

  Future<void> handleVoiceoverSelection() async {
    final isTextOrImage = [
      PostStoryContentType.storyImage,
      PostStoryContentType.storyText,
    ].contains(content.value.type);

    // Pause playback before opening sheet
    isTextOrImage ? _pauseAudioOnly() : _pausePlayback();

    final String? voiceoverFilePath = await Get.bottomSheet<String?>(
      const VoiceoverSheet(),
      isScrollControlled: true,
    );

    if (voiceoverFilePath == null) {
      isTextOrImage ? _playAudioOnly() : _startPlayback();
      return;
    }

    // Wrap the voiceover audio file as a SelectedMusic (reuse existing pipeline)
    final voiceoverMusic = SelectedMusic(null, 0, voiceoverFilePath, null);
    await _processSelectedMusic(voiceoverMusic, isTextOrImage);
  }

  Future<void> handleAutoEnhance() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) {
      showSnackBar('No video to enhance');
      return;
    }

    isEnhancingVideo.value = true;
    _pausePlayback();

    try {
      final result = await AiVoiceService.instance.enhanceVideo(
        videoFilePath: videoPath,
      );

      if (result.status == true && result.data?.enhancedUrl != null) {
        final enhancedRelUrl = result.data!.enhancedUrl!;
        final fullUrl = enhancedRelUrl.startsWith('http')
            ? enhancedRelUrl
            : '${baseURL}storage/$enhancedRelUrl';
        // Download the enhanced video to local storage
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(fullUrl));
        final httpResponse = await request.close();
        final enhancedPath = '${localPath}enhanced_video.mp4';
        final file = File(enhancedPath);
        final sink = file.openWrite();
        await httpResponse.pipe(sink);
        client.close();

        // Replace current video with enhanced one
        content.update((val) => val?.content = enhancedPath);

        // Reinitialize video player with new file
        videoPlayerController.value?.removeListener(_handleVideoCompletion);
        videoPlayerController.value?.dispose();
        videoPlayerController.value = null;
        _initVideoController();

        showSnackBar('Video enhanced successfully');
      } else {
        showSnackBar(result.message ?? 'Enhancement failed');
      }
    } catch (e) {
      Loggers.error('Auto-enhance error: $e');
      showSnackBar('Enhancement unavailable');
    } finally {
      isEnhancingVideo.value = false;
    }
  }

  Future<void> handleTrim() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) return;

    final durationMs =
        (videoPlayerController.value?.value.duration.inMilliseconds ?? 0);
    if (durationMs <= 0) return;

    _pausePlayback();

    final trimmedPath = await VideoTrimSheet.show(
      videoPath: videoPath,
      durationMs: durationMs,
    );

    if (trimmedPath != null && trimmedPath.isNotEmpty) {
      // Replace current video with trimmed one
      content.update((val) => val?.content = trimmedPath);

      // Reinitialize video player with new file
      videoPlayerController.value?.removeListener(_handleVideoCompletion);
      videoPlayerController.value?.dispose();
      videoPlayerController.value = null;
      _initVideoController();
    } else {
      _startPlayback();
    }
  }

  Future<void> handleAddClip() async {
    final currentPath = content.value.content;
    if (currentPath == null || currentPath.isEmpty) return;

    _pausePlayback();

    // Step 1: Select merge mode
    final MergeMode? mode = await Get.bottomSheet<MergeMode>(
      _MergeModeSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );

    if (mode == null) {
      _startPlayback();
      return;
    }

    // Step 2: Select audio option (only for split-screen modes)
    // For sequential mode: offer transition selection
    MergeAudio audio = MergeAudio.mixBoth;
    VideoTransition? transition;

    if (mode == MergeMode.sequential) {
      // Offer transition selection for sequential merge
      transition = await Get.bottomSheet<VideoTransition>(
        const TransitionPickerSheet(),
        isScrollControlled: true,
      );
      // null means user cancelled; they can skip transition
    } else {
      final MergeAudio? selectedAudio = await Get.bottomSheet<MergeAudio>(
        _MergeAudioSheet(),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
      );

      if (selectedAudio == null) {
        _startPlayback();
        return;
      }
      audio = selectedAudio;
    }

    // Step 3: Pick video from gallery
    final MediaFile? picked =
        await MediaPickerHelper.shared.pickVideo(source: ImageSource.gallery);

    if (picked == null) {
      _startPlayback();
      return;
    }

    isMergingVideo.value = true;
    showSnackBar(LKey.mergingClips.tr);

    try {
      final outputPath =
          '${localPath}merged_${DateTime.now().millisecondsSinceEpoch}.mp4';

      String? mergedPath;

      // Use transition merge if a transition was selected
      if (mode == MergeMode.sequential &&
          transition != null &&
          transition != VideoTransition.none) {
        mergedPath = await VideoMergeService.shared.mergeTwoWithTransition(
          videoA: currentPath,
          videoB: picked.file.path,
          outputPath: outputPath,
          transition: transition,
        );
      } else {
        mergedPath = await VideoMergeService.shared.mergeTwoWithLayout(
          videoA: currentPath,
          videoB: picked.file.path,
          outputPath: outputPath,
          mode: mode,
          audio: audio,
        );
      }

      if (mergedPath != null) {
        content.update((val) => val?.content = mergedPath);
        _reinitVideoPlayer();
      } else {
        showSnackBar(LKey.mergeFailed.tr);
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[AddClip] Error: $e');
      showSnackBar(LKey.mergeFailed.tr);
      _startPlayback();
    } finally {
      isMergingVideo.value = false;
    }
  }

  // ─── F4: GIF/Sticker Browser ───

  Future<void> handleGifSelection() async {
    final result = await Get.bottomSheet<String>(
      const GifSheet(),
      isScrollControlled: true,
    );

    if (result != null && result.isNotEmpty) {
      gifOverlays.add(GifOverlayData(url: result));
      content.update((val) {
        val?.gifOverlays = gifOverlays.map((g) => g.toJson()).toList();
      });
    }
  }

  void updateGifOverlay(int index, GifOverlayData data) {
    gifOverlays[index] = data;
    content.update((val) {
      val?.gifOverlays = gifOverlays.map((g) => g.toJson()).toList();
    });
  }

  void deleteGifOverlay(int index) {
    gifOverlays.removeAt(index);
    content.update((val) {
      val?.gifOverlays = gifOverlays.map((g) => g.toJson()).toList();
    });
  }

  // ─── F2: Transitions Between Clips ───

  Future<void> handleAddClipWithTransition() async {
    final currentPath = content.value.content;
    if (currentPath == null || currentPath.isEmpty) return;

    _pausePlayback();

    // Pick transition
    final VideoTransition? transition = await Get.bottomSheet<VideoTransition>(
      const TransitionPickerSheet(),
      isScrollControlled: true,
    );

    if (transition == null) {
      _startPlayback();
      return;
    }

    // Pick video from gallery
    final MediaFile? picked =
        await MediaPickerHelper.shared.pickVideo(source: ImageSource.gallery);

    if (picked == null) {
      _startPlayback();
      return;
    }

    isMergingVideo.value = true;
    showSnackBar('Merging with transition...');

    try {
      final outputPath =
          '${localPath}trans_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final mergedPath = await VideoMergeService.shared.mergeTwoWithTransition(
        videoA: currentPath,
        videoB: picked.file.path,
        outputPath: outputPath,
        transition: transition,
      );

      if (mergedPath != null) {
        content.update((val) => val?.content = mergedPath);
        _reinitVideoPlayer();
      } else {
        showSnackBar(LKey.mergeFailed.tr);
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[TransitionMerge] Error: $e');
      showSnackBar(LKey.mergeFailed.tr);
      _startPlayback();
    } finally {
      isMergingVideo.value = false;
    }
  }

  // ─── F5: Speed Ramp ───

  Future<void> handleSpeedRamp() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) return;

    _pausePlayback();

    final result = await Get.bottomSheet<List<SpeedSegment>>(
      SpeedRampSheet(
        current: speedSegments.isNotEmpty ? speedSegments.toList() : null,
      ),
      isScrollControlled: true,
    );

    if (result == null) {
      _startPlayback();
      return;
    }

    isProcessingEffect.value = true;

    try {
      final duration = await VideoMergeService.shared.getVideoDuration(videoPath);
      final outputPath =
          '${localPath}speed_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final processed = await VideoMergeService.shared.applySpeedRamp(
        inputPath: videoPath,
        outputPath: outputPath,
        segments: result.map((s) => s.toJson()).toList(),
        totalDuration: duration,
      );

      if (processed != null) {
        speedSegments.assignAll(result);
        content.update((val) {
          val?.content = processed;
          val?.speedSegments = result.map((s) => s.toJson()).toList();
        });
        _reinitVideoPlayer();
      } else {
        showSnackBar('Speed ramp failed');
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[SpeedRamp] Error: $e');
      showSnackBar('Speed ramp failed');
      _startPlayback();
    } finally {
      isProcessingEffect.value = false;
    }
  }

  // ─── F7: Sound Effects ───

  Future<void> handleSoundEffect() async {
    final positionMs =
        videoPlayerController.value?.value.position.inMilliseconds ?? 0;

    final result = await Get.bottomSheet<SoundEffectEntry>(
      SoundEffectSheet(currentPositionMs: positionMs),
      isScrollControlled: true,
    );

    if (result != null) {
      soundEffectEntries.add(result);
      content.update((val) {
        val?.soundEffects =
            soundEffectEntries.map((e) => e.toJson()).toList();
      });
      showSnackBar('Added "${result.item.name}" at ${_formatMs(result.timestampMs)}');
    }
  }

  String _formatMs(int ms) {
    final sec = ms ~/ 1000;
    return '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }

  // ─── F8: Audio Effects ───

  Future<void> handleAudioEffect() async {
    final result = await Get.bottomSheet<AudioEffect>(
      AudioEffectSheet(current: selectedAudioEffect.value),
      isScrollControlled: true,
    );

    if (result != null) {
      selectedAudioEffect.value = result;
      content.update((val) =>
          val?.audioEffect = result == AudioEffect.none ? null : result.name);
    }
  }

  // ─── F10: Video Stabilization ───

  Future<void> handleStabilize() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) return;

    isStabilizing.value = true;
    _pausePlayback();

    try {
      final outputPath =
          '${localPath}stab_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final result = await VideoMergeService.shared.stabilizeVideo(
        inputPath: videoPath,
        outputPath: outputPath,
      );

      if (result != null) {
        content.update((val) {
          val?.content = result;
          val?.isStabilized = true;
        });
        _reinitVideoPlayer();
        showSnackBar('Video stabilized');
      } else {
        showSnackBar('Stabilization failed');
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[Stabilize] Error: $e');
      showSnackBar('Stabilization failed');
      _startPlayback();
    } finally {
      isStabilizing.value = false;
    }
  }

  // ─── F13: Blend Mode ───

  Future<void> handleBlendMode() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) return;

    _pausePlayback();

    // Pick overlay media
    final MediaFile? overlay = await MediaPickerHelper.shared
        .pickVideo(source: ImageSource.gallery);

    if (overlay == null) {
      _startPlayback();
      return;
    }

    // Select blend mode
    final result = await Get.bottomSheet<BlendModeResult>(
      BlendModeSheet(
        currentMode: content.value.blendMode != null
            ? VideoBlendMode.values.firstWhereOrNull(
                (m) => m.ffmpegMode == content.value.blendMode)
            : null,
        currentOpacity: content.value.blendOpacity ?? 0.5,
      ),
      isScrollControlled: true,
    );

    if (result == null) {
      _startPlayback();
      return;
    }

    isProcessingEffect.value = true;

    try {
      final outputPath =
          '${localPath}blend_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final processed = await VideoMergeService.shared.applyBlendOverlay(
        mainPath: videoPath,
        overlayPath: overlay.file.path,
        outputPath: outputPath,
        blendMode: result.mode.ffmpegMode,
        opacity: result.opacity,
      );

      if (processed != null) {
        content.update((val) {
          val?.content = processed;
          val?.blendOverlayPath = overlay.file.path;
          val?.blendMode = result.mode.ffmpegMode;
          val?.blendOpacity = result.opacity;
        });
        _reinitVideoPlayer();
      } else {
        showSnackBar('Blend effect failed');
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[Blend] Error: $e');
      showSnackBar('Blend effect failed');
      _startPlayback();
    } finally {
      isProcessingEffect.value = false;
    }
  }

  // ─── F9: Picture-in-Picture ───

  Future<void> handlePiP() async {
    final videoPath = content.value.content;
    if (videoPath == null || videoPath.isEmpty) return;

    _pausePlayback();

    // Pick PiP video
    final MediaFile? pipVideo = await MediaPickerHelper.shared
        .pickVideo(source: ImageSource.gallery);

    if (pipVideo == null) {
      _startPlayback();
      return;
    }

    isProcessingEffect.value = true;

    try {
      final outputPath =
          '${localPath}pip_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final processed = await VideoMergeService.shared.applyPiPOverlay(
        mainPath: videoPath,
        pipPath: pipVideo.file.path,
        outputPath: outputPath,
        position: content.value.pipPosition ?? 'bottomRight',
      );

      if (processed != null) {
        content.update((val) {
          val?.content = processed;
          val?.pipVideoPath = pipVideo.file.path;
          val?.pipPosition ??= 'bottomRight';
        });
        _reinitVideoPlayer();
      } else {
        showSnackBar('PiP overlay failed');
        _startPlayback();
      }
    } catch (e) {
      Loggers.error('[PiP] Error: $e');
      showSnackBar('PiP overlay failed');
      _startPlayback();
    } finally {
      isProcessingEffect.value = false;
    }
  }

  // ─── Helper: reinitialize video player ───

  void _reinitVideoPlayer() {
    videoPlayerController.value?.removeListener(_handleVideoCompletion);
    videoPlayerController.value?.dispose();
    videoPlayerController.value = null;
    _initVideoController();
  }

  changeBg(bool isTextStory) async {
    if (isTextStory) {
      selectedBgIndex.value =
          (selectedBgIndex.value + 1) % storyGradientColor.length;
    } else {
      final gradient = await content.value.content?.getGradientFromImage;
      content.update((val) => val?.bgGradient = gradient);
    }
  }

  changeStoryTime() async {
    currentStoryDurationIndex.value =
        (currentStoryDurationIndex.value + 1) % AppRes.storyDurations.length;
    selectStorySecond = AppRes.storyDurations[currentStoryDurationIndex.value];
    if (content.value.sound != null) {
      await _pauseAudioOnly();
      _playAudioOnly();
    }
  }
}

class _MergeModeSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Merge Layout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _MergeOptionTile(
              icon: Icons.view_stream_rounded,
              title: 'Sequential',
              subtitle: 'One after another',
              onTap: () => Get.back(result: MergeMode.sequential),
            ),
            _MergeOptionTile(
              icon: Icons.view_sidebar_rounded,
              title: 'Side by Side',
              subtitle: 'Split screen horizontally',
              onTap: () => Get.back(result: MergeMode.sideBySide),
            ),
            _MergeOptionTile(
              icon: Icons.view_agenda_rounded,
              title: 'Top & Bottom',
              subtitle: 'Split screen vertically',
              onTap: () => Get.back(result: MergeMode.topBottom),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MergeAudioSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _MergeOptionTile(
              icon: Icons.volume_up_rounded,
              title: 'Mix Both',
              subtitle: 'Combine audio from both videos',
              onTap: () => Get.back(result: MergeAudio.mixBoth),
            ),
            _MergeOptionTile(
              icon: Icons.looks_one_rounded,
              title: 'Current Video Only',
              subtitle: 'Keep audio from your video',
              onTap: () => Get.back(result: MergeAudio.videoAOnly),
            ),
            _MergeOptionTile(
              icon: Icons.looks_two_rounded,
              title: 'New Video Only',
              subtitle: 'Keep audio from the added video',
              onTap: () => Get.back(result: MergeAudio.videoBOnly),
            ),
            _MergeOptionTile(
              icon: Icons.volume_off_rounded,
              title: 'Mute All',
              subtitle: 'No audio (add music later)',
              onTap: () => Get.back(result: MergeAudio.muteAll),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MergeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MergeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }
}
