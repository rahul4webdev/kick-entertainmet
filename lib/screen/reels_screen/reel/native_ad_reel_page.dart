import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/ads/native_ad_manager.dart';

class NativeAdReelPage extends StatefulWidget {
  const NativeAdReelPage({super.key});

  @override
  State<NativeAdReelPage> createState() => _NativeAdReelPageState();
}

class _NativeAdReelPageState extends State<NativeAdReelPage> {
  NativeAd? _nativeAd;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _nativeAd = NativeAdManager.instance.getAd();
    if (_nativeAd == null) {
      _adFailed = true;
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // When no ad is available, show a minimal branded placeholder
    // that users can quickly swipe past
    if (_adFailed || _nativeAd == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.swipe_up_rounded,
            color: Colors.white24,
            size: 48,
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: AdWidget(ad: _nativeAd!),
            ),
          ),
        ),
      ),
    );
  }
}
