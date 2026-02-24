class PendingReportsModel {
  bool? status;
  String? message;
  List<PendingReport>? data;

  PendingReportsModel({this.status, this.message, this.data});

  PendingReportsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List).map((e) => PendingReport.fromJson(e)).toList();
    }
  }
}

class PendingReport {
  int? id;
  int? userId;
  int? postId;
  String? reason;
  int? status;
  String? createdAt;
  ReportUser? byUser;
  ReportUser? user;
  ReportPost? post;

  PendingReport({
    this.id,
    this.userId,
    this.postId,
    this.reason,
    this.status,
    this.createdAt,
    this.byUser,
    this.user,
    this.post,
  });

  PendingReport.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    postId = json['post_id'];
    reason = json['reason'];
    status = json['status'];
    createdAt = json['created_at'];
    byUser = json['by_user'] != null ? ReportUser.fromJson(json['by_user']) : null;
    user = json['user'] != null ? ReportUser.fromJson(json['user']) : null;
    post = json['post'] != null ? ReportPost.fromJson(json['post']) : null;
  }
}

class ReportUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;

  ReportUser({this.id, this.username, this.fullname, this.profilePhoto});

  ReportUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
  }
}

class ReportPost {
  int? id;
  String? description;
  int? postType;
  String? thumbnail;
  String? createdAt;

  ReportPost({this.id, this.description, this.postType, this.thumbnail, this.createdAt});

  ReportPost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    postType = json['post_type'];
    thumbnail = json['thumbnail'];
    createdAt = json['created_at'];
  }
}
