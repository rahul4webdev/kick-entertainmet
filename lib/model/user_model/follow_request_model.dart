import 'package:shortzz/model/user_model/user_model.dart';

class FollowRequestListModel {
  FollowRequestListModel(
      {bool? status, String? message, List<FollowRequest>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  FollowRequestListModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(FollowRequest.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<FollowRequest>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<FollowRequest>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class FollowRequest {
  FollowRequest(
      {this.id,
      this.fromUserId,
      this.toUserId,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.fromUser});

  FollowRequest.fromJson(dynamic json) {
    id = json['id'];
    fromUserId = json['from_user_id'];
    toUserId = json['to_user_id'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fromUser = json['from_user'] != null
        ? User.fromJson(json['from_user'])
        : null;
  }

  int? id;
  int? fromUserId;
  int? toUserId;
  int? status;
  String? createdAt;
  String? updatedAt;
  User? fromUser;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['from_user_id'] = fromUserId;
    map['to_user_id'] = toUserId;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (fromUser != null) {
      map['from_user'] = fromUser?.toJson();
    }
    return map;
  }
}
