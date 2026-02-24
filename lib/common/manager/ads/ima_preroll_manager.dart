import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:shortzz/common/manager/ads/vast/vast_ad_preloader.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';

enum ImaAdPlacement { preRoll, midRoll, postRoll }

class ImaAdManager {
  ImaAdManager._();
  static final instance = ImaAdManager._();

  int _preRollViewCount = 0;
  int _midRollViewCount = 0;
  int _postRollViewCount = 0;

  /// Expose counts for smart preload prediction (peek without incrementing)
  int get midRollViewCount => _midRollViewCount;
  int get postRollViewCount => _postRollViewCount;

  // Pre-loaded ad for the next placement
  VastAdPreloader? _preloadedAd;
  ImaAdPlacement? _preloadedPlacement;

  /// Check if pre-roll should show (called when reel initializes)
  /// [videoDurationSeconds] is the video length to check against min video length setting.
  bool shouldShowPreRoll({int videoDurationSeconds = 0}) {
    if (isSubscribe.value) return false;
    final settings = SessionManager.instance.getSettings();
    // Check if pre-roll is enabled
    if (settings?.imaPrerollEnabled == false) {
      debugPrint('[AdManager] Pre-roll disabled in settings');
      return false;
    }
    // Check minimum video length
    final minLength = settings?.imaPrerollMinVideoLength ?? 0;
    if (minLength > 0 && videoDurationSeconds > 0 && videoDurationSeconds < minLength) {
      debugPrint('[AdManager] Pre-roll skipped: video ${videoDurationSeconds}s < min ${minLength}s');
      return false;
    }
    final frequency = settings?.imaPreRollFrequency ?? 0;
    if (frequency <= 0) {
      debugPrint('[AdManager] Pre-roll frequency=$frequency (disabled)');
      return false;
    }
    _preRollViewCount++;
    final show = (_preRollViewCount % frequency) == 0;
    debugPrint('[AdManager] shouldShowPreRoll: count=$_preRollViewCount, freq=$frequency, show=$show');
    return show;
  }

  /// Check if mid-roll should show (called after first video loop completes)
  /// [videoDurationSeconds] is the video length to check against min video length setting.
  bool shouldShowMidRoll({int videoDurationSeconds = 0}) {
    if (isSubscribe.value) return false;
    final settings = SessionManager.instance.getSettings();
    if (settings?.imaMidrollEnabled == false) {
      debugPrint('[AdManager] Mid-roll disabled in settings');
      return false;
    }
    final minLength = settings?.imaMidrollMinVideoLength ?? 0;
    if (minLength > 0 && videoDurationSeconds > 0 && videoDurationSeconds < minLength) {
      debugPrint('[AdManager] Mid-roll skipped: video ${videoDurationSeconds}s < min ${minLength}s');
      return false;
    }
    final frequency = settings?.imaMidRollFrequency ?? 0;
    if (frequency <= 0) return false;
    _midRollViewCount++;
    return (_midRollViewCount % frequency) == 0;
  }

  /// Check if post-roll should show (called when video completes Nth loop)
  /// [videoDurationSeconds] is the video length to check against min video length setting.
  bool shouldShowPostRoll({int videoDurationSeconds = 0}) {
    if (isSubscribe.value) return false;
    final settings = SessionManager.instance.getSettings();
    if (settings?.imaPostrollEnabled == false) {
      debugPrint('[AdManager] Post-roll disabled in settings');
      return false;
    }
    final minLength = settings?.imaPostrollMinVideoLength ?? 0;
    if (minLength > 0 && videoDurationSeconds > 0 && videoDurationSeconds < minLength) {
      debugPrint('[AdManager] Post-roll skipped: video ${videoDurationSeconds}s < min ${minLength}s');
      return false;
    }
    final frequency = settings?.imaPostRollFrequency ?? 0;
    if (frequency <= 0) return false;
    _postRollViewCount++;
    return (_postRollViewCount % frequency) == 0;
  }

  /// Get the preload-before-end setting (in seconds).
  int get preloadSecondsBefore =>
      SessionManager.instance.getSettings()?.imaPreloadSecondsBefore ?? 10;

  /// Get VAST feed ad tag URL for current platform.
  String? get vastFeedAdTagUrl {
    final settings = SessionManager.instance.getSettings();
    if (settings?.vastFeedAdEnabled != true) return null;
    return Platform.isAndroid
        ? settings?.vastFeedAdTagAndroid
        : settings?.vastFeedAdTagIos;
  }

  String? getAdTagUrl(ImaAdPlacement placement) {
    final setting = SessionManager.instance.getSettings();
    switch (placement) {
      case ImaAdPlacement.preRoll:
        return Platform.isAndroid
            ? setting?.imaAdTagAndroid
            : setting?.imaAdTagIos;
      case ImaAdPlacement.midRoll:
        return Platform.isAndroid
            ? setting?.imaMidRollAdTagAndroid
            : setting?.imaMidRollAdTagIos;
      case ImaAdPlacement.postRoll:
        return Platform.isAndroid
            ? setting?.imaPostRollAdTagAndroid
            : setting?.imaPostRollAdTagIos;
    }
  }

  /// Start preloading an ad for the given placement.
  /// Call this well before the ad needs to play.
  Future<void> preloadAd(ImaAdPlacement placement) async {
    final tagUrl = getAdTagUrl(placement);
    if (tagUrl == null || tagUrl.isEmpty) return;

    // Don't re-preload if same placement is already loaded
    if (_preloadedPlacement == placement && _preloadedAd?.isReady == true) {
      return;
    }

    // Dispose any existing preload
    _preloadedAd?.dispose();
    _preloadedAd = VastAdPreloader();
    _preloadedPlacement = placement;

    debugPrint('[AdManager] Preloading ${placement.name} ad...');
    final success = await _preloadedAd!.preload(tagUrl);
    if (success) {
      debugPrint('[AdManager] ${placement.name} ad preloaded and ready');
    } else {
      debugPrint('[AdManager] ${placement.name} preload failed');
    }
  }

  /// Get the preloaded ad for the given placement.
  /// Returns null if not ready.
  VastAdPreloader? getPreloadedAd(ImaAdPlacement placement) {
    if (_preloadedPlacement == placement && _preloadedAd?.isReady == true) {
      return _preloadedAd;
    }
    return null;
  }

  /// Consume the preloaded ad (takes ownership, clears the slot).
  VastAdPreloader? consumePreloadedAd(ImaAdPlacement placement) {
    if (_preloadedPlacement == placement && _preloadedAd?.isReady == true) {
      final ad = _preloadedAd;
      _preloadedAd = null;
      _preloadedPlacement = null;
      return ad;
    }
    return null;
  }

  /// Dispose any preloaded ads.
  void disposePreloads() {
    _preloadedAd?.dispose();
    _preloadedAd = null;
    _preloadedPlacement = null;
  }
}
