import 'dart:developer';
import 'dart:io';

import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';
import 'package:shortzz/common/manager/ads/adapters/admob_adapter.dart';
import 'package:shortzz/common/manager/ads/adapters/applovin_adapter.dart';
import 'package:shortzz/common/manager/ads/adapters/meta_adapter.dart';
import 'package:shortzz/common/manager/ads/adapters/unity_adapter.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/general/settings_model.dart';

class WaterfallAdManager {
  WaterfallAdManager._();
  static final instance = WaterfallAdManager._();

  final Map<AdNetwork, AdNetworkAdapter> _adapters = {};
  LoadedAd? _cachedInterstitial;
  LoadedAd? _cachedRewarded;
  LoadedAd? _cachedAppOpen;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final setting = SessionManager.instance.getSettings();

    // Always register AdMob (SDK already initialized in main.dart)
    _adapters[AdNetwork.admob] = AdMobAdapter();

    if (setting?.metaAdsEnabled == true) {
      final meta = MetaAdapter();
      await meta.initialize();
      _adapters[AdNetwork.meta] = meta;
    }

    if (setting?.unityAdsEnabled == true) {
      final unity = UnityAdsAdapter();
      await unity.initialize();
      _adapters[AdNetwork.unity] = unity;
    }

    if (setting?.applovinEnabled == true) {
      final applovin = AppLovinAdapter();
      await applovin.initialize();
      _adapters[AdNetwork.applovin] = applovin;
    }

