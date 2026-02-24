import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_video_trimmer/flutter_native_video_trimmer.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class VideoTrimSheet extends StatefulWidget {
  final String videoPath;
  final int durationMs;

  const VideoTrimSheet({
    super.key,
    required this.videoPath,
    required this.durationMs,
  });

  static Future<String?> show({
    required String videoPath,
    required int durationMs,
  }) {
    return showModalBottomSheet<String>(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VideoTrimSheet(
        videoPath: videoPath,
        durationMs: durationMs,
      ),
    );
  }

  @override
  State<VideoTrimSheet> createState() => _VideoTrimSheetState();
}

class _VideoTrimSheetState extends State<VideoTrimSheet> {
  late RangeValues _range;
  bool _isTrimming = false;
  final _trimmer = VideoTrimmer();

  @override
  void initState() {
    super.initState();
    _range = RangeValues(0, widget.durationMs.toDouble());
    _initTrimmer();
  }

  Future<void> _initTrimmer() async {
    try {
      await _trimmer.loadVideo(widget.videoPath);
    } catch (e) {
      debugPrint('Trimmer load error: $e');
    }
  }

  String _formatDuration(double ms) {
    final totalSeconds = (ms / 1000).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleTrim() async {
    if (_isTrimming) return;
    setState(() => _isTrimming = true);

    try {
      final trimmedPath = await _trimmer.trimVideo(
        startTimeMs: _range.start.round(),
        endTimeMs: _range.end.round(),
        includeAudio: true,
      );

      if (trimmedPath != null && File(trimmedPath).existsSync()) {
        if (mounted) Navigator.pop(context, trimmedPath);
      } else {
        if (mounted) setState(() => _isTrimming = false);
      }
    } catch (e) {
      debugPrint('Trim error: $e');
      if (mounted) setState(() => _isTrimming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final durationMs = widget.durationMs.toDouble();
    final selectedDuration = _range.end - _range.start;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              LKey.trimVideo.tr,
              style: TextStyleCustom.unboundedSemiBold600(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 20),
            // Time display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_range.start),
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: themeAccentSolid(context)),
                ),
                Text(
                  '${_formatDuration(selectedDuration)} selected',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 12, color: textLightGrey(context)),
                ),
                Text(
                  _formatDuration(_range.end),
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: themeAccentSolid(context)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Range slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: themeAccentSolid(context),
                inactiveTrackColor:
                    textLightGrey(context).withValues(alpha: 0.2),
                thumbColor: themeAccentSolid(context),
                overlayColor:
                    themeAccentSolid(context).withValues(alpha: 0.15),
                rangeThumbShape:
                    const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: RangeSlider(
                values: _range,
                min: 0,
                max: durationMs,
                divisions: (durationMs / 100).round().clamp(10, 1000),
                onChanged: (values) {
                  setState(() => _range = values);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Duration label
            Text(
              '${LKey.totalDuration.tr}: ${_formatDuration(durationMs)}',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textLightGrey(context)),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: textLightGrey(context)
                                .withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          LKey.cancel.tr,
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 14, color: textDarkGrey(context)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _isTrimming ? null : _handleTrim,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: themeAccentSolid(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: _isTrimming
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                LKey.trimVideo.tr,
                                style: TextStyleCustom.outFitMedium500(
                                    fontSize: 14, color: Colors.white),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
