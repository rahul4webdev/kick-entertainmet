import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/favorite_user_model.dart';

class FavoriteUsersScreenController extends BaseController {
  RxList<FavoriteUser> favoriteUsers = RxList<FavoriteUser>();

  @override
  void onInit() {
    super.onInit();
    fetchFavoriteUsers();
  }

  Future<void> fetchFavoriteUsers() async {
    isLoading.value = true;
    List<FavoriteUser> users = await UserService.instance.fetchMyFavorites();
    favoriteUsers.value = users;
    isLoading.value = false;
  }

  Future<void> removeFromFavorites(FavoriteUser favorite) async {
    await UserService.instance
        .removeFromFavorites(userId: favorite.toUserId?.toInt() ?? 0);
    favoriteUsers.removeWhere((e) => e.toUserId == favorite.toUserId);
  }
}
