import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/cart_screen/cart_screen.dart';
import 'package:shortzz/screen/seller_kyc_screen/seller_kyc_screen.dart';
import 'package:shortzz/screen/shop_screen/shop_controller.dart';
import 'package:shortzz/screen/shop_screen/product_detail_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopController());
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackButton(
            image: AssetRes.icBackArrow_1,
            height: 25,
            width: 25,
            padding: EdgeInsets.zero,
          ),
          title: Text(
            LKey.shop,
            style: TextStyleCustom.unboundedMedium500(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => Get.to(() => const CartScreen()),
              icon: Icon(Icons.shopping_cart_outlined,
                  color: textDarkGrey(context)),
            ),
          ],
          bottom: TabBar(
            labelStyle: TextStyleCustom.outFitMedium500(fontSize: 13),
            unselectedLabelStyle:
                TextStyleCustom.outFitRegular400(fontSize: 13),
            labelColor: themeAccentSolid(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: themeAccentSolid(context),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: LKey.browseProducts),
              Tab(text: LKey.myProducts),
              Tab(text: LKey.myOrdersBuyer),
              Tab(text: LKey.sellerOrders),
            ],
            onTap: (index) {
              if (index == 1 && controller.myProducts.isEmpty) {
                controller.fetchMyProducts();
              } else if (index == 2 && controller.myOrders.isEmpty) {
                controller.fetchMyOrders();
              } else if (index == 3 && controller.sellerOrders.isEmpty) {
                controller.fetchSellerOrders();
              }
            },
          ),
        ),
        body: TabBarView(
          children: [
            _BrowseTab(controller: controller),
            _MyProductsTab(controller: controller),
            _MyOrdersTab(controller: controller),
            _SellerOrdersTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─── Browse Tab ─────────────────────────────────────────────

class _BrowseTab extends StatelessWidget {
  final ShopController controller;
  const _BrowseTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSearchActive = controller.searchQuery.value.isNotEmpty;

      if (!isSearchActive &&
          controller.isLoadingProducts.value &&
          controller.products.isEmpty) {
        return const LoaderWidget();
      }

      return Column(
        children: [
          // Search bar
          _SearchBar(controller: controller),
          // Category filter chips
          _CategoryFilterBar(controller: controller),
          // Content
          Expanded(
            child: isSearchActive
                ? _SearchResults(controller: controller)
                : _BrowseContent(controller: controller),
          ),
        ],
      );
    });
  }
}

class _SearchBar extends StatelessWidget {
  final ShopController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Container(
        height: 40,
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, size: 20, color: textLightGrey(context)),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: LKey.searchProducts,
                  hintStyle: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyleCustom.outFitRegular400(
                    color: textDarkGrey(context), fontSize: 13),
                onSubmitted: controller.onSearchSubmitted,
                textInputAction: TextInputAction.search,
              ),
            ),
            Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: controller.clearSearch,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close,
                      size: 18, color: textLightGrey(context)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final ShopController controller;
  const _SearchResults({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isSearching.value && controller.searchResults.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isSearching.value &&
            controller.searchResults.isEmpty,
        title: LKey.noProducts,
        description: LKey.noProductsDesc,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            return _ProductCard(product: controller.searchResults[index]);
          },
        ),
      );
    });
  }
}

