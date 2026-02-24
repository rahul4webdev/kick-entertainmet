import 'package:shortzz/model/user_model/user_model.dart';

class PostCollaborator {
  int? id;
  int? postId;
  User? user;
  int? status; // 0=pending, 1=accepted, 2=declined

  PostCollaborator({this.id, this.postId, this.user, this.status});

  factory PostCollaborator.fromJson(Map<String, dynamic> json) {
    return PostCollaborator(
      id: json['id'],
      postId: json['post_id'],
      user: json['user'] != null
          ? User.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      status: json['status'],
    );
  }
}

class CollabInvite {
  int? id;
  int? postId;
  String? postThumbnail;
  String? postDescription;
  User? inviter;
  String? createdAt;

  CollabInvite({
    this.id,
    this.postId,
    this.postThumbnail,
    this.postDescription,
    this.inviter,
    this.createdAt,
  });

  factory CollabInvite.fromJson(Map<String, dynamic> json) {
    return CollabInvite(
      id: json['id'],
      postId: json['post_id'],
      postThumbnail: json['post_thumbnail'],
      postDescription: json['post_description'],
      inviter: json['inviter'] != null
          ? User.fromJson(Map<String, dynamic>.from(json['inviter']))
          : null,
      createdAt: json['created_at'],
    );
  }
}
