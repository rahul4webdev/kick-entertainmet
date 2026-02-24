import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/monetization_service.dart';
import 'package:shortzz/model/gift_wallet/coin_transaction_model.dart';
import 'package:shortzz/model/gift_wallet/earnings_summary_model.dart';
import 'package:shortzz/utilities/app_res.dart';

class EarningsDashboardScreenController extends BaseController {
  Rx<EarningsSummary?> summary = Rx(null);
  RxList<CoinTransaction> transactions = <CoinTransaction>[].obs;
  RxBool isSummaryLoading = true.obs;
  RxBool isTransactionsLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEarningsSummary();
    fetchTransactions();
  }

  Future<void> fetchEarningsSummary() async {
    isSummaryLoading.value = true;
    try {
      EarningsSummaryModel response =
          await MonetizationService.instance.fetchEarningsSummary();
      if (response.status == true) {
        summary.value = response.data;
      }
    } catch (_) {}
    isSummaryLoading.value = false;
  }

  Future<void> fetchTransactions() async {
    isTransactionsLoading.value = true;
    try {
      List<CoinTransaction> result =
          await MonetizationService.instance.fetchTransactionHistory();
      transactions.addAll(result);
    } catch (_) {}
    isTransactionsLoading.value = false;
  }

  void loadMoreTransactions() async {
    if (transactions.isEmpty) return;
    List<CoinTransaction> result = await MonetizationService.instance
        .fetchTransactionHistory(lastItemId: transactions.last.id);
    transactions.addAll(result);
  }

  bool get hasMoreData =>
      transactions.length >= AppRes.paginationLimit;
}
