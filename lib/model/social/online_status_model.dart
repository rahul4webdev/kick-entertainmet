class OnlineStatusListModel {
  bool? status;
  String? message;
  List<UserOnlineStatus>? data;

  OnlineStatusListModel({this.status, this.message, this.data});

  OnlineStatusListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => UserOnlineStatus.fromJson(e))
          .toList();
    }
  }
}

class UserOnlineStatus {
  int? userId;
  bool? isOnline;
  String? lastSeen;

  UserOnlineStatus({this.userId, this.isOnline, this.lastSeen});

  UserOnlineStatus.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    isOnline = json['is_online'];
    lastSeen = json['last_seen'];
  }
}
