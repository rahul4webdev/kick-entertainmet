import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/manager/ads/vast/vast_ad_preloader.dart';
import 'package:shortzz/common/manager/ads/vast/vast_tracker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Compact inline VAST video ad card for use in ListView feeds.
/// Shows a 16:9 video player with Ad badge, progress bar, and Learn More CTA.
class VastAdCard extends StatefulWidget {
  const VastAdCard({super.key});

  @override
  State<VastAdCard> createState() => _VastAdCardState();
}

class _VastAdCardState extends State<VastAdCard> {
  VastAdPreloader? _preloader;
  VastTracker? _tracker;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _adFailed = false;
  bool _adStarted = false;
  bool _isDisposed = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final tagUrl = ImaAdManager.instance.vastFeedAdTagUrl;
    if (tagUrl == null || tagUrl.isEmpty) {
      if (mounted) setState(() { _adFailed = true; _isLoading = false; });
      return;
    }

    _preloader = VastAdPreloader();
    final success = await _preloader!.preload(tagUrl);

    if (_isDisposed) {
      _preloader?.dispose();
      return;
    }

    if (success && _preloader!.isReady) {
      _controller = _preloader!.controller;
      _tracker = _preloader!.tracker;
      _controller!.addListener(_onPositionChanged);
      if (mounted) setState(() => _isLoading = false);
      _startAd();
    } else {
      _preloader?.dispose();
      _preloader = null;
      if (mounted) setState(() { _adFailed = true; _isLoading = false; });
    }
  }

  void _startAd() {
    if (_controller == null || _isDisposed) return;
    _controller!.play();
    _adStarted = true;
    _tracker?.fireImpressions();
  }

  void _onPositionChanged() {
    if (_isDisposed || _controller == null) return;
    final value = _controller!.value;
    if (value.duration.inMilliseconds <= 0) return;

    final pos = value.position.inMilliseconds;
    final dur = value.duration.inMilliseconds;
    _progress = pos / dur;
    _tracker?.updatePosition(value.position, value.duration);

    // Loop ad after completion
    if (!value.isPlaying && pos >= dur - 300 && _adStarted) {
      _controller?.seekTo(Duration.zero);
      _controller?.play();
    }

    if (mounted) setState(() {});
  }

  void _onAdTap() {
    final clickUrl = _preloader?.adData?.clickThroughUrl;
    if (clickUrl != null && clickUrl.isNotEmpty) {
      _tracker?.fireClick();
      _controller?.pause();
      launchUrl(Uri.parse(clickUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.removeListener(_onPositionChanged);
    _preloader?.dispose();
    _preloader = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adFailed) return const SizedBox.shrink();

    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _onAdTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),

              // "Ad" badge
              Positioned(
                top: 8,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              // "Learn More" CTA
              if (_preloader?.adData?.clickThroughUrl != null)
                Positioned(
                  bottom: 16,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Learn More',
                      style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

              // Progress bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: _progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
