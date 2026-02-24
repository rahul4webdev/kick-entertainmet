import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/restricted_user_model.dart';

class RestrictedUsersScreenController extends BaseController {
  RxList<RestrictedUsers> restrictedUsers = RxList<RestrictedUsers>();

  @override
  void onInit() {
    super.onInit();
    fetchRestrictedUsers();
  }

  Future<void> fetchRestrictedUsers() async {
    isLoading.value = true;
    List<RestrictedUsers> users =
        await UserService.instance.fetchMyRestrictedUsers();
    restrictedUsers.value = users;
    isLoading.value = false;
  }

  Future<void> unrestrictUser(RestrictedUsers restricted) async {
    await UserService.instance
        .unrestrictUser(userId: restricted.toUserId?.toInt() ?? 0);
    restrictedUsers
        .removeWhere((e) => e.toUserId == restricted.toUserId);
  }
}
