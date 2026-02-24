import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/muted_user_model.dart';

class MutedUsersScreenController extends BaseController {
  RxList<MutedUsers> mutedUsers = RxList<MutedUsers>();

  @override
  void onInit() {
    super.onInit();
    fetchMutedUsers();
  }

  Future<void> fetchMutedUsers() async {
    isLoading.value = true;
    List<MutedUsers> users = await UserService.instance.fetchMyMutedUsers();
    mutedUsers.value = users;
    isLoading.value = false;
  }

  Future<void> unmuteUser(MutedUsers muted) async {
    await UserService.instance.unMuteUser(userId: muted.toUserId?.toInt() ?? 0);
    mutedUsers.removeWhere((e) => e.toUserId == muted.toUserId);
  }
}
