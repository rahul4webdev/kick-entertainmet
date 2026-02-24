import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/stitch_screen/stitch_recording_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:video_player/video_player.dart';

class StitchClipSelectorScreen extends StatefulWidget {
  final Post sourcePost;

  const StitchClipSelectorScreen({super.key, required this.sourcePost});

  @override
  State<StitchClipSelectorScreen> createState() =>
      _StitchClipSelectorScreenState();
}

class _StitchClipSelectorScreenState extends State<StitchClipSelectorScreen> {
  VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _isDisposed = false;

  Duration _totalDuration = Duration.zero;
  double _clipStartFraction = 0.0;
  double _clipDurationSec = 5.0;
  Timer? _positionTimer;

  static const double _minClipSec = 1.0;
  static const double _maxClipSec = 5.0;

  Duration get _clipStart =>
      Duration(milliseconds: (_clipStartFraction * _totalDuration.inMilliseconds).round());

  Duration get _clipEnd {
    final endMs = _clipStart.inMilliseconds + (_clipDurationSec * 1000).round();
    return Duration(
        milliseconds: endMs.clamp(0, _totalDuration.inMilliseconds));
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final url = Uri.parse(widget.sourcePost.video?.addBaseURL() ?? '');
      _videoController = VideoPlayerController.networkUrl(url);
      await _videoController!.initialize();
      if (_isDisposed) return;
      _videoController!.setLooping(true);
      _totalDuration = _videoController!.value.duration;

      // Limit clip duration to video duration
      if (_clipDurationSec > _totalDuration.inSeconds) {
        _clipDurationSec =
            _totalDuration.inMilliseconds / 1000.0;
      }

      _videoController!.play();
      _initialized = true;
      _startPositionTimer();
      setState(() {});
    } catch (e) {
      Loggers.error('Stitch source video init error: $e');
    }
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_isDisposed || !_initialized) return;
      final pos = _videoController?.value.position ?? Duration.zero;
      // Loop within selected clip range
      if (pos >= _clipEnd) {
        _videoController?.seekTo(_clipStart);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _positionTimer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  void _onClipStartChanged(double value) {
    _clipStartFraction = value;
    // Make sure clip doesn't exceed video end
    final maxStartMs =
        _totalDuration.inMilliseconds - (_clipDurationSec * 1000).round();
    if (_clipStart.inMilliseconds > maxStartMs && maxStartMs > 0) {
      _clipStartFraction = maxStartMs / _totalDuration.inMilliseconds;
    }
    _videoController?.seekTo(_clipStart);
    setState(() {});
  }

  void _onClipDurationChanged(double value) {
    _clipDurationSec = value;
    // Adjust start if clip would exceed video end
    final maxStartMs =
        _totalDuration.inMilliseconds - (_clipDurationSec * 1000).round();
    if (_clipStart.inMilliseconds > maxStartMs && maxStartMs > 0) {
      _clipStartFraction = maxStartMs / _totalDuration.inMilliseconds;
    }
    _videoController?.seekTo(_clipStart);
    setState(() {});
  }

  void _onNext() {
    _videoController?.pause();
    Get.off(() => StitchRecordingScreen(
          sourcePost: widget.sourcePost,
          clipStartMs: _clipStart.inMilliseconds,
          clipEndMs: _clipEnd.inMilliseconds,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildVideoPreview()),
            _buildClipControls(context),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select Clip to Stitch',
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (!_initialized || _videoController == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    final size = _videoController!.value.size;
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
          // Clip range indicator overlay
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_formatDuration(_clipStart)} - ${_formatDuration(_clipEnd)}',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${_clipDurationSec.toStringAsFixed(1)}s)',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClipControls(BuildContext context) {
    if (!_initialized) return const SizedBox(height: 120);

    final maxClipDuration = _totalDuration.inMilliseconds / 1000.0;
    final effectiveMaxClip =
        maxClipDuration.clamp(_minClipSec, _maxClipSec);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start position slider
          Text(
            'Clip Start',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 13, color: Colors.white70),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: themeColor(context),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _clipStartFraction,
              min: 0.0,
              max: 1.0,
              onChanged: _onClipStartChanged,
            ),
          ),
          const SizedBox(height: 4),
          // Clip duration slider
          Text(
            'Clip Duration: ${_clipDurationSec.toStringAsFixed(1)}s',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 13, color: Colors.white70),
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: themeColor(context),
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _clipDurationSec.clamp(_minClipSec, effectiveMaxClip),
              min: _minClipSec,
              max: effectiveMaxClip,
              onChanged: _onClipDurationChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _initialized ? _onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor(context),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          child: Text(
            'Next - Record Your Response',
            style: TextStyleCustom.outFitMedium500(
                fontSize: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }
}
