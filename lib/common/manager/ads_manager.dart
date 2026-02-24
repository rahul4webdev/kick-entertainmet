import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/ads/waterfall_ad_manager.dart';

class AdsManager {
  AdsManager._();

  static final instance = AdsManager._();

  /// Legacy API — delegates to WaterfallAdManager
  void loadBannerAd({required Function(Ad) onAdLoaded}) async {
    final loaded = await WaterfallAdManager.instance.loadBannerAd();
    if (loaded != null && loaded.nativeAd != null) {
      onAdLoaded(loaded.nativeAd);
    }
  }

  /// Legacy API — delegates to WaterfallAdManager
  Future<void> loadInterstitialAd(
      {required Function(InterstitialAd) onAdLoaded}) async {
    await WaterfallAdManager.instance.loadInterstitialAd();
  }

  void loadRewardedAd() {
    WaterfallAdManager.instance.loadRewardedAd();
  }

  void showRewardedAd({required Function() onEarned}) {
    WaterfallAdManager.instance.showRewardedAd(onEarned: onEarned);
  }

  bool get isRewardedAdReady => WaterfallAdManager.instance.isRewardedAdReady;

  void requestConsentInfoUpdate() {
    final params = ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
            debugGeography: DebugGeography.debugGeographyEea,
            testIdentifiers: ['D5E5A833CA124D2CD5E33A574AF9EA88']));
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          loadForm();
        }
      },
      (FormError error) {
        // Handle the error
      },
    );
  }

  void loadForm() {
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        var status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((formError) {
            loadForm();
          });
        }
      },
      (FormError formError) {
        // Handle the error
      },
    );
  }
}
