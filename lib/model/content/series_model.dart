class SeriesListModel {
  SeriesListModel({bool? status, String? message, List<SeriesItem>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  SeriesListModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(SeriesItem.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<SeriesItem>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<SeriesItem>? get data => _data;
}

class SeriesItem {
  SeriesItem({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.coverImage,
    this.genre,
    this.language,
    this.episodeCount,
    this.totalViews,
    this.isActive,
    this.status,
    this.user,
  });

  SeriesItem.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    coverImage = json['cover_image'];
    genre = json['genre'];
    language = json['language'];
    episodeCount = json['episode_count'];
    totalViews = json['total_views'];
    isActive = json['is_active'];
    status = json['status'];
    if (json['user'] != null) {
      user = SeriesUser.fromJson(json['user']);
    }
  }

  int? id;
  int? userId;
  String? title;
  String? description;
  String? coverImage;
  String? genre;
  String? language;
  int? episodeCount;
  int? totalViews;
  bool? isActive;
  int? status;
  SeriesUser? user;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'genre': genre,
      'language': language,
      'episode_count': episodeCount,
      'total_views': totalViews,
      'is_active': isActive,
      'status': status,
    };
  }
}

class SeriesUser {
  SeriesUser({this.id, this.username, this.profilePhoto});

  SeriesUser.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    profilePhoto = json['profile_photo'];
  }

  int? id;
  String? username;
  String? profilePhoto;
}
