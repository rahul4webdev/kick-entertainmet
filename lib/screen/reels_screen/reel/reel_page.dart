import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/widget/black_gradient_shadow.dart';
import 'package:shortzz/common/widget/double_tap_detector.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/reels_screen/reel/widget/reel_animation_like.dart';
import 'package:shortzz/screen/reels_screen/reel/widget/reel_seek_bar.dart';
import 'package:shortzz/screen/reels_screen/reel/widget/side_bar_list.dart';
import 'package:shortzz/screen/reels_screen/reel/widget/user_information.dart';
import 'package:shortzz/screen/reels_screen/reels_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/manager/ads/vast/vast_ad_preloader.dart';
import 'package:shortzz/common/widget/vast_ad_overlay.dart';
import 'package:shortzz/common/widget/video_linking_overlay.dart';
import 'package:shortzz/common/widget/product_links_overlay.dart';
import 'package:shortzz/common/widget/reel_product_overlay.dart';
import 'package:shortzz/screen/reels_screen/reel/widget/caption_overlay.dart';
import 'package:visibility_detector/visibility_detector.dart';

// ---------------------------------------------------------------
// REEL PAGE — uses media_kit (libmpv/ffmpeg) for reliable software
// decoding on all Android chipsets including MediaTek Helio.
// ---------------------------------------------------------------
class ReelPage extends StatefulWidget {
  final Post reelData;
  final bool autoPlay;
  final PostByIdData? postByIdData;
  final bool isFromChat;
  final GlobalKey likeKey;
  final ReelsScreenController reelsScreenController;
  final Function(Post reel) onUpdateReelData;
  final bool isHomePage;

  const ReelPage(
      {super.key,
      required this.reelData,
      this.autoPlay = false,
      this.postByIdData,
      this.isFromChat = false,
      required this.likeKey,
      required this.reelsScreenController,
      required this.onUpdateReelData,
      required this.isHomePage});

