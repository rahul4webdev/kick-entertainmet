class AiContentIdeasModel {
  bool? status;
  String? message;
  List<ContentIdea>? data;

  AiContentIdeasModel({this.status, this.message, this.data});

  AiContentIdeasModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data =
          (json['data'] as List).map((e) => ContentIdea.fromJson(e)).toList();
    }
  }
}

class ContentIdea {
  String? title;
  String? description;
  String? format;
  List<String>? hashtags;
  String? hook;
  String? difficulty;

  ContentIdea({
    this.title,
    this.description,
    this.format,
    this.hashtags,
    this.hook,
    this.difficulty,
  });

  ContentIdea.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    format = json['format'];
    if (json['hashtags'] != null) {
      hashtags = (json['hashtags'] as List).map((e) => e.toString()).toList();
    }
    hook = json['hook'];
    difficulty = json['difficulty'];
  }
}

class TrendingTopicsModel {
  bool? status;
  String? message;
  TrendingTopicsData? data;

  TrendingTopicsModel({this.status, this.message, this.data});

  TrendingTopicsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? TrendingTopicsData.fromJson(json['data'])
        : null;
  }
}

class TrendingTopicsData {
  List<TrendingHashtag>? hashtags;
  List<TrendingSound>? sounds;

  TrendingTopicsData({this.hashtags, this.sounds});

  TrendingTopicsData.fromJson(Map<String, dynamic> json) {
    if (json['hashtags'] != null) {
      hashtags = (json['hashtags'] as List)
          .map((e) => TrendingHashtag.fromJson(e))
          .toList();
    }
    if (json['sounds'] != null) {
      sounds = (json['sounds'] as List)
          .map((e) => TrendingSound.fromJson(e))
          .toList();
    }
  }
}

class TrendingHashtag {
  int? id;
  String? hashtagName;
  int? hashtagCount;

  TrendingHashtag({this.id, this.hashtagName, this.hashtagCount});

  TrendingHashtag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hashtagName = json['hashtag_name'];
    hashtagCount = json['hashtag_count'];
  }
}

class TrendingSound {
  int? id;
  String? title;
  String? artist;
  int? useCount;

  TrendingSound({this.id, this.title, this.artist, this.useCount});

  TrendingSound.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    artist = json['artist'];
    useCount = json['use_count'];
  }
}
