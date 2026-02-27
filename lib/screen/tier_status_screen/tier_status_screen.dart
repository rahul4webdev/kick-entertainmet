import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/common/service/api/gift_wallet_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/model/monetization/tier_status_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TierStatusScreen extends StatefulWidget {
  const TierStatusScreen({super.key});

  @override
  State<TierStatusScreen> createState() => _TierStatusScreenState();
}

class _TierStatusScreenState extends State<TierStatusScreen> {
  TierStatusData? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final result = await GiftWalletService.instance.fetchMyTierStatus();
      if (mounted) {
        setState(() {
          data = result;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Color _tierColor(int? level) {
    switch (level) {
      case 1:
        return const Color(0xFFCD7F32);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFFFD700);
      case 4:
        return const Color(0xFFE5E4E2);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Creator Tier'),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (data == null)
            Expanded(
              child: Center(
                child: Text('Unable to load tier status',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 16, color: textLightGrey(context))),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCurrentTierCard(context),
                    const SizedBox(height: 16),
                    if (data!.progress != null) _buildProgressSection(context),
                    const SizedBox(height: 16),
                    _buildStatsCard(context),
                    const SizedBox(height: 16),
                    if (data!.commissionRate != null)
                      _buildCommissionCard(context),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentTierCard(BuildContext context) {
    final tier = data!.currentTier;
    final tierName = tier?.name ?? 'No Tier';
    final tierLevel = tier?.level ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        gradient: tierLevel > 0 ? StyleRes.themeGradient : null,
        color: tierLevel > 0 ? null : bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tierLevel > 0
                  ? Colors.white.withValues(alpha: 0.2)
                  : disableGrey(context),
            ),
            child: Center(
              child: Image.asset(AssetRes.icCoin, width: 36, height: 36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tierName,
            style: TextStyleCustom.outFitBold700(
              fontSize: 24,
              color: tierLevel > 0 ? Colors.white : blackPure(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tierLevel > 0 ? 'Creator Tier $tierLevel' : 'Keep creating to earn a tier!',
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: tierLevel > 0
                  ? Colors.white.withValues(alpha: 0.8)
                  : textLightGrey(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final progress = data!.progress!;
    final nextTier = data!.nextTier;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progress to ',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 16, color: blackPure(context)),
              ),
              Text(
                nextTier?.name ?? 'Next Tier',
                style: TextStyleCustom.outFitBold700(
                  fontSize: 16,
                  color: _tierColor(nextTier?.level),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (progress.followers != null)
            _buildProgressBar(
              context,
              label: 'Followers',
              current: progress.followers!.current ?? 0,
              required_: progress.followers!.required_ ?? 0,
              percentage: progress.followers!.percentage ?? 0,
            ),
          const SizedBox(height: 12),
          if (progress.views != null)
            _buildProgressBar(
              context,
              label: 'Total Views',
              current: progress.views!.current ?? 0,
              required_: progress.views!.required_ ?? 0,
              percentage: progress.views!.percentage ?? 0,
            ),
          const SizedBox(height: 12),
          if (progress.likes != null)
            _buildProgressBar(
              context,
              label: 'Total Likes',
              current: progress.likes!.current ?? 0,
              required_: progress.likes!.required_ ?? 0,
              percentage: progress.likes!.percentage ?? 0,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context, {
    required String label,
    required int current,
    required int required_,
    required double percentage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 13, color: blackPure(context))),
            Text(
              '$current / ${_formatNumber(required_)}',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: disableGrey(context),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final stats = data!.stats;
    if (stats == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tip Stats',
              style: TextStyleCustom.outFitBold700(
                  fontSize: 16, color: blackPure(context))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: AssetRes.icCoin,
                  label: 'Total Tips',
                  value: '${stats.totalTipsReceived ?? 0}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: AssetRes.icCoin,
                  label: 'This Month',
                  value: '${stats.tipsThisMonth ?? 0}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyleCustom.outFitBold700(
                  fontSize: 20, color: blackPure(context))),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textLightGrey(context))),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commission Rate',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: blackPure(context))),
                const SizedBox(height: 4),
                Text(
                  'Applied on withdrawals',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 12, color: textLightGrey(context)),
                ),
              ],
            ),
          ),
          Text(
            '${data!.commissionRate?.toStringAsFixed(0) ?? '15'}%',
            style: TextStyleCustom.outFitBold700(
                fontSize: 24, color: themeColor(context)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
