import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/family_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/family/family_link_model.dart';

class ParentalControlController extends BaseController {
  RxList<FamilyLink> linkedTeens = <FamilyLink>[].obs;
  RxList<FamilyLink> linkedParents = <FamilyLink>[].obs;
  RxBool isLoadingData = false.obs;
  Rx<String?> currentPairingCode = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchLinkedAccounts();
  }

  Future<void> fetchLinkedAccounts() async {
    isLoadingData.value = true;
    try {
      final response = await FamilyService.instance.fetchLinkedAccounts();
      if (response.status == true && response.data != null) {
        linkedTeens.value = response.data!.linkedTeens ?? [];
        linkedParents.value = response.data!.linkedParents ?? [];
      }
    } catch (_) {}
    isLoadingData.value = false;
  }

  Future<void> generatePairingCode() async {
    showLoader();
    try {
      final response = await FamilyService.instance.generatePairingCode();
      stopLoader();
      if (response.status == true && response.data != null) {
        currentPairingCode.value = response.data!.pairingCode;
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> linkWithCode(String code) async {
    showLoader();
    try {
      final response = await FamilyService.instance.linkWithCode(pairingCode: code);
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.familyLinked);
        fetchLinkedAccounts();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> unlinkAccount(int linkId) async {
    showLoader();
    try {
      final response = await FamilyService.instance.unlinkAccount(linkId: linkId);
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.familyUnlinked);
        fetchLinkedAccounts();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> updateControls(int linkId, Map<String, dynamic> controls) async {
    showLoader();
    try {
      final response = await FamilyService.instance.updateControls(
        linkId: linkId,
        controls: controls,
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar(LKey.familyControlsUpdated);
        fetchLinkedAccounts();
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<ActivityReportData?> fetchActivityReport(int linkId) async {
    showLoader();
    try {
      final response = await FamilyService.instance.fetchActivityReport(linkId: linkId);
      stopLoader();
      if (response.status == true && response.data != null) {
        return response.data;
      } else {
        showSnackBar(response.message ?? LKey.somethingWentWrong);
      }
    } catch (_) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
    return null;
  }
}
