import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/notification_screen/widget/activity_notification_page.dart';

class ActivityNotificationModel {
  ActivityNotificationModel({
    this.status,
    this.message,
    this.data,
  });

  ActivityNotificationModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ActivityNotification.fromJson(v));
      });
    }
  }

  bool? status;
  String? message;
  List<ActivityNotification>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ActivityNotification {
  ActivityNotification({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.type = ActivityNotifyType.none,
    this.dataId,
    this.createdAt,
    this.updatedAt,
    this.data,
    this.fromUser,
  });

  ActivityNotification.fromJson(dynamic json) {
    id = json['id'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    type = json['type'] != null
        ? ActivityNotifyType.fromString(json['type'])
        : ActivityNotifyType.none;
    dataId = json['data_id'];
    category = json['category'];
    isRead = json['is_read'] == true || json['is_read'] == 1;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    data = json['data'] != null
        ? ActivityNotificationData.fromJson(json['data'])
        : null;
    fromUser =
        json['from_user'] != null ? User.fromJson(json['from_user']) : null;
  }

  int? id;
  num? fromUserId;
  num? toUserId;
  ActivityNotifyType type = ActivityNotifyType.none;
  num? dataId;
  String? category;
  bool isRead = false;
  String? createdAt;
  String? updatedAt;
  ActivityNotificationData? data;
  User? fromUser;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['from_user_id'] = fromUserId;
    map['to_user_id'] = toUserId;
    map['type'] = type.type;
    map['data_id'] = dataId;
    map['category'] = category;
    map['is_read'] = isRead;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    if (fromUser != null) {
      map['from_user'] = fromUser?.toJson();
    }
    return map;
  }
}

class ActivityNotificationData {
  ActivityNotificationData({
    this.post,
    this.comment,
    this.reply,
    this.gift,
  });

  ActivityNotificationData.fromJson(dynamic json) {
    comment =
        json['comment'] != null ? Comment.fromJson(json['comment']) : null;
    reply = json['reply'] != null ? Comment.fromJson(json['reply']) : null;
    post = json['post'] != null ? Post.fromJson(json['post']) : null;
    gift = json['gift'] != null ? Gift.fromJson(json['gift']) : null;
  }

  Post? post;
  Comment? comment;
  Comment? reply;
  Gift? gift;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (comment != null) {
      map['comment'] = comment?.toJson();
    }
    if (reply != null) {
      map['reply'] = reply?.toJson();
    }
    if (post != null) {
      map['post'] = post?.toJson();
    }
    if (gift != null) {
      map['gift'] = gift?.toJson();
    }
    return map;
  }
}

class UnreadNotificationCount {
  bool? status;
  String? message;
  int total;
  Map<String, int> byCategory;

  UnreadNotificationCount({
    this.status,
    this.message,
    this.total = 0,
    this.byCategory = const {},
  });

  UnreadNotificationCount.fromJson(dynamic json)
      : status = json['status'],
        message = json['message'],
        total = json['data']?['total'] is bool ? 0 : (json['data']?['total'] ?? 0),
        byCategory = json['data']?['by_category'] is Map
            ? Map<String, int>.from((json['data']['by_category'] as Map).map(
                (k, v) => MapEntry(k.toString(), v is int ? v : int.tryParse(v.toString()) ?? 0)))
            : {};
}
