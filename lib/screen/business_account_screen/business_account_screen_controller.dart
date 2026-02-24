import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/user_model/profile_category_model.dart';

class BusinessAccountScreenController extends BaseController {
  RxInt currentStep = 0.obs;
  RxInt selectedAccountType = 0.obs;
  Rx<ProfileCategory?> selectedCategory = Rx(null);
  Rx<ProfileSubCategory?> selectedSubCategory = Rx(null);
  RxList<ProfileCategory> categories = <ProfileCategory>[].obs;
  RxBool isLoadingCategories = false.obs;
  PageController pageController = PageController();

  /// Current user's account type (0 = personal)
  int get currentAccountType =>
      SessionManager.instance.getUser()?.accountType ?? 0;

  @override
  void onInit() {
    super.onInit();
    // If user already has a business account, pre-set the type
    if (currentAccountType > 0) {
      selectedAccountType.value = currentAccountType;
    }
  }

  void selectAccountType(int type) {
    selectedAccountType.value = type;
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    fetchCategories();
    nextStep();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    categories.value = await UserService.instance
        .fetchProfileCategories(accountType: selectedAccountType.value);
    isLoadingCategories.value = false;
  }

  void selectCategory(ProfileCategory cat) {
    selectedCategory.value = cat;
    selectedSubCategory.value = null;
    if (cat.subCategories != null && cat.subCategories!.isNotEmpty) {
      nextStep();
    } else {
      submitConversion();
    }
  }

  void selectSubCategory(ProfileSubCategory sub) {
    selectedSubCategory.value = sub;
    submitConversion();
  }

  Future<void> submitConversion() async {
    showLoader();
    StatusModel result = await UserService.instance.convertToBusinessAccount(
      accountType: selectedAccountType.value,
      profileCategoryId: selectedCategory.value!.id!,
      profileSubCategoryId: selectedSubCategory.value?.id,
    );
    stopLoader();
    if (result.status == true) {
      await UserService.instance.fetchUserDetails();
      showSnackBar(result.message);
      Get.back(result: true);
    } else {
      showSnackBar(result.message);
    }
  }

  Future<void> revertToPersonal() async {
    showLoader();
    StatusModel result =
        await UserService.instance.revertToPersonalAccount();
    stopLoader();
    if (result.status == true) {
      await UserService.instance.fetchUserDetails();
      showSnackBar(result.message);
      Get.back(result: true);
    } else {
      showSnackBar(result.message);
    }
  }

  void nextStep() {
    currentStep.value++;
    pageController.animateToPage(currentStep.value,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void goBack() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(currentStep.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }
}
