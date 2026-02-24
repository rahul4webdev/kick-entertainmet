import 'package:shortzz/model/post_story/hashtag_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class EnhancedExploreModel {
  bool? status;
  String? message;
  EnhancedExploreData? data;

  EnhancedExploreModel({this.status, this.message, this.data});

  EnhancedExploreModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? EnhancedExploreData.fromJson(json['data'])
        : null;
  }
}

class EnhancedExploreData {
  List<Post>? featured;
  List<Hashtag>? trendingHashtags;
  List<User>? popularCreators;
  List<ContentSection>? contentSections;

  EnhancedExploreData({
    this.featured,
    this.trendingHashtags,
    this.popularCreators,
    this.contentSections,
  });

  EnhancedExploreData.fromJson(dynamic json) {
    if (json['featured'] != null) {
      featured = (json['featured'] as List).map((v) => Post.fromJson(v)).toList();
    }
    if (json['trending_hashtags'] != null) {
      trendingHashtags = (json['trending_hashtags'] as List)
          .map((v) => Hashtag.fromJson(v))
          .toList();
    }
    if (json['popular_creators'] != null) {
      popularCreators = (json['popular_creators'] as List)
          .map((v) => User.fromJson(v))
          .toList();
    }
    if (json['content_sections'] != null) {
      contentSections = (json['content_sections'] as List)
          .map((v) => ContentSection.fromJson(v))
          .toList();
    }
  }
}

class ContentSection {
  int? contentType;
  String? label;
  List<Post>? posts;

  ContentSection({this.contentType, this.label, this.posts});

  ContentSection.fromJson(dynamic json) {
    contentType = json['content_type'];
    label = json['label'];
    if (json['posts'] != null) {
      posts = (json['posts'] as List).map((v) => Post.fromJson(v)).toList();
    }
  }
}
