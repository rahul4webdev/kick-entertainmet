import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/interest_model.dart';

class FeedPreferencesScreenController extends BaseController {
  RxList<Interest> interests = <Interest>[].obs;
  RxMap<int, int> preferences = <int, int>{}.obs; // interest_id -> weight (-1, 0, 1)
  RxBool isDataLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isDataLoading.value = true;
    final results = await Future.wait([
      UserService.instance.fetchInterests(),
      UserService.instance.fetchFeedPreferences(),
    ]);
    interests.value = results[0] as List<Interest>;
    preferences.value = results[1] as Map<int, int>;
    isDataLoading.value = false;
  }

  int getWeight(int interestId) {
    return preferences[interestId] ?? 0;
  }

  String getWeightLabel(int weight) {
    switch (weight) {
      case 1:
        return LKey.seeMore;
      case -1:
        return LKey.seeLess;
      default:
        return LKey.normal;
    }
  }

  Future<void> cycleWeight(int interestId) async {
    final current = getWeight(interestId);
    final next = switch (current) {
      0 => 1,
      1 => -1,
      _ => 0,
    };
    preferences[interestId] = next;
    await UserService.instance.updateFeedPreference(
      interestId: interestId,
      weight: next,
    );
  }
}
