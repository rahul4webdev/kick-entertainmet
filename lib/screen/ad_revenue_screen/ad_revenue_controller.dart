import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/ad_revenue_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/ad_revenue/ad_revenue_model.dart';

class AdRevenueController extends BaseController {
  Rx<AdRevenueStatusData?> statusData = Rx(null);
  Rx<AdRevenueSummary?> summary = Rx(null);
  RxBool isLoadingStatus = true.obs;
  RxBool isLoadingSummary = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    isLoadingStatus.value = true;
    try {
      final response = await AdRevenueService.instance.fetchAdRevenueStatus();
      if (response.status == true) {
        statusData.value = response.data;
        if (response.data?.isEnrolled == true) {
          fetchSummary();
        }
      }
    } catch (_) {}
    isLoadingStatus.value = false;
  }

  Future<void> fetchSummary() async {
    isLoadingSummary.value = true;
    try {
      final response =
          await AdRevenueService.instance.fetchAdRevenueSummary();
      if (response.status == true) {
        summary.value = response.data;
      }
    } catch (_) {}
    isLoadingSummary.value = false;
  }

  Future<void> enroll() async {
    showLoader();
    try {
      final response =
          await AdRevenueService.instance.enrollInAdRevenueShare();
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.enrollmentSubmitted);
        fetchStatus();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }
}
