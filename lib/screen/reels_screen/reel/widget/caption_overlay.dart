import 'package:flutter/material.dart';
import 'package:shortzz/model/post_story/caption/caption_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:video_player/video_player.dart' hide Caption;

class CaptionOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final List<Caption> captions;

  const CaptionOverlay({
    super.key,
    required this.controller,
    required this.captions,
  });

  @override
  State<CaptionOverlay> createState() => _CaptionOverlayState();
}

class _CaptionOverlayState extends State<CaptionOverlay> {
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onPositionChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPositionChanged);
    super.dispose();
  }

  void _onPositionChanged() {
    if (!mounted) return;
    final posMs = widget.controller.value.position.inMilliseconds;
    String text = '';
    for (final caption in widget.captions) {
      if (posMs >= caption.startMs && posMs <= caption.endMs) {
        text = caption.text;
        break;
      }
    }
    if (text != _currentText) {
      setState(() => _currentText = text);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentText.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: 100,
      left: 20,
      right: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: blackPure(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _currentText,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 15, color: whitePure(context)),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
