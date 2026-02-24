class TrendingHashtagsModel {
  bool? status;
  String? message;
  List<TrendingHashtag>? data;

  TrendingHashtagsModel({this.status, this.message, this.data});

  TrendingHashtagsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => TrendingHashtag.fromJson(e))
          .toList();
    }
  }
}

class TrendingHashtag {
  int? id;
  String? hashtag;
  int? postCount;
  String? createdAt;

  TrendingHashtag({this.id, this.hashtag, this.postCount, this.createdAt});

  TrendingHashtag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hashtag = json['hashtag'];
    postCount = json['post_count'];
    createdAt = json['created_at'];
  }
}