class _BrowseContent extends StatelessWidget {
  final ShopController controller;
  const _BrowseContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return NoDataView(
      showShow: !controller.isLoadingProducts.value &&
          controller.products.isEmpty,
      title: LKey.noProducts,
      description: LKey.noProductsDesc,
      child: RefreshIndicator(
        onRefresh: () async {
          controller.fetchProducts(reset: true);
          controller.fetchFeaturedProducts();
        },
        child: CustomScrollView(
          slivers: [
            // Featured products carousel
            Obx(() {
              if (controller.featuredProducts.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: _FeaturedCarousel(
                  title: LKey.featured,
                  products: controller.featuredProducts,
                ),
              );
            }),
            // Trending products
            Obx(() {
              if (controller.trendingProducts.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: _FeaturedCarousel(
                  title: LKey.trending,
                  products: controller.trendingProducts,
                ),
              );
            }),
            // All products heading
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                child: Text(
                  LKey.allProducts,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 15),
                ),
              ),
            ),
            // Product grid
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _ProductCard(
                      product: controller.products[index],
                    );
                  },
                  childCount: controller.products.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  final String title;
  final List<Product> products;
  const _FeaturedCarousel({required this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Text(
            title,
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 15),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () =>
                    Get.to(() => ProductDetailScreen(product: product)),
                child: Container(
                  width: 140,
                  decoration: ShapeDecoration(
                    color: bgLightGrey(context),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 14, cornerSmoothing: 1),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: product.firstImageUrl.isNotEmpty
                              ? Image.network(product.firstImageUrl,
                                  fit: BoxFit.cover)
                              : Container(
                                  color: bgMediumGrey(context),
                                  child: Icon(Icons.shopping_bag_outlined,
                                      size: 30,
                                      color: textLightGrey(context)),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name ?? '',
                              style: TextStyleCustom.outFitMedium500(
                                  color: textDarkGrey(context),
                                  fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.pricePaise != null && product.pricePaise! > 0
                                  ? product.formattedPrice
                                  : '${product.priceCoins ?? 0} coins',
                              style: TextStyleCustom.outFitMedium500(
                                  color: themeAccentSolid(context),
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  final ShopController controller;
  const _CategoryFilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) return const SizedBox();
      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: [
            _FilterChip(
              label: LKey.allCategories,
              isSelected: controller.selectedCategoryId.value == null,
              onTap: () => controller.onCategoryChanged(null),
              context: context,
            ),
            ...controller.categories.map((cat) => _FilterChip(
                  label: cat.name ?? '',
                  isSelected:
                      controller.selectedCategoryId.value == cat.id,
                  onTap: () => controller.onCategoryChanged(cat.id),
                  context: context,
                )),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BuildContext context;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: ShapeDecoration(
          color: isSelected
              ? themeAccentSolid(context)
              : bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 12,
            color: isSelected ? whitePure(context) : textDarkGrey(context),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(product: product));
      },
      child: Container(
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: product.firstImageUrl.isNotEmpty
                    ? Image.network(product.firstImageUrl, fit: BoxFit.cover)
                    : Container(
                        color: bgMediumGrey(context),
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 40, color: textLightGrey(context)),
                      ),
              ),
            ),
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Rating
                    if (product.ratingCount != null &&
                        product.ratingCount! > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                size: 12, color: Colors.amber[700]),
                            const SizedBox(width: 3),
                            Text(
                              '${product.avgRating?.toStringAsFixed(1)} (${product.ratingCount})',
                              style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.pricePaise != null && product.pricePaise! > 0
                                ? product.formattedPrice
                                : '${product.priceCoins ?? 0} coins',
                            style: TextStyleCustom.outFitMedium500(
                                color: themeAccentSolid(context),
                                fontSize: 14),
                          ),
                        ),
                        if (product.soldCount != null &&
                            product.soldCount! > 0)
                          Text(
                            '${product.soldCount} ${LKey.soldCount}',
                            style: TextStyleCustom.outFitLight300(
                                color: textLightGrey(context), fontSize: 10),
                          ),
                      ],
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

// ─── My Products Tab ────────────────────────────────────────

class _MyProductsTab extends StatelessWidget {
  final ShopController controller;
  const _MyProductsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.getUser();
    if (user?.isApprovedSeller != true) {
      return _SellerKycPrompt();
    }
    return Obx(() {
      if (controller.isLoadingMyProducts.value &&
          controller.myProducts.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isLoadingMyProducts.value &&
            controller.myProducts.isEmpty,
        title: LKey.noMyProducts,
        description: LKey.noMyProductsDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchMyProducts(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _MyProductRow(
                product: controller.myProducts[index],
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }
}

class _MyProductRow extends StatelessWidget {
  final Product product;
  final ShopController controller;

  const _MyProductRow({required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: product.firstImageUrl.isNotEmpty
                ? Image.network(product.firstImageUrl, fit: BoxFit.cover)
                : Container(
                    color: bgMediumGrey(context),
                    child: Icon(Icons.shopping_bag_outlined,
                        size: 30, color: textLightGrey(context)),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusBadge(product: product),
                      const SizedBox(width: 8),
                      Text(
                        product.pricePaise != null && product.pricePaise! > 0
                            ? product.formattedPrice
                            : '${product.priceCoins ?? 0} ${LKey.coinsText}',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        '${product.soldCount ?? 0} ${LKey.soldCount}',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                color: Colors.red.withValues(alpha: .7), size: 20),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Delete Product?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteProduct(product.id!);
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Product product;
  const _StatusBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final color = product.isApproved
        ? Colors.green
        : product.isPending
            ? Colors.orange
            : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .1),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 6, cornerSmoothing: 1),
        ),
      ),
      child: Text(product.statusLabel,
          style:
              TextStyleCustom.outFitMedium500(color: color, fontSize: 10)),
    );
  }
}

// ─── My Orders Tab ──────────────────────────────────────────

class _MyOrdersTab extends StatelessWidget {
  final ShopController controller;
  const _MyOrdersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOrders.value && controller.myOrders.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isLoadingOrders.value &&
            controller.myOrders.isEmpty,
        title: LKey.noOrders,
        description: LKey.noOrdersDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchMyOrders(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _OrderRow(order: controller.myOrders[index]);
            },
          ),
        ),
      );
    });
  }
}

