import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/favorite_user_model.dart';

class CloseFriendsScreenController extends BaseController {
  RxList<FavoriteUser> closeFriends = RxList<FavoriteUser>();

  @override
  void onInit() {
    super.onInit();
    fetchCloseFriends();
  }

  Future<void> fetchCloseFriends() async {
    isLoading.value = true;
    List<FavoriteUser> users = await UserService.instance.fetchMyCloseFriends();
    closeFriends.value = users;
    isLoading.value = false;
  }

  Future<void> removeCloseFriend(FavoriteUser friend) async {
    await UserService.instance
        .removeCloseFriend(userId: friend.toUserId?.toInt() ?? 0);
    closeFriends.removeWhere((e) => e.toUserId == friend.toUserId);
  }
}
