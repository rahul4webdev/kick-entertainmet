import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsAdapter implements AdNetworkAdapter {
  @override
  AdNetwork get network => AdNetwork.unity;

  @override
  Future<void> initialize() async {
    try {
      final setting = SessionManager.instance.getSettings();
      final gameId = Platform.isAndroid
          ? (setting?.unityGameIdAndroid ?? '')
          : (setting?.unityGameIdIos ?? '');
      if (gameId.isEmpty) return;
      await UnityAds.init(
        gameId: gameId,
        testMode: false,
      );
      log('Unity Ads initialized');
    } catch (e) {
      log('Unity init failed: $e');
    }
  }

  @override
  Future<LoadedAd?> loadBanner({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final widget = UnityBannerAd(
        placementId: adUnitId,
        size: BannerSize.standard,
      );
      return LoadedAd(
        network: AdNetwork.unity,
        type: AdType.banner,
        nativeAd: adUnitId,
        bannerWidget: SizedBox(
          height: 50,
          child: widget,
        ),
      );
    } catch (e) {
      log('Unity banner failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadInterstitial({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      UnityAds.load(
        placementId: adUnitId,
        onComplete: (placementId) {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.unity,
              type: AdType.interstitial,
              nativeAd: placementId,
            ));
          }
        },
        onFailed: (placementId, error, message) {
          log('Unity interstitial failed: $error $message');
          if (!completer.isCompleted) completer.complete(null);
        },
      );
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('Unity interstitial failed: $e');
      return null;
    }
  }

  @override
  Future<LoadedAd?> loadRewarded({required String adUnitId}) async {
    if (adUnitId.isEmpty) return null;
    try {
      final completer = Completer<LoadedAd?>();
      UnityAds.load(
        placementId: adUnitId,
        onComplete: (placementId) {
          if (!completer.isCompleted) {
            completer.complete(LoadedAd(
              network: AdNetwork.unity,
              type: AdType.rewarded,
              nativeAd: placementId,
            ));
          }
        },
        onFailed: (placementId, error, message) {
          log('Unity rewarded failed: $error $message');
          if (!completer.isCompleted) completer.complete(null);
        },
      );
      return completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
    } catch (e) {
      log('Unity rewarded failed: $e');
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
      final placementId = ad.nativeAd as String;
      final completer = Completer<bool>();
      UnityAds.showVideoAd(
        placementId: placementId,
        onComplete: (placementId) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onFailed: (placementId, error, message) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onSkipped: (placementId) {
          if (!completer.isCompleted) completer.complete(true);
        },
      );
      return completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => false,
      );
    } catch (e) {
      log('Unity show interstitial failed: $e');
      return false;
    }
  }

  @override
  Future<bool> showRewarded(LoadedAd ad, {required Function() onEarned}) async {
    try {
      final placementId = ad.nativeAd as String;
      final completer = Completer<bool>();
      UnityAds.showVideoAd(
        placementId: placementId,
        onComplete: (placementId) {
          onEarned();
          if (!completer.isCompleted) completer.complete(true);
        },
        onFailed: (placementId, error, message) {
          if (!completer.isCompleted) completer.complete(false);
        },
        onSkipped: (placementId) {
          if (!completer.isCompleted) completer.complete(true);
        },
      );
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => false,
      );
    } catch (e) {
      log('Unity show rewarded failed: $e');
      return false;
    }
  }
}
