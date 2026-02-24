import 'dart:io';

import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/ads/waterfall_ad_manager.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';

class AdsController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    WaterfallAdManager.instance.loadInterstitialAd();
  }

  Future<void> showInterstitialAdIfAvailable({bool isPopScope = false}) async {
    final setting = SessionManager.instance.getSettings();

    final isAdDisabled =
        (Platform.isAndroid && setting?.admobAndroidStatus == 0) ||
            (Platform.isIOS && setting?.admobIosStatus == 0);

    if (isAdDisabled ||
        isSubscribe.value ||
        !WaterfallAdManager.instance.isInterstitialReady) {
      if (!isPopScope) {
        Get.back();
      }
      return;
    }
    if (!isPopScope) {
      Get.back();
    }
    await WaterfallAdManager.instance.showInterstitialAd();
  }
}
