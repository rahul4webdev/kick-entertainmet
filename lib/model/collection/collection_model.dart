import 'package:shortzz/model/post_story/post_model.dart';

class CollectionsResponse {
  bool? status;
  String? message;
  CollectionsData? data;

  CollectionsResponse({this.status, this.message, this.data});

  factory CollectionsResponse.fromJson(dynamic json) {
    return CollectionsResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? CollectionsData.fromJson(json['data']) : null,
    );
  }
}

class CollectionsData {
  int allSavedCount;
  List<SaveCollection> collections;

  CollectionsData({this.allSavedCount = 0, this.collections = const []});

  factory CollectionsData.fromJson(dynamic json) {
    return CollectionsData(
      allSavedCount: json['all_saved_count'] ?? 0,
      collections: json['collections'] != null
          ? (json['collections'] as List)
              .map((v) => SaveCollection.fromJson(v))
              .toList()
          : [],
    );
  }
}

class SaveCollection {
  int? id;
  int? userId;
  String? name;
  int? coverPostId;
  bool isDefault;
  bool isShared;
  int postCount;
  int acceptedMembersCount;
  String? createdAt;
  Post? coverPost;

  SaveCollection({
    this.id,
    this.userId,
    this.name,
    this.coverPostId,
    this.isDefault = false,
    this.isShared = false,
    this.postCount = 0,
    this.acceptedMembersCount = 0,
    this.createdAt,
    this.coverPost,
  });

  factory SaveCollection.fromJson(dynamic json) {
    return SaveCollection(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      coverPostId: json['cover_post_id'],
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      isShared: json['is_shared'] == true || json['is_shared'] == 1,
      postCount: json['post_count'] ?? 0,
      acceptedMembersCount: json['accepted_members_count'] ?? 0,
      createdAt: json['created_at'],
      coverPost: json['cover_post'] != null
          ? Post.fromJson(json['cover_post'])
          : null,
    );
  }
}
