import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_border_round_icon.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen_controller.dart';
import 'package:shortzz/screen/camera_edit_screen/gif_overlay/gif_overlay_view.dart';
import 'package:shortzz/screen/ai_sticker_screen/ai_sticker_screen.dart';
import 'package:shortzz/screen/camera_edit_screen/sticker/story_sticker_sheet.dart';
import 'package:shortzz/screen/music_sheet/music_sheet.dart';
import 'package:shortzz/screen/camera_edit_screen/text_story/story_text_view.dart';
import 'package:shortzz/screen/camera_edit_screen/text_story/story_text_view_controller.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/camera_screen/widget/camera_top_view.dart';
import 'package:shortzz/screen/color_filter_screen/color_filter_view.dart';
import 'package:shortzz/screen/color_filter_screen/widget/color_filtered.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:video_player/video_player.dart';

class CameraEditScreen extends StatelessWidget {
  final PostStoryContent content;

  const CameraEditScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CameraEditScreenController(content.obs));
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 20),
                child: Stack(
                  children: [
                    GenerateContentView(controller: controller),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CameraEditTopViewTools(controller: controller),
                        FilterAndMusicView(controller: controller)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _CloseFriendsToggle(controller: controller),
            CameraEditActionButtons(controller: controller),
          ],
        ),
      ),
    );
  }
}

class GenerateContentView extends StatelessWidget {
  final CameraEditScreenController controller;

  const GenerateContentView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return switch (controller.content.value.type) {
      PostStoryContentType.storyText ||
      PostStoryContentType.storyImage =>
        CameraEditImageView(cameraEditController: controller),
      PostStoryContentType.reel ||
      PostStoryContentType.storyVideo =>
        _VideoWithTextOverlay(controller: controller),
    };
  }
}

class _VideoWithTextOverlay extends StatelessWidget {
  final CameraEditScreenController controller;

  const _VideoWithTextOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    final textController =
        Get.put(StoryTextViewController(controller));
    return Stack(
      children: [
        CameraEditVideoView(content: controller.content),
        // Text overlays
        Obx(() => Stack(
              children: textController.textWidgets
                  .asMap()
                  .map(
                    (i, element) => MapEntry(
                      i,
                      DraggableTextWidget(
                        data: element,
                        onUpdate: (updatedData) =>
                            textController.updateTextWidget(i, updatedData),
                        onDelete: () => textController.deleteTextWidget(i),
                      ),
                    ),
                  )
                  .values
                  .toList(),
            )),
        // GIF overlays
        Obx(() => Stack(
              children: controller.gifOverlays
                  .asMap()
                  .map(
                    (i, data) => MapEntry(
                      i,
                      DraggableGifWidget(
                        data: data,
                        onUpdate: (updated) =>
                            controller.updateGifOverlay(i, updated),
                        onDelete: () => controller.deleteGifOverlay(i),
                      ),
                    ),
                  )
                  .values
                  .toList(),
            )),
      ],
    );
  }
}

class CameraEditTopViewTools extends StatelessWidget {
  final CameraEditScreenController controller;

