import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/payment_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/model/payment/payment_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

// ─── Controller ─────────────────────────────────────────────

class _SellerDashboardController extends GetxController {
  final isLoading = true.obs;
  final Rxn<SellerEarningsData> earnings = Rxn<SellerEarningsData>();

  @override
  void onInit() {
    super.onInit();
    fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      final result = await PaymentService.instance.getSellerEarnings();
      if (result.status == true && result.data != null) {
        earnings.value = result.data;
      } else {
        BaseController.share.showSnackBar(result.message ?? 'Failed to load earnings');
      }
    } catch (e) {
      BaseController.share.showSnackBar('Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }
}

// ─── Screen ─────────────────────────────────────────────────

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_SellerDashboardController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          'Seller Dashboard',
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoaderWidget();
        }

        final data = controller.earnings.value;
        if (data == null) {
          return _EmptyState(onRetry: controller.fetchEarnings);
        }

        return RefreshIndicator(
          color: themeAccentSolid(context),
          onRefresh: controller.fetchEarnings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 2x2 Stat Cards ──
                _EarningsGrid(summary: data.summary),
                const SizedBox(height: 16),

                // ── Stats Row ──
                _StatsRow(summary: data.summary),
                const SizedBox(height: 20),

                // ── Monthly Summary ──
                _MonthlySummaryCard(summary: data.summary),
                const SizedBox(height: 20),

                // ── Payout History ──
                _PayoutHistorySection(payouts: data.recentPayouts),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined,
              size: 56, color: textLightGrey(context)),
          const SizedBox(height: 14),
          Text(
            'No earnings data available',
            style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context), fontSize: 15),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: ShapeDecoration(
                color: themeAccentSolid(context),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                'Retry',
                style: TextStyleCustom.outFitMedium500(
                    color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2x2 Earnings Grid ─────────────────────────────────────

class _EarningsGrid extends StatelessWidget {
  final EarningsSummary? summary;
  const _EarningsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Wallet Balance',
                amount: summary?.walletBalanceRupees ?? 0,
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Pending Payout',
                amount: summary?.pendingPayoutRupees ?? 0,
                icon: Icons.schedule_outlined,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'In Hold',
                amount: summary?.inHoldRupees ?? 0,
                icon: Icons.lock_outline,
                color: const Color(0xFFF44336),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Lifetime Earnings',
                amount: summary?.lifetimeEarningsRupees ?? 0,
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .08),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          side: BorderSide(color: color.withValues(alpha: .2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatRupees(amount),
            style: TextStyleCustom.unboundedSemiBold600(
                color: textDarkGrey(context), fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ──────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final EarningsSummary? summary;
  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Total Orders',
              value: '${summary?.totalOrdersCount ?? 0}',
              icon: Icons.shopping_bag_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: bgMediumGrey(context),
          ),
          Expanded(
            child: _MiniStat(
              label: 'This Month',
              value: _formatRupees(summary?.currentMonthRupees ?? 0),
              icon: Icons.calendar_today_outlined,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: bgMediumGrey(context),
          ),
          Expanded(
            child: _MiniStat(
              label: 'Last Month',
              value: _formatRupees(summary?.previousMonthRupees ?? 0),
              icon: Icons.history_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: textLightGrey(context)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyleCustom.outFitLight300(
              color: textLightGrey(context), fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Monthly Summary Card ───────────────────────────────────

class _MonthlySummaryCard extends StatelessWidget {
  final EarningsSummary? summary;
  const _MonthlySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            'Monthly Summary',
            style: TextStyleCustom.unboundedMedium500(
                color: textDarkGrey(context), fontSize: 15),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Total Sales',
            value: _formatRupees(summary?.currentMonthRupees ?? 0),
            color: textDarkGrey(context),
            isBold: true,
          ),
          const SizedBox(height: 4),
          Divider(color: bgMediumGrey(context), height: 16),
          _SummaryRow(
            label: 'Platform Commission',
            value: '- ${_formatRupees(_estimateDeduction(summary?.currentMonthRupees ?? 0, 0.10))}',
            color: const Color(0xFFF44336),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'TCS (1%)',
            value: '- ${_formatRupees(_estimateDeduction(summary?.currentMonthRupees ?? 0, 0.01))}',
            color: const Color(0xFFF44336),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'TDS (1%)',
            value: '- ${_formatRupees(_estimateDeduction(summary?.currentMonthRupees ?? 0, 0.01))}',
            color: const Color(0xFFF44336),
          ),
          Divider(color: bgMediumGrey(context), height: 20),
          _SummaryRow(
            label: 'Net Earnings',
            value: _formatRupees(_estimateNet(summary?.currentMonthRupees ?? 0)),
            color: const Color(0xFF4CAF50),
            isBold: true,
          ),
        ],
      ),
    );
  }

  double _estimateDeduction(double total, double rate) {
    return total * rate;
  }

  double _estimateNet(double total) {
    // Net = total - commission(10%) - TCS(1%) - TDS(1%) = 88%
    return total * 0.88;
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 13)
              : TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context), fontSize: 13),
        ),
        Text(
          value,
          style: isBold
              ? TextStyleCustom.outFitMedium500(color: color, fontSize: 14)
              : TextStyleCustom.outFitRegular400(color: color, fontSize: 13),
        ),
      ],
    );
  }
}

