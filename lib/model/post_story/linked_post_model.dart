import 'package:shortzz/model/post_story/post_model.dart';

class LinkedPostModel {
  bool? status;
  String? message;
  LinkedPostData? data;

  LinkedPostModel({this.status, this.message, this.data});

  factory LinkedPostModel.fromJson(Map<String, dynamic> json) =>
      LinkedPostModel(
        status: json['status'],
        message: json['message'],
        data: json['data'] == null
            ? null
            : LinkedPostData.fromJson(json['data']),
      );
}

class LinkedPostData {
  Post? previousPost;
  Post? nextPost;

  LinkedPostData({this.previousPost, this.nextPost});

  factory LinkedPostData.fromJson(Map<String, dynamic> json) =>
      LinkedPostData(
        previousPost: json['previous_post'] == null
            ? null
            : Post.fromJson(json['previous_post']),
        nextPost: json['next_post'] == null
            ? null
            : Post.fromJson(json['next_post']),
      );
}
