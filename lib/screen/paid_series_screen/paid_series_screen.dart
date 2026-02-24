import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/paid_series/paid_series_model.dart';
import 'package:shortzz/screen/paid_series_screen/paid_series_controller.dart';
import 'package:shortzz/screen/paid_series_screen/paid_series_detail_screen.dart';
import 'package:shortzz/screen/paid_series_screen/create_paid_series_sheet.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PaidSeriesScreen extends StatelessWidget {
  const PaidSeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaidSeriesController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackButton(
            image: AssetRes.icBackArrow_1,
            height: 25,
            width: 25,
            padding: EdgeInsets.zero,
          ),
          title: Text(
            LKey.paidSeries,
            style: TextStyleCustom.unboundedMedium500(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Get.bottomSheet(
                  CreatePaidSeriesSheet(controller: controller),
                  isScrollControlled: true,
                );
              },
              icon:
                  Icon(Icons.add_circle_outline, color: themeAccentSolid(context)),
            ),
          ],
          bottom: TabBar(
            labelStyle: TextStyleCustom.outFitMedium500(fontSize: 14),
            unselectedLabelStyle:
                TextStyleCustom.outFitRegular400(fontSize: 14),
            labelColor: themeAccentSolid(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: themeAccentSolid(context),
            tabs: [
              Tab(text: LKey.paidSeries),
              Tab(text: LKey.myPaidSeries),
              Tab(text: LKey.myPurchases),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BrowseTab(controller: controller),
            _MySeriesTab(controller: controller),
            _PurchasesTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _BrowseTab extends StatelessWidget {
  final PaidSeriesController controller;
  const _BrowseTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingList.value && controller.seriesList.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow:
            !controller.isLoadingList.value && controller.seriesList.isEmpty,
        title: LKey.noPaidSeries,
        description: LKey.noPaidSeriesDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchSeriesList(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.seriesList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _PaidSeriesCard(
                series: controller.seriesList[index],
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }
}

class _MySeriesTab extends StatelessWidget {
  final PaidSeriesController controller;
  const _MySeriesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingList.value && controller.mySeriesList.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isLoadingList.value &&
            controller.mySeriesList.isEmpty,
        title: LKey.noMyPaidSeries,
        description: LKey.noMyPaidSeriesDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchMySeriesList(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.mySeriesList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _PaidSeriesCard(
                series: controller.mySeriesList[index],
                controller: controller,
                isCreator: true,
              );
            },
          ),
        ),
      );
    });
  }
}

class _PurchasesTab extends StatelessWidget {
  final PaidSeriesController controller;
  const _PurchasesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return NoDataView(
        showShow: controller.myPurchases.isEmpty,
        title: LKey.noPurchases,
        description: LKey.noPurchasesDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchMyPurchasesList(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myPurchases.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final purchase = controller.myPurchases[index];
              if (purchase.series == null) return const SizedBox();
              return _PaidSeriesCard(
                series: purchase.series!,
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }
}

class _PaidSeriesCard extends StatelessWidget {
  final PaidSeries series;
  final PaidSeriesController controller;
  final bool isCreator;

  const _PaidSeriesCard({
    required this.series,
    required this.controller,
    this.isCreator = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => PaidSeriesDetailScreen(
              series: series,
              controller: controller,
            ));
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
        child: Row(
          children: [
            // Cover image
            SizedBox(
              width: 100,
              height: 130,
              child: series.coverImageUrl != null
                  ? Image.network(series.coverImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: bgMediumGrey(context),
                      child: Icon(Icons.play_circle_outline,
                          size: 40, color: textLightGrey(context)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title ?? '',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (series.creator != null)
                      Row(
                        spacing: 6,
                        children: [
                          CustomImage(
                            size: const Size(20, 20),
                            image: series.creator?.profilePhoto?.addBaseURL(),
                            fullName: series.creator?.fullname,
                          ),
                          Expanded(
                            child: Text(
                              series.creator?.username ?? '',
                              style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context), fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.play_circle_outline,
                          text: '${series.videoCount ?? 0} videos',
                          context: context,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.monetization_on_outlined,
                          text: '${series.priceCoins ?? 0} ${LKey.coinsText}',
                          context: context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (isCreator)
                      Row(
                        children: [
                          _StatusBadge(series: series, context: context),
                          const Spacer(),
                          Text(
                            '${series.purchaseCount ?? 0} ${LKey.purchases}',
                            style: TextStyleCustom.outFitLight300(
                                color: textLightGrey(context), fontSize: 11),
                          ),
                        ],
                      )
                    else if (series.isPurchased == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: ShapeDecoration(
                          color: Colors.green.withValues(alpha: .1),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 6, cornerSmoothing: 1),
                          ),
                        ),
                        child: Text(
                          LKey.alreadyPurchased,
                          style: TextStyleCustom.outFitMedium500(
                              color: Colors.green, fontSize: 11),
                        ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final BuildContext context;

  const _InfoChip(
      {required this.icon, required this.text, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Icon(icon, size: 14, color: textLightGrey(context)),
        Text(text,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 11)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PaidSeries series;
  final BuildContext context;

  const _StatusBadge({required this.series, required this.context});

  @override
  Widget build(BuildContext context) {
    final color = series.isApproved
        ? Colors.green
        : series.isPending
            ? Colors.orange
            : Colors.red;
    final label = series.isApproved
        ? 'Approved'
        : series.isPending
            ? 'Pending'
            : 'Rejected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .1),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 6, cornerSmoothing: 1),
        ),
      ),
      child: Text(label,
          style:
              TextStyleCustom.outFitMedium500(color: color, fontSize: 11)),
    );
  }
}
