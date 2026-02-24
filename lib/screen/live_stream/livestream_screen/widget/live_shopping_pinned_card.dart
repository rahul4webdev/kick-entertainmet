import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/model/livestream/live_shopping_product.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/color_res.dart';

class LiveShoppingPinnedCard extends StatelessWidget {
  final LiveShoppingProduct item;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const LiveShoppingPinnedCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    if (product == null) return const SizedBox();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(8),
        decoration: ShapeDecoration(
          color: Colors.black.withValues(alpha: .7),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipSmoothRect(
              radius:
                  SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
              child: CachedNetworkImage(
                imageUrl: product.firstImageUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.shopping_bag,
                      color: Colors.white54, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                        color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      Text(
                        '${product.priceCoins ?? 0} coins',
                        style: TextStyleCustom.outFitMedium500(
                            color: ColorRes.orange, fontSize: 12),
                      ),
                      if ((item.unitsSold ?? 0) > 0)
                        Text(
                          '${item.unitsSold} sold',
                          style: TextStyleCustom.outFitLight300(
                              color: Colors.white60, fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAddToCart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: ColorRes.orange,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    const Icon(Icons.add_shopping_cart,
                        color: Colors.white, size: 14),
                    Text(
                      'Add',
                      style: TextStyleCustom.outFitMedium500(
                          color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
