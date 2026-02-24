import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/content/content_genre_model.dart';
import 'package:shortzz/model/content/content_language_model.dart';
import 'package:shortzz/model/content/series_model.dart';
import 'package:shortzz/model/live/live_channel_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/comment/add_comment_model.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/comment/reply_comment_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/model/post_story/music/musics_model.dart';
import 'package:shortzz/model/post_story/post/enhanced_explore_model.dart';
import 'package:shortzz/model/post_story/post/explore_page_model.dart';
import 'package:shortzz/model/post_story/post/hashtag_post_model.dart';
import 'package:shortzz/model/post_story/post/posts_model.dart';
import 'package:shortzz/model/post_story/linked_post_model.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/collection/collection_model.dart';
import 'package:shortzz/model/post_story/story/stories_model.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/model/post_story/user_post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/app_res.dart';

enum PostType {
  reel,
  image,
  video,
  text,
  none;

  int get type {
    switch (this) {
      case PostType.reel:
        return 1;
      case PostType.image:
        return 2;
      case PostType.video:
        return 3;
      case PostType.text:
        return 4;
      case PostType.none:
        return 0;
    }
  }

  static String get posts =>
      '${PostType.image.type},${PostType.video.type},${PostType.text.type}';

  static String get reels => '${PostType.reel.type}';

  static PostType fromString(int value) {
    return PostType.values.firstWhere(
      (e) => e.type == value,
      orElse: () => throw ArgumentError('Invalid MessageType: $value'),
    );
  }
}

class PostService {
  PostService._();

  static final PostService instance = PostService._();