// ─── Payout History ─────────────────────────────────────────

class _PayoutHistorySection extends StatelessWidget {
  final List<PayoutEntry>? payouts;
  const _PayoutHistorySection({required this.payouts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payout History',
          style: TextStyleCustom.unboundedMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 12),
        if (payouts == null || payouts!.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: ShapeDecoration(
              color: bgLightGrey(context),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 36, color: textLightGrey(context)),
                const SizedBox(height: 8),
                Text(
                  'No payouts yet',
                  style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context), fontSize: 13),
                ),
              ],
            ),
          )
        else
          ...payouts!.map((payout) => _PayoutTile(payout: payout)),
      ],
    );
  }
}

class _PayoutTile extends StatelessWidget {
  final PayoutEntry payout;
  const _PayoutTile({required this.payout});

  @override
  Widget build(BuildContext context) {
    final statusInfo = _payoutStatusInfo(payout.status);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: statusInfo.color.withValues(alpha: .1),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
              ),
            ),
            child: Icon(statusInfo.icon, size: 20, color: statusInfo.color),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatRupees(payout.amountRupees),
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 15),
                    ),
                    _StatusBadge(
                      label: statusInfo.label,
                      color: statusInfo.color,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (payout.method != null) ...[
                      Text(
                        payout.method!.capitalizeFirst ?? '',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                      Text(
                        '  |  ',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                    ],
                    Text(
                      _formatDate(payout.createdAt),
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 11),
                    ),
                  ],
                ),
                if (payout.utrNumber != null &&
                    payout.utrNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'UTR: ${payout.utrNumber}',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ───────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: .1),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 6, cornerSmoothing: 1),
        ),
      ),
      child: Text(
        label,
        style: TextStyleCustom.outFitMedium500(color: color, fontSize: 10),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────

String _formatRupees(double amount) {
  if (amount == 0) return '\u20B90';
  if (amount == amount.truncateToDouble()) {
    return '\u20B9${amount.toInt()}';
  }
  return '\u20B9${amount.toStringAsFixed(2)}';
}

String _formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateStr);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return dateStr;
  }
}

({String label, Color color, IconData icon}) _payoutStatusInfo(String? status) {
  switch (status?.toLowerCase()) {
    case 'completed':
      return (
        label: 'Completed',
        color: const Color(0xFF4CAF50),
        icon: Icons.check_circle_outline,
      );
    case 'processing':
      return (
        label: 'Processing',
        color: const Color(0xFF2196F3),
        icon: Icons.sync_outlined,
      );
    case 'failed':
      return (
        label: 'Failed',
        color: const Color(0xFFF44336),
        icon: Icons.error_outline,
      );
    case 'pending':
    default:
      return (
        label: 'Pending',
        color: const Color(0xFFFF9800),
        icon: Icons.schedule_outlined,
      );
  }
}
