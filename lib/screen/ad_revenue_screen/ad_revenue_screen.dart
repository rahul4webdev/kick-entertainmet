import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/ad_revenue/ad_revenue_model.dart';
import 'package:shortzz/screen/ad_revenue_screen/ad_revenue_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AdRevenueScreen extends StatelessWidget {
  const AdRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdRevenueController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          LKey.adRevenueShare,
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingStatus.value) {
          return const LoaderWidget();
        }
        final status = controller.statusData.value;
        if (status == null) {
          return const LoaderWidget();
        }

        final enrollment = status.enrollment;
        final isEnrolled = status.isEnrolled == true;

        // Not enrolled yet — show enrollment screen
        if (!isEnrolled && (enrollment == null || enrollment.isPending || enrollment.isRejected)) {
          return _EnrollmentView(
            controller: controller,
            status: status,
            enrollment: enrollment,
          );
        }

        // Enrolled — show dashboard
        return _DashboardView(controller: controller);
      }),
    );
  }
}

class _EnrollmentView extends StatelessWidget {
  final AdRevenueController controller;
  final AdRevenueStatusData status;
  final AdRevenueEnrollment? enrollment;

  const _EnrollmentView({
    required this.controller,
    required this.status,
    this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = enrollment?.isPending == true;
    final isRejected = enrollment?.isRejected == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              gradient: StyleRes.themeGradient,
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.monetization_on,
                    size: 56, color: whitePure(context)),
                const SizedBox(height: 12),
                Text(
                  LKey.adRevenueProgram,
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 22, color: whitePure(context)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Earn ${status.revenueSharePercent ?? 55}% of ad revenue generated from your content',
                  style: TextStyleCustom.outFitLight300(
                      color: whitePure(context).withValues(alpha: 0.9),
                      fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Status badge
          if (isPending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.orange.withValues(alpha: .1),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top,
                      color: Colors.orange, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LKey.enrollmentPending,
                      style: TextStyleCustom.outFitMedium500(
                          color: Colors.orange, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

          if (isRejected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.red.withValues(alpha: .1),
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
                      const Icon(Icons.cancel, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        LKey.enrollmentRejected,
                        style: TextStyleCustom.outFitMedium500(
                            color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                  if (enrollment?.rejectionReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      enrollment!.rejectionReason!,
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),

          if (!isPending && !isRejected) ...[
            // Requirements
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                  Text(
                    LKey.adRevenueRequirements,
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _RequirementRow(
                    label: 'Monetized Account',
                    met: status.isMonetized == true,
                    context: context,
                  ),
                  const SizedBox(height: 8),
                  _RequirementRow(
                    label:
                        '${status.minFollowersRequired ?? 1000}+ followers',
                    met: status.isMonetized == true,
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Enroll button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed:
                    status.isMonetized == true ? controller.enroll : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  disabledBackgroundColor: bgMediumGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  LKey.enrollNow,
                  style: TextStyleCustom.outFitMedium500(
                      color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],

          // Info section
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                Text(
                  'How it works',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 15),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                    icon: Icons.ads_click,
                    text:
                        'Ads shown on your content generate revenue',
                    context: context),
                const SizedBox(height: 6),
                _InfoRow(
                    icon: Icons.pie_chart,
                    text:
                        'You earn ${status.revenueSharePercent ?? 55}% of the ad revenue',
                    context: context),
                const SizedBox(height: 6),
                _InfoRow(
                    icon: Icons.payments,
                    text: 'Revenue is credited monthly as coins',
                    context: context),
                const SizedBox(height: 6),
                _InfoRow(
                    icon: Icons.trending_up,
                    text:
                        'Current eCPM: \$${(status.ecpmRate ?? 2.0).toStringAsFixed(2)}',
                    context: context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool met;
  final BuildContext context;

  const _RequirementRow(
      {required this.label, required this.met, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context), fontSize: 14),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final BuildContext context;

  const _InfoRow(
      {required this.icon, required this.text, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textLightGrey(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _DashboardView extends StatelessWidget {
  final AdRevenueController controller;

  const _DashboardView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSummary.value) {
        return const LoaderWidget();
      }
      final summary = controller.summary.value;
      if (summary == null) {
        return const LoaderWidget();
      }

      return RefreshIndicator(
        onRefresh: () async => controller.fetchSummary(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue overview card
              _RevenueOverviewCard(summary: summary),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  Expanded(
                      child: _MiniStatCard(
                    label: LKey.todayImpressions,
                    value: (summary.today?.impressions ?? 0).numberFormat,
                    subValue:
                        '\$${(summary.today?.creatorShare ?? 0).toStringAsFixed(2)}',
                    context: context,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _MiniStatCard(
                    label: LKey.monthImpressions,
                    value: (summary.thisMonth?.impressions ?? 0).numberFormat,
                    subValue:
                        '\$${(summary.thisMonth?.creatorShare ?? 0).toStringAsFixed(2)}',
                    context: context,
                  )),
                ],
              ),
              const SizedBox(height: 16),

              // Revenue share info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: ShapeDecoration(
                  color: bgLightGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 10, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LKey.revenueSharePercent,
                      style: TextStyleCustom.outFitRegular400(
                          color: textLightGrey(context), fontSize: 13),
                    ),
                    Text(
                      '${summary.revenueSharePercent ?? 55}%',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: ShapeDecoration(
                  color: bgLightGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 10, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LKey.totalCoinsEarned,
                      style: TextStyleCustom.outFitRegular400(
                          color: textLightGrey(context), fontSize: 13),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AssetRes.icCoin, width: 14, height: 14),
                        const SizedBox(width: 4),
                        Text(
                          (summary.totalCoinsEarned ?? 0).numberFormat,
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ad type breakdown
              if (summary.byAdType != null &&
                  summary.byAdType!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  LKey.adTypeBreakdown,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...summary.byAdType!.map((item) => _AdTypeRow(
                      item: item,
                      context: context,
                    )),
              ],

              // Top earning posts
              if (summary.topEarningPosts != null &&
                  summary.topEarningPosts!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  LKey.topEarningPosts,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...summary.topEarningPosts!.map((post) => _TopPostRow(
                      post: post,
                      context: context,
                    )),
              ],

              // Payout history
              if (summary.payouts != null &&
                  summary.payouts!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  LKey.payoutHistory,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...summary.payouts!.map((payout) => _PayoutRow(
                      payout: payout,
                      context: context,
                    )),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }
}

class _RevenueOverviewCard extends StatelessWidget {
  final AdRevenueSummary summary;

  const _RevenueOverviewCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: StyleRes.themeGradient,
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            LKey.totalImpressions,
            style: TextStyleCustom.outFitLight300(
                color: whitePure(context).withValues(alpha: 0.8),
                fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            (summary.total?.impressions ?? 0).numberFormat,
            style: TextStyleCustom.unboundedExtraBold800(
                color: whitePure(context), fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '${LKey.yourShare}: \$${(summary.total?.creatorShare ?? 0).toStringAsFixed(2)}',
            style: TextStyleCustom.outFitMedium500(
                color: whitePure(context), fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${LKey.estimatedRevenue}: \$${(summary.total?.revenue ?? 0).toStringAsFixed(2)}',
            style: TextStyleCustom.outFitLight300(
                color: whitePure(context).withValues(alpha: 0.7),
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final BuildContext context;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyleCustom.unboundedSemiBold600(
                color: textDarkGrey(context), fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            subValue,
            style: TextStyleCustom.outFitMedium500(
                color: Colors.green, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AdTypeRow extends StatelessWidget {
  final AdTypeBreakdown item;
  final BuildContext context;

  const _AdTypeRow({required this.item, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item.adType ?? '').replaceAll('_', ' ').capitalize!,
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 14),
                  ),
                  Text(
                    '${(item.impressions ?? 0).numberFormat} ${LKey.impressions}',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '\$${(item.creatorShare ?? 0).toStringAsFixed(2)}',
              style: TextStyleCustom.outFitMedium500(
                  color: Colors.green, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopPostRow extends StatelessWidget {
  final TopEarningPost post;
  final BuildContext context;

  const _TopPostRow({required this.post, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 50,
              child: post.thumbnail != null
                  ? Image.network(post.thumbnail!.addBaseURL(),
                      fit: BoxFit.cover)
                  : Container(
                      color: bgMediumGrey(context),
                      child: Icon(Icons.play_arrow,
                          color: textLightGrey(context), size: 20)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(post.views ?? 0).numberFormat} views',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 13),
                    ),
                    Text(
                      '${(post.impressions ?? 0).numberFormat} ads',
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '\$${(post.creatorShare ?? 0).toStringAsFixed(2)}',
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.green, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutRow extends StatelessWidget {
  final AdRevenuePayout payout;
  final BuildContext context;

  const _PayoutRow({required this.payout, required this.context});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (payout.status) {
      1 => Colors.green,
      2 => Colors.blue,
      _ => Colors.orange,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${payout.periodStart ?? ''} - ${payout.periodEnd ?? ''}',
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 13),
                  ),
                  Text(
                    '${(payout.totalImpressions ?? 0).numberFormat} ${LKey.impressions}',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AssetRes.icCoin, width: 12, height: 12),
                    const SizedBox(width: 3),
                    Text(
                      (payout.coinsCredit ?? 0).numberFormat,
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    payout.statusLabel,
                    style: TextStyleCustom.outFitMedium500(
                        color: statusColor, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
