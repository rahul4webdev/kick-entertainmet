class UserViolationsModel {
  bool? status;
  String? message;
  UserViolationsData? data;

  UserViolationsModel({this.status, this.message, this.data});

  UserViolationsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? UserViolationsData.fromJson(json['data']) : null;
  }
}

class UserViolationsData {
  List<UserViolation>? violations;
  int? violationCount;
  bool? isBanned;
  String? banUntil;
  String? banReason;

  UserViolationsData({
    this.violations,
    this.violationCount,
    this.isBanned,
    this.banUntil,
    this.banReason,
  });

  UserViolationsData.fromJson(Map<String, dynamic> json) {
    violationCount = json['violation_count'];
    isBanned = json['is_banned'];
    banUntil = json['ban_until'];
    banReason = json['ban_reason'];
    if (json['violations'] != null) {
      violations = (json['violations'] as List)
          .map((e) => UserViolation.fromJson(e))
          .toList();
    }
  }
}

class UserViolation {
  int? id;
  int? userId;
  int? moderatorId;
  int? severity;
  String? reason;
  String? description;
  int? referencePostId;
  int? referenceReportId;
  String? actionTaken;
  int? banDays;
  String? createdAt;

  UserViolation({
    this.id,
    this.userId,
    this.moderatorId,
    this.severity,
    this.reason,
    this.description,
    this.referencePostId,
    this.referenceReportId,
    this.actionTaken,
    this.banDays,
    this.createdAt,
  });

  UserViolation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    moderatorId = json['moderator_id'];
    severity = json['severity'];
    reason = json['reason'];
    description = json['description'];
    referencePostId = json['reference_post_id'];
    referenceReportId = json['reference_report_id'];
    actionTaken = json['action_taken'];
    banDays = json['ban_days'];
    createdAt = json['created_at'];
  }
}
