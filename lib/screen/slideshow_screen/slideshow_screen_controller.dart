import 'dart:io';

import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/video/video_merge_service.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/transition_picker_sheet.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/color_filter_screen/widget/color_filtered.dart';
import 'package:shortzz/screen/music_sheet/music_sheet.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';

class SlideshowScreenController extends BaseController {
  final List<String> initialImages;

  SlideshowScreenController(this.initialImages);

  RxList<String> images = <String>[].obs;
  RxList<int> durations = <int>[].obs;
  Rx<VideoTransition> transition = VideoTransition.fade.obs;
  RxBool kenBurnsEnabled = false.obs;
  RxBool isProcessing = false.obs;
  Rx<String?> musicPath = Rx(null);
  Rx<SelectedMusic?> selectedMusic = Rx(null);

  @override
  void onInit() {
    super.onInit();
    images.assignAll(initialImages);
    durations.assignAll(List.filled(initialImages.length, 3));
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final img = images.removeAt(oldIndex);
    final dur = durations.removeAt(oldIndex);
    images.insert(newIndex, img);
    durations.insert(newIndex, dur);
  }

  void setDuration(int index, int seconds) {
    durations[index] = seconds.clamp(2, 7);
  }

  void removeImage(int index) {
    if (images.length <= 1) return;
    images.removeAt(index);
    durations.removeAt(index);
  }

  Future<void> selectMusic() async {
    final totalDuration =
        durations.fold<int>(0, (sum, d) => sum + d);
    final SelectedMusic? result = await Get.bottomSheet<SelectedMusic?>(
      MusicSheet(videoDurationInSecond: totalDuration),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );

    if (result != null) {
      selectedMusic.value = result;
      musicPath.value = result.downloadedURL;
    }
  }

  Future<void> createSlideshow() async {
    if (images.isEmpty) return;

    isProcessing.value = true;
    showSnackBar('Creating slideshow...');

    try {
      final localPath = await PlatformPathExtension.localPath;
      final outputPath =
          '${localPath}slideshow_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final result = await VideoMergeService.shared.createSlideshow(
        imagePaths: images.toList(),
        durations: durations.toList(),
        outputPath: outputPath,
        transition: transition.value,
        kenBurns: kenBurnsEnabled.value,
      );

      if (result != null && await File(result).exists()) {
        Loggers.success('[Slideshow] Created: $result');

        final content = PostStoryContent(
          type: PostStoryContentType.reel,
          content: result,
          filter: defaultFilter.toList(),
          sound: selectedMusic.value,
        );

        Get.off(() => CameraEditScreen(content: content));
      } else {
        showSnackBar('Failed to create slideshow');
      }
    } catch (e) {
      Loggers.error('[Slideshow] Error: $e');
      showSnackBar('Failed to create slideshow');
    } finally {
      isProcessing.value = false;
    }
  }
}
