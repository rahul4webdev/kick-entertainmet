import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum VideoTransition {
  none,
  fade,
  dissolve,
  slideLeft,
  slideRight,
  slideUp,
  slideDown,
  zoomIn,
  wipeLeft,
  wipeRight,
  circleOpen,
  circleClose,
  pixelize,
  radial,
  smoothLeft,
  smoothRight,
}

extension VideoTransitionInfo on VideoTransition {
  String get label => switch (this) {
        VideoTransition.none => 'None',
        VideoTransition.fade => 'Fade',
        VideoTransition.dissolve => 'Dissolve',
        VideoTransition.slideLeft => 'Slide Left',
        VideoTransition.slideRight => 'Slide Right',
        VideoTransition.slideUp => 'Slide Up',
        VideoTransition.slideDown => 'Slide Down',
        VideoTransition.zoomIn => 'Zoom In',
        VideoTransition.wipeLeft => 'Wipe Left',
        VideoTransition.wipeRight => 'Wipe Right',
        VideoTransition.circleOpen => 'Circle Open',
        VideoTransition.circleClose => 'Circle Close',
        VideoTransition.pixelize => 'Pixelize',
        VideoTransition.radial => 'Radial',
        VideoTransition.smoothLeft => 'Smooth Left',
        VideoTransition.smoothRight => 'Smooth Right',
      };

  IconData get icon => switch (this) {
        VideoTransition.none => Icons.block,
        VideoTransition.fade => Icons.gradient,
        VideoTransition.dissolve => Icons.blur_on,
        VideoTransition.slideLeft => Icons.arrow_back,
        VideoTransition.slideRight => Icons.arrow_forward,
        VideoTransition.slideUp => Icons.arrow_upward,
        VideoTransition.slideDown => Icons.arrow_downward,
        VideoTransition.zoomIn => Icons.zoom_in,
        VideoTransition.wipeLeft => Icons.swipe_left,
        VideoTransition.wipeRight => Icons.swipe_right,
        VideoTransition.circleOpen => Icons.radio_button_unchecked,
        VideoTransition.circleClose => Icons.adjust,
        VideoTransition.pixelize => Icons.grid_on,
        VideoTransition.radial => Icons.rotate_right,
        VideoTransition.smoothLeft => Icons.trending_flat,
        VideoTransition.smoothRight => Icons.trending_flat,
      };

  /// FFmpeg xfade transition name
  String get ffmpegName => switch (this) {
        VideoTransition.none => 'fade',
        VideoTransition.fade => 'fade',
        VideoTransition.dissolve => 'dissolve',
        VideoTransition.slideLeft => 'slideleft',
        VideoTransition.slideRight => 'slideright',
        VideoTransition.slideUp => 'slideup',
        VideoTransition.slideDown => 'slidedown',
        VideoTransition.zoomIn => 'zoomin',
        VideoTransition.wipeLeft => 'wipeleft',
        VideoTransition.wipeRight => 'wiperight',
        VideoTransition.circleOpen => 'circleopen',
        VideoTransition.circleClose => 'circleclose',
        VideoTransition.pixelize => 'pixelize',
        VideoTransition.radial => 'radial',
        VideoTransition.smoothLeft => 'smoothleft',
        VideoTransition.smoothRight => 'smoothright',
      };
}

class TransitionPickerSheet extends StatelessWidget {
  final VideoTransition? current;

  const TransitionPickerSheet({super.key, this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Transition Effect',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: VideoTransition.values.length,
              itemBuilder: (context, index) {
                final transition = VideoTransition.values[index];
                return GestureDetector(
                  onTap: () => Get.back(result: transition),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          transition.icon,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        transition.label,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
