import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/model/creator/creator_dashboard_model.dart';
import 'package:shortzz/model/creator/milestone_model.dart';
import 'package:shortzz/screen/content_calendar_screen/content_calendar_screen.dart';
import 'package:shortzz/screen/creator_dashboard_screen/creator_dashboard_controller.dart';
import 'package:shortzz/screen/creator_insights_screen/creator_insights_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreatorDashboardScreen extends StatelessWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatorDashboardController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Creator Dashboard'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.dashboardData.value == null) {
                return const LoaderWidget();
              }
              return MyRefreshIndicator(
                onRefresh: controller.refreshAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content Calendar button
                      GestureDetector(
                        onTap: () => Get.to(() => const ContentCalendarScreen()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgMediumGrey(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  size: 20, color: themeAccentSolid(context)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Content Calendar',
                                  style: TextStyleCustom.outFitMedium500(
                                    fontSize: 14,
                                    color: textDarkGrey(context),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 20, color: textLightGrey(context)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // AI Insights button
                      GestureDetector(
                        onTap: () => Get.to(() => const CreatorInsightsScreen()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgMediumGrey(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 20, color: Colors.amber),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'AI Insights',
                                  style: TextStyleCustom.outFitMedium500(
                                    fontSize: 14,
                                    color: textDarkGrey(context),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 20, color: textLightGrey(context)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Period selector
                      _PeriodSelector(controller: controller),
                      const SizedBox(height: 16),

                      // Overview stats grid
                      if (controller.dashboardData.value?.overview != null)
                        _OverviewGrid(
                          overview: controller.dashboardData.value!.overview!,
                        ),
                      const SizedBox(height: 20),

                      // Period stats
                      if (controller.dashboardData.value?.period != null)
                        _PeriodStatsCard(
                          period: controller.dashboardData.value!.period!,
                        ),
                      const SizedBox(height: 20),

                      // Ad Revenue estimation
                      if (controller.dashboardData.value?.adRevenue != null)
                        _AdRevenueCard(
                          adRevenue: controller.dashboardData.value!.adRevenue!,
                          periodLabel: controller.selectedPeriod.value,
                        ),
                      if (controller.dashboardData.value?.adRevenue != null)
                        const SizedBox(height: 20),

                      // Milestones
                      if (controller.milestones.isNotEmpty) ...[
                        Text(
                          'Milestones',
                          style: TextStyleCustom.unboundedMedium500(
                            color: textDarkGrey(context),
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MilestonesList(controller: controller),
                        const SizedBox(height: 20),
                      ],

                      // Content breakdown
                      if (controller.dashboardData.value?.contentBreakdown?.isNotEmpty ?? false) ...[
                        Text(
                          'Content Breakdown',
                          style: TextStyleCustom.unboundedMedium500(
                            color: textDarkGrey(context),
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ContentBreakdownList(
                          items: controller.dashboardData.value!.contentBreakdown!,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Top posts
                      if (controller.dashboardData.value?.topPosts?.isNotEmpty ?? false) ...[
                        Text(
                          'Top Performing Posts',
                          style: TextStyleCustom.unboundedMedium500(
                            color: textDarkGrey(context),
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...controller.dashboardData.value!.topPosts!
                            .map((post) => _TopPostTile(post: post)),
                        const SizedBox(height: 20),
                      ],

                      // Audience insights
                      if (controller.audienceData.value != null) ...[
                        Text(
                          'Audience Insights',
                          style: TextStyleCustom.unboundedMedium500(
                            color: textDarkGrey(context),
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Top followers
                        if (controller.audienceData.value!.topFollowers?.isNotEmpty ?? false) ...[
                          Text(
                            'Most Influential Followers',
                            style: TextStyleCustom.outFitRegular400(
                              color: textLightGrey(context),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.audienceData.value!.topFollowers!.length,
                              itemBuilder: (context, index) {
                                final user = controller.audienceData.value!.topFollowers![index];
                                return Container(
                                  width: 70,
                                  margin: const EdgeInsets.only(right: 8),
                                  child: Column(
                                    children: [
                                      ClipOval(
                                        child: CustomImage(
                                          size: const Size(48, 48),
                                          radius: 24,
                                          image: user.profilePhoto?.addBaseURL(),
                                          isShowPlaceHolder: true,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user.username ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyleCustom.outFitRegular400(
                                          color: textDarkGrey(context),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Top gifters
                        if (controller.audienceData.value!.topGifters?.isNotEmpty ?? false) ...[
                          Text(
                            'Top Supporters',
                            style: TextStyleCustom.outFitRegular400(
                              color: textLightGrey(context),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.audienceData.value!.topGifters!
                              .map((gifter) => _GifterTile(gifter: gifter)),
                        ],
                      ],

                      const SizedBox(height: 20),

                      // Search Insights
                      _SearchInsightsSection(controller: controller),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Period Selector ────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  final CreatorDashboardController controller;

  const _PeriodSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: controller.periodOptions.map((period) {
            final isSelected = controller.selectedPeriod.value == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.onPeriodChanged(period),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeAccentSolid(context)
                        : bgMediumGrey(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.periodLabel(period),
                    style: TextStyleCustom.outFitRegular400(
                      color: isSelected ? Colors.white : textLightGrey(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }
}

// ─── Overview Stats Grid ────────────────────────────────────────────

class _OverviewGrid extends StatelessWidget {
  final DashboardOverview overview;

  const _OverviewGrid({required this.overview});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _StatCard(
          label: 'Views',
          value: overview.totalViews.numberFormat,
          icon: Icons.visibility_rounded,
          color: Colors.blue,
        ),
        _StatCard(
          label: 'Likes',
          value: overview.totalLikes.numberFormat,
          icon: Icons.favorite_rounded,
          color: Colors.redAccent,
        ),
        _StatCard(
          label: 'Followers',
          value: overview.followerCount.numberFormat,
          icon: Icons.people_rounded,
          color: Colors.teal,
        ),
        _StatCard(
          label: 'Comments',
          value: overview.totalComments.numberFormat,
          icon: Icons.chat_bubble_rounded,
          color: Colors.orange,
        ),
        _StatCard(
          label: 'Shares',
          value: overview.totalShares.numberFormat,
          icon: Icons.share_rounded,
          color: Colors.purple,
        ),
        _StatCard(
          label: 'Engagement',
          value: '${overview.engagementRate}%',
          icon: Icons.trending_up_rounded,
          color: Colors.green,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context),
              fontSize: 15,
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

// ─── Period Stats Card ──────────────────────────────────────────────

class _PeriodStatsCard extends StatelessWidget {
  final DashboardPeriod period;

  const _PeriodStatsCard({required this.period});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Period Summary',
            style: TextStyleCustom.unboundedMedium500(
              color: textDarkGrey(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PeriodStatItem(label: 'Posts', value: '${period.posts}'),
              _PeriodStatItem(label: 'Views', value: period.views.numberFormat),
              _PeriodStatItem(label: 'Likes', value: period.likes.numberFormat),
              _PeriodStatItem(
                  label: 'New Followers',
                  value: '+${period.newFollowers}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodStatItem extends StatelessWidget {
  final String label;
  final String value;

  const _PeriodStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ad Revenue Card ────────────────────────────────────────────────

class _AdRevenueCard extends StatelessWidget {
  final AdRevenueEstimate adRevenue;
  final String periodLabel;

  const _AdRevenueCard({required this.adRevenue, required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Estimated Ad Revenue',
                style: TextStyleCustom.unboundedMedium500(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '\$${adRevenue.estimatedTotalRevenue.toStringAsFixed(2)}',
                      style: TextStyleCustom.unboundedSemiBold600(
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All Time',
                      style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '\$${adRevenue.estimatedPeriodRevenue.toStringAsFixed(2)}',
                      style: TextStyleCustom.unboundedSemiBold600(
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'This Period',
                      style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'eCPM: \$${adRevenue.ecpmRate.toStringAsFixed(2)}',
                style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 11,
                ),
              ),
              Text(
                'Revenue Share: ${adRevenue.revenueSharePercent}%',
                style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Content Breakdown ──────────────────────────────────────────────

class _ContentBreakdownList extends StatelessWidget {
  final List<ContentBreakdownItem> items;

  const _ContentBreakdownList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgMediumGrey(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                item.label,
                style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${item.count} posts',
                style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${item.views.numberFormat} views',
                style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Top Post Tile ──────────────────────────────────────────────────

class _TopPostTile extends StatelessWidget {
  final dynamic post;

  const _TopPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    final thumbnail = (post.thumbnail as String?)?.addBaseURL();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImage(
              size: const Size(50, 50),
              radius: 8,
              image: thumbnail,
              isShowPlaceHolder: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              post.description ?? 'No description',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 14, color: textLightGrey(context)),
                  const SizedBox(width: 4),
                  Text(
                    '${(post.views as num? ?? 0).numberFormat}',
                    style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(
                    '${(post.likes as num? ?? 0).numberFormat}',
                    style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Gifter Tile ────────────────────────────────────────────────────

class _GifterTile extends StatelessWidget {
  final TopGifter gifter;

  const _GifterTile({required this.gifter});

  @override
  Widget build(BuildContext context) {
    final user = gifter.user;
    if (user == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipOval(
            child: CustomImage(
              size: const Size(36, 36),
              radius: 18,
              image: user.profilePhoto?.addBaseURL(),
              isShowPlaceHolder: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username ?? '',
                  style: TextStyleCustom.outFitRegular400(
                    color: textDarkGrey(context),
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${gifter.giftCount} gifts',
                  style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${gifter.totalCoins.numberFormat} coins',
            style: TextStyleCustom.unboundedSemiBold600(
              color: Colors.amber,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Milestones List ────────────────────────────────────────────────

class _MilestonesList extends StatelessWidget {
  final CreatorDashboardController controller;

  const _MilestonesList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.milestones;
      if (items.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final milestone = items[index];
            return _MilestoneCard(
              milestone: milestone,
              isNew: !milestone.isSeen,
              onTap: () {
                if (!milestone.isSeen) {
                  controller.markMilestoneSeen(milestone);
                }
                _showMilestoneDetail(context, milestone);
              },
            );
          },
        ),
      );
    });
  }

  void _showMilestoneDetail(BuildContext context, MilestoneModel milestone) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textLightGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(milestone.iconEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                milestone.label ?? '',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _milestoneDescription(milestone),
                style: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (!milestone.isShared)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.markMilestoneShared(milestone);
                      Get.back();
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: Text(
                      'Share Achievement',
                      style: TextStyleCustom.outFitMedium500(fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeAccentSolid(context),
                      foregroundColor: whitePure(context),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _milestoneDescription(MilestoneModel milestone) {
    return switch (milestone.type) {
      'followers_100' => 'You reached 100 followers! Keep growing your community.',
      'followers_1k' => 'Amazing! 1,000 people are following your journey.',
      'followers_10k' => 'Incredible! 10K followers and counting!',
      'followers_100k' => 'You\'re a star! 100K followers believe in you.',
      'followers_1m' => 'Legendary! 1 million followers. You made it!',
      'viral_post' => 'One of your posts went viral with over 10K views!',
      'anniversary_1y' => 'Happy anniversary! You\'ve been creating for 1 year.',
      'first_post' => 'You published your very first post. Welcome!',
      'posts_100' => 'You\'ve created 100 posts. Consistency is key!',
      _ => 'Congratulations on this achievement!',
    };
  }
}

class _MilestoneCard extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isNew;
  final VoidCallback onTap;

  const _MilestoneCard({
    required this.milestone,
    required this.isNew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgMediumGrey(context),
          borderRadius: BorderRadius.circular(14),
          border: isNew
              ? Border.all(color: themeAccentSolid(context), width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NEW',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 8,
                    color: whitePure(context),
                  ),
                ),
              ),
            if (isNew) const SizedBox(height: 4),
            Text(milestone.iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              milestone.label ?? '',
              style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context),
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search Insights Section ─────────────────────────────────────────

class _SearchInsightsSection extends StatelessWidget {
  final CreatorDashboardController controller;

  const _SearchInsightsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show load button if not yet loaded
      if (controller.searchInsightsData.value == null &&
          !controller.isSearchInsightsLoading.value) {
        return GestureDetector(
          onTap: () => controller.fetchSearchInsights(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgMediumGrey(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_rounded, color: themeAccentSolid(context), size: 20),
                const SizedBox(width: 8),
                Text(
                  'View Search Insights',
                  style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.isSearchInsightsLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }

      final data = controller.searchInsightsData.value;
      if (data == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + period selector
          Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Search Insights',
                style: TextStyleCustom.unboundedMedium500(
                  color: textDarkGrey(context),
                  fontSize: 17,
                ),
              ),
              const Spacer(),
              _SearchPeriodChip(
                controller: controller,
                label: '7d',
                value: '7d',
              ),
              const SizedBox(width: 6),
              _SearchPeriodChip(
                controller: controller,
                label: '30d',
                value: '30d',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _MiniStatCard(
                  label: 'Total Searches',
                  value: '${data.totalSearches}',
                  icon: Icons.trending_up_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStatCard(
                  label: 'Unique Searchers',
                  value: '${data.uniqueSearchers}',
                  icon: Icons.people_outline_rounded,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trending searches
          if (data.trendingSearches?.isNotEmpty ?? false) ...[
            Text(
              'Trending Searches',
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...data.trendingSearches!.take(10).map(
                  (s) => _TrendingSearchRow(search: s),
                ),
            const SizedBox(height: 16),
          ],

          // Rising searches
          if (data.risingSearches?.isNotEmpty ?? false) ...[
            Text(
              'Rising Searches',
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            ...data.risingSearches!.take(8).map(
                  (s) => _RisingSearchRow(search: s),
                ),
            const SizedBox(height: 16),
          ],

          // Opportunity keywords
          if (data.lowResultSearches?.isNotEmpty ?? false) ...[
            Text(
              'Opportunity Keywords',
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Popular searches with few results — create content for these!',
              style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.lowResultSearches!.take(12).map((s) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${s.term ?? ''} (${s.searchCount})',
                    style: TextStyleCustom.outFitRegular400(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    });
  }
}

class _SearchPeriodChip extends StatelessWidget {
  final CreatorDashboardController controller;
  final String label;
  final String value;

  const _SearchPeriodChip({
    required this.controller,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.searchInsightsPeriod.value == value;
      return GestureDetector(
        onTap: () => controller.onSearchInsightsPeriodChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? themeAccentSolid(context) : bgMediumGrey(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            style: TextStyleCustom.outFitRegular400(
              color: isSelected ? Colors.white : textLightGrey(context),
              fontSize: 11,
            ),
          ),
        ),
      );
    });
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendingSearchRow extends StatelessWidget {
  final TrendingSearch search;

  const _TrendingSearchRow({required this.search});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              search.term ?? '',
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
                fontSize: 13,
              ),
            ),
          ),
          Text(
            '${search.searchCount} searches',
            style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${search.uniqueUsers} users',
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

class _RisingSearchRow extends StatelessWidget {
  final RisingSearch search;

  const _RisingSearchRow({required this.search});

  @override
  Widget build(BuildContext context) {
    final growth = search.olderCount > 0
        ? ((search.recentCount - search.olderCount) / search.olderCount * 100).round()
        : search.recentCount > 0
            ? 100
            : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              search.term ?? '',
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$growth%',
              style: TextStyleCustom.outFitMedium500(
                color: Colors.green,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${search.totalCount}',
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
