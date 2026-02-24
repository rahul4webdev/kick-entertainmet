import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/vast/vast_ad_preloader.dart';
import 'package:shortzz/common/manager/ads/vast/vast_tracker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Seamless VAST video ad overlay. Uses the app's own video player —
/// no platform views, no IMA SDK, no black screen blink.
/// The ad video is pre-cached and the controller pre-initialized,
/// so playback starts instantly with a smooth fade-in.
class VastAdOverlay extends StatefulWidget {
  final VastAdPreloader preloader;
  final VoidCallback onAdComplete;

  const VastAdOverlay({
    super.key,
    required this.preloader,
    required this.onAdComplete,
  });

  @override
  State<VastAdOverlay> createState() => _VastAdOverlayState();
}

class _VastAdOverlayState extends State<VastAdOverlay> {
  VideoPlayerController? _controller;
  VastTracker? _tracker;
  bool _adPlaying = false;
  bool _completed = false;
  bool _showSkip = false;
  Timer? _trackingTimer;
  Timer? _skipTimer;

  @override
  void initState() {
    super.initState();
    _startAd();
  }

  void _startAd() {
    if (!widget.preloader.isReady) {
      debugPrint('[VastAd] Preloader not ready, skipping');
      _completeOnce();
      return;
    }

    _controller = widget.preloader.controller;
    _tracker = widget.preloader.tracker;

    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint('[VastAd] Controller not initialized, skipping');
      _completeOnce();
      return;
    }

    // Listen for video end
    _controller!.addListener(_onVideoUpdate);

    // Start playback instantly (already initialized from cache)
    _controller!.play().then((_) {
      if (!mounted) return;
      _adPlaying = true;
      _tracker?.fireImpressions();
      setState(() {});
      debugPrint('[VastAd] Ad playback started');
    });

    // Fire tracking events periodically
    _trackingTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_controller == null || _completed) return;
      final value = _controller!.value;
      _tracker?.updatePosition(value.position, value.duration);
    });

    // Show skip button after delay (if ad is skippable)
    final skipDelay = widget.preloader.adData?.skipDelaySec ?? 5;
    _skipTimer = Timer(Duration(seconds: skipDelay), () {
      if (mounted && !_completed) {
        setState(() => _showSkip = true);
      }
    });
  }

  void _onVideoUpdate() {
    if (_completed || _controller == null) return;
    final value = _controller!.value;

    // Detect video end
    if (!value.isPlaying &&
        value.position.inMilliseconds >= value.duration.inMilliseconds - 300 &&
        value.duration.inMilliseconds > 0) {
      _completeOnce();
    }
  }

  void _onSkip() {
    _tracker?.fireSkip();
    _completeOnce();
  }

  void _onAdTap() {
    final clickUrl = widget.preloader.adData?.clickThroughUrl;
    if (clickUrl != null && clickUrl.isNotEmpty) {
      _tracker?.fireClick();
      _controller?.pause();
      launchUrl(Uri.parse(clickUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _completeOnce() {
    if (_completed) return;
    _completed = true;
    debugPrint('[VastAd] Ad complete');
    _trackingTimer?.cancel();
    _skipTimer?.cancel();
    _controller?.removeListener(_onVideoUpdate);
    widget.onAdComplete();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _skipTimer?.cancel();
    _controller?.removeListener(_onVideoUpdate);
    // Don't dispose the controller here — the preloader owns it
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _adPlaying ? 1.0 : 0.0,
        child: Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Ad video player (same engine as content — no platform view)
              if (_controller != null && _controller!.value.isInitialized)
                GestureDetector(
                  onTap: _onAdTap,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),

              // "Ad" label (top left)
              if (_adPlaying)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Ad',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Countdown / progress
              if (_adPlaying && _controller != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder(
                    valueListenable: _controller!,
                    builder: (context, VideoPlayerValue value, _) {
                      if (value.duration.inMilliseconds <= 0) {
                        return const SizedBox.shrink();
                      }
                      final progress = value.position.inMilliseconds /
                          value.duration.inMilliseconds;
                      return LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 3,
                      );
                    },
                  ),
                ),

              // Skip button (appears after delay)
              if (_showSkip)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: GestureDetector(
                    onTap: _onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.skip_next, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),

              // "Learn more" / CTA button (if click-through URL exists)
              if (_adPlaying &&
                  widget.preloader.adData?.clickThroughUrl != null)
                Positioned(
                  bottom: 16,
                  right: 12,
                  child: GestureDetector(
                    onTap: _onAdTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
