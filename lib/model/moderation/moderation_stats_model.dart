class ModerationStatsModel {
  bool? status;
  String? message;
  ModerationStats? data;

  ModerationStatsModel({this.status, this.message, this.data});

  ModerationStatsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ModerationStats.fromJson(json['data']) : null;
  }
}

class ModerationStats {
  int? pendingPostReports;
  int? pendingUserReports;
  int? totalPending;
  int? myTotalActions;
  int? myActionsToday;
  int? recentViolations7d;

  ModerationStats({
    this.pendingPostReports,
    this.pendingUserReports,
    this.totalPending,
    this.myTotalActions,
    this.myActionsToday,
    this.recentViolations7d,
  });

  ModerationStats.fromJson(Map<String, dynamic> json) {
    pendingPostReports = json['pending_post_reports'];
    pendingUserReports = json['pending_user_reports'];
    totalPending = json['total_pending'];
    myTotalActions = json['my_total_actions'];
    myActionsToday = json['my_actions_today'];
    recentViolations7d = json['recent_violations_7d'];
  }
}
