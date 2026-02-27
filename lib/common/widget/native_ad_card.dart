import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shortzz/common/manager/ads/native_ad_manager.dart';
import 'package:shortzz/utilities/theme_res.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _nativeAd;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _nativeAd = NativeAdManager.instance.getAd();
    if (_nativeAd == null) {
      // Ads may still be loading; retry after a delay
      _retryTimer = Timer(const Duration(seconds: 6), () {
        if (mounted && _nativeAd == null) {
          final ad = NativeAdManager.instance.getAd();
          if (ad != null && mounted) {
            setState(() => _nativeAd = ad);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_nativeAd == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgLightGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 100,
          maxHeight: 340,
        ),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