  const CameraEditTopViewTools({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    PostStoryContent content = controller.content.value;
    PostStoryContentType type = content.type;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 10,
        runSpacing: 10,
        children: [
          // Obx(
          //   () {
          //     if (controller.videoPlayerController.value != null) {
          //       return ValueListenableBuilder(
          //         valueListenable: controller.videoPlayerController.value!,
          //         builder: (context, value, child) => CustomBorderRoundIcon(
          //           image: value.volume == 1.0
          //               ? AssetRes.icVolumeOn
          //               : AssetRes.icVolumeOff,
          //           onTap: controller.toggleVideoVolume,
          //         ),
          //       );
          //     } else {
          //       return const SizedBox();
          //     }
          //   },
          // ),
          if ([PostStoryContentType.storyImage, PostStoryContentType.storyText]
              .contains(type))
            Obx(
              () => CustomBorderRoundIcon(
                onTap: controller.changeStoryTime,
                widget: Center(
                  child: Text(
                      '${AppRes.storyDurations[controller.currentStoryDurationIndex.value]}s',
                      style: TextStyleCustom.unboundedMedium500(
                          color: whitePure(context)),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          if ([PostStoryContentType.storyImage, PostStoryContentType.storyText,
                PostStoryContentType.reel]
              .contains(type))
            CustomBorderRoundIcon(
              onTap: () => controller.onNewTexFieldAdd?.call(),
              image: AssetRes.icText1,
            ),
          if (![PostStoryContentType.storyText].contains(content.type))
            CustomBorderRoundIcon(
                image: AssetRes.icFilter, onTap: controller.onFilterToggle),
          if ([PostStoryContentType.storyText, PostStoryContentType.storyImage]
              .contains(type))
            Obx(() {
              bool isTextStory = PostStoryContentType.storyText == type;
              int selectedGradientIndex = controller.selectedBgIndex.value;

              var gradient = isTextStory
                  ? controller.storyGradientColor[selectedGradientIndex]
                  : controller.content.value.bgGradient;
              return CustomBorderRoundIcon(
                onTap: () => controller.changeBg(isTextStory),
                widget: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isTextStory
                          ? gradient
                          : controller.content.value.bgGradient,
                      border: Border.all(color: whitePure(context), width: 2)),
                ),
              );
            }),
          Obx(() {
              final hasStickerData = controller.content.value.stickerData != null;
              return CustomBorderRoundIcon(
                image: AssetRes.icSticker,
                onTap: () async {
                  final result = await Get.bottomSheet<Map<String, dynamic>>(
                    const StoryStickerSheet(),
                    isScrollControlled: true,
                  );
                  if (result != null) {
                    if (result['type'] == 'ai_sticker') {
                      Get.to(() => const AiStickerScreen());
                    } else if (result['type'] == 'music_picker') {
                      final duration = controller.content.value.duration ?? 15;
                      final selected = await Get.bottomSheet<SelectedMusic?>(
                        MusicSheet(videoDurationInSecond: duration),
                        isScrollControlled: true,
                        isDismissible: false,
                        enableDrag: false,
                      );
                      if (selected?.music != null) {
                        final m = selected!.music!;
                        controller.content.update((val) => val?.stickerData = {
                          'type': 'music',
                          'music_id': m.id,
                          'title': m.title ?? '',
                          'artist': m.artist ?? '',
                          'image': m.image ?? '',
                        });
                      }
                    } else {
                      controller.content.update((val) => val?.stickerData = result);
                    }
                  }
                },
                widget: hasStickerData
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(AssetRes.icSticker,
                              width: 22, height: 22, color: whitePure(context)),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: themeAccentSolid(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              );
            }),
          if ([PostStoryContentType.reel, PostStoryContentType.storyVideo]
              .contains(type))
            CustomBorderRoundIcon(
              onTap: controller.handleTrim,
              widget: const Center(
                child: Icon(Icons.content_cut,
                    color: Colors.white, size: 20),
              ),
            ),
          if ([PostStoryContentType.reel, PostStoryContentType.storyVideo]
              .contains(type))
            Obx(() => controller.isMergingVideo.value
                ? const SizedBox(
                    width: 38,
                    height: 38,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : CustomBorderRoundIcon(
                    onTap: controller.handleAddClip,
                    widget: const Center(
                      child: Icon(Icons.add_circle_outline,
                          color: Colors.white, size: 20),
                    ),
                  )),
          if ([PostStoryContentType.reel, PostStoryContentType.storyVideo]
              .contains(type))
            Obx(() => controller.isEnhancingVideo.value
                ? const SizedBox(
                    width: 38,
                    height: 38,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : CustomBorderRoundIcon(
                    onTap: controller.handleAutoEnhance,
                    widget: const Center(
                      child: Icon(Icons.auto_fix_high,
                          color: Colors.white, size: 20),
                    ),
                  )),
          CustomBorderRoundIcon(
              image: AssetRes.icMusic, onTap: controller.handleMusicSelection),
          CustomBorderRoundIcon(
            image: AssetRes.icSpeaker,
            onTap: controller.handleTtsSelection,
          ),
          CustomBorderRoundIcon(
            image: AssetRes.icMicrophone,
            onTap: controller.handleVoiceoverSelection,
          ),
          // GIF overlay (all content types)
          CustomBorderRoundIcon(
            onTap: controller.handleGifSelection,
            widget: const Center(
              child: Icon(Icons.gif_box, color: Colors.white, size: 22),
            ),
          ),
          // Video-only editing tools
          if ([PostStoryContentType.reel, PostStoryContentType.storyVideo]
              .contains(type)) ...[
            // Speed Ramp
            CustomBorderRoundIcon(
              onTap: controller.handleSpeedRamp,
              widget: const Center(
                child: Icon(Icons.speed, color: Colors.white, size: 20),
              ),
            ),
            // Sound Effects
            CustomBorderRoundIcon(
              onTap: controller.handleSoundEffect,
              widget: const Center(
                child: Icon(Icons.graphic_eq, color: Colors.white, size: 20),
              ),
            ),
            // Audio Effects
            CustomBorderRoundIcon(
              onTap: controller.handleAudioEffect,
              widget: const Center(
                child:
                    Icon(Icons.spatial_audio, color: Colors.white, size: 20),
              ),
            ),
            // Stabilize
            Obx(() => controller.isStabilizing.value
                ? const SizedBox(
                    width: 38,
                    height: 38,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : CustomBorderRoundIcon(
                    onTap: controller.handleStabilize,
                    widget: const Center(
                      child: Icon(Icons.video_stable,
                          color: Colors.white, size: 20),
                    ),
                  )),
            // Blend Mode
            CustomBorderRoundIcon(
              onTap: controller.handleBlendMode,
              widget: const Center(
                child: Icon(Icons.layers, color: Colors.white, size: 20),
              ),
            ),
            // PiP
            CustomBorderRoundIcon(
              onTap: controller.handlePiP,
              widget: const Center(
                child: Icon(Icons.picture_in_picture,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class FilterAndMusicView extends StatelessWidget {
  final CameraEditScreenController controller;

  const FilterAndMusicView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isFilterShow = controller.isFilterShow.value;
      PostStoryContent content = controller.content.value;
      SelectedMusic? music = content.sound;
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: isFilterShow ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: IgnorePointer(
                ignoring: !isFilterShow,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ColorFiltersView(
                      onPageChanged: controller.changedFilter,
                      image: content.thumbNail),
                ),
              ),
            ),
            if (music != null)
              SelectedMusicView(
                  selectedMusic: music.obs,
                  isReelType: false,
                  onDeleteMusic: controller.onMusicDelete,
                  onMusicTap: (music) {
                    controller.handleMusicSelection(initialMusic: music);
                  })
          ],
        ),
      );
    });
  }
}

class CameraEditVideoView extends StatelessWidget {
  final Rx<PostStoryContent> content;

  const CameraEditVideoView({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CameraEditScreenController>();
    return Obx(() {
      final filter = controller.selectedFilter.value.length == 20
          ? controller.selectedFilter.value
          : defaultFilter;
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(filter),
        child: Container(
          decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 15, cornerSmoothing: 1))),
          child: Obx(() => CustomVideoPlayer(
              videoPlayerController: controller.videoPlayerController.value,
              onPlayPause: controller.onPlayPauseToggle)),
        ),
      );
    });
  }
}

class CustomVideoPlayer extends StatelessWidget {
  final VideoPlayerController? videoPlayerController;
  final VoidCallback onPlayPause;

  const CustomVideoPlayer(
      {super.key,
      required this.videoPlayerController,
      required this.onPlayPause});

  @override
  Widget build(BuildContext context) {
    if (videoPlayerController != null &&
        videoPlayerController!.value.isInitialized) {
      final videoSize = videoPlayerController!.value.size;
      final fitType =
          videoSize.width < videoSize.height ? BoxFit.cover : BoxFit.fitWidth;
      return InkWell(
        onTap: onPlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipSmoothRect(
              radius: SmoothBorderRadius(cornerRadius: 15, cornerSmoothing: 1),
              child: Container(
                color: blackPure(context),
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: fitType,
                    child: SizedBox(
                        width: videoSize.width,
                        height: videoSize.height,
                        child: VideoPlayer(videoPlayerController!)),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: videoPlayerController!,
              builder: (context, value, child) => AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: value.isPlaying ? 0 : 1,
                child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: blackPure(context).withValues(alpha: 0.5),
                        shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Image.asset(AssetRes.icPause,
                        width: 35, height: 35, color: bgGrey(context))),
              ),
            )
          ],
        ),
      );
    } else {
      return const LoaderWidget();
    }
  }
}

