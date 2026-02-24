import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/affiliate/affiliate_model.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/affiliate_screen/affiliate_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AffiliateScreen extends StatelessWidget {
  const AffiliateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AffiliateController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            const CustomAppBar(title: 'Affiliate Program'),
            TabBar(
              labelColor: textDarkGrey(context),
              unselectedLabelColor: textLightGrey(context),
              indicatorColor: themeAccentSolid(context),
              labelStyle: TextStyleCustom.outFitMedium500(fontSize: 13),
              unselectedLabelStyle: TextStyleCustom.outFitRegular400(fontSize: 13),
              tabs: [
                Tab(text: LKey.affiliateDashboard),
                Tab(text: LKey.affiliateMyLinks),
                Tab(text: LKey.affiliateBrowse),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DashboardTab(controller: controller),
                  _MyLinksTab(controller: controller),
                  _BrowseTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Tab ─────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final AffiliateController controller;

  const _DashboardTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDashboard.value && controller.dashboardData.value == null) {
        return const LoaderWidget();
      }

      final data = controller.dashboardData.value;

      return MyRefreshIndicator(
        onRefresh: controller.fetchDashboard,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _DashStatCard(
                    label: 'Total Earnings',
                    value: (data?.totalEarnings ?? 0).numberFormat,
                    suffix: ' coins',
                    icon: Icons.monetization_on_rounded,
                    color: Colors.amber,
                  ),
                  _DashStatCard(
                    label: 'Last 30 Days',
                    value: (data?.last30DaysEarnings ?? 0).numberFormat,
                    suffix: ' coins',
                    icon: Icons.calendar_today_rounded,
                    color: Colors.green,
                  ),
                  _DashStatCard(
                    label: LKey.affiliatePurchases,
                    value: '${data?.totalPurchases ?? 0}',
                    icon: Icons.shopping_bag_rounded,
                    color: Colors.blue,
                  ),
                  _DashStatCard(
                    label: LKey.affiliateClicks,
                    value: '${data?.totalClicks ?? 0}',
                    icon: Icons.touch_app_rounded,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Active links count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgMediumGrey(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, color: themeAccentSolid(context), size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data?.totalLinks ?? 0} Active Links',
                          style: TextStyleCustom.unboundedMedium500(
                            color: textDarkGrey(context),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Products you are promoting',
                          style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Top products
              if (data?.topProducts?.isNotEmpty ?? false) ...[
                Text(
                  'Top Earning Products',
                  style: TextStyleCustom.unboundedMedium500(
                    color: textDarkGrey(context),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                ...data!.topProducts!.map((link) => _TopProductRow(link: link)),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _DashStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const _DashStatCard({
    required this.label,
    required this.value,
    this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyleCustom.unboundedSemiBold600(
                color: textDarkGrey(context),
                fontSize: 16,
              ),
              children: suffix != null
                  ? [
                      TextSpan(
                        text: suffix,
                        style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context),
                          fontSize: 10,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          Text(
            label,
            style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final AffiliateLink link;

  const _TopProductRow({required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (link.product != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImage(
                size: const Size(44, 44),
                radius: 8,
                image: link.product!.firstImageUrl,
                isShowPlaceHolder: true,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.product?.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleCustom.outFitRegular400(
                    color: textDarkGrey(context),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${link.purchaseCount} sales  |  ${link.commissionRate}% commission',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            link.totalEarnings.numberFormat,
            style: TextStyleCustom.unboundedSemiBold600(
              color: Colors.amber,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── My Links Tab ──────────────────────────────────────────────────

class _MyLinksTab extends StatelessWidget {
  final AffiliateController controller;

  const _MyLinksTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingLinks.value && controller.myLinks.isEmpty) {
        return const LoaderWidget();
      }

      if (controller.myLinks.isEmpty) {
        return NoDataView(
          title: LKey.affiliateNoLinks,
          description: LKey.affiliateNoLinksDesc,
        );
      }

      return MyRefreshIndicator(
        onRefresh: controller.fetchMyLinks,
        child: ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: controller.myLinks.length,
          itemBuilder: (context, index) {
            final link = controller.myLinks[index];
            return _AffiliateLinkCard(
              link: link,
              onRemove: () => controller.removeAffiliateLink(link.id!),
            );
          },
        ),
      );
    });
  }
}

class _AffiliateLinkCard extends StatelessWidget {
  final AffiliateLink link;
  final VoidCallback onRemove;

  const _AffiliateLinkCard({required this.link, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (link.product != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImage(
                    size: const Size(50, 50),
                    radius: 8,
                    image: link.product!.firstImageUrl,
                    isShowPlaceHolder: true,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.product?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${link.product?.priceCoins ?? 0} coins  |  ${link.commissionRate}% commission',
                      style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(icon: Icons.touch_app, label: '${link.clickCount}', subtitle: LKey.affiliateClicks),
              _MiniStat(icon: Icons.shopping_bag, label: '${link.purchaseCount}', subtitle: LKey.affiliatePurchases),
              _MiniStat(icon: Icons.monetization_on, label: link.totalEarnings.numberFormat, subtitle: LKey.affiliateEarned),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scaffoldBackgroundColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.link, size: 14, color: textLightGrey(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    link.affiliateCode ?? '',
                    style: TextStyleCustom.outFitRegular400(
                      color: themeAccentSolid(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _MiniStat({required this.icon, required this.label, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: textLightGrey(context)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context),
              fontSize: 13,
            ),
          ),
          Text(
            subtitle,
            style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Browse Products Tab ───────────────────────────────────────────

class _BrowseTab extends StatefulWidget {
  final AffiliateController controller;

  const _BrowseTab({required this.controller});

  @override
  State<_BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<_BrowseTab> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.affiliateProducts.isEmpty) {
      widget.controller.fetchAffiliateProducts(reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 0),
            child: TextField(
              onChanged: widget.controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products to promote...',
                hintStyle: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 13,
                ),
                prefixIcon: Icon(Icons.search, color: textLightGrey(context), size: 20),
                filled: true,
                fillColor: bgMediumGrey(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Products list
          Expanded(
            child: widget.controller.isLoadingProducts.value && widget.controller.affiliateProducts.isEmpty
                ? const LoaderWidget()
                : widget.controller.affiliateProducts.isEmpty
                    ? NoDataView(
                        title: LKey.affiliateNoProducts,
                      )
                    : MyRefreshIndicator(
                        onRefresh: () => widget.controller.fetchAffiliateProducts(reset: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: widget.controller.affiliateProducts.length,
                          itemBuilder: (context, index) {
                            final product = widget.controller.affiliateProducts[index];
                            return _AffiliateProductCard(
                              product: product,
                              onPromote: product.hasAffiliateLink
                                  ? null
                                  : () => widget.controller.createAffiliateLink(product.id!),
                            );
                          },
                        ),
                      ),
          ),
        ],
      );
    });
  }
}

class _AffiliateProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onPromote;

  const _AffiliateProductCard({required this.product, this.onPromote});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImage(
              size: const Size(56, 56),
              radius: 8,
              image: product.firstImageUrl,
              isShowPlaceHolder: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.priceCoins ?? 0} coins  |  ${product.soldCount ?? 0} sold',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                    fontSize: 11,
                  ),
                ),
                if (product.affiliateCommissionRate != null)
                  Text(
                    '${product.affiliateCommissionRate}% commission',
                    style: TextStyleCustom.outFitRegular400(
                      color: Colors.green,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPromote,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: product.hasAffiliateLink
                    ? Colors.green.withValues(alpha: 0.15)
                    : themeAccentSolid(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                product.hasAffiliateLink ? LKey.affiliatePromoted : LKey.affiliatePromote,
                style: TextStyleCustom.outFitMedium500(
                  color: product.hasAffiliateLink ? Colors.green : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
