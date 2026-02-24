import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/marketplace_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/marketplace/marketplace_model.dart';

class MarketplaceController extends BaseController {
  RxList<MarketplaceCampaign> campaigns = <MarketplaceCampaign>[].obs;
  RxList<MarketplaceCampaign> myCampaigns = <MarketplaceCampaign>[].obs;
  RxList<MarketplaceProposal> myProposals = <MarketplaceProposal>[].obs;
  RxBool isLoadingCampaigns = true.obs;
  RxBool isLoadingMyCampaigns = false.obs;
  RxBool isLoadingProposals = false.obs;
  RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns({bool reset = false}) async {
    if (reset) campaigns.clear();
    isLoadingCampaigns.value = true;
    try {
      final response = await MarketplaceService.instance.fetchCampaigns(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        lastItemId: campaigns.isNotEmpty ? campaigns.last.id : null,
      );
      if (response.status == true && response.data != null) {
        if (reset) {
          campaigns.value = response.data!;
        } else {
          campaigns.addAll(response.data!);
        }
      }
    } catch (_) {}
    isLoadingCampaigns.value = false;
  }

  Future<void> fetchMyCampaigns() async {
    isLoadingMyCampaigns.value = true;
    try {
      final response = await MarketplaceService.instance.fetchMyCampaigns();
      if (response.status == true && response.data != null) {
        myCampaigns.value = response.data!;
      }
    } catch (_) {}
    isLoadingMyCampaigns.value = false;
  }

  Future<void> fetchMyProposals() async {
    isLoadingProposals.value = true;
    try {
      final response = await MarketplaceService.instance.fetchMyProposals();
      if (response.status == true && response.data != null) {
        myProposals.value = response.data!;
      }
    } catch (_) {}
    isLoadingProposals.value = false;
  }

  Future<void> applyToCampaign(int campaignId, {String? message, int? offeredCoins}) async {
    showLoader();
    try {
      final response = await MarketplaceService.instance.applyToCampaign(
        campaignId: campaignId,
        message: message,
        offeredCoins: offeredCoins,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.applicationSubmitted);
        // Update the campaign's hasApplied flag locally
        final idx = campaigns.indexWhere((c) => c.id == campaignId);
        if (idx != -1) {
          campaigns[idx].hasApplied = true;
          campaigns.refresh();
        }
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> createCampaign({
    required String title,
    required int budgetCoins,
    String? description,
    String? category,
    int? minFollowers,
    String? requirements,
    int? maxCreators,
    String? deadline,
  }) async {
    showLoader();
    try {
      final response = await MarketplaceService.instance.createCampaign(
        title: title,
        budgetCoins: budgetCoins,
        description: description,
        category: category,
        minFollowers: minFollowers,
        requirements: requirements,
        maxCreators: maxCreators,
        deadline: deadline,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.campaignCreated);
        fetchMyCampaigns();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> deleteCampaign(int campaignId) async {
    showLoader();
    try {
      final response = await MarketplaceService.instance.deleteCampaign(
        campaignId: campaignId,
      );
      stopLoader();
      if (response.status == true) {
        myCampaigns.removeWhere((c) => c.id == campaignId);
        showSnackBar(LKey.campaignDeleted);
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> respondToProposal(int proposalId, String action) async {
    showLoader();
    try {
      final response = await MarketplaceService.instance.respondToProposal(
        proposalId: proposalId,
        action: action,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(response.message ?? 'Done');
        fetchMyProposals();
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
    fetchCampaigns(reset: true);
  }
}