  @override
  State<ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<ReelPage> {
  static bool _mediaKitInitialized = false;

  Player? _player;
  VideoController? _videoController;
  bool _initialized = false;
  bool _isDisposed = false;
  bool isPlaying = true;
  late ReelController reelController;
  Rx<TapDownDetails?> details = Rx(null);
  final dashboardController = Get.find<DashboardScreenController>();
  StreamSubscription? _visibilitySub;
  bool _showVastAd = false;
  bool _showCaptions = true;
  ImaAdPlacement? _currentAdPlacement;
  int _loopCount = 0;
  final ValueNotifier<int> _videoPositionMs = ValueNotifier<int>(0);
  VastAdPreloader? _vastPreloader;
  bool _preRollDecisionPending = false;
  bool _hasTriggeredSmartPreload = false;
  int _lastPositionMs = 0; // Track position for backward-jump loop detection
  int _initGeneration = 0; // Generation counter to cancel in-flight inits
  StreamSubscription? _positionSub;
  StreamSubscription? _completedSub;
  int _videoDurationMs = 0;
  int _videoWidth = 0;
  int _videoHeight = 0;

  @override
  void initState() {
    super.initState();
    // Pre-roll & video init: only for the current page (autoPlay=true)
    // Other pages defer initialization until they become current.
    if (widget.autoPlay) {
      if (ImaAdManager.instance.shouldShowPreRoll()) {
        debugPrint('[ReelPage] Pre-roll frequency matched for reel ${widget.reelData.id} — pending duration check');
        _preRollDecisionPending = true;
        _currentAdPlacement = ImaAdPlacement.preRoll;
        _preloadVastAd(ImaAdPlacement.preRoll);
      }
    }

    // Listen to page visibility changes (pause when bottom sheet opens)
    _visibilitySub = widget.reelsScreenController.isCurrentPageVisible.listen((visible) {
      if (_isDisposed || !_initialized || _player == null) return;
      if (!visible && (_player!.state.playing)) {
        _player!.pause();
        isPlaying = false;
        if (mounted) setState(() {});
      } else if (visible && !(_player!.state.playing) && isPlaying && !_showVastAd) {
        _player!.play();
        if (mounted) setState(() {});
      }
    });

    // Setup Reel Controller
    if (Get.isRegistered<ReelController>(tag: '${widget.reelData.id}')) {
      reelController = Get.find<ReelController>(tag: '${widget.reelData.id}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.isFromChat) {
          reelController.updateReelData(reel: widget.reelData);
        }
        reelController.notifyCommentSheet(widget.postByIdData);
      });
    } else {
      reelController = Get.put(
        ReelController(widget.reelData.obs, widget.onUpdateReelData),
        tag: '${widget.reelData.id}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        reelController.notifyCommentSheet(widget.postByIdData);
      });
    }

    // Only initialize video for the currently visible page
    if (widget.autoPlay) {
      _initializeAndPlayVideo();
    }
  }

  @override
  void didUpdateWidget(ReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autoPlay && widget.autoPlay) {
      // Page became current — initialize video if not already done
      if (!_initialized && _player == null) {
        if (ImaAdManager.instance.shouldShowPreRoll()) {
          debugPrint('[ReelPage] Pre-roll frequency matched for reel ${widget.reelData.id} — pending duration check');
          _preRollDecisionPending = true;
          _currentAdPlacement = ImaAdPlacement.preRoll;
          _preloadVastAd(ImaAdPlacement.preRoll);
        }
        _initializeAndPlayVideo();
      } else if (_initialized && _player != null) {
        _player!.play();
        isPlaying = true;
        if (mounted) setState(() {});
      }
    } else if (oldWidget.autoPlay && !widget.autoPlay) {
      // Page is no longer current — dispose to free resources
      _disposeVideoController();
    }
  }

  Future<void> _initializeAndPlayVideo({int retryCount = 0}) async {
    if (_isDisposed) return;
    final gen = ++_initGeneration;

    // Lazy-init media_kit on first use (avoids ANR from loading
    // libmpv + ffmpeg native libs during app startup)
    if (!_mediaKitInitialized) {
      MediaKit.ensureInitialized();
      _mediaKitInitialized = true;
    }

    try {
      // Dispose old player if any (prevents resource leak on retries)
      if (_player != null) {
        _positionSub?.cancel();
        _positionSub = null;
        _completedSub?.cancel();
        _completedSub = null;
        await _player!.dispose();
        _player = null;
        _videoController = null;
        _initialized = false;
      }

      final url = widget.reelData.video?.addBaseURL() ?? '';
      debugPrint('[ReelPage] Initializing video for reel ${widget.reelData.id}: $url');

      // Create media_kit Player and VideoController.
      // Force software decoding (hwdec: 'no') to avoid MediaTek hardware
      // decoder failures, and skip the Utils.IsEmulator platform call.
      _player = Player();
      _videoController = VideoController(
        _player!,
        configuration: const VideoControllerConfiguration(
          vo: 'gpu',
          hwdec: 'no',
          enableHardwareAcceleration: false,
        ),
      );

      // Progressive delay before open — gives resources time to release
      final delayMs = retryCount == 0 ? 100 : 500 * retryCount;
      await Future.delayed(Duration(milliseconds: delayMs));
      if (_isDisposed || gen != _initGeneration) {
        _player?.dispose();
        _player = null;
        _videoController = null;
        return;
      }

      // Open media without auto-play (we control play timing)
      await _player!.open(Media(url), play: false);

      // Wait for video to be ready (dimensions available)
      final width = await _player!.stream.width.firstWhere((w) => w != null).timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );

      if (_isDisposed || gen != _initGeneration) {
        _player?.dispose();
        _player = null;
        _videoController = null;
        return;
      }

      if (width == null) {
        throw Exception('Video failed to load — no dimensions received');
      }

      // Cache video dimensions and duration
      _videoWidth = _player!.state.width ?? 1080;
      _videoHeight = _player!.state.height ?? 1920;
      _videoDurationMs = _player!.state.duration.inMilliseconds;

      debugPrint('[ReelPage] Video ready: ${_videoWidth}x$_videoHeight, duration=${_videoDurationMs}ms');

      // Set looping via playlist mode
      await _player!.setPlaylistMode(PlaylistMode.single);

      // Listen to position stream for seek bar, captions, and ad timing
      _positionSub = _player!.stream.position.listen(_onVideoPositionChanged);

      _initialized = true;

      // After init, check if pre-roll should be cancelled due to min video length
      if (_preRollDecisionPending) {
        final videoDurSec = _videoDurationMs ~/ 1000;
        final minLength = SessionManager.instance.getSettings()?.imaPrerollMinVideoLength ?? 0;
        if (minLength > 0 && videoDurSec < minLength) {
          debugPrint('[ReelPage] Pre-roll cancelled: video ${videoDurSec}s < min ${minLength}s');
          _preRollDecisionPending = false;
          _currentAdPlacement = null;
          _showVastAd = false;
          _vastPreloader?.dispose();
          _vastPreloader = null;
        } else {
          _preRollDecisionPending = false;
        }
      }

      if (dashboardController.selectedPageIndex.value != 0 && widget.isHomePage) {
        return;
      }
      // Auto play only when visible and autoplay flag true
      if (widget.autoPlay && widget.reelsScreenController.isCurrentPageVisible.value) {
        // If pre-roll ad is loading/showing, don't auto-play yet
        if (_currentAdPlacement == ImaAdPlacement.preRoll) {
          if (_showVastAd) {
            setState(() {}); // trigger build to show pre-roll overlay
          }
          return;
        }
        await _player!.play();
        _increaseViewsCount(widget.reelData);
        isPlaying = true;
      }

      setState(() {});
    } catch (e) {
      debugPrint('[ReelPage] Video init error (retry $retryCount/3) for reel ${widget.reelData.id}: $e');

      // Clean up failed player
      _positionSub?.cancel();
      _positionSub = null;
      _completedSub?.cancel();
      _completedSub = null;
      _player?.dispose();
      _player = null;
      _videoController = null;
      _initialized = false;

      // Retry with exponential backoff (max 4 retries: 1s, 2s, 3s, 4s)
      if (retryCount < 4 && !_isDisposed && gen == _initGeneration) {
        final backoffMs = 1000 * (retryCount + 1);
        debugPrint('[ReelPage] Retrying in ${backoffMs}ms...');
        await Future.delayed(Duration(milliseconds: backoffMs));
        if (!_isDisposed && gen == _initGeneration) {
          _initializeAndPlayVideo(retryCount: retryCount + 1);
        }
      } else {
        debugPrint('[ReelPage] All retries exhausted for reel ${widget.reelData.id}');
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _initGeneration++; // Cancel any in-flight initialization
    _visibilitySub?.cancel();
    _positionSub?.cancel();
    _completedSub?.cancel();
    _player?.dispose();
    _player = null;
    _videoController = null;
    _vastPreloader?.dispose();
    _vastPreloader = null;
    super.dispose();
  }

  /// Dispose the video player to free resources.
  /// Called when this page is no longer the current page.
  void _disposeVideoController() {
    _initGeneration++; // Cancel any in-flight initialization
    _positionSub?.cancel();
    _positionSub = null;
    _completedSub?.cancel();
    _completedSub = null;
    _player?.dispose();
    _player = null;
    _videoController = null;
    _initialized = false;
    _vastPreloader?.dispose();
    _vastPreloader = null;
    _showVastAd = false;
    _currentAdPlacement = null;
    _preRollDecisionPending = false;
    isPlaying = false;
    _loopCount = 0;
    _hasTriggeredSmartPreload = false;
    _lastPositionMs = 0;
    _videoDurationMs = 0;
    if (mounted) setState(() {});
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!_initialized || _player == null) return;

    final isPageVisible = widget.reelsScreenController.isCurrentPageVisible.value;

    if ((info.visibleFraction * 100) > 90 && isPageVisible && !_showVastAd) {
      if (!(_player!.state.playing)) {
        _player!.play();
        isPlaying = true;
      }
    } else {
      if (_player!.state.playing) {
        _player!.pause();
        isPlaying = false;
      }
    }
    setState(() {});
  }

  void _onVideoPositionChanged(Duration position) {
    if (_isDisposed || _player == null || !_initialized) return;

    if (_videoDurationMs <= 0) {
      // Update cached duration if it wasn't available at init
      _videoDurationMs = _player!.state.duration.inMilliseconds;
      if (_videoDurationMs <= 0) return;
    }

    final posMs = position.inMilliseconds;
    final durMs = _videoDurationMs;

    // Track position for product tag timing and captions
    _videoPositionMs.value = posMs;

    if (_showVastAd || _currentAdPlacement != null) {
      _lastPositionMs = posMs;
      return;
    }

    final preloadBeforeSec = ImaAdManager.instance.preloadSecondsBefore;

    // Smart preload: start preloading N seconds before video ends
    if (!_hasTriggeredSmartPreload &&
        preloadBeforeSec > 0 &&
        durMs > preloadBeforeSec * 1000) {
      final triggerMs = durMs - (preloadBeforeSec * 1000);
      if (posMs >= triggerMs) {
        _hasTriggeredSmartPreload = true;
        _smartPreloadUpcomingAd();
      }
    }

    // Detect loop boundary: position jumps backward significantly.
    // media_kit with PlaylistMode.single seamlessly loops the video —
    // position goes from near-end back to near-start.
    if (_lastPositionMs > durMs - 1000 && posMs < 1000 && durMs > 1000) {
      debugPrint('[ReelPage] LOOP DETECTED: lastPos=${_lastPositionMs}ms pos=${posMs}ms dur=${durMs}ms loop=$_loopCount');
      _lastPositionMs = posMs;
      _onVideoLoopComplete();
      return;
    }

    _lastPositionMs = posMs;
  }

  /// Pre-load the next ad (mid-roll or post-roll) before the video ends.
  void _smartPreloadUpcomingAd() {
    final videoDurSec = _videoDurationMs ~/ 1000;
    ImaAdPlacement? placement;

    if (_loopCount == 0) {
      final settings = SessionManager.instance.getSettings();
      if (settings?.imaMidrollEnabled != false) {
        final freq = settings?.imaMidRollFrequency ?? 0;
        if (freq > 0 && ((_midRollViewCountPeek + 1) % freq == 0)) {
          final minLen = settings?.imaMidrollMinVideoLength ?? 0;
          if (minLen <= 0 || videoDurSec >= minLen) {
            placement = ImaAdPlacement.midRoll;
          }
        }
      }
    } else {
      final settings = SessionManager.instance.getSettings();
      if (settings?.imaPostrollEnabled != false) {
        final freq = settings?.imaPostRollFrequency ?? 0;
        if (freq > 0 && ((_postRollViewCountPeek + 1) % freq == 0)) {
          final minLen = settings?.imaPostrollMinVideoLength ?? 0;
          if (minLen <= 0 || videoDurSec >= minLen) {
            placement = ImaAdPlacement.postRoll;
          }
        }
      }
    }

    if (placement != null) {
      debugPrint('[ReelPage] Smart preloading ${placement.name} ad before video end');
      _vastPreloader?.dispose();
      _vastPreloader = VastAdPreloader();
      final tagUrl = ImaAdManager.instance.getAdTagUrl(placement);
      if (tagUrl != null && tagUrl.isNotEmpty) {
        _vastPreloader!.preload(tagUrl).then((success) {
          if (_isDisposed) {
            _vastPreloader?.dispose();
            _vastPreloader = null;
            return;
          }
          if (success) {
            debugPrint('[ReelPage] Smart preload SUCCESS for ${placement!.name}');
          } else {
            debugPrint('[ReelPage] Smart preload FAILED for ${placement!.name}');
            _vastPreloader?.dispose();
            _vastPreloader = null;
          }
        });
      }
    }
  }

  /// Peek at current view counts without incrementing (for smart preload prediction)
  int get _midRollViewCountPeek => ImaAdManager.instance.midRollViewCount;
  int get _postRollViewCountPeek => ImaAdManager.instance.postRollViewCount;

  void _onVideoLoopComplete() {
    _loopCount++;
    final videoDurSec = _videoDurationMs ~/ 1000;

    if (_loopCount == 1) {
      // First loop completed — check mid-roll
      if (ImaAdManager.instance.shouldShowMidRoll(videoDurationSeconds: videoDurSec)) {
        _currentAdPlacement = ImaAdPlacement.midRoll;
        _player?.pause(); // Pause content video for ad
        isPlaying = false;
        if (_vastPreloader?.isReady == true) {
          debugPrint('[ReelPage] Using smart-preloaded mid-roll ad — instant!');
          _showVastAd = true;
          if (mounted) setState(() {});
          return;
        }
        debugPrint('[ReelPage] Mid-roll needed but no preloaded ad — loading now');
        _preloadVastAd(ImaAdPlacement.midRoll);
        return;
      }
    } else {
      // Subsequent loops — check post-roll
      if (ImaAdManager.instance.shouldShowPostRoll(videoDurationSeconds: videoDurSec)) {
        _currentAdPlacement = ImaAdPlacement.postRoll;
        _player?.pause(); // Pause content video for ad
        isPlaying = false;
        if (_vastPreloader?.isReady == true) {
          debugPrint('[ReelPage] Using smart-preloaded post-roll ad — instant!');
          _showVastAd = true;
          if (mounted) setState(() {});
          return;
        }
        debugPrint('[ReelPage] Post-roll needed but no preloaded ad — loading now');
        _preloadVastAd(ImaAdPlacement.postRoll);
        return;
      }
    }

    // No ad needed — video is already looping via PlaylistMode.single
    _hasTriggeredSmartPreload = false;
  }

  void _onVastAdComplete() {
    debugPrint('[ReelPage] _onVastAdComplete called, loopCount=$_loopCount');
    if (_isDisposed || _player == null) return;
    _showVastAd = false;
    _currentAdPlacement = null;
    _hasTriggeredSmartPreload = false;
    // Dispose the consumed preloader
    _vastPreloader?.dispose();
    _vastPreloader = null;

    if (_loopCount == 0) {
      // Pre-roll finished — start playing for first time
      _player!.play();
      _increaseViewsCount(widget.reelData);
      isPlaying = true;
    } else {
      // Mid/post-roll finished — resume video
      _player!.play();
      isPlaying = true;
    }
    if (mounted) setState(() {});
  }

  /// Pre-load a VAST ad for the given placement.
  /// When ready, sets _showVastAd = true to trigger the overlay.
  Future<void> _preloadVastAd(ImaAdPlacement placement) async {
    final tagUrl = ImaAdManager.instance.getAdTagUrl(placement);
    debugPrint('[ReelPage] _preloadVastAd(${placement.name})');
    if (tagUrl == null || tagUrl.isEmpty) {
      debugPrint('[ReelPage] No ad tag for ${placement.name} — skipping');
      _currentAdPlacement = null;
      if (placement != ImaAdPlacement.preRoll) {
        _player?.play();
        isPlaying = true;
        _hasTriggeredSmartPreload = false;
        if (mounted) setState(() {});
      }
      return;
    }

    _vastPreloader?.dispose();
    _vastPreloader = VastAdPreloader();
    final success = await _vastPreloader!.preload(tagUrl);

    if (_isDisposed) {
      _vastPreloader?.dispose();
      _vastPreloader = null;
      return;
    }

    if (success) {
      debugPrint('[ReelPage] VAST preload SUCCESS for ${placement.name} — showing ad');
      _showVastAd = true;
      if (mounted) setState(() {});
    } else {
      debugPrint('[ReelPage] VAST preload FAILED for ${placement.name} — skipping');
      _vastPreloader?.dispose();
      _vastPreloader = null;
      _currentAdPlacement = null;
      if (placement == ImaAdPlacement.preRoll &&
          _loopCount == 0 &&
          _initialized &&
          _player != null &&
          !(_player!.state.playing)) {
        _player!.play();
        _increaseViewsCount(widget.reelData);
        isPlaying = true;
        if (mounted) setState(() {});
      }
      if (placement != ImaAdPlacement.preRoll) {
        _player?.play();
        isPlaying = true;
        _hasTriggeredSmartPreload = false;
        if (mounted) setState(() {});
      }
    }
  }

  void onPlayPause() {
    if (_player == null || !_initialized) return;
    if (_player!.state.playing) {
      _player!.pause();
      isPlaying = false;
    } else {
      _player!.play();
      isPlaying = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DoubleTapDetector(
      onDoubleTap: (value) {
        if (details.value != null) return;
        details.value = value;
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// Video content via media_kit
          if (_videoController != null) buildContent(),

          /// Loading indicator while video initializes
          if (_videoController == null && widget.autoPlay)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white38,
                strokeWidth: 2,
              ),
            ),

          /// Tap Overlay (pause/play)
          InkWell(onTap: onPlayPause, child: const BlackGradientShadow()),

          /// Play/Pause Icon overlay
          if (_videoController != null)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: isPlaying ? 0.0 : 1.0,
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 60,
                  width: 60,
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  alignment: const Alignment(0.25, 0),
                  child: Image.asset(isPlaying ? AssetRes.icPause : AssetRes.icPlay,
                      width: 45, height: 45, color: bgGrey(context)),
                ),
              ),
            ),

          /// Video Reply to Comment badge
          if (widget.reelData.isVideoReply && _initialized && !_showVastAd)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 12,
              right: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.reelData.replyToCommentText ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          /// Video Linking: Previous/Next Part buttons
          if (_initialized && !_showVastAd)
            VideoLinkingOverlay(post: widget.reelData),

          /// Product Links overlay (external links)
          if (_initialized && !_showVastAd)
            ProductLinksOverlay(post: widget.reelData),

          /// Enhanced product tags overlay (positioned + timed)
          if (_initialized && !_showVastAd && widget.reelData.productTags != null && widget.reelData.productTags!.isNotEmpty)
            ValueListenableBuilder<int>(
              valueListenable: _videoPositionMs,
              builder: (context, posMs, _) => ReelProductOverlay(
                post: widget.reelData,
                currentPositionMs: posMs,
              ),
            ),

          /// Captions overlay
          if (_initialized &&
              !_showVastAd &&
              _player != null &&
              widget.reelData.hasCaptions &&
              widget.reelData.captions != null &&
              widget.reelData.captions!.isNotEmpty &&
              _showCaptions)
            CaptionOverlay(
              videoPositionMs: _videoPositionMs,
              captions: widget.reelData.captions!,
            ),

          /// CC toggle button
          if (_initialized &&
              !_showVastAd &&
              widget.reelData.hasCaptions &&
              widget.reelData.captions != null &&
              widget.reelData.captions!.isNotEmpty)
            Positioned(
              bottom: 70,
              left: 12,
              child: InkWell(
                onTap: () => setState(() => _showCaptions = !_showCaptions),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _showCaptions ? Colors.white70 : Colors.white30,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.closed_caption,
                        size: 16,
                        color: _showCaptions ? Colors.white : Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CC',
                        style: TextStyle(
                          color: _showCaptions ? Colors.white : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// VAST Ad Overlay (pre-roll, mid-roll, or post-roll)
          if (_showVastAd && _initialized && _vastPreloader != null)
            VastAdOverlay(
              preloader: _vastPreloader!,
              onAdComplete: _onVastAdComplete,
            ),

          /// Reel Info Section
          ReelInfoSection(
            controller: reelController,
            likeKey: widget.likeKey,
            player: _player,
          ),

          /// Like Animation
          Obx(() {
            if (details.value == null) return const SizedBox();
            return ReelAnimationLike(
              likeKey: widget.likeKey,
              position: details.value!.globalPosition,
              size: const Size(50, 50),
              leftRightPosition: 8,
              onLikeCall: () {
                if (reelController.reelData.value.isLiked == true) return;
                reelController.onLikeTap();
              },
              onCompleteAnimation: () => details.value = null,
            );
          }),
        ],
      ),
    );
  }

  Widget buildContent() {
    final w = _videoWidth > 0 ? _videoWidth.toDouble() : 1080.0;
    final h = _videoHeight > 0 ? _videoHeight.toDouble() : 1920.0;
    return VisibilityDetector(
      key: Key('reel_${widget.reelData.id}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: InkWell(
        onTap: onPlayPause,
        child: ClipRRect(
          child: SizedBox.expand(
            child: FittedBox(
              fit: (w < h) ? BoxFit.cover : BoxFit.fitWidth,
              child: SizedBox(
                width: w,
                height: h,
                child: Video(
                  controller: _videoController!,
                  controls: NoVideoControls,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _increaseViewsCount(Post reelData) {
    PostService.instance.increaseViewsCount(postId: reelData.id).then((value) {
      if (value.status == true) {
        reelController.updateReelData(reel: reelData, isIncreaseCoin: true);
      }
    });
  }
}

class ReelInfoSection extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;
  final Player? player;

  const ReelInfoSection({super.key,
    required this.controller,
    required this.likeKey,
    required this.player});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ReelInfoRow(controller: controller, likeKey: likeKey),
        ReelSeekBar(player: player, controller: controller),
      ],
    );
  }
}

class ReelInfoRow extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;

  const ReelInfoRow({super.key, required this.controller, required this.likeKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: UserInformation(controller: controller)),
        SideBarList(controller: controller, likeKey: likeKey),
      ],
    );
  }
}
