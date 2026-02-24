import 'dart:async';
import 'dart:developer';

import 'package:easy_audience_network/easy_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';

class MetaAdapter implements AdNetworkAdapter {
  @override
  AdNetwork get network => AdNetwork.meta;

  @override
  Future<void> initialize() async {
    try {
      await EasyAudienceNetwork.init();
      log('Meta Audience Network initialized');
    } catch (e) {
      log('Meta init failed: $e');
    }
  }

  @override
  Future<LoadedAd?> loadBanner({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final widget = BannerAd(
        placementId: adUnitId,
        bannerSize: BannerSize.STANDARD,
      );
      return LoadedAd(
        network: AdNetwork.meta,
        type: AdType.banner,
        nativeAd: adUnitId,
        bannerWidget: SizedBox(
          height: 50,
          child: widget,
        ),
      );
    } catch (e) {
      log('Meta banner failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadInterstitial({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      final ad = InterstitialAd(adUnitId);
      ad.listener = InterstitialAdListener(
        onLoaded: () {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.meta,
              type: AdType.interstitial,
              nativeAd: ad,
            ));
          }
        },
        onError: (code, message) {
          log('Meta interstitial failed: $code $message');
          if (!completer.isCompleted) completer.complete(null);
        },
      );
      ad.load();
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('Meta interstitial failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadRewarded({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      final ad = RewardedAd(adUnitId);
      ad.listener = RewardedAdListener(
        onLoaded: () {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.meta,
              type: AdType.rewarded,
              nativeAd: ad,
            ));
          }
        },
        onError: (code, message) {
          log('Meta rewarded failed: $code $message');
          if (!completer.isCompleted) completer.complete(null);
        },
      );
      ad.load();
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('Meta rewarded failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadAppOpen({required String adUnitId}) async => null;

  @override
  Future<bool> showAppOpen(LoadedAd ad) async => false;

  @override
  Future<bool> showInterstitial(LoadedAd ad) async {
    try {
      final interstitial = ad.nativeAd as InterstitialAd;
      final completer = Completer<bool>();
      interstitial.listener = InterstitialAdListener(
        onDismissed: () {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (code, message) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      interstitial.show();
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
    } catch (e) {
      log('Meta show interstitial failed: $e');
      return false;
    }
  }

  @override
  Future<bool> showRewarded(LoadedAd ad, {required Function() onEarned}) async {
    try {
      final rewarded = ad.nativeAd as RewardedAd;
      final completer = Completer<bool>();
      rewarded.listener = RewardedAdListener(
        onVideoComplete: () {
          onEarned();
        },
        onVideoClosed: () {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (code, message) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      rewarded.show();
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => false,
      );
    } catch (e) {
      log('Meta show rewarded failed: $e');
      return false;
    }
  }
}
