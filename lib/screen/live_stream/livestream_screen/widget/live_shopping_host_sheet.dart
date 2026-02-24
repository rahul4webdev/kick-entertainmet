import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/live_shopping_product.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveShoppingHostSheet extends StatefulWidget {
  final LivestreamScreenController controller;

  const LiveShoppingHostSheet({super.key, required this.controller});

  @override
  State<LiveShoppingHostSheet> createState() => _LiveShoppingHostSheetState();
}

class _LiveShoppingHostSheetState extends State<LiveShoppingHostSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.controller.fetchMyProductsForLive();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.7,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.storefront, size: 20),
                const SizedBox(width: 8),
                Text(
                  LKey.manageProducts,
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
          TabBar(
            controller: _tabController,
            labelColor: textDarkGrey(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: ColorRes.themeAccentSolid,
            labelStyle:
                TextStyleCustom.outFitMedium500(fontSize: 14),
            tabs: [
              Tab(text: LKey.liveProducts),
              Tab(text: LKey.addProductToLive),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _LiveProductsTab(controller: widget.controller),
                _AddProductsTab(controller: widget.controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 1: Currently added live products (with pin/remove)
class _LiveProductsTab extends StatelessWidget {
  final LivestreamScreenController controller;

  const _LiveProductsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = products[index];
          return _HostProductRow(item: item, controller: controller);
        },
      );
    });
  }
}

class _HostProductRow extends StatelessWidget {
  final LiveShoppingProduct item;
  final LivestreamScreenController controller;

  const _HostProductRow({required this.item, required this.controller});

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
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 48,
                height: 48,
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
                Text(
                  product.name ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.priceCoins ?? 0} coins  •  ${item.unitsSold ?? 0} ${LKey.unitsSold}',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
              ],
            ),
          ),
          // Pin button
          GestureDetector(
            onTap: () => controller.togglePinProduct(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 18,
                color: isPinned ? ColorRes.orange : textLightGrey(context),
              ),
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: () =>
                controller.removeProductFromLive(product.id ?? 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.remove_circle_outline,
                  size: 18, color: ColorRes.likeRed),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Select from own products to add
class _AddProductsTab extends StatelessWidget {
  final LivestreamScreenController controller;

  const _AddProductsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final myProducts = controller.myProducts;
      if (myProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 48, color: textLightGrey(context)),
              const SizedBox(height: 12),
              Text(
                LKey.noProductsToAdd,
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                LKey.noProductsToAddDesc,
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 13),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: myProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final product = myProducts[index];
          final isAlreadyAdded = controller.liveShoppingProducts
              .any((p) => p.productId == product.id);

          return _AddProductRow(
            product: product,
            isAlreadyAdded: isAlreadyAdded,
            onAdd: () => controller.addProductToLive(product.id ?? 0),
          );
        },
      );
    });
  }
}

class _AddProductRow extends StatelessWidget {
  final Product product;
  final bool isAlreadyAdded;
  final VoidCallback onAdd;

  const _AddProductRow({
    required this.product,
    required this.isAlreadyAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          ClipSmoothRect(
            radius: SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
            child: CachedNetworkImage(
              imageUrl: product.firstImageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 48,
                height: 48,
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
                Text(
                  product.name ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.priceCoins ?? 0} coins',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
              ],
            ),
          ),
          if (isAlreadyAdded)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(
                color: ColorRes.green.withValues(alpha: .1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 8, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                'Added',
                style: TextStyleCustom.outFitMedium500(
                    color: ColorRes.green, fontSize: 12),
              ),
            )
          else
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: ShapeDecoration(
                  color: ColorRes.themeAccentSolid,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  '+ Add',
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
