import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retrytech_plugin/retrytech_plugin.dart';
import 'package:shortzz/common/widget/black_gradient_shadow.dart';
import 'package:shortzz/common/widget/custom_border_round_icon.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/camera_screen/widget/camera_bottom_view.dart';
import 'package:shortzz/screen/camera_screen/widget/camera_top_view.dart';
import 'package:shortzz/screen/selected_music_sheet/selected_music_sheet_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/theme_res.dart';

enum CameraScreenType { post, story }

class CameraScreen extends StatelessWidget {
  final CameraScreenType cameraType;
  final SelectedMusic? selectedMusic;
  final int? replyToCommentId;
  final String? replyToCommentText;

  const CameraScreen({
    super.key,
    required this.cameraType,
    this.selectedMusic,
    this.replyToCommentId,
    this.replyToCommentText,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CameraScreenController(
      cameraType,
      selectedMusic.obs,
      replyToCommentId: replyToCommentId,
      replyToCommentText: replyToCommentText,
    ));

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: blackPure(context),
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.center,
          children: [
            _buildCameraPreview(controller),
            // Ghost/Align overlay (shows last frame when paused)
            Obx(() {
              final bytes = controller.ghostFrameBytes.value;
              final isPaused = controller.isStartingRecording.value &&
                  !controller.isRecording.value;
              if (bytes == null ||
                  !controller.ghostEnabled.value ||
                  !isPaused) {
                return const SizedBox();
              }
              return AspectRatio(
                aspectRatio: 0.52,
                child: ClipSmoothRect(
                  radius: SmoothBorderRadius(
                      cornerRadius: 20, cornerSmoothing: 1),
                  child: Opacity(
                    opacity: CameraScreenController.ghostOpacity,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
              );
            }),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BlackGradientShadow(
                height: 150,
              ),
            ),
            _buildCameraUI(context, controller),
            // Countdown overlay
            Obx(() {
              if (!controller.isCountingDown.value) {
                return const SizedBox();
              }
              return Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Text(
                    '${controller.countdownValue.value}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraScreenController controller) {
    return AspectRatio(
      aspectRatio: 0.52,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1),
        child: Obx(() {
          Widget cameraView = RetrytechPlugin.shared.cameraView;
          final filter = controller.selectedColorFilter.value;
          if (filter?.colorMatrix != null && filter!.colorMatrix!.length == 20) {
            cameraView = ColorFiltered(
              colorFilter: ColorFilter.matrix(filter.colorMatrix!),
              child: cameraView,
            );
          }
          return cameraView;
        }),
      ),
    );
  }

  Widget _buildCameraUI(
      BuildContext context, CameraScreenController controller) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CameraTopView(cameraType: cameraType),
          if (cameraType == CameraScreenType.story)
            _buildTextStoryButton(controller),
          CameraBottomView(cameraType: cameraType),
        ],
      ),
    );
  }

  Widget _buildTextStoryButton(CameraScreenController controller) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: CustomBorderRoundIcon(
          image: AssetRes.icText,
          onTap: controller.onNavigateTextStory,
        ),
      ),
    );
  }
}
