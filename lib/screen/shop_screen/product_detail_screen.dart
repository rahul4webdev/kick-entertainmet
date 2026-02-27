import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/common/service/api/cart_service.dart';
import 'package:shortzz/common/service/api/product_service.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? detail;
  bool isLoading = true;
  int currentImageIndex = 0;
  ProductVariant? selectedVariant;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await ProductService.instance.fetchProductById(
        productId: widget.product.id!,
      );
      if (response.status == true && response.data != null) {
        setState(() {
          detail = response.data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = detail ?? widget.product;
    final images = product.imageUrls ?? [];

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          product.name ?? '',
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 16, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image carousel
                  if (images.isNotEmpty)
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (i) =>
                            setState(() => currentImageIndex = i),
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: 320,
                      width: double.infinity,
                      color: bgMediumGrey(context),
                      child: Icon(Icons.shopping_bag_outlined,
                          size: 80, color: textLightGrey(context)),
                    ),

                  // Image indicators
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (i) => Container(
                            width: i == currentImageIndex ? 20 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: i == currentImageIndex
                                  ? themeAccentSolid(context)
                                  : textLightGrey(context)
                                      .withValues(alpha: .3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          product.name ?? '',
                          style: TextStyleCustom.unboundedMedium500(
                              fontSize: 20, color: textDarkGrey(context)),
                        ),
                        const SizedBox(height: 8),

                        // Price row — INR pricing
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _displayPrice(product),
                              style: TextStyleCustom.unboundedSemiBold600(
                                  fontSize: 22,
                                  color: themeAccentSolid(context)),
                            ),
                            if (product.formattedCompareAtPrice != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                product.formattedCompareAtPrice!,
                                style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context),
                                  fontSize: 14,
                                ).copyWith(
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                            if (product.discountPercent != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.discountPercent}% off',
                                  style: TextStyleCustom.outFitMedium500(
                                      color: Colors.green, fontSize: 11),
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (product.soldCount != null &&
                                product.soldCount! > 0)
                              Text(
                                '${product.soldCount} ${LKey.soldCount}',
                                style: TextStyleCustom.outFitLight300(
                                    color: textLightGrey(context),
                                    fontSize: 13),
                              ),
                          ],
                        ),

                        // Shipping & COD info
                        if (product.pricePaise != null &&
                            product.pricePaise! > 0) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            children: [
                              if (product.shippingChargeRupees != null &&
                                  product.shippingChargeRupees! > 0)
                                Text(
                                  '+ ₹${product.shippingChargeRupees!.toStringAsFixed(0)} shipping',
                                  style: TextStyleCustom.outFitLight300(
                                      color: textLightGrey(context),
                                      fontSize: 12),
                                )
                              else
                                Text(
                                  'Free Shipping',
                                  style: TextStyleCustom.outFitLight300(
                                      color: Colors.green, fontSize: 12),
                                ),
                              if (product.codAvailable == true)
                                Text(
                                  'COD Available',
                                  style: TextStyleCustom.outFitLight300(
                                      color: Colors.green, fontSize: 12),
                                ),
                              if (product.isReturnable == true)
                                Text(
                                  '${product.returnWindowDays ?? 7} day returns',
                                  style: TextStyleCustom.outFitLight300(
                                      color: Colors.blue, fontSize: 12),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),

                        // Variant selector
                        if (product.hasVariants == true &&
                            product.variants != null &&
                            product.variants!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Select Variant',
                            style: TextStyleCustom.outFitMedium500(
                                color: textDarkGrey(context), fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                product.variants!.map((variant) {
                              final isSelected =
                                  selectedVariant?.id == variant.id;
                              final label = [
                                if (variant.size != null) variant.size,
                                if (variant.color != null) variant.color,
                              ].join(' / ');
                              final outOfStock =
                                  variant.stock != null && variant.stock! <= 0;
                              return GestureDetector(
                                onTap: outOfStock
                                    ? null
                                    : () => setState(
                                        () => selectedVariant = variant),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: ShapeDecoration(
                                    color: outOfStock
                                        ? bgMediumGrey(context)
                                        : isSelected
                                            ? themeAccentSolid(context)
                                                .withValues(alpha: .1)
                                            : bgLightGrey(context),
                                    shape: SmoothRectangleBorder(
                                      borderRadius: SmoothBorderRadius(
                                          cornerRadius: 10,
                                          cornerSmoothing: 1),
                                      side: BorderSide(
                                        color: isSelected
                                            ? themeAccentSolid(context)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        label.isNotEmpty ? label : 'Option',
                                        style: TextStyleCustom.outFitMedium500(
                                          color: outOfStock
                                              ? textLightGrey(context)
                                              : isSelected
                                                  ? themeAccentSolid(context)
                                                  : textDarkGrey(context),
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (variant.priceRupees != null &&
                                          variant.priceRupees! > 0)
                                        Text(
                                          '₹${variant.priceRupees!.toStringAsFixed(variant.priceRupees!.truncateToDouble() == variant.priceRupees! ? 0 : 2)}',
                                          style:
                                              TextStyleCustom.outFitLight300(
                                            color: outOfStock
                                                ? textLightGrey(context)
                                                : themeAccentSolid(context),
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (outOfStock)
                                        Text(
                                          'Out of stock',
                                          style:
                                              TextStyleCustom.outFitLight300(
                                                  color: Colors.red,
                                                  fontSize: 10),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 4),
                        ],

                        // Brand
                        if (product.brandName != null &&
                            product.brandName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.business_outlined,
                                  size: 14, color: textLightGrey(context)),
                              const SizedBox(width: 4),
                              Text(
                                product.brandName!,
                                style: TextStyleCustom.outFitLight300(
                                    color: textLightGrey(context),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),

                        // Stock info
                        Text(
                          product.isUnlimitedStock
                              ? LKey.unlimitedStock
                              : product.isInStock
                                  ? '${LKey.inStock} (${product.stock})'
                                  : LKey.outOfStock,
                          style: TextStyleCustom.outFitLight300(
                            color: product.isInStock
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Seller info
                        if (product.sellerInfo != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: ShapeDecoration(
                              color: bgLightGrey(context),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                    cornerRadius: 12, cornerSmoothing: 1),
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomImage(
                                  size: const Size(36, 36),
                                  image: product.sellerInfo?.profilePhoto
                                      ?.addBaseURL(),
                                  fullName: product.sellerInfo?.fullname,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          product.sellerInfo?.fullname ?? '',
                                          style: TextStyleCustom
                                              .outFitMedium500(
                                                  color:
                                                      textDarkGrey(context),
                                                  fontSize: 14),
                                        ),
                                        if (product.sellerInfo?.isVerify ==
                                            1) ...[
                                          const SizedBox(width: 4),
                                          Icon(Icons.verified,
                                              size: 14,
                                              color:
                                                  themeAccentSolid(context)),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '@${product.sellerInfo?.username ?? ''}',
                                      style:
                                          TextStyleCustom.outFitLight300(
                                              color: textLightGrey(context),
                                              fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Category
                        if (product.categoryName != null) ...[
                          Row(
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 16, color: textLightGrey(context)),
                              const SizedBox(width: 6),
                              Text(
                                product.categoryName!,
                                style: TextStyleCustom.outFitLight300(
                                    color: textLightGrey(context),
                                    fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description
                        if (product.description != null &&
                            product.description!.isNotEmpty) ...[
                          Text(
                            LKey.productDescription,
                            style: TextStyleCustom.outFitMedium500(
                                color: textDarkGrey(context), fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.description!,
                            style: TextStyleCustom.outFitRegular400(
                                color: textLightGrey(context), fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Rating summary
                        if (detail?.reviewSummary != null &&
                            (detail!.reviewSummary!.total ?? 0) > 0) ...[
                          _RatingSummary(summary: detail!.reviewSummary!),
                          const SizedBox(height: 16),
                        ],

                        // Recent reviews
                        if (detail?.recentReviews != null &&
                            detail!.recentReviews!.isNotEmpty) ...[
                          Text(
                            LKey.reviews,
                            style: TextStyleCustom.outFitMedium500(
                                color: textDarkGrey(context), fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          ...detail!.recentReviews!
                              .map((r) => _ReviewCard(review: r)),
                        ],

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: product.isInStock
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Add to Cart button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _addToCart(product),
                        child: Container(
                          height: 50,
                          decoration: ShapeDecoration(
                            color: bgMediumGrey(context),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 14, cornerSmoothing: 1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined,
                                  size: 18, color: textDarkGrey(context)),
                              const SizedBox(width: 6),
                              Text(
                                LKey.addToCart,
                                style: TextStyleCustom.outFitMedium500(
                                    color: textDarkGrey(context), fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Buy Now button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showPurchaseConfirm(context, product),
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
                              '${LKey.buyNow} - ${_displayPrice(product)}',
                              style: TextStyleCustom.outFitMedium500(
                                  color: whitePure(context), fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  String _displayPrice(Product product) {
    if (selectedVariant != null &&
        selectedVariant!.priceRupees != null &&
        selectedVariant!.priceRupees! > 0) {
      final r = selectedVariant!.priceRupees!;
      return '₹${r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 2)}';
    }
    if (product.pricePaise != null && product.pricePaise! > 0) {
      return product.formattedPrice;
    }
    return '${product.priceCoins ?? 0} ${LKey.coinsText}';
  }

  Future<void> _addToCart(Product product) async {
    if (product.hasVariants == true &&
        product.variants != null &&
        product.variants!.isNotEmpty &&
        selectedVariant == null) {
      Get.snackbar('Select Variant', 'Please select a variant first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      final response = await CartService.instance.addToCart(
        productId: product.id!,
        variantId: selectedVariant?.id,
      );
      if (response.status == true) {
        Get.snackbar(LKey.addedToCart, '',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar(
            LKey.error, response.message ?? LKey.somethingWentWrong,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar(LKey.error, LKey.somethingWentWrong,
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showPurchaseConfirm(BuildContext context, Product product) {
    if (product.hasVariants == true &&
        product.variants != null &&
        product.variants!.isNotEmpty &&
        selectedVariant == null) {
      Get.snackbar('Select Variant', 'Please select a variant first',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // For INR-priced products, add to cart and go to checkout
    if (product.pricePaise != null && product.pricePaise! > 0) {
      _addToCart(product).then((_) {
        Get.toNamed('/cart');
      });
      return;
    }

    // Coin-based purchase (legacy)
    Get.dialog(
      AlertDialog(
        title: Text(LKey.confirmPurchase),
        content: Text(
            'Buy "${product.name}" for ${product.priceCoins} ${LKey.coinsText}?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              final response = await ProductService.instance.purchaseProduct(
                productId: product.id!,
              );
              if (response.status == true) {
                Get.snackbar(LKey.purchaseSuccessful, '',
                    snackPosition: SnackPosition.BOTTOM);
                _fetchDetail();
              } else {
                Get.snackbar(
                    LKey.error, response.message ?? LKey.somethingWentWrong,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text(LKey.buyNow),
          ),
        ],
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  final ReviewSummary summary;
  const _RatingSummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, size: 20, color: Colors.amber[700]),
        const SizedBox(width: 4),
        Text(
          '${summary.average?.toStringAsFixed(1) ?? '0'}',
          style: TextStyleCustom.unboundedSemiBold600(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        const SizedBox(width: 6),
        Text(
          '(${summary.total ?? 0} ${LKey.reviews})',
          style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context), fontSize: 13),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ProductReview review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (review.reviewer != null)
                CustomImage(
                  size: const Size(24, 24),
                  image: review.reviewer?.profilePhoto?.addBaseURL(),
                  fullName: review.reviewer?.fullname,
                ),
              const SizedBox(width: 8),
              Text(
                review.reviewer?.username ?? '',
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 13),
              ),
              const Spacer(),
              // Stars
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (review.rating ?? 0) ? Icons.star : Icons.star_border,
                    size: 14,
                    color: Colors.amber[700],
                  ),
                ),
              ),
            ],
          ),
          if (review.isVerifiedPurchase == true) ...[
            const SizedBox(height: 4),
            Text(
              LKey.verifiedPurchase,
              style: TextStyleCustom.outFitLight300(
                  color: Colors.green, fontSize: 10),
            ),
          ],
          if (review.reviewText != null &&
              review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              review.reviewText!,
              style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
