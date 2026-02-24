import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/gift_wallet/earnings_summary_model.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class EarningsSummaryCard extends StatelessWidget {
  final EarningsSummary summary;

  const EarningsSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
        gradient: StyleRes.themeGradient,
      ),
      child: Column(
        children: [
          Text(
            LKey.totalEarnings.tr,
            style: TextStyleCustom.outFitLight300(
                color: whitePure(context).withValues(alpha: 0.8), fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            (summary.totalEarnings ?? 0).numberFormat,
            style: TextStyleCustom.unboundedExtraBold800(
                color: whitePure(context), fontSize: 36),
          ),
          Text(
            LKey.coins.tr,
            style: TextStyleCustom.outFitLight300(
                color: whitePure(context).withValues(alpha: 0.8), fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: LKey.todayEarnings.tr,
                  value: (summary.todayEarnings ?? 0).numberFormat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: LKey.thisMonth.tr,
                  value: (summary.thisMonthEarnings ?? 0).numberFormat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
        ),
        color: whitePure(context).withValues(alpha: 0.15),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyleCustom.unboundedSemiBold600(
                color: whitePure(context), fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyleCustom.outFitLight300(
                color: whitePure(context).withValues(alpha: 0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
