import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/creator_dashboard_service.dart';
import 'package:shortzz/common/service/api/milestone_service.dart';
import 'package:shortzz/model/creator/creator_dashboard_model.dart';
import 'package:shortzz/model/creator/milestone_model.dart';

class CreatorDashboardController extends BaseController {
  Rx<CreatorDashboardData?> dashboardData = Rx(null);
  Rx<AudienceInsightsData?> audienceData = Rx(null);
  Rx<SearchInsightsData?> searchInsightsData = Rx(null);
  RxString selectedPeriod = '30d'.obs;
  RxBool isAudienceLoading = false.obs;
  RxBool isSearchInsightsLoading = false.obs;
  RxString searchInsightsPeriod = '7d'.obs;

  // Milestones
  RxList<MilestoneModel> milestones = <MilestoneModel>[].obs;
  RxList<MilestoneModel> newMilestones = <MilestoneModel>[].obs;

  // Period options
  final List<String> periodOptions = ['7d', '30d', '90d', 'all'];

  String periodLabel(String period) => switch (period) {
        '7d' => 'Last 7 Days',
        '30d' => 'Last 30 Days',
        '90d' => 'Last 90 Days',
        'all' => 'All Time',
        _ => period,
      };

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchAudience();
    fetchSearchInsights();
    _fetchMilestones();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;
    try {
      dashboardData.value = await CreatorDashboardService.instance
          .fetchCreatorDashboard(period: selectedPeriod.value);
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> fetchAudience() async {
    isAudienceLoading.value = true;
    try {
      audienceData.value =
          await CreatorDashboardService.instance.fetchAudienceInsights();
    } catch (_) {}
    isAudienceLoading.value = false;
  }

  Future<void> _fetchMilestones() async {
    try {
      final newOnes = await MilestoneService.instance.checkMilestones();
      newMilestones.value = newOnes;
      final all = await MilestoneService.instance.fetchMyMilestones();
      milestones.value = all;
    } catch (_) {}
  }

  Future<void> markMilestoneSeen(MilestoneModel milestone) async {
    if (milestone.id == null) return;
    await MilestoneService.instance.markMilestoneSeen(milestoneId: milestone.id!);
    milestone.isSeen = true;
    milestones.refresh();
  }

  Future<void> markMilestoneShared(MilestoneModel milestone) async {
    if (milestone.id == null) return;
    await MilestoneService.instance.markMilestoneShared(milestoneId: milestone.id!);
    milestone.isShared = true;
    milestones.refresh();
  }

  void onPeriodChanged(String period) {
    selectedPeriod.value = period;
    fetchDashboard();
  }

  Future<void> fetchSearchInsights() async {
    isSearchInsightsLoading.value = true;
    try {
      searchInsightsData.value = await CreatorDashboardService.instance
          .fetchSearchInsights(period: searchInsightsPeriod.value);
    } catch (_) {}
    isSearchInsightsLoading.value = false;
  }

  void onSearchInsightsPeriodChanged(String period) {
    searchInsightsPeriod.value = period;
    fetchSearchInsights();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboard(),
      fetchAudience(),
      fetchSearchInsights(),
      _fetchMilestones(),
    ]);
  }
}
