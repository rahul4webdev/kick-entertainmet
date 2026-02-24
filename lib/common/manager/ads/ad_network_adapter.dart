import 'package:flutter/material.dart';

enum AdNetwork { admob, meta, unity, applovin }

enum AdType { banner, interstitial, rewarded, appOpen }

class LoadedAd {
  final AdNetwork network;
  final AdType type;
  final dynamic nativeAd;
  final Widget? bannerWidget;

  LoadedAd({
    required this.network,
    required this.type,
    required this.nativeAd,
    this.bannerWidget,
  });
}

abstract class AdNetworkAdapter {
  AdNetwork get network;

  Future<void> initialize();

  Future<LoadedAd?> loadBanner({required String adUnitId});

  Future<LoadedAd?> loadInterstitial({required String adUnitId});

  Future<LoadedAd?> loadRewarded({required String adUnitId});

  Future<LoadedAd?> loadAppOpen({required String adUnitId});

  Future<bool> showInterstitial(LoadedAd ad);

  Future<bool> showRewarded(LoadedAd ad, {required Function() onEarned});

  Future<bool> showAppOpen(LoadedAd ad);
}
