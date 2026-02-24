import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/ads/waterfall_ad_manager.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/monetization_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/gift_wallet/rewarded_ad_claim_model.dart';
import 'package:shortzz/screen/coin_wallet_screen/coin_wallet_screen_controller.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class RewardedAdButton extends StatefulWidget {
  const RewardedAdButton({super.key});

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  int? remainingAds;
  bool isClaiming = false;

  Setting? get settings => SessionManager.instance.getSettings();
  int get maxAds => settings?.maxRewardedAdsDaily ?? 10;
  int get rewardCoins => settings?.rewardCoinsPerAd ?? 5;

  @override
  void initState() {
    super.initState();
    remainingAds = maxAds;
    WaterfallAdManager.instance.loadRewardedAd();
  }

  void _onWatchAd() {
    if (isClaiming) return;
    if (remainingAds != null && remainingAds! <= 0) return;

    WaterfallAdManager.instance.showRewardedAd(onEarned: () async {
      setState(() => isClaiming = true);
      try {
        RewardedAdClaimModel response =
            await MonetizationService.instance.claimRewardedAd();
        if (response.status == true && response.data != null) {
          setState(() {
            remainingAds = response.data!.remainingAdsToday;
          });
          if (response.data!.user != null) {
            SessionManager.instance.setUser(response.data!.user);
            final walletController =
                Get.find<CoinWalletScreenController>();
            walletController.fetchData();
          }
        }
      } catch (_) {}
      setState(() => isClaiming = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasAdsRemaining = remainingAds != null && remainingAds! > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: InkWell(
        onTap: hasAdsRemaining ? _onWatchAd : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
            ),
            gradient: hasAdsRemaining
                ? StyleRes.themeGradient
                : null,
            color: hasAdsRemaining ? null : bgGrey(context),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                color: hasAdsRemaining
                    ? whitePure(context)
                    : textLightGrey(context),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAdsRemaining
                          ? LKey.watchAdEarnCoins
                              .trParams({'count': '$rewardCoins'})
                          : LKey.dailyLimitReached.tr,
                      style: TextStyleCustom.outFitMedium500(
                        color: hasAdsRemaining
                            ? whitePure(context)
                            : textLightGrey(context),
                        fontSize: 15,
                      ),
                    ),
                    if (hasAdsRemaining)
                      Text(
                        LKey.adsRemainingToday
                            .trParams({'count': '$remainingAds'}),
                        style: TextStyleCustom.outFitLight300(
                          color: whitePure(context).withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                  ],
                ),
              ),
              if (isClaiming)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: whitePure(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
