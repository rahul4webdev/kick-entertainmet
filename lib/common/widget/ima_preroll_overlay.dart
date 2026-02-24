import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';

/// Generic IMA ad overlay used for pre-roll, mid-roll, and post-roll ads.
/// Uses smooth fade transitions — no jarring black screen or blink.
/// Timeout auto-skips if ad doesn't load within 6 seconds.
class ImaAdOverlay extends StatefulWidget {
  final String adTagUrl;
  final VoidCallback onAdComplete;

  const ImaAdOverlay({
    super.key,
    required this.adTagUrl,
    required this.onAdComplete,
  });

  @override
  State<ImaAdOverlay> createState() => _ImaAdOverlayState();
}

class _ImaAdOverlayState extends State<ImaAdOverlay> {
  late final AdDisplayContainer _adDisplayContainer;
  AdsLoader? _adsLoader;
  AdsManager? _adsManager;
  bool _adStarted = false;
  bool _completed = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    // Timeout: if ad doesn't start within 6 seconds, skip silently
    _timeoutTimer = Timer(const Duration(seconds: 6), () {
      if (!_adStarted && !_completed) {
        log('[IMA] Ad timed out after 6s, skipping');
        _completeOnce();
      }
    });

    _adDisplayContainer = AdDisplayContainer(
      onContainerAdded: (container) {
        log('[IMA] Container added, requesting ads...');
        _adsLoader = AdsLoader(
          container: container,
          onAdsLoaded: _onAdsLoaded,
          onAdsLoadError: _onAdsLoadError,
        );
        _requestAds();
      },
    );
  }

  void _requestAds() {
    if (widget.adTagUrl.isEmpty) {
      log('[IMA] Empty ad tag URL, skipping');
      _completeOnce();
      return;
    }
    final tagPreview = widget.adTagUrl.length > 60
        ? widget.adTagUrl.substring(0, 60)
        : widget.adTagUrl;
    log('[IMA] Requesting ads with tag: $tagPreview...');
    _adsLoader?.requestAds(AdsRequest(adTagUrl: widget.adTagUrl));
  }

  void _onAdsLoaded(OnAdsLoadedData data) {
    log('[IMA] Ads loaded successfully');
    _adsManager = data.manager;
    _adsManager!.setAdsManagerDelegate(AdsManagerDelegate(
      onAdEvent: (AdEvent event) {
        log('[IMA] Ad event: ${event.type}');
        if (event.type == AdEventType.started) {
          _adStarted = true;
          _timeoutTimer?.cancel();
          if (mounted) setState(() {});
        } else if (event.type == AdEventType.allAdsCompleted ||
            event.type == AdEventType.complete) {
          _disposeAndComplete();
        }
      },
      onAdErrorEvent: (AdErrorEvent event) {
        log('[IMA] Ad error: ${event.error.message}');
        _disposeAndComplete();
      },
    ));
    _adsManager!.init();
    _adsManager!.start();
    if (mounted) setState(() {});
  }

  void _onAdsLoadError(AdsLoadErrorData data) {
    log('[IMA] Ads load error: ${data.error.message}');
    _completeOnce();
  }

  void _disposeAndComplete() {
    _adsManager?.destroy();
    _adsManager = null;
    _completeOnce();
  }

  void _completeOnce() {
    if (_completed) return;
    _completed = true;
    _timeoutTimer?.cancel();
    widget.onAdComplete();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _adsManager?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Before ad starts: overlay is fully transparent so the video frame
    // underneath stays visible (no black screen / blink). The ad container
    // loads in the background at full size but isn't painted.
    // When the ad actually starts: smooth 300ms fade-in.
    // IgnorePointer prevents the invisible overlay from eating touch events.
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_adStarted,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _adStarted ? 1.0 : 0.0,
          child: Container(
            color: Colors.black,
            child: SizedBox.expand(child: _adDisplayContainer),
          ),
        ),
      ),
    );
  }
}

/// Keep old name as typedef for backward compatibility
typedef ImaPreRollOverlay = ImaAdOverlay;
