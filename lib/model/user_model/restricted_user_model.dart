import 'package:shortzz/model/user_model/user_model.dart';

class RestrictedUsers {
  num? id;
  num? fromUserId;
  num? toUserId;
  String? createdAt;
  String? updatedAt;
  User? toUser;

  RestrictedUsers({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.createdAt,
    this.updatedAt,
    this.toUser,
  });

  RestrictedUsers.fromJson(dynamic json)
      : id = json['id'],
        fromUserId = json['from_user_id'],
        toUserId = json['to_user_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        toUser = json['to_user'] != null ? User.fromJson(json['to_user']) : null;
}

class RestrictedUsersModel {
  bool? status;
  String? message;
  List<RestrictedUsers>? data;

  RestrictedUsersModel({this.status, this.message, this.data});

  RestrictedUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <RestrictedUsers>[];
      json['data'].forEach((v) {
        data!.add(RestrictedUsers.fromJson(v));
      });
    }
  }
}
