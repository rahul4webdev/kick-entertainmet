import 'package:shortzz/model/user_model/user_model.dart';

class MutedUsers {
  num? id;
  num? fromUserId;
  num? toUserId;
  bool mutePosts;
  bool muteStories;
  String? createdAt;
  String? updatedAt;
  User? toUser;

  MutedUsers({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.mutePosts = true,
    this.muteStories = true,
    this.createdAt,
    this.updatedAt,
    this.toUser,
  });

  MutedUsers.fromJson(dynamic json)
      : id = json['id'],
        fromUserId = json['from_user_id'],
        toUserId = json['to_user_id'],
        mutePosts = json['mute_posts'] ?? true,
        muteStories = json['mute_stories'] ?? true,
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        toUser = json['to_user'] != null ? User.fromJson(json['to_user']) : null;
}

class MutedUsersModel {
  bool? status;
  String? message;
  List<MutedUsers>? data;

  MutedUsersModel({this.status, this.message, this.data});

  MutedUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MutedUsers>[];
      json['data'].forEach((v) {
        data!.add(MutedUsers.fromJson(v));
      });
    }
  }
}