class _OrderRow extends StatelessWidget {
  final ProductOrder order;
  final bool isSeller;

  const _OrderRow({required this.order, this.isSeller = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (order.status) {
      0 => Colors.orange,
      1 => Colors.blue,
      2 => Colors.indigo,
      3 => Colors.green,
      4 => Colors.red,
      5 => Colors.grey,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product image
              if (order.product != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: order.product!.firstImageUrl.isNotEmpty
                        ? Image.network(order.product!.firstImageUrl,
                            fit: BoxFit.cover)
                        : Container(
                            color: bgMediumGrey(context),
                            child: Icon(Icons.shopping_bag_outlined,
                                size: 20, color: textLightGrey(context)),
                          ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.product?.name ?? 'Product',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.totalAmountPaise != null && order.totalAmountPaise! > 0
                          ? '₹${(order.totalAmountPaise! / 100.0).toStringAsFixed(2)} x${order.quantity ?? 1}'
                          : '${order.totalCoins ?? 0} ${LKey.coinsText} x${order.quantity ?? 1}',
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: .1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyleCustom.outFitMedium500(
                      color: statusColor, fontSize: 11),
                ),
              ),
            ],
          ),
          if (order.trackingNumber != null) ...[
            const SizedBox(height: 8),
            Text(
              'Tracking: ${order.trackingNumber}',
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Seller Orders Tab ──────────────────────────────────────

class _SellerOrdersTab extends StatelessWidget {
  final ShopController controller;
  const _SellerOrdersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = SessionManager.instance.getUser();
    if (user?.isApprovedSeller != true) {
      return _SellerKycPrompt();
    }
    return Obx(() {
      if (controller.isLoadingSellerOrders.value &&
          controller.sellerOrders.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isLoadingSellerOrders.value &&
            controller.sellerOrders.isEmpty,
        title: LKey.noSellerOrders,
        description: LKey.noSellerOrdersDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchSellerOrders(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.sellerOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final order = controller.sellerOrders[index];
              return _SellerOrderRow(
                order: order,
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }
}

class _SellerOrderRow extends StatelessWidget {
  final ProductOrder order;
  final ShopController controller;

  const _SellerOrderRow(
      {required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderRow(order: order, isSeller: true),
          if (order.buyer != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                CustomImage(
                  size: const Size(20, 20),
                  image: order.buyer?.profilePhoto?.addBaseURL(),
                  fullName: order.buyer?.fullname,
                ),
                const SizedBox(width: 6),
                Text(
                  'Buyer: ${order.buyer?.username ?? ''}',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
              ],
            ),
          ],
          if (order.status == 0 || order.status == 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 0) ...[
                  _ActionButton(
                    label: LKey.confirmOrder,
                    color: Colors.blue,
                    onTap: () => controller.updateOrderStatus(order.id!, 1),
                    context: context,
                  ),
                  const SizedBox(width: 8),
                ],
                if (order.status == 1)
                  _ActionButton(
                    label: LKey.shipOrder,
                    color: Colors.indigo,
                    onTap: () => controller.updateOrderStatus(order.id!, 2),
                    context: context,
                  ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: LKey.cancelOrder,
                  color: Colors.red,
                  onTap: () => controller.updateOrderStatus(order.id!, 4),
                  context: context,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final BuildContext context;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: .1),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
          ),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
              color: color, fontSize: 11),
        ),
      ),
    );
  }
}

// ─── Seller KYC Prompt ──────────────────────────────────────

class _SellerKycPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: ShapeDecoration(
                color: themeAccentSolid(context).withValues(alpha: .1),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 24, cornerSmoothing: 1),
                ),
              ),
              child: Icon(Icons.storefront_outlined,
                  size: 40, color: themeAccentSolid(context)),
            ),
            const SizedBox(height: 20),
            Text(
              'Become a Seller',
              style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context), fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Complete your seller verification to list products and manage orders on the marketplace.',
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 14),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.to(() => const SellerKycScreen()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: ShapeDecoration(
                  color: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  'Apply Now',
                  style: TextStyleCustom.outFitMedium500(
                      color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
