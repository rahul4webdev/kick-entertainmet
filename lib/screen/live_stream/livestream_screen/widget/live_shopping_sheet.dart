import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/live_shopping_product.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveShoppingSheet extends StatelessWidget {
  final LivestreamScreenController controller;

  const LiveShoppingSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  LKey.liveProducts,
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 18, color: textDarkGrey(context)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close,
                      color: textLightGrey(context), size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingShoppingProducts.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final products = controller.liveShoppingProducts;
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 48, color: textLightGrey(context)),
                      const SizedBox(height: 12),
                      Text(
                        LKey.noLiveProducts,
                        style: TextStyleCustom.outFitMedium500(
                            color: textDarkGrey(context), fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        LKey.noLiveProductsDesc,
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = products[index];
                  return _ProductRow(
                    item: item,
                    controller: controller,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final LiveShoppingProduct item;
  final LivestreamScreenController controller;

  const _ProductRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    if (product == null) return const SizedBox();
    final isPinned = item.isPinned == true;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: isPinned
            ? ColorRes.orange.withValues(alpha: .06)
            : bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          side: isPinned
              ? BorderSide(color: ColorRes.orange.withValues(alpha: .3))
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          ClipSmoothRect(
            radius: SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
            child: CachedNetworkImage(
              imageUrl: product.firstImageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isPinned) ...[
                      Icon(Icons.push_pin,
                          size: 12, color: ColorRes.orange),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: Text(
                        product.name ?? '',
                        style: TextStyleCustom.outFitMedium500(
                            color: textDarkGrey(context), fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      '${product.priceCoins ?? 0} coins',
                      style: TextStyleCustom.outFitMedium500(
                          color: ColorRes.orange, fontSize: 13),
                    ),
                    if ((item.unitsSold ?? 0) > 0)
                      Text(
                        '${item.unitsSold} ${LKey.unitsSold}',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              controller.addToCartFromLive(product.id ?? 0);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: ShapeDecoration(
                color: ColorRes.orange,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 8, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                LKey.addToCart,
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
