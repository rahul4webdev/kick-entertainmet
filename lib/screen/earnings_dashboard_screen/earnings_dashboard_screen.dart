import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/gift_wallet/coin_transaction_model.dart';
import 'package:shortzz/screen/earnings_dashboard_screen/earnings_dashboard_screen_controller.dart';
import 'package:shortzz/screen/earnings_dashboard_screen/widget/earnings_summary_card.dart';
import 'package:shortzz/screen/earnings_dashboard_screen/widget/top_supporters_list.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EarningsDashboardScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.earnings.tr),
          Expanded(
            child: Obx(() {
              if (controller.isSummaryLoading.value) {
                return const LoaderWidget();
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 100) {
                    controller.loadMoreTransactions();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.summary.value != null)
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: EarningsSummaryCard(
                              summary: controller.summary.value!),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Text(
                          LKey.topSupporters.tr,
                          style: TextStyleCustom.unboundedMedium500(
                              color: textDarkGrey(context), fontSize: 17),
                        ),
                      ),
                      TopSupportersList(
                        supporters:
                            controller.summary.value?.topSupporters ?? [],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        child: Text(
                          LKey.transactionHistory.tr,
                          style: TextStyleCustom.unboundedMedium500(
                              color: textDarkGrey(context), fontSize: 17),
                        ),
                      ),
                      _TransactionList(controller: controller),
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

class _TransactionList extends StatelessWidget {
  final EarningsDashboardScreenController controller;

  const _TransactionList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isTransactionsLoading.value &&
          controller.transactions.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: LoaderWidget(),
        );
      }

      return NoDataView(
        showShow: !controller.isTransactionsLoading.value &&
            controller.transactions.isEmpty,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactions.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            CoinTransaction txn = controller.transactions[index];
            return _TransactionTile(txn: txn);
          },
        ),
      );
    });
  }
}

class _TransactionTile extends StatelessWidget {
  final CoinTransaction txn;

  const _TransactionTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final bool isCredit = txn.isCredit;
    final Color amountColor = isCredit ? Colors.green : Colors.red;
    final String prefix = isCredit ? '+' : '-';

    return Container(
      color: bgLightGrey(context),
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: amountColor.withValues(alpha: 0.1),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.typeLabel,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 15),
                ),
                if (txn.relatedUser != null)
                  Text(
                    '@${txn.relatedUser?.username ?? ''}',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 13),
                  ),
                Text(
                  (txn.createdAt ?? '').formatDate1,
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetRes.icCoin, width: 16, height: 16),
              const SizedBox(width: 4),
              Text(
                '$prefix${(txn.coins ?? 0).numberFormat}',
                style: TextStyleCustom.unboundedSemiBold600(
                    color: amountColor, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
