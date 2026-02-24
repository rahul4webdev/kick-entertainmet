import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/interest_model.dart';

class InterestSelectionScreenController extends BaseController {
  RxList<Interest> allInterests = <Interest>[].obs;
  RxSet<int> selectedIds = <int>{}.obs;
  RxBool isSaving = false.obs;
  RxBool isLoadingInterests = true.obs;

  @override
  void onInit() {
    super.onInit();
    _preSelectExisting();
    fetchInterests();
  }

  void _preSelectExisting() {
    String? existing = SessionManager.instance.getUser()?.interestIds;
    if (existing != null && existing.isNotEmpty) {
      selectedIds.addAll(existing.split(',').map(int.parse));
    }
  }

  Future<void> fetchInterests() async {
    isLoadingInterests.value = true;
    allInterests.value = await UserService.instance.fetchInterests();
    isLoadingInterests.value = false;
  }

  void toggleInterest(int id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  Future<void> saveInterests() async {
    isSaving.value = true;
    try {
      await UserService.instance
          .updateMyInterests(interestIds: selectedIds.toList());
      await UserService.instance.fetchUserDetails();
      showSnackBar(LKey.interestsSaved.tr);
    } catch (_) {}
    isSaving.value = false;
    Get.back(result: true);
  }
}
