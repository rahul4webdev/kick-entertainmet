import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';

class AdMobAdapter implements AdNetworkAdapter {
  @override
  AdNetwork get network => AdNetwork.admob;

  @override
  Future<void> initialize() async {
    // Already initialized in main.dart via MobileAds.instance.initialize()
  }

  @override
  Future<LoadedAd?> loadBanner({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    final completer = Completer<LoadedAd?>();
    BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          final bannerAd = ad as BannerAd;
          completer.complete(LoadedAd(
            network: AdNetwork.admob,
            type: AdType.banner,
            nativeAd: bannerAd,
            bannerWidget: SizedBox(
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              child: AdWidget(ad: bannerAd),
            ),
          ));
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          log('AdMob banner failed: $err');
          completer.complete(null);
        },
      ),
    ).load();
    return completer.future;
  }

  @override
  Future<LoadedAd?> loadInterstitial({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    final completer = Completer<LoadedAd?>();
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(LoadedAd(
            network: AdNetwork.admob,
            type: AdType.interstitial,
            nativeAd: ad,
          ));
        },
        onAdFailedToLoad: (error) {
          log('AdMob interstitial failed: $error');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<LoadedAd?> loadRewarded({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    final completer = Completer<LoadedAd?>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(LoadedAd(
            network: AdNetwork.admob,
            type: AdType.rewarded,
            nativeAd: ad,
          ));
        },
        onAdFailedToLoad: (error) {
          log('AdMob rewarded failed: $error');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<LoadedAd?> loadAppOpen({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    final completer = Completer<LoadedAd?>();
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(LoadedAd(
            network: AdNetwork.admob,
            type: AdType.appOpen,
            nativeAd: ad,
          ));
        },
        onAdFailedToLoad: (error) {
          log('AdMob app open failed: $error');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  @override
  Future<bool> showAppOpen(LoadedAd ad) async {
    final appOpenAd = ad.nativeAd as AppOpenAd;
    final completer = Completer<bool>();
    appOpenAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await appOpenAd.show();
    return completer.future;
  }

  @override
  Future<bool> showInterstitial(LoadedAd ad) async {
    final interstitial = ad.nativeAd as InterstitialAd;
    final completer = Completer<bool>();
    interstitial.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        completer.complete(false);
      },
    );
    await interstitial.show();
    return completer.future;
  }

  @override
  Future<bool> showRewarded(LoadedAd ad, {required Function() onEarned}) async {
    final rewarded = ad.nativeAd as RewardedAd;
    final completer = Completer<bool>();
    rewarded.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    rewarded.show(onUserEarnedReward: (ad, reward) {
      onEarned();
    });
    return completer.future;
  }
}
