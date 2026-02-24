class ModerationLogListModel {
  bool? status;
  String? message;
  List<ModerationLogEntry>? data;

  ModerationLogListModel({this.status, this.message, this.data});

  ModerationLogListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => ModerationLogEntry.fromJson(e))
          .toList();
    }
  }
}

class ModerationLogEntry {
  int? id;
  int? moderatorId;
  String? action;
  String? targetType;
  int? targetId;
  String? notes;
  String? createdAt;

  ModerationLogEntry({
    this.id,
    this.moderatorId,
    this.action,
    this.targetType,
    this.targetId,
    this.notes,
    this.createdAt,
  });

  ModerationLogEntry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    moderatorId = json['moderator_id'];
    action = json['action'];
    targetType = json['target_type'];
    targetId = json['target_id'];
    notes = json['notes'];
    createdAt = json['created_at'];
  }
}
