import 'package:shortzz/model/user_model/user_model.dart';

class FavoriteUser {
  num? id;
  num? fromUserId;
  num? toUserId;
  String? createdAt;
  String? updatedAt;
  User? toUser;

  FavoriteUser({
    this.id,
    this.fromUserId,
    this.toUserId,
    this.createdAt,
    this.updatedAt,
    this.toUser,
  });

  FavoriteUser.fromJson(dynamic json)
      : id = json['id'],
        fromUserId = json['from_user_id'],
        toUserId = json['to_user_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        toUser = json['to_user'] != null ? User.fromJson(json['to_user']) : null;
}

class FavoriteUsersModel {
  bool? status;
  String? message;
  List<FavoriteUser>? data;

  FavoriteUsersModel({this.status, this.message, this.data});

  FavoriteUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <FavoriteUser>[];
      json['data'].forEach((v) {
        data!.add(FavoriteUser.fromJson(v));
      });
    }
  }
}
