import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/creator/milestone_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class MilestoneService {
  MilestoneService._();
  static final MilestoneService instance = MilestoneService._();

  Future<List<MilestoneModel>> fetchMyMilestones() async {
    final response = await ApiService.instance.call(
      url: WebService.milestone.fetchMyMilestones,
      param: {},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      final list = response['data'] as List;
      return list
          .map((e) => MilestoneModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<MilestoneModel>> checkMilestones() async {
    final response = await ApiService.instance.call(
      url: WebService.milestone.checkMilestones,
      param: {},
      fromJson: (json) => json,
    );
    if (response['status'] == true && response['data'] != null) {
      final data = Map<String, dynamic>.from(response['data']);
      final newList = data['new_milestones'] as List? ?? [];
      return newList
          .map((e) => MilestoneModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<StatusModel> markMilestoneSeen({required int milestoneId}) async {
    return await ApiService.instance.call(
      url: WebService.milestone.markMilestoneSeen,
      param: {'milestone_id': milestoneId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> markMilestoneShared({required int milestoneId}) async {
    return await ApiService.instance.call(
      url: WebService.milestone.markMilestoneShared,
      param: {'milestone_id': milestoneId},
      fromJson: StatusModel.fromJson,
    );
  }
}