    log('[Waterfall] Initialized with ${_adapters.length} adapters: ${_adapters.keys.map((e) => e.name).join(', ')}');
  }

  /// Returns the ordered list of (AdNetwork, adUnitId) for the given ad type
  List<(AdNetwork, String)> _getWaterfall(AdType adType) {
    final setting = SessionManager.instance.getSettings();
    if (setting == null) return [];

    List<String> priorityList;
    switch (adType) {
      case AdType.banner:
        priorityList = setting.waterfallBannerPriority ?? ['admob'];
      case AdType.interstitial:
        priorityList = setting.waterfallInterstitialPriority ?? ['admob'];
      case AdType.rewarded:
        priorityList = setting.waterfallRewardedPriority ?? ['admob'];
      case AdType.appOpen:
        priorityList = ['admob']; // App Open Ads are AdMob-only
    }

    final result = <(AdNetwork, String)>[];
    for (final networkName in priorityList) {
      final network = AdNetwork.values.where((e) => e.name == networkName).firstOrNull;
      if (network == null) continue;
      if (!_adapters.containsKey(network)) continue;

      final adUnitId = _getAdUnitId(setting, network, adType);
      if (adUnitId != null && adUnitId.isNotEmpty) {
        result.add((network, adUnitId));
      }
    }
    return result;
  }

  String? _getAdUnitId(Setting setting, AdNetwork network, AdType adType) {
    final isAndroid = Platform.isAndroid;
    switch (network) {
      case AdNetwork.admob:
        switch (adType) {
          case AdType.banner:
            return isAndroid ? setting.admobBanner : setting.admobBannerIos;
          case AdType.interstitial:
            return isAndroid ? setting.admobInt : setting.admobIntIos;
          case AdType.rewarded:
            return isAndroid ? setting.admobRewardedAndroid : setting.admobRewardedIos;
          case AdType.appOpen:
            return isAndroid ? setting.admobAppOpenAndroid : setting.admobAppOpenIos;
        }
      case AdNetwork.meta:
        switch (adType) {
          case AdType.banner:
            return isAndroid ? setting.metaBannerAndroid : setting.metaBannerIos;
          case AdType.interstitial:
            return isAndroid ? setting.metaInterstitialAndroid : setting.metaInterstitialIos;
          case AdType.rewarded:
            return isAndroid ? setting.metaRewardedAndroid : setting.metaRewardedIos;
          case AdType.appOpen:
            return null;
        }
      case AdNetwork.unity:
        switch (adType) {
          case AdType.banner:
            return isAndroid ? setting.unityBannerAndroid : setting.unityBannerIos;
          case AdType.interstitial:
            return isAndroid ? setting.unityInterstitialAndroid : setting.unityInterstitialIos;
          case AdType.rewarded:
            return isAndroid ? setting.unityRewardedAndroid : setting.unityRewardedIos;
          case AdType.appOpen:
            return null;
        }
      case AdNetwork.applovin:
        switch (adType) {
          case AdType.banner:
            return isAndroid ? setting.applovinBannerAndroid : setting.applovinBannerIos;
          case AdType.interstitial:
            return isAndroid ? setting.applovinInterstitialAndroid : setting.applovinInterstitialIos;
          case AdType.rewarded:
            return isAndroid ? setting.applovinRewardedAndroid : setting.applovinRewardedIos;
          case AdType.appOpen:
            return null;
        }
    }
  }

  /// Try each network in priority order until one loads successfully
  Future<LoadedAd?> _loadWithWaterfall(AdType adType) async {
    final waterfall = _getWaterfall(adType);

    for (final (network, adUnitId) in waterfall) {
      final adapter = _adapters[network];
      if (adapter == null) continue;

      try {
        LoadedAd? result;
        switch (adType) {
          case AdType.banner:
            result = await adapter.loadBanner(adUnitId: adUnitId);
          case AdType.interstitial:
            result = await adapter.loadInterstitial(adUnitId: adUnitId);
          case AdType.rewarded:
            result = await adapter.loadRewarded(adUnitId: adUnitId);
          case AdType.appOpen:
            result = await adapter.loadAppOpen(adUnitId: adUnitId);
        }

        if (result != null) {
          log('[Waterfall] ${adType.name} loaded from ${network.name}');
          return result;
        }
        log('[Waterfall] ${network.name} failed for ${adType.name}, trying next...');
      } catch (e) {
        log('[Waterfall] ${network.name} error for ${adType.name}: $e');
      }
    }
    log('[Waterfall] All networks exhausted for ${adType.name}');
    return null;
  }

  // ─── Public API ───

  Future<LoadedAd?> loadBannerAd() => _loadWithWaterfall(AdType.banner);

  Future<void> loadInterstitialAd() async {
    _cachedInterstitial = await _loadWithWaterfall(AdType.interstitial);
  }

  bool get isInterstitialReady => _cachedInterstitial != null;

  Future<void> showInterstitialAd() async {
    if (_cachedInterstitial == null) return;
    final ad = _cachedInterstitial!;
    _cachedInterstitial = null;
    final adapter = _adapters[ad.network];
    await adapter?.showInterstitial(ad);
    // Preload next
    loadInterstitialAd();
  }

  Future<void> loadRewardedAd() async {
    _cachedRewarded = await _loadWithWaterfall(AdType.rewarded);
  }

  bool get isRewardedAdReady => _cachedRewarded != null;

  Future<void> showRewardedAd({required Function() onEarned}) async {
    if (_cachedRewarded == null) return;
    final ad = _cachedRewarded!;
    _cachedRewarded = null;
    final adapter = _adapters[ad.network];
    await adapter?.showRewarded(ad, onEarned: onEarned);
    // Preload next
    loadRewardedAd();
  }

  // ─── App Open Ad ───

  Future<void> loadAppOpenAd() async {
    final setting = SessionManager.instance.getSettings();
    if (setting?.appOpenAdEnabled != true) return;
    _cachedAppOpen = await _loadWithWaterfall(AdType.appOpen);
  }

  bool get isAppOpenAdReady => _cachedAppOpen != null;

  Future<bool> showAppOpenAd() async {
    if (_cachedAppOpen == null) return false;
    final ad = _cachedAppOpen!;
    _cachedAppOpen = null;
    final adapter = _adapters[ad.network];
    final shown = await adapter?.showAppOpen(ad) ?? false;
    return shown;
  }
}
