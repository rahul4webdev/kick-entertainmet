import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/cart/cart_model.dart';
import 'package:shortzz/screen/cart_screen/cart_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          LKey.myCart,
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox();
            return IconButton(
              onPressed: () => _showClearCartDialog(context, controller),
              icon: Icon(Icons.delete_sweep_outlined,
                  color: textLightGrey(context)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCart.value && controller.cartItems.isEmpty) {
          return const LoaderWidget();
        }
        return NoDataView(
          showShow: !controller.isLoadingCart.value &&
              controller.cartItems.isEmpty,
          title: LKey.cartEmpty,
          description: LKey.cartEmptyDesc,
          child: RefreshIndicator(
            onRefresh: () async => controller.fetchCart(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: controller.cartItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _CartItemRow(
                  item: controller.cartItems[index],
                  controller: controller,
                );
              },
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.cartItems.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scaffoldBackgroundColor(context),
              boxShadow: [
                BoxShadow(
                  color: blackPure(context).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${LKey.cartTotal}:',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 16),
                    ),
                    Row(
                      children: [
                        Icon(Icons.monetization_on_outlined,
                            size: 20, color: themeAccentSolid(context)),
                        const SizedBox(width: 4),
                        Text(
                          '${controller.totalCoins.value}',
                          style: TextStyleCustom.unboundedSemiBold600(
                              fontSize: 20,
                              color: themeAccentSolid(context)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: controller.goToCheckout,
                  child: Container(
                    height: 50,
                    decoration: ShapeDecoration(
                      color: themeAccentSolid(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 14, cornerSmoothing: 1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        LKey.proceedToCheckout,
                        style: TextStyleCustom.outFitMedium500(
                            color: whitePure(context), fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showClearCartDialog(BuildContext context, CartController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(LKey.clearCartTitle),
        content: Text(LKey.clearCartDesc),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text(LKey.cancel)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            child: Text(LKey.clearCartTitle,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final CartController controller;

  const _CartItemRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: ShapeDecoration(
          color: Colors.red.withValues(alpha: .1),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (_) => controller.removeItem(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            // Product image
            ClipSmoothRect(
              radius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
              child: SizedBox(
                width: 70,
                height: 70,
                child: product != null && product.firstImageUrl.isNotEmpty
                    ? Image.network(product.firstImageUrl, fit: BoxFit.cover)
                    : Container(
                        color: bgMediumGrey(context),
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 28, color: textLightGrey(context)),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.monetization_on_outlined,
                          size: 14, color: themeAccentSolid(context)),
                      const SizedBox(width: 3),
                      Text(
                        '${product?.priceCoins ?? 0}',
                        style: TextStyleCustom.outFitMedium500(
                            color: themeAccentSolid(context), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () => controller.updateQuantity(
                            item, (item.quantity ?? 1) - 1),
                        context: context,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity ?? 1}',
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 15),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => controller.updateQuantity(
                            item, (item.quantity ?? 1) + 1),
                        context: context,
                      ),
                      const Spacer(),
                      Text(
                        '${item.itemTotal}',
                        style: TextStyleCustom.unboundedSemiBold600(
                            color: textDarkGrey(context), fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final BuildContext context;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: ShapeDecoration(
          color: bgMediumGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
          ),
        ),
        child: Icon(icon, size: 16, color: textDarkGrey(context)),
      ),
    );
  }
}
