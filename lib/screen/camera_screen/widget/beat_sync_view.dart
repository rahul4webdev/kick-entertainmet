import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Displays beat markers as visual ticks during recording.
/// Shows a horizontal bar with tick marks at beat positions,
/// and a moving playhead that syncs with the recording progress.
class BeatSyncView extends StatelessWidget {
  final List<int> beatMarkers;
  final int totalDurationMs;

  const BeatSyncView({
    super.key,
    required this.beatMarkers,
    required this.totalDurationMs,
  });

  @override
  Widget build(BuildContext context) {
    if (beatMarkers.isEmpty || totalDurationMs <= 0) {
      return const SizedBox();
    }

    final controller = Get.find<CameraScreenController>();

    return Obx(() {
      if (!controller.isStartingRecording.value) return const SizedBox();

      final progressFraction =
          (controller.progress.value / controller.selectedSecond.value)
              .clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  // Track background
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 10,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: whitePure(context).withAlpha(40),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Beat markers
                  ...beatMarkers.where((b) => b < totalDurationMs).map((beatMs) {
                    final x = (beatMs / totalDurationMs) * width;
                    return Positioned(
                      left: x - 1,
                      top: 4,
                      child: Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: whitePure(context).withAlpha(180),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    );
                  }),
                  // Playhead
                  Positioned(
                    left: (progressFraction * width) - 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 16,
                      decoration: BoxDecoration(
                        color: themeAccentSolid(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