  Future<PostsModel> fetchPostsDiscover(
      {required String type, CancelToken? cancelToken}) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchPostsDiscover,
        param: {Params.limit: AppRes.paginationLimit, Params.types: type},
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<PostsModel> fetchTrendingPosts(
      {required String type, CancelToken? cancelToken}) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchTrendingPosts,
        param: {Params.limit: AppRes.paginationLimit, Params.types: type},
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<PostByIdModel> fetchPostById(
      {required int postId, int? commentId, int? replyId}) async {
    if (postId == -1) {
      Loggers.error('InValid Post Id : $postId');
      return PostByIdModel();
    }
    PostByIdModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostById,
        param: {
          Params.postId: postId,
          if (commentId != null) Params.commentId: commentId,
          if (replyId != null) Params.replyId: replyId
        },
        fromJson: PostByIdModel.fromJson);
    return model;
  }

  Future<PostsModel> fetchPostsNearBy(
      {required String type,
      required double placeLat,
      required double placeLon,
      CancelToken? cancelToken}) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchPostsNearBy,
        param: {
          Params.placeLat: placeLat,
          Params.placeLon: placeLon,
          Params.types: type,
        },
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<PostsModel> fetchPostsFollowing(
      {required String type, CancelToken? cancelToken}) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchPostsFollowing,
        param: {Params.limit: AppRes.paginationLimit, Params.types: type},
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<PostsModel> fetchPostsFavorites(
      {required String type, CancelToken? cancelToken}) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchPostsFavorites,
        param: {Params.limit: AppRes.paginationLimit, Params.types: type},
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<List<Post>> fetchReelPostsByMusic(
      {int? musicId, int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchReelPostsByMusic,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.musicId: musicId,
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Post>> fetchPostsByLocation(
      {required String type,
      required double placeLat,
      required double placeLon,
      int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostsByLocation,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.types: type,
          Params.placeLat: placeLat,
          Params.placeLon: placeLon
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<UserPostData?> fetchUserPosts(
      {required String type,
      required int? userId,
      required int? lastItemId}) async {
    UserPostModel model = await ApiService.instance.call(
        url: WebService.post.fetchUserPosts,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.userId: userId,
          Params.types: type,
          Params.lastItemId: lastItemId
        },
        fromJson: UserPostModel.fromJson);
    return model.data;
  }

  Future<HashtagPostData?> fetchPostsByHashtag(
      {required String type,
      required String hashTag,
      required int? lastItemId}) async {
    HashtagPostModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostsByHashtag,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.hashtag: hashTag,
          Params.types: type,
          Params.lastItemId: lastItemId
        },
        fromJson: HashtagPostModel.fromJson);
    return model.data;
  }

  Future<List<Post>> fetchSavedPosts(
      {required String type, required int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchSavedPosts,
        param: {
          Params.types: type,
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> deletePost({int? postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.deletePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> deleteComment({int? commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.deleteComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> deleteCommentReply({int? replyId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.deleteCommentReply,
        param: {Params.replyId: replyId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> increaseShareCount({int? postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.increaseShareCount,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> increaseViewsCount({int? postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.increaseViewsCount,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> likeComment({int? commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.likeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> disLikeComment({int? commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.disLikeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> likePost({required int postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.likePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> pinPost({required int postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.pinPost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> unpinPost({required int postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.unpinPost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> pinComment({required int commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.pinComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> unPinComment({required int commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.unPinComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> creatorLikeComment({required int commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.creatorLikeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> creatorUnlikeComment({required int commentId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.creatorUnlikeComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<Comment>> fetchTopComments(
      {required int postId, int? lastItemId}) async {
    ReplyCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchTopComments,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId
        },
        fromJson: ReplyCommentModel.fromJson);
    return model.data ?? [];
  }

  Future<StatusModel> disLikePost({required int postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.disLikePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> savePost({required int postId, int? collectionId}) async {
    final params = <String, dynamic>{Params.postId: postId};
    if (collectionId != null) params['collection_id'] = collectionId;
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.savePost,
        param: params,
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<StatusModel> unSavePost({required int postId}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.unSavePost,
        param: {Params.postId: postId},
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<CommentData?> fetchPostComments(
      {required int postId, int? lastItemId}) async {
    FetchCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostComments,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: FetchCommentModel.fromJson);
    return model.data;
  }

  Future<List<Comment>> fetchPostCommentReplies(
      {required int commentId, int? lastItemId}) async {
    ReplyCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchPostCommentReplies,
        param: {
          Params.commentId: commentId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId
        },
        fromJson: ReplyCommentModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Post>> fetchVideoRepliesForComment(
      {required int commentId, int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchVideoRepliesForComment,
        param: {
          Params.commentId: commentId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId
        },
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<List<Comment>> fetchPendingComments(
      {required int postId, int? lastItemId}) async {
    FetchCommentModel model = await ApiService.instance.call(
        url: WebService.post.fetchPendingComments,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId
        },
        fromJson: FetchCommentModel.fromJson);
    // pending endpoint returns data directly as a list
    return model.data?.comments ?? [];
  }

  Future<StatusModel> approveComment({required int commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.approveComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<StatusModel> rejectComment({required int commentId}) async {
    return await ApiService.instance.call(
        url: WebService.post.rejectComment,
        param: {Params.commentId: commentId},
        fromJson: StatusModel.fromJson);
  }

  Future<bool> updatePostCaptions(
      {required int postId, required String captionsJson}) async {
    final result = await ApiService.instance.call(
        url: WebService.post.updatePostCaptions,
        param: {
          Params.postId: postId,
          Params.captions: captionsJson,
        },
        fromJson: (json) => json);
    return result['status'] == true;
  }

  Future<List<Post>> fetchScheduledPosts() async {
    PostsModel model = await ApiService.instance.call(
        url: WebService.post.fetchScheduledPosts,
        param: {},
        fromJson: PostsModel.fromJson);
    return model.data ?? [];
  }

  Future<bool> cancelScheduledPost({required int postId}) async {
    final result = await ApiService.instance.call(
        url: WebService.post.cancelScheduledPost,
        param: {Params.postId: postId},
        fromJson: (json) => json);
    return result['status'] == true;
  }

  Future<bool> markNotInterested({required int postId}) async {
    final result = await ApiService.instance.call(
        url: WebService.post.markNotInterested,
        param: {Params.postId: postId},
        fromJson: (json) => json);
    return result['status'] == true;
  }

  Future<bool> undoNotInterested({required int postId}) async {
    final result = await ApiService.instance.call(
        url: WebService.post.undoNotInterested,
        param: {Params.postId: postId},
        fromJson: (json) => json);
    return result['status'] == true;
  }

  Future<Map<String, dynamic>?> generateEmbedCode({required int postId}) async {
    final result = await ApiService.instance.call(
        url: WebService.post.generateEmbedCode,
        param: {Params.postId: postId},
        fromJson: (json) => json);
    if (result['status'] == true) {
      return Map<String, dynamic>.from(result['data'] as Map);
    }
    return null;
  }

  Future<Comment?> addComment(
      {required int postId,
      int? type,
      required String comment,
      String? mentionUserIds}) async {
    AddCommentModel model = await ApiService.instance.call(
        url: WebService.post.addPostComment,
        param: {
          Params.postId: postId,
          Params.type: type,
          Params.comment: comment,
          Params.mentionedUserIds: mentionUserIds
        },
        fromJson: AddCommentModel.fromJson);
    if (model.status == false) {
      BaseController.share.showSnackBar(model.message);
    }
    return model.data;
  }

  Future<Comment?> replyToComment(
      {required int commentId,
      required String reply,
      String? mentionUserIds}) async {
    AddCommentModel model = await ApiService.instance.call(
        url: WebService.post.replyToComment,
        param: {
          Params.commentId: commentId,
          Params.reply: reply,
          Params.mentionedUserIds: mentionUserIds
        },
        fromJson: AddCommentModel.fromJson);
    if (model.status == false) {
      BaseController.share.showSnackBar(model.message);
    }

    return model.data;
  }

  Future<StatusModel> reportPost(
      {required int postId,
      required String reason,
      required String description}) async {
    StatusModel model = await ApiService.instance.call(
        url: WebService.post.reportPost,
        param: {
          Params.postId: postId,
          Params.reason: reason,
          Params.description: description,
        },
        fromJson: StatusModel.fromJson);
    return model;
  }

  Future<List<Music>> fetchMusicExplore({int? lastItemId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchMusicExplore,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId
        },
        fromJson: MusicsModel.fromJson);

    if (response.status == true) {
      return response.data ?? [];
    }

    return [];
  }

  Future<List<Music>> fetchMusicByCategories(
      {int? lastItemId, required int categoryId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchMusicByCategories,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.lastItemId: lastItemId,
          Params.categoryId: categoryId
        },
        fromJson: MusicsModel.fromJson);
    if (response.status == true) {
      return response.data ?? [];
    }
    return [];
  }

  Future<List<Music>> fetchSavedMusics() async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.fetchSavedMusics, fromJson: MusicsModel.fromJson);

    if (response.status == true) {
      return response.data ?? [];
    }

    return [];
  }

  Future<List<Music>> searchMusic(
      {required String keyword, int? lastItemId}) async {
    MusicsModel response = await ApiService.instance.call(
        url: WebService.post.serchMusic,
        param: {
          Params.limit: AppRes.paginationLimit,
          Params.keyword: keyword,
          Params.lastItemId: lastItemId
        },
        fromJson: MusicsModel.fromJson);

    if (response.status == true) {
      return response.data ?? [];
    }

    return [];
  }

  Future<StoryModel> createStory({
    required Map<String, dynamic> param,
    required Map<String, List<XFile?>> files,
  }) async {
    StoryModel response = await ApiService.instance.multiPartCallApi(
        url: WebService.post.createStory,
        filesMap: files,
        param: param,
        fromJson: StoryModel.fromJson);
    return response;
  }

  Future<Story?> viewStory({
    required int storyId,
  }) async {
    StoryModel response = await ApiService.instance.call(
        url: WebService.post.viewStory,
        param: {Params.storyId: storyId},
        fromJson: StoryModel.fromJson);
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<StatusModel> deleteStory({
    required int storyId,
  }) async {
    StatusModel response = await ApiService.instance.call(
        url: WebService.post.deleteStory,
        param: {Params.storyId: storyId},
        fromJson: StatusModel.fromJson);

    return response;
  }

  Future<Music?> addUserMusic({
    required String title,
    required String duration,
    required String artist,
    required XFile? sound,
    required XFile? image,
  }) async {
    MusicModel response = await ApiService.instance.multiPartCallApi(
        url: WebService.post.addUserMusic,
        param: {
          Params.title: title,
          Params.duration: duration,
          Params.artist: artist
        },
        fromJson: MusicModel.fromJson,
        filesMap: {
          Params.sound: [sound],
          if (image != null) Params.image: [image],
        });
    return response.data;
  }

  Future<List<User>> fetchStory() async {
    StoriesModel response = await ApiService.instance
        .call(url: WebService.post.fetchStory, fromJson: StoriesModel.fromJson);
    if (response.status == true) {
      return response.data ?? [];
    }
    return [];
  }

  Future<Story?> fetchStoryByID(int id) async {
    StoryModel response = await ApiService.instance.call(
        url: WebService.post.fetchStoryByID,
        fromJson: StoryModel.fromJsonWithUser,
        param: {Params.storyId: id});
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<ExplorePageData?> fetchExplorePageData() async {
    ExplorePageModel response = await ApiService.instance.call(
        url: WebService.post.fetchExplorePageData,
        fromJson: ExplorePageModel.fromJson);
    if (response.status == true) {
      return response.data;
    } else {
      Loggers.error(response.message);
      return null;
    }
  }

  Future<EnhancedExploreData?> fetchEnhancedExplore() async {
    EnhancedExploreModel response = await ApiService.instance.call(
        url: WebService.post.fetchEnhancedExplore,
        fromJson: EnhancedExploreModel.fromJson);
    if (response.status == true) {
      return response.data;
    } else {
      Loggers.error(response.message);
      return null;
    }
  }

  // ================================================================
  // DUET METHODS
  // ================================================================

  Future<PostsModel> fetchDuetsOfPost({
    required int postId,
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchDuetsOfPost,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId,
        },
        fromJson: PostsModel.fromJson);
  }

  // ================================================================
  // STITCH METHODS
  // ================================================================

  Future<PostsModel> fetchStitchesOfPost({
    required int postId,
    int? lastItemId,
  }) async {
    return await ApiService.instance.call(
        url: WebService.post.fetchStitchesOfPost,
        param: {
          Params.postId: postId,
          Params.limit: AppRes.paginationLimit,
          if (lastItemId != null) Params.lastItemId: lastItemId,
        },
        fromJson: PostsModel.fromJson);
  }

  // ================================================================
  // CONTENT TYPE METHODS (Music Videos, Trailers, News)
  // ================================================================

  Future<PostsModel> fetchContentByType({
    required int contentType,
    String subTab = 'for_you',
    String? genre,
    String? language,
    int? lastItemId,
    CancelToken? cancelToken,
  }) async {
    return await ApiService.instance.call(
        url: WebService.content.fetchContentByType,
        param: {
          Params.contentType: contentType,
          Params.subTab: subTab,
          Params.limit: AppRes.paginationLimit,
          if (genre != null) Params.genre: genre,
          if (language != null) Params.language: language,
          if (lastItemId != null) Params.lastItemId: lastItemId,
        },
        fromJson: PostsModel.fromJson,
        cancelToken: cancelToken);
  }

  Future<List<ContentGenre>> fetchContentGenres({required int contentType}) async {
    ContentGenresModel response = await ApiService.instance.call(
        url: WebService.content.fetchContentGenres,
        param: {Params.contentType: contentType},
        fromJson: ContentGenresModel.fromJson);
    return response.data ?? [];
  }

  Future<List<ContentLanguageItem>> fetchContentLanguages() async {
    ContentLanguagesModel response = await ApiService.instance.call(
        url: WebService.content.fetchContentLanguages,
        fromJson: ContentLanguagesModel.fromJson);
    return response.data ?? [];
  }

  Future<LinkedPostModel> fetchLinkedPost({required int postId}) async {
    return await ApiService.instance.call(
        url: WebService.content.fetchLinkedPost,
        param: {Params.postId: postId},
        fromJson: LinkedPostModel.fromJson);
  }

  // ─── Live TV ──────────────────────────────────────────────────

  Future<LiveChannelsModel> fetchLiveChannels({
    int limit = 20,
    int? lastItemId,
    String? category,
    String? language,
  }) async {
    Map<String, dynamic> param = {Params.limit: limit};
    if (lastItemId != null) param[Params.lastItemId] = lastItemId;
    if (category != null) param['category'] = category;
    if (language != null) param['language'] = language;

    return await ApiService.instance.call(
        url: WebService.liveTV.fetchLiveChannels,
        param: param,
        fromJson: LiveChannelsModel.fromJson);
  }

  // ─── Short Stories / Series ───────────────────────────────────

  Future<SeriesListModel> fetchSeries({
    int limit = 20,
    int? lastItemId,
    String? genre,
    String? language,
    String subTab = 'for_you',
  }) async {
    Map<String, dynamic> param = {
      Params.limit: limit,
      Params.subTab: subTab,
    };
    if (lastItemId != null) param[Params.lastItemId] = lastItemId;
    if (genre != null) param[Params.genre] = genre;
    if (language != null) param[Params.language] = language;

    return await ApiService.instance.call(
        url: WebService.series.fetchSeries,
        param: param,
        fromJson: SeriesListModel.fromJson);
  }

  Future<PostsModel> fetchSeriesEpisodes({
    required int seriesId,
    int limit = 50,
    int? lastItemId,
  }) async {
    Map<String, dynamic> param = {
      'series_id': seriesId,
      Params.limit: limit,
    };
    if (lastItemId != null) param[Params.lastItemId] = lastItemId;

    return await ApiService.instance.call(
        url: WebService.series.fetchSeriesEpisodes,
        param: param,
        fromJson: PostsModel.fromJson);
  }

  // ─── Collections ───────────────────────────────────────────

  Future<CollectionsData?> fetchCollections() async {
    CollectionsResponse response = await ApiService.instance.call(
      url: WebService.post.fetchCollections,
      fromJson: CollectionsResponse.fromJson,
    );
    if (response.status == true) {
      return response.data;
    }
    return null;
  }

  Future<StatusModel> createCollection({required String name}) async {
    return await ApiService.instance.call(
      url: WebService.post.createCollection,
      param: {'name': name},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> editCollection({required int collectionId, required String name}) async {
    return await ApiService.instance.call(
      url: WebService.post.editCollection,
      param: {'collection_id': collectionId, 'name': name},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> deleteCollection({required int collectionId}) async {
    return await ApiService.instance.call(
      url: WebService.post.deleteCollection,
      param: {'collection_id': collectionId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> movePostToCollection({required int saveId, int? collectionId}) async {
    return await ApiService.instance.call(
      url: WebService.post.movePostToCollection,
      param: {'save_id': saveId, 'collection_id': collectionId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<List<Post>> fetchCollectionPosts({required int collectionId, int? lastItemId}) async {
    PostsModel model = await ApiService.instance.call(
      url: WebService.post.fetchCollectionPosts,
      param: {
        'collection_id': collectionId,
        Params.limit: AppRes.paginationLimit,
        if (lastItemId != null) Params.lastItemId: lastItemId,
      },
      fromJson: PostsModel.fromJson,
    );
    return model.data ?? [];
  }

  // ─── Shared Collections ────────────────────────────────────────

  Future<StatusModel> shareCollection({required int collectionId, required List<int> userIds}) async {
    return await ApiService.instance.call(
      url: WebService.post.shareCollection,
      param: {'collection_id': collectionId, 'user_ids': userIds},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> respondCollectionInvite({required int memberId, required bool accept}) async {
    return await ApiService.instance.call(
      url: WebService.post.respondCollectionInvite,
      param: {'member_id': memberId, 'accept': accept},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> fetchCollectionInvites() async {
    return await ApiService.instance.call(
      url: WebService.post.fetchCollectionInvites,
      param: {},
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> fetchCollectionMembers({required int collectionId}) async {
    return await ApiService.instance.call(
      url: WebService.post.fetchCollectionMembers,
      param: {'collection_id': collectionId},
      fromJson: (json) => json,
    );
  }

  Future<StatusModel> removeCollectionMember({required int collectionId, required int userId}) async {
    return await ApiService.instance.call(
      url: WebService.post.removeCollectionMember,
      param: {'collection_id': collectionId, 'user_id': userId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> leaveCollection({required int collectionId}) async {
    return await ApiService.instance.call(
      url: WebService.post.leaveCollection,
      param: {'collection_id': collectionId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> savePostToSharedCollection({required int postId, required int collectionId}) async {
    return await ApiService.instance.call(
      url: WebService.post.savePostToSharedCollection,
      param: {'post_id': postId, 'collection_id': collectionId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<Map<String, dynamic>> fetchSharedCollections() async {
    return await ApiService.instance.call(
      url: WebService.post.fetchSharedCollections,
      param: {},
      fromJson: (json) => json,
    );
  }

  Future<List<Post>> fetchSubscriberOnlyPosts({
    required int creatorId,
    int? lastItemId,
  }) async {
    PostsModel model = await ApiService.instance.call(
      url: WebService.post.fetchSubscriberOnlyPosts,
      param: {
        'creator_id': creatorId,
        Params.limit: AppRes.paginationLimit,
        if (lastItemId != null) 'offset': lastItemId,
      },
      fromJson: PostsModel.fromJson,
    );
    return model.data ?? [];
  }
}
