import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/ads/ad_network_adapter.dart';
import 'package:shortzz/common/manager/ads/waterfall_ad_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';

class BannerAdsCustom extends StatefulWidget {
  final double? size;

  const BannerAdsCustom({super.key, this.size});

  @override
  State<BannerAdsCustom> createState() => _BannerAdsCustomState();
}

class _BannerAdsCustomState extends State<BannerAdsCustom> {
  LoadedAd? loadedAd;

  @override
  void initState() {
    getBannerAds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(
        () {
          bool _isSubscribe = isSubscribe.value;
          return !_isSubscribe && loadedAd != null
              ? SafeArea(
                  top: false,
                  child: loadedAd!.bannerWidget ?? const SizedBox(),
                )
              : const SizedBox();
        },
      ),
    );
  }

  void getBannerAds() {
    if (isSubscribe.value) return;
    WaterfallAdManager.instance.loadBannerAd().then((loaded) {
      if (loaded != null && mounted) {
        loadedAd = loaded;
        setState(() {});
      }
    });
  }
}
