import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/post/posts_model.dart';
import 'package:shortzz/model/social/comment_reaction_model.dart';
import 'package:shortzz/model/social/online_status_model.dart';
import 'package:shortzz/model/social/trending_hashtag_model.dart';

class SocialService {
  SocialService._();

  static final SocialService instance = SocialService._();

  // ─── Repost ───────────────────────────────────────────────

  Future<StatusModel> repostPost({
    required int postId,
    String? caption,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.social.repostPost,
        fromJson: StatusModel.fromJson,
        param: {
          Params.postId: postId,
          if (caption != null) Params.caption: caption,
        });
    return response;
  }

  Future<StatusModel> undoRepost({required int postId}) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.social.undoRepost,
        fromJson: StatusModel.fromJson,
        param: {
          Params.postId: postId,
        });
    return response;
  }

  Future<List<Post>> fetchUserReposts({int? userId, int? lastItemId}) async {
    PostsModel response = await ApiService.instance.call(
        url: WebService.social.fetchUserReposts,
        fromJson: PostsModel.fromJson,
        param: {
          if (userId != null) Params.userId: userId,
          Params.limit: 20,
          Params.lastItemId: lastItemId,
        });
    return response.data ?? [];
  }

  // ─── Trending Hashtags ───────────────────────────────────

  Future<List<TrendingHashtag>> fetchTrendingHashtags() async {
    TrendingHashtagsModel response = await ApiService.instance.call(
        url: WebService.social.fetchTrendingHashtags,
        fromJson: TrendingHashtagsModel.fromJson,
        param: {Params.limit: 30});
    return response.data ?? [];
  }

  // ─── Online Status ───────────────────────────────────────

  Future<List<UserOnlineStatus>> fetchUsersOnlineStatus({
    required List<int> userIds,
  }) async {
    OnlineStatusListModel response = await ApiService.instance.call(
        url: WebService.social.fetchUsersOnlineStatus,
        fromJson: OnlineStatusListModel.fromJson,
        param: {
          Params.userIds: userIds.join(','),
        });
    return response.data ?? [];
  }

  // ─── Comment Reactions ───────────────────────────────────

  Future<StatusModel> reactToComment({
    required int commentId,
    required String emoji,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.social.reactToComment,
        fromJson: StatusModel.fromJson,
        param: {
          Params.commentId: commentId,
          Params.emoji: emoji,
        });
    return response;
  }

  Future<CommentReactionsData?> fetchCommentReactions({
    required int commentId,
  }) async {
    CommentReactionsModel response = await ApiService.instance.call(
        url: WebService.social.fetchCommentReactions,
        fromJson: CommentReactionsModel.fromJson,
        param: {
          Params.commentId: commentId,
        });
    if (response.status == true) {
      return response.data;
    }
    return null;
  }
}
