import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/monetization_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/gift_wallet/monetization_status_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class MonetizationScreenController extends BaseController {
  Rx<MonetizationStatusData?> statusData = Rx(null);
  RxBool isDataLoading = true.obs;
  RxBool isUploading = false.obs;

  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    isDataLoading.value = true;
    try {
      MonetizationStatusModel response =
          await MonetizationService.instance.fetchMonetizationStatus();
      if (response.status == true) {
        statusData.value = response.data;
      }
    } catch (_) {}
    isDataLoading.value = false;
  }

  Future<void> uploadKycDocument(String documentType) async {
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    isUploading.value = true;
    try {
      StatusModel response = await MonetizationService.instance
          .submitKycDocument(document: file, documentType: documentType);
      showSnackBar(response.message);
      if (response.status == true) {
        fetchStatus();
      }
    } catch (_) {}
    isUploading.value = false;
  }

  Future<void> applyForMonetization() async {
    showLoader();
    try {
      UserModel response =
          await MonetizationService.instance.applyForMonetization();
      if (response.status == true && response.data != null) {
        await UserService.instance.fetchUserDetails();
        fetchStatus();
      }
      showSnackBar(response.message);
    } catch (_) {}
    stopLoader();
  }
}
