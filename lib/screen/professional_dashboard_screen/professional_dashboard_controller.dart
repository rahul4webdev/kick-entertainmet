import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class ProfessionalDashboardController extends BaseController {
  Rx<User?> myUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    myUser.value = SessionManager.instance.getUser();
  }

  int get accountType => myUser.value?.accountType ?? 0;
  bool get isMonetized => myUser.value?.isMonetized == true;
  bool get hasSubscriptionsEnabled =>
      myUser.value?.subscriptionsEnabled == true;

  String get accountTypeLabel {
    switch (accountType) {
      case 1:
        return LKey.creatorLabel.tr;
      case 2:
        return LKey.businessText.tr;
      case 3:
        return LKey.productionHouse.tr;
      case 4:
        return LKey.newsMedia.tr;
      default:
        return '';
    }
  }

  String? get categoryName => myUser.value?.profileCategory?['name'];

  void refreshUser() {
    myUser.value = SessionManager.instance.getUser();
  }
}
