import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/ad_revenue_screen/ad_revenue_screen.dart';
import 'package:shortzz/screen/affiliate_screen/affiliate_screen.dart';
import 'package:shortzz/screen/bank_accounts_screen/bank_accounts_screen.dart';
import 'package:shortzz/screen/business_account_screen/business_account_screen.dart';
import 'package:shortzz/screen/content_calendar_screen/content_calendar_screen.dart';
import 'package:shortzz/screen/creator_dashboard_screen/creator_dashboard_screen.dart';
import 'package:shortzz/screen/creator_insights_screen/creator_insights_screen.dart';
import 'package:shortzz/screen/earnings_dashboard_screen/earnings_dashboard_screen.dart';
import 'package:shortzz/screen/marketplace_screen/marketplace_screen.dart';
import 'package:shortzz/screen/monetization_screen/monetization_screen.dart';
import 'package:shortzz/screen/paid_series_screen/paid_series_screen.dart';
import 'package:shortzz/screen/portfolio_screen/portfolio_screen.dart';
import 'package:shortzz/screen/professional_dashboard_screen/professional_dashboard_controller.dart';
import 'package:shortzz/screen/settings_screen/widget/setting_icon_text_with_arrow.dart';
import 'package:shortzz/screen/shop_screen/shop_screen.dart';
import 'package:shortzz/screen/subscription_screen/manage_tiers_screen.dart';
import 'package:shortzz/screen/subscription_screen/my_subscribers_screen.dart';
import 'package:shortzz/screen/team_screen/team_screen.dart';
import 'package:shortzz/screen/tier_status_screen/tier_status_screen.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfessionalDashboardScreen extends StatelessWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfessionalDashboardController());
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      body: Column(
        children: [
          CustomAppBar(title: LKey.professionalDashboard.tr),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Type Badge Card
                  _AccountTypeBadge(controller: controller),

                  // --- TRACK YOUR PERFORMANCE ---
                  SettingSection(
                    title: LKey.trackYourPerformance,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.dashboard_outlined,
                        title: LKey.creatorDashboard,
                        iconBgColor: Colors.deepPurple.withValues(alpha: 0.08),
                        iconColor: Colors.deepPurple,
                        onTap: () =>
                            Get.to(() => const CreatorDashboardScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.auto_awesome_outlined,
                        title: LKey.aiInsights,
                        iconBgColor: Colors.amber.withValues(alpha: 0.08),
                        iconColor: Colors.amber.shade700,
                        onTap: () =>
                            Get.to(() => const CreatorInsightsScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.calendar_month_outlined,
                        title: LKey.contentCalendar,
                        iconBgColor: Colors.blue.withValues(alpha: 0.08),
                        iconColor: Colors.blue.shade600,
                        onTap: () =>
                            Get.to(() => const ContentCalendarScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.attach_money_rounded,
                        title: LKey.adRevenueShare,
                        iconBgColor: Colors.teal.withValues(alpha: 0.08),
                        iconColor: Colors.teal,
                        onTap: () => Get.to(() => const AdRevenueScreen()),
                      ),
                    ],
                  ),

                  // --- GROW YOUR BUSINESS ---
                  SettingSection(
                    title: LKey.growYourBusiness,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.monetization_on_outlined,
                        title: LKey.monetization,
                        iconBgColor: Colors.green.withValues(alpha: 0.08),
                        iconColor: Colors.green.shade700,
                        onTap: () => Get.to(() => const MonetizationScreen()),
                      ),
                      Obx(() {
                        if (controller.isMonetized) {
                          return SettingIconTextWithArrow(
                            iconData: Icons.trending_up_rounded,
                            title: LKey.creatorEarnings,
                            iconBgColor: Colors.green.withValues(alpha: 0.08),
                            iconColor: Colors.green.shade700,
                            onTap: () => Get.to(
                                () => const EarningsDashboardScreen()),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      SettingIconTextWithArrow(
                        iconData: Icons.card_membership_outlined,
                        title: LKey.subscriptionTiers,
                        onTap: () => Get.to(() => const ManageTiersScreen()),
                      ),
                      Obx(() {
                        if (controller.hasSubscriptionsEnabled) {
                          return SettingIconTextWithArrow(
                            iconData: Icons.people_outline_rounded,
                            title: LKey.mySubscribers,
                            onTap: () =>
                                Get.to(() => const MySubscribersScreen()),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      SettingIconTextWithArrow(
                        iconData: Icons.video_library_outlined,
                        title: LKey.paidSeries,
                        onTap: () => Get.to(() => const PaidSeriesScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.store_outlined,
                        title: LKey.creatorMarketplace,
                        onTap: () => Get.to(() => const MarketplaceScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.link_rounded,
                        title: LKey.affiliateProgram,
                        onTap: () => Get.to(() => const AffiliateScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.shopping_bag_outlined,
                        title: LKey.shop,
                        onTap: () => Get.to(() => const ShopScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.work_outline_rounded,
                        title: LKey.myPortfolio,
                        onTap: () => Get.to(() => const PortfolioScreen()),
                      ),
                    ],
                  ),

                  // --- MANAGE YOUR ACCOUNT ---
                  SettingSection(
                    title: LKey.manageYourAccount,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.groups_outlined,
                        title: LKey.teamManagement,
                        onTap: () => Get.to(() => const TeamScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.account_balance_outlined,
                        title: LKey.bankAccounts,
                        onTap: () => Get.to(() => const BankAccountsScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.military_tech_outlined,
                        title: LKey.creatorTier,
                        iconBgColor: Colors.amber.withValues(alpha: 0.08),
                        iconColor: Colors.amber.shade700,
                        onTap: () => Get.to(() => const TierStatusScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.storefront_outlined,
                        title: LKey.accountTypeSettings,
                        onTap: () =>
                            Get.to(() => const BusinessAccountScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTypeBadge extends StatelessWidget {
  final ProfessionalDashboardController controller;
  const _AccountTypeBadge({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () => Get.to(() => const BusinessAccountScreen()),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                    cornerRadius: 14, cornerSmoothing: 0.8),
              ),
              gradient: StyleRes.themeGradient,
            ),
            child: Row(
              children: [
                Icon(_accountIcon(controller.accountType),
                    size: 24, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.accountTypeLabel} ${LKey.accountLabel2.tr}',
                        style: TextStyleCustom.outFitSemiBold600(
                            color: Colors.white, fontSize: 15),
                      ),
                      if (controller.categoryName != null)
                        Text(
                          controller.categoryName!,
                          style: TextStyleCustom.outFitLight300(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 22, color: Colors.white),
              ],
            ),
          ),
        ),
      );
    });
  }

  IconData _accountIcon(int type) {
    switch (type) {
      case 1:
        return Icons.person_outline;
      case 2:
        return Icons.business_outlined;
      case 3:
        return Icons.movie_outlined;
      case 4:
        return Icons.newspaper_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }
}
