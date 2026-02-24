import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Flash sale countdown overlay shown during live stream
class LiveFlashSaleOverlay extends StatelessWidget {
  final LivestreamScreenController controller;

  const LiveFlashSaleOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final product = controller.flashSaleProduct.value;
      if (product == null) return const SizedBox();

      final seconds = controller.flashSaleSecondsLeft.value;
      final discount = controller.flashSaleDiscountPercent.value;
      final productName = product.product?.name ?? '';
      final mins = seconds ~/ 60;
      final secs = seconds % 60;

      return Positioned(
        bottom: 120,
        left: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ShapeDecoration(
            color: ColorRes.likeRed.withValues(alpha: .9),
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.yellow, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FLASH SALE  $discount% OFF',
                      style: TextStyleCustom.unboundedSemiBold600(
                          color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      productName,
                      style: TextStyleCustom.outFitRegular400(
                          color: Colors.white.withValues(alpha: .85),
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                  style: TextStyleCustom.unboundedSemiBold600(
                      color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Giveaway overlay shown during live stream
class LiveGiveawayOverlay extends StatelessWidget {
  final LivestreamScreenController controller;

  const LiveGiveawayOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isGiveawayActive.value) return const SizedBox();

      final prize = controller.giveawayPrize.value;
      final winner = controller.giveawayWinner.value;
      final isPicking = controller.isPickingWinner.value;

      return Positioned(
        top: 100,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C3CE0), Color(0xFFE040FB)],
            ),
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'GIVEAWAY',
                    style: TextStyleCustom.unboundedSemiBold600(
                        color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                prize,
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.white.withValues(alpha: .9), fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (winner != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Winner: @$winner',
                    style: TextStyleCustom.unboundedSemiBold600(
                        color: Colors.yellow, fontSize: 18),
                  ),
                ),
              ] else if (isPicking) ...[
                const SizedBox(height: 12),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Picking winner...',
                  style: TextStyleCustom.outFitRegular400(
                      color: Colors.white, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// Promotional billboard banner overlay
class LivePromoBannerOverlay extends StatelessWidget {
  final LivestreamScreenController controller;

  const LivePromoBannerOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isPromoBannerVisible.value) return const SizedBox();

      return Positioned(
        top: 60,
        left: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ShapeDecoration(
            color: themeAccentSolid(context).withValues(alpha: .9),
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.campaign, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.promoBannerText.value,
                  style: TextStyleCustom.outFitMedium500(
                      color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
