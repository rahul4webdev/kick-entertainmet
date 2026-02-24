import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';

class SensitiveContentScreenController extends BaseController {
  RxInt selectedLevel = 1.obs; // 0=allow, 1=limit, 2=limit even more

  @override
  void onInit() {
    super.onInit();
    final user = SessionManager.instance.getUser();
    selectedLevel.value = user?.sensitiveContentLevel ?? 1;
  }

  Future<void> setLevel(int level) async {
    if (selectedLevel.value == level) return;
    selectedLevel.value = level;
    await UserService.instance.updateUserDetails(
      sensitiveContentLevel: level,
    );
  }
}
