import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/manager/ads/vast/vast_ad_preloader.dart';
import 'package:shortzz/common/manager/ads/vast/vast_tracker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Full-screen VAST video ad page that appears in the reel feed.
/// Auto-plays the ad when visible, fires VAST tracking events,
/// and shows a "Learn More" CTA if click-through URL is available.
class VastAdReelPage extends StatefulWidget {
  const VastAdReelPage({super.key});

  @override
  State<VastAdReelPage> createState() => _VastAdReelPageState();
}

class _VastAdReelPageState extends State<VastAdReelPage> {
  VastAdPreloader? _preloader;
  VastTracker? _tracker;
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _adFailed = false;
  bool _adStarted = false;
  bool _adComplete = false;
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
      if (!_isDisposed && mounted) setState(() => _adFailed = true);
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
      _isLoading = false;
      if (mounted) setState(() {});
      _startAd();
    } else {
      _adFailed = true;
      _isLoading = false;
      _preloader?.dispose();
      _preloader = null;
      if (mounted) setState(() {});
    }
  }

  void _startAd() {
    if (_controller == null || _isDisposed) return;
    _controller!.play();
    _adStarted = true;
    _tracker?.fireImpressions();
    debugPrint('[VastFeedAd] Ad started playing');
  }

  void _onPositionChanged() {
    if (_isDisposed || _controller == null || _adComplete) return;

    final value = _controller!.value;
    if (value.duration.inMilliseconds <= 0) return;

    final pos = value.position.inMilliseconds;
    final dur = value.duration.inMilliseconds;
    _progress = pos / dur;

    // Fire quartile/tracking events via tracker
    _tracker?.updatePosition(value.position, value.duration);

    // Ad complete — loop the ad
    if (!value.isPlaying && pos >= dur - 300 && _adStarted) {
      _adComplete = true;
      debugPrint('[VastFeedAd] Ad completed — looping');
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
    if (_adFailed) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(Icons.swipe_up_rounded, color: Colors.white24, size: 48),
        ),
      );
    }

    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 2),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(color: Colors.black);
    }

    final size = _controller!.value.size;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video
          GestureDetector(
            onTap: _onAdTap,
            child: Center(
              child: FittedBox(
                fit: (size.width < size.height) ? BoxFit.cover : BoxFit.fitWidth,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

          // "Ad" badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Progress bar at bottom
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

          // "Learn More" button if click-through available
          if (_preloader?.adData?.clickThroughUrl != null)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _onAdTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Learn More',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
