import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/moderation/moderation_log_model.dart';
import 'package:shortzz/model/moderation/moderation_stats_model.dart';
import 'package:shortzz/model/moderation/pending_report_model.dart';
import 'package:shortzz/model/moderation/user_violation_model.dart';

class ModerationService {
  ModerationService._();

  static final ModerationService instance = ModerationService._();

  Future<ModerationStats?> fetchModerationStats() async {
    ModerationStatsModel response = await ApiService.instance.call(
        url: WebService.moderation.fetchModerationStats,
        fromJson: ModerationStatsModel.fromJson,
        param: {});
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<List<PendingReport>> fetchPendingReports({
    String type = 'post',
    int? lastItemId,
  }) async {
    PendingReportsModel response = await ApiService.instance.call(
        url: WebService.moderation.fetchPendingReports,
        fromJson: PendingReportsModel.fromJson,
        param: {
          Params.type: type,
          Params.limit: 20,
          Params.lastItemId: lastItemId,
        });
    return response.data ?? [];
  }

  Future<StatusModel> resolveReport({
    required int reportId,
    required String type,
    required String action,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.moderation.resolveReport,
        fromJson: StatusModel.fromJson,
        param: {
          Params.reportId: reportId,
          Params.type: type,
          Params.action: action,
        });
    return response;
  }

  Future<StatusModel> issueViolation({
    required int userId,
    required int severity,
    required String reason,
    String? description,
    int? postId,
    int? reportId,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.moderation.issueViolation,
        fromJson: StatusModel.fromJson,
        param: {
          Params.userId: userId,
          Params.severity: severity,
          Params.reason: reason,
          if (description != null) Params.description: description,
          if (postId != null) Params.postId: postId,
          if (reportId != null) Params.reportId: reportId,
        });
    return response;
  }

  Future<UserViolationsData?> fetchUserViolations({required int userId}) async {
    UserViolationsModel response = await ApiService.instance.call(
        url: WebService.moderation.fetchUserViolations,
        fromJson: UserViolationsModel.fromJson,
        param: {
          Params.userId: userId,
        });
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<List<ModerationLogEntry>> fetchModerationLog({int? lastItemId}) async {
    ModerationLogListModel response = await ApiService.instance.call(
        url: WebService.moderation.fetchModerationLog,
        fromJson: ModerationLogListModel.fromJson,
        param: {
          Params.limit: 30,
          Params.lastItemId: lastItemId,
        });
    return response.data ?? [];
  }

  Future<StatusModel> freezeUser({
    required int userId,
    String? reason,
    int? banDays,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.moderation.moderatorFreezeUser,
        fromJson: StatusModel.fromJson,
        param: {
          Params.userId: userId,
          if (reason != null) Params.reason: reason,
          if (banDays != null) Params.banDays: banDays,
        });
    return response;
  }

  Future<StatusModel> unfreezeUser({required int userId}) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.moderation.moderatorUnFreezeUser,
        fromJson: StatusModel.fromJson,
        param: {
          Params.userId: userId,
        });
    return response;
  }

  Future<StatusModel> deletePost({required int postId}) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.moderation.moderatorDeletePost,
        fromJson: StatusModel.fromJson,
        param: {
          Params.postId: postId,
        });
    return response;
  }
}
