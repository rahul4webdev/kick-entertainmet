import 'dart:async';
import 'dart:developer';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';
import 'package:shortzz/common/manager/session_manager.dart';

class AppLovinAdapter implements AdNetworkAdapter {
  @override
  AdNetwork get network => AdNetwork.applovin;

  @override
  Future<void> initialize() async {
    try {
      final setting = SessionManager.instance.getSettings();
      final sdkKey = setting?.applovinSdkKey ?? '';
      if (sdkKey.isEmpty) return;
      await AppLovinMAX.initialize(sdkKey);
      log('AppLovin initialized');
    } catch (e) {
      log('AppLovin init failed: $e');
    }
  }

  @override
  Future<LoadedAd?> loadBanner({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final widget = MaxAdView(
        adUnitId: adUnitId,
        adFormat: AdFormat.banner,
      );
      return LoadedAd(
        network: AdNetwork.applovin,
        type: AdType.banner,
        nativeAd: adUnitId,
        bannerWidget: SizedBox(
          height: 50,
          child: widget,
        ),
      );
    } catch (e) {
      log('AppLovin banner failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadInterstitial({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      AppLovinMAX.setInterstitialListener(InterstitialListener(
        onAdLoadedCallback: (ad) {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.applovin,
              type: AdType.interstitial,
              nativeAd: adUnitId,
            ));
          }
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          log('AppLovin interstitial failed: ${error.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
      ));
      AppLovinMAX.loadInterstitial(adUnitId);
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('AppLovin interstitial failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadRewarded({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.applovin,
              type: AdType.rewarded,
              nativeAd: adUnitId,
            ));
          }
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          log('AppLovin rewarded failed: ${error.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
        onAdReceivedRewardCallback: (ad, reward) {},
      ));
      AppLovinMAX.loadRewardedAd(adUnitId);
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('AppLovin rewarded failed: $e');
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
      final adUnitId = ad.nativeAd as String;
      final isReady = await AppLovinMAX.isInterstitialReady(adUnitId) ?? false;
      if (!isReady) return false;
      final completer = Completer<bool>();
      AppLovinMAX.setInterstitialListener(InterstitialListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {},
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          if (!completer.isCompleted) completer.complete(true);
        },
      ));
      AppLovinMAX.showInterstitial(adUnitId);
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
    } catch (e) {
      log('AppLovin show interstitial failed: $e');
      return false;
    }
  }

  @override
  Future<bool> showRewarded(LoadedAd ad, {required Function() onEarned}) async {
    try {
      final adUnitId = ad.nativeAd as String;
      final isReady = await AppLovinMAX.isRewardedAdReady(adUnitId) ?? false;
      if (!isReady) return false;
      final completer = Completer<bool>();
      AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {},
        onAdLoadFailedCallback: (adUnitId, error) {},
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdReceivedRewardCallback: (ad, reward) {
          onEarned();
        },
      ));
      AppLovinMAX.showRewardedAd(adUnitId);
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => false,
      );
    } catch (e) {
      log('AppLovin show rewarded failed: $e');
      return false;
    }
  }
}
