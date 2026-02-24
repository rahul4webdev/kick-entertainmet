import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/affiliate_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/affiliate/affiliate_model.dart';
import 'package:shortzz/model/product/product_model.dart';

class AffiliateController extends BaseController {
  RxList<Product> affiliateProducts = <Product>[].obs;
  RxList<AffiliateLink> myLinks = <AffiliateLink>[].obs;
  RxList<AffiliateEarning> earnings = <AffiliateEarning>[].obs;
  Rx<AffiliateDashboardData?> dashboardData = Rx(null);
  RxBool isLoadingProducts = true.obs;
  RxBool isLoadingLinks = false.obs;
  RxBool isLoadingEarnings = false.obs;
  RxBool isLoadingDashboard = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchMyLinks();
  }

  Future<void> fetchDashboard() async {
    isLoadingDashboard.value = true;
    try {
      final response = await AffiliateService.instance.fetchAffiliateDashboard();
      if (response.status == true && response.data != null) {
        dashboardData.value = response.data;
      }
    } catch (_) {}
    isLoadingDashboard.value = false;
  }

  Future<void> fetchAffiliateProducts({bool reset = false}) async {
    if (reset) affiliateProducts.clear();
    isLoadingProducts.value = true;
    try {
      final response = await AffiliateService.instance.fetchAffiliateProducts(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        lastItemId: affiliateProducts.isNotEmpty ? affiliateProducts.last.id : null,
      );
      if (response.status == true && response.data != null) {
        if (reset) {
          affiliateProducts.value = response.data!;
        } else {
          affiliateProducts.addAll(response.data!);
        }
      }
    } catch (_) {}
    isLoadingProducts.value = false;
  }

  Future<void> fetchMyLinks() async {
    isLoadingLinks.value = true;
    try {
      final response = await AffiliateService.instance.fetchMyAffiliateLinks();
      if (response.status == true && response.data != null) {
        myLinks.value = response.data!;
      }
    } catch (_) {}
    isLoadingLinks.value = false;
  }

  Future<void> fetchEarnings() async {
    isLoadingEarnings.value = true;
    try {
      final response = await AffiliateService.instance.fetchAffiliateEarnings();
      if (response.status == true && response.data != null) {
        earnings.value = response.data!;
      }
    } catch (_) {}
    isLoadingEarnings.value = false;
  }

  Future<void> createAffiliateLink(int productId) async {
    showLoader();
    try {
      final response = await AffiliateService.instance.createAffiliateLink(
        productId: productId,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.affiliateLinkCreated);
        // Mark product as linked locally
        final idx = affiliateProducts.indexWhere((p) => p.id == productId);
        if (idx != -1) {
          affiliateProducts[idx].hasAffiliateLink = true;
          affiliateProducts.refresh();
        }
        // Refresh links and dashboard
        fetchMyLinks();
        fetchDashboard();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> removeAffiliateLink(int linkId) async {
    showLoader();
    try {
      final response = await AffiliateService.instance.removeAffiliateLink(
        linkId: linkId,
      );
      stopLoader();
      if (response.status == true) {
        myLinks.removeWhere((l) => l.id == linkId);
        showSnackBar(LKey.affiliateLinkRemoved);
        fetchDashboard();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    fetchAffiliateProducts(reset: true);
  }
}
