import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class ThreadModel {
  bool? status;
  String? message;
  int? threadId;
  List<Post>? posts;

  ThreadModel({this.status, this.message, this.threadId, this.posts});

  ThreadModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      threadId = json['data']['thread_id'];
      if (json['data']['posts'] != null) {
        posts = [];
        json['data']['posts'].forEach((v) {
          posts?.add(Post.fromJson(v));
        });
      }
    }
  }
}

class ThreadService {
  ThreadService._();
  static final ThreadService instance = ThreadService._();

  Future<ThreadModel> createThread({
    required List<Map<String, String>> posts,
    int canComment = 1,
    int visibility = 0,
  }) async {
    return await ApiService.instance.call(
      url: WebService.thread.createThread,
      fromJson: ThreadModel.fromJson,
      param: {
        'posts': posts,
        'can_comment': canComment,
        'visibility': visibility,
      },
    );
  }

  Future<PostModel> addToThread({
    required int threadId,
    required String description,
  }) async {
    return await ApiService.instance.call(
      url: WebService.thread.addToThread,
      fromJson: PostModel.fromJson,
      param: {
        'thread_id': threadId,
        'description': description,
      },
    );
  }

  Future<ThreadModel> fetchThread({required int threadId}) async {
    return await ApiService.instance.call(
      url: WebService.thread.fetchThread,
      fromJson: ThreadModel.fromJson,
      param: {'thread_id': threadId},
    );
  }

  Future<PostModel> quoteRepost({
    required int quotedPostId,
    String? description,
  }) async {
    return await ApiService.instance.call(
      url: WebService.thread.quoteRepost,
      fromJson: PostModel.fromJson,
      param: {
        'quoted_post_id': quotedPostId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }
}
