import 'package:flutter/material.dart';

enum TextAnimation {
  none,
  typewriter,
  fadeIn,
  slideUp,
  slideDown,
  bounceIn,
  scaleUp,
  wave,
}

extension TextAnimationLabel on TextAnimation {
  String get label => switch (this) {
        TextAnimation.none => 'None',
        TextAnimation.typewriter => 'Typewriter',
        TextAnimation.fadeIn => 'Fade In',
        TextAnimation.slideUp => 'Slide Up',
        TextAnimation.slideDown => 'Slide Down',
        TextAnimation.bounceIn => 'Bounce',
        TextAnimation.scaleUp => 'Scale',
        TextAnimation.wave => 'Wave',
      };

  IconData get icon => switch (this) {
        TextAnimation.none => Icons.block,
        TextAnimation.typewriter => Icons.keyboard,
        TextAnimation.fadeIn => Icons.gradient,
        TextAnimation.slideUp => Icons.arrow_upward,
        TextAnimation.slideDown => Icons.arrow_downward,
        TextAnimation.bounceIn => Icons.sports_basketball,
        TextAnimation.scaleUp => Icons.zoom_in,
        TextAnimation.wave => Icons.waves,
      };
}

class TextAnimationPicker extends StatelessWidget {
  final TextAnimation selected;
  final ValueChanged<TextAnimation> onChanged;

  const TextAnimationPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: TextAnimation.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final anim = TextAnimation.values[index];
          final isSelected = anim == selected;
          return GestureDetector(
            onTap: () => onChanged(anim),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha(50)
                    : Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 1)
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(anim.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    anim.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
