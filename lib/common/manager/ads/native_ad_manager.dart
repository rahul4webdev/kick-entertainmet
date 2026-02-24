import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';

class NativeAdManager {
  NativeAdManager._();
  static final instance = NativeAdManager._();

  static const _poolSize = 3;
  static const _maxConsecutiveFailures = 3;

  final Queue<NativeAd> _adPool = Queue();
  bool _isLoading = false;
  int _consecutiveFailures = 0;
  bool _temporarilyDisabled = false;
  DateTime? _disabledUntil;

  String? get _adUnitId {
    final s = SessionManager.instance.getSettings();
    if (s?.nativeAdFeedEnabled != true) return null;
    return Platform.isAndroid ? s?.admobNativeAndroid : s?.admobNativeIos;
  }

  bool get isEnabled {
    if (isSubscribe.value) return false;
    if (_adUnitId?.isNotEmpty != true) return false;
    // If temporarily disabled due to consecutive failures, check cooldown
    if (_temporarilyDisabled) {
      if (_disabledUntil != null &&
          DateTime.now().isAfter(_disabledUntil!)) {
        // Cooldown expired, re-enable and retry
        _temporarilyDisabled = false;
        _consecutiveFailures = 0;
        _disabledUntil = null;
      } else {
        return false;
      }
    }
    return true;
  }

  /// Whether the ad pool has ads ready to serve
  bool get hasAdsReady => _adPool.isNotEmpty;

  Future<void> preloadAds() async {
    if (!isEnabled) return;
    if (_isLoading) return;
    _isLoading = true;

    final needed = _poolSize - _adPool.length;
    log('[NativeAdManager] Loading $needed ads (pool: ${_adPool.length})');
    for (int i = 0; i < needed; i++) {
      await _loadSingleAd();
    }

    _isLoading = false;
    log('[NativeAdManager] Pool size after load: ${_adPool.length}');
  }

  Future<void> _loadSingleAd() async {
    final unitId = _adUnitId;
    if (unitId == null || unitId.isEmpty) return;

    final completer = Completer<void>();

    try {
      final ad = NativeAd(
        adUnitId: unitId,
        request: const AdRequest(),
        nativeTemplateStyle:
            NativeTemplateStyle(templateType: TemplateType.medium),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            _adPool.add(ad as NativeAd);
            _consecutiveFailures = 0; // Reset on success
            log('[NativeAdManager] Ad loaded, pool: ${_adPool.length}');
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            _consecutiveFailures++;
            log('[NativeAdManager] Failed to load: ${error.message} '
                '(failures: $_consecutiveFailures/$_maxConsecutiveFailures)');
            ad.dispose();
            // Auto-disable after too many consecutive failures (e.g. ad blocker)
            if (_consecutiveFailures >= _maxConsecutiveFailures) {
              _temporarilyDisabled = true;
              _disabledUntil =
                  DateTime.now().add(const Duration(minutes: 5));
              log('[NativeAdManager] Temporarily disabled for 5 min '
                  'after $_consecutiveFailures failures');
            }
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await ad.load();
      await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _consecutiveFailures++;
          log('[NativeAdManager] Ad load timed out');
          if (_consecutiveFailures >= _maxConsecutiveFailures) {
            _temporarilyDisabled = true;
            _disabledUntil =
                DateTime.now().add(const Duration(minutes: 5));
          }
        },
      );
    } catch (e) {
      log('[NativeAdManager] Error loading ad: $e');
      _consecutiveFailures++;
      if (!completer.isCompleted) completer.complete();
    }
  }

  NativeAd? getAd() {
    if (_adPool.isEmpty) {
      log('[NativeAdManager] Pool empty, refilling...');
      _refillInBackground();
      return null;
    }
    final ad = _adPool.removeFirst();
    log('[NativeAdManager] Serving ad, remaining: ${_adPool.length}');
    _refillInBackground();
    return ad;
  }

  void _refillInBackground() {
    if (_adPool.length < _poolSize && !_isLoading) {
      preloadAds();
    }
  }

  void dispose() {
    for (final ad in _adPool) {
      ad.dispose();
    }
    _adPool.clear();
  }
}