class _CloseFriendsToggle extends StatelessWidget {
  final CameraEditScreenController controller;

  const _CloseFriendsToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hasSubscriptions =
        SessionManager.instance.getUser()?.subscriptionsEnabled == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
      child: Obx(() {
        final vis = controller.storyVisibility.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOption(
              context,
              icon: Icons.public,
              label: LKey.public.tr,
              isSelected: vis == 0,
              color: Colors.white70,
              onTap: () => controller.storyVisibility.value = 0,
            ),
            const SizedBox(width: 8),
            _buildOption(
              context,
              icon: Icons.star_rounded,
              label: LKey.closeFriends.tr,
              isSelected: vis == 1,
              color: Colors.green,
              onTap: () => controller.storyVisibility.value = 1,
            ),
            if (hasSubscriptions) ...[
              const SizedBox(width: 8),
              _buildOption(
                context,
                icon: Icons.workspace_premium,
                label: LKey.subscribersOnly.tr,
                isSelected: vis == 2,
                color: Colors.amber,
                onTap: () => controller.storyVisibility.value = 2,
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(40)
              : Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white70),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyleCustom.outFitMedium500(
                fontSize: 12,
                color: isSelected ? color : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraEditActionButtons extends StatelessWidget {
  final CameraEditScreenController controller;

  const CameraEditActionButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Row(
        children: [
          Expanded(
            child: TextButtonCustom(
              onTap: controller.onDiscard,
              title: LKey.discard.tr,
              btnHeight: 44,
              backgroundColor: bgMediumGrey(context),
              titleColor: textLightGrey(context),
              horizontalMargin: 10,
            ),
          ),
          Expanded(
            child: Obx(() => controller.isMergingVideo.value
                ? const LoaderWidget()
                : TextButtonCustom(
                    onTap: controller.handleContentUpload,
                    title: LKey.post.tr,
                    btnHeight: 44,
                    backgroundColor: themeAccentSolid(context),
                    titleColor: whitePure(context),
                    horizontalMargin: 10,
                  )),
          ),
        ],
      ),
    );
  }
}
