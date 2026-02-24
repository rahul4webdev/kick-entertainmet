class PlaylistItem {
  int? id;
  int? userId;
  String? name;
  String? description;
  int? postCount;
  int? sortOrder;
  bool isPublic;
  String? coverThumbnail;
  String? createdAt;
  String? updatedAt;

  PlaylistItem({
    this.id,
    this.userId,
    this.name,
    this.description,
    this.postCount,
    this.sortOrder,
    this.isPublic = true,
    this.coverThumbnail,
    this.createdAt,
    this.updatedAt,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      postCount: json['post_count'] ?? 0,
      sortOrder: json['sort_order'] ?? 0,
      isPublic: json['is_public'] ?? true,
      coverThumbnail: json['cover_thumbnail'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'description': description,
        'post_count': postCount,
        'sort_order': sortOrder,
        'is_public': isPublic,
        'cover_thumbnail': coverThumbnail,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

class PlaylistListModel {
  bool? status;
  String? message;
  List<PlaylistItem>? data;

  PlaylistListModel({this.status, this.message, this.data});

  factory PlaylistListModel.fromJson(Map<String, dynamic> json) {
    return PlaylistListModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => PlaylistItem.fromJson(e))
              .toList()
          : [],
    );
  }
}
