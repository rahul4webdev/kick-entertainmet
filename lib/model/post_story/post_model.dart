import 'dart:convert';

import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/url_extractor/parsers/base_parser.dart';
import 'package:shortzz/model/post_story/caption/caption_model.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/model/post_story/poll_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

enum ContentType {
  normal(0),
  musicVideo(1),
  trailer(2),
  news(3),
  shortStory(4);

  final int value;
  const ContentType(this.value);

  static ContentType fromInt(int v) => ContentType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => ContentType.normal,
      );

  String get label {
    switch (this) {
      case ContentType.normal:
        return 'Normal';
      case ContentType.musicVideo:
        return 'Music Video';
      case ContentType.trailer:
        return 'Trailer';
      case ContentType.news:
        return 'News';
      case ContentType.shortStory:
        return 'Short Story';
    }
  }
}

class PostModel {
  PostModel({
    bool? status,
    String? message,
    Post? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  PostModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    _data = json['data'] != null ? Post.fromJson(json['data']) : null;
  }

  bool? _status;
  String? _message;
  Post? _data;

  bool? get status => _status;

  String? get message => _message;

  Post? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class Post {
  Post({
    this.id,
    this.postSaveId,
    this.postType = PostType.none,
    this.contentType = ContentType.normal,
    this.contentMetadata,
    this.productLinks,
    this.linkedPreviousPostId,
    this.duetSourcePostId,
    this.allowDuet = true,
    this.duetLayout,
    this.duetSource,
    this.stitchSourcePostId,
    this.stitchStartMs,
    this.stitchEndMs,
    this.allowStitch = true,
    this.stitchSource,
    this.replyToCommentId,
    this.replyToCommentText,
    this.captions,
    this.hasCaptions = false,
    this.postStatus = 1,
    this.scheduledAt,
    this.isFeatured,
    this.isSubscriberOnly = false,
    this.isLocked = false,
    this.lockReason,
    this.isSubscribedToCreator = false,
    this.userId,
    this.soundId,
    this.metadata,
    this.description,
    this.hashtags,
    this.video,
    this.thumbnail,
    this.views,
    this.likes,
    this.comments,
    this.saves,
    this.shares,
    this.repostCount,
    this.mentionedUserIds,
    this.isTrending,
    this.canComment,
    this.isAiGenerated = false,
    this.visibility,
    this.placeTitle,
    this.placeLat,
    this.placeLon,
    this.state,
    this.country,
    this.isPinned,
    this.createdAt,
    this.updatedAt,
    this.isLiked,
    this.isSaved,
    this.mentionedUsers,
    this.images,
    this.music,
    this.user,
    this.collaborators,
    this.isCollaborative = false,
    this.productTags,
    this.threadId,
    this.threadPosition,
    this.threadCount,
    this.isQuoteRepost = false,
    this.quotedPostId,
    this.quotedPost,
  });

  Post.fromJson(dynamic json) {
    id = json['id'];
    postSaveId = json['post_save_id'];
    postType = json['post_type'] != null
        ? PostType.fromString(json['post_type'])
        : PostType.none;
    contentType = json['content_type'] != null
        ? ContentType.fromInt(json['content_type'])
        : ContentType.normal;
    if (json['content_metadata'] != null) {
      contentMetadata = json['content_metadata'] is String
          ? jsonDecode(json['content_metadata'])
          : Map<String, dynamic>.from(json['content_metadata']);
    }
    if (json['product_links'] != null) {
      final raw = json['product_links'] is String
          ? jsonDecode(json['product_links'])
          : json['product_links'];
      if (raw is List) {
        productLinks = raw.map((e) => ProductLink.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }
    linkedPreviousPostId = json['linked_previous_post_id'];
    duetSourcePostId = json['duet_source_post_id'];
    allowDuet = json['allow_duet'] ?? true;
    duetLayout = json['duet_layout'];
    if (json['duet_source'] != null) {
      duetSource = DuetSourceInfo.fromJson(json['duet_source']);
    }
    stitchSourcePostId = json['stitch_source_post_id'];
    stitchStartMs = json['stitch_start_ms'];
    stitchEndMs = json['stitch_end_ms'];
    allowStitch = json['allow_stitch'] ?? true;
    if (json['stitch_source'] != null) {
      stitchSource = DuetSourceInfo.fromJson(json['stitch_source']);
    }
    replyToCommentId = json['reply_to_comment_id'];
    replyToCommentText = json['reply_to_comment_text'];
    hasCaptions = json['has_captions'] == true || json['has_captions'] == 1;
    if (json['captions'] != null) {
      final raw = json['captions'] is String
          ? jsonDecode(json['captions'])
          : json['captions'];
      if (raw is List) {
        captions = raw
            .map((v) => Caption.fromJson(Map<String, dynamic>.from(v)))
            .toList();
      }
    }
    postStatus = json['post_status'] ?? 1;
    scheduledAt = json['scheduled_at'];
    isFeatured = json['is_featured'];
    isSubscriberOnly = json['is_subscriber_only'] == true || json['is_subscriber_only'] == 1;
    isLocked = json['is_locked'] == true || json['is_locked'] == 1;
    lockReason = json['lock_reason'];
    isSubscribedToCreator = json['is_subscribed_to_creator'] == true || json['is_subscribed_to_creator'] == 1;
    userId = json['user_id'];
    metadata = json['metadata'];
    soundId = json['sound_id'];
    description = json['description'];
    hashtags = json['hashtags'];
    video = json['video'];
    thumbnail = json['thumbnail'];
    views = json['views'] is bool ? (json['views'] == true ? 1 : 0) : json['views'];
    likes = json['likes'] is bool ? (json['likes'] == true ? 1 : 0) : json['likes'];
    comments = json['comments'] is bool ? (json['comments'] == true ? 1 : 0) : json['comments'];
    saves = json['saves'] is bool ? (json['saves'] == true ? 1 : 0) : json['saves'];
    shares = json['shares'] is bool ? (json['shares'] == true ? 1 : 0) : json['shares'];
    repostCount = json['repost_count'] is bool ? (json['repost_count'] == true ? 1 : 0) : json['repost_count'];
    mentionedUserIds = json['mentioned_user_ids'];
    isTrending = json['is_trending'] is bool ? (json['is_trending'] == true ? 1 : 0) : json['is_trending'];
    canComment = json['can_comment'] is bool ? (json['can_comment'] == true ? 1 : 0) : json['can_comment'];
    isAiGenerated = json['is_ai_generated'] == true || json['is_ai_generated'] == 1;
    visibility = json['visibility'];
    placeTitle = json['place_title'];
    placeLat = json['place_lat'] is String ? num.tryParse(json['place_lat']) : json['place_lat'];
    placeLon = json['place_lon'] is String ? num.tryParse(json['place_lon']) : json['place_lon'];
    state = json['state'];
    country = json['country'];
    isPinned = json['is_pinned'] is bool ? (json['is_pinned'] == true ? 1 : 0) : json['is_pinned'];
    hideLikeCount = json['hide_like_count'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isLiked = json['is_liked'];
    isSaved = json['is_saved'];
    if (json['mentioned_users'] != null) {
      mentionedUsers = [];
      json['mentioned_users'].forEach((v) {
        mentionedUsers?.add(User.fromJson(v));
      });
    }
    if (json['images'] != null) {
      images = [];
      json['images'].forEach((v) {
        images?.add(Images.fromJson(v));
      });
    }
    music = json['music'] != null ? Music.fromJson(json['music']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    if (json['collaborators'] != null) {
      collaborators = [];
      json['collaborators'].forEach((v) {
        if (v['user'] != null) {
          collaborators?.add(User.fromJson(v['user']));
        }
      });
    }
    isCollaborative = json['is_collaborative'] == true || json['is_collaborative'] == 1;
    if (json['product_tags'] != null) {
      productTags = [];
      json['product_tags'].forEach((v) {
        productTags?.add(PostProductTag.fromJson(v));
      });
    }
    if (json['poll'] != null) {
      poll = Poll.fromJson(json['poll']);
    }
    threadId = json['thread_id'];
    threadPosition = json['thread_position'];
    threadCount = json['thread_count'];
    isQuoteRepost = json['is_quote_repost'] == true || json['is_quote_repost'] == 1;
    quotedPostId = json['quoted_post_id'];
    if (json['quoted_post'] != null) {
      quotedPost = Post.fromJson(json['quoted_post']);
    }
  }

  int? id;
  int? postSaveId;
  PostType postType = PostType.none;
  ContentType contentType = ContentType.normal;
  Map<String, dynamic>? contentMetadata;
  List<ProductLink>? productLinks;
  int? linkedPreviousPostId;
  int? duetSourcePostId;
  bool allowDuet = true;
  String? duetLayout;
  DuetSourceInfo? duetSource;
  int? stitchSourcePostId;
  int? stitchStartMs;
  int? stitchEndMs;
  bool allowStitch = true;
  DuetSourceInfo? stitchSource;
  int? replyToCommentId;
  String? replyToCommentText;
  List<Caption>? captions;
  bool hasCaptions = false;
  int postStatus = 1; // 1=published, 2=scheduled, 3=failed
  String? scheduledAt;
  bool? isFeatured;
  bool isSubscriberOnly = false;
  bool isLocked = false;
  String? lockReason;
  bool isSubscribedToCreator = false;
  int? userId;
  int? soundId;
  String? metadata;
  String? description;
  String? hashtags;
  String? video;
  String? thumbnail;
  num? views;
  num? likes;
  num? comments;
  num? saves;
  num? shares;
  num? repostCount;
  String? mentionedUserIds;
  num? isTrending;
  num? canComment;
  bool isAiGenerated = false;
  int? visibility;
  String? placeTitle;
  num? placeLat;
  num? placeLon;
  String? state;
  String? country;
  int? isPinned;
  bool? hideLikeCount;
  String? createdAt;
  String? updatedAt;
  bool? isLiked;
  bool? isSaved;
  List<User>? mentionedUsers;
  List<Images>? images;
  Music? music;
  User? user;
  List<User>? collaborators;
  bool isCollaborative = false;
  List<PostProductTag>? productTags;
  Poll? poll;
  int? threadId;
  int? threadPosition;
  int? threadCount;
  bool isQuoteRepost = false;
  int? quotedPostId;
  Post? quotedPost;

  // Post status helpers
  bool get isScheduled => postStatus == 2;
  bool get isPublished => postStatus == 1;

  // Thread helpers
  bool get isThread => threadId != null;
  bool get isThreadParent => threadId != null && threadId == id;

  // Duet, Stitch & Video Reply helpers
  bool get isDuet => duetSourcePostId != null;
  bool get isStitch => stitchSourcePostId != null;
  bool get isVideoReply => replyToCommentId != null;

  // Content metadata helpers
  String? get genre => contentMetadata?['genre'];
  String? get contentLanguage => contentMetadata?['language'];
  String? get artistName => contentMetadata?['artist'];
  String? get releaseDate => contentMetadata?['release_date'];
  String? get category => contentMetadata?['category'];
  String? get production => contentMetadata?['production'];
  String? get source => contentMetadata?['source'];
  bool get isBreaking => contentMetadata?['is_breaking'] == true;
  int? get seriesId => contentMetadata?['series_id'];
  int? get episodeNumber => contentMetadata?['episode_number'];

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['post_save_id'] = postSaveId;
    map['post_type'] = postType.type;
    map['content_type'] = contentType.value;
    map['content_metadata'] = contentMetadata;
    if (productLinks != null) {
      map['product_links'] = productLinks!.map((e) => e.toJson()).toList();
    }
    map['linked_previous_post_id'] = linkedPreviousPostId;
    map['duet_source_post_id'] = duetSourcePostId;
    map['allow_duet'] = allowDuet;
    map['duet_layout'] = duetLayout;
    if (duetSource != null) {
      map['duet_source'] = duetSource!.toJson();
    }
    map['stitch_source_post_id'] = stitchSourcePostId;
    map['stitch_start_ms'] = stitchStartMs;
    map['stitch_end_ms'] = stitchEndMs;
    map['allow_stitch'] = allowStitch;
    if (stitchSource != null) {
      map['stitch_source'] = stitchSource!.toJson();
    }
    map['reply_to_comment_id'] = replyToCommentId;
    map['reply_to_comment_text'] = replyToCommentText;
    map['has_captions'] = hasCaptions;
    if (captions != null) {
      map['captions'] = captions!.map((v) => v.toJson()).toList();
    }
    map['post_status'] = postStatus;
    map['scheduled_at'] = scheduledAt;
    map['is_featured'] = isFeatured;
    map['is_subscriber_only'] = isSubscriberOnly;
    map['is_locked'] = isLocked;
    map['lock_reason'] = lockReason;
    map['is_subscribed_to_creator'] = isSubscribedToCreator;
    map['user_id'] = userId;
    map['sound_id'] = soundId;
    map['metadata'] = metadata;
    map['description'] = description;
    map['hashtags'] = hashtags;
    map['video'] = video;
    map['thumbnail'] = thumbnail;
    map['views'] = views;
    map['likes'] = likes;
    map['comments'] = comments;
    map['saves'] = saves;
    map['shares'] = shares;
    map['mentioned_user_ids'] = mentionedUserIds;
    map['is_trending'] = isTrending;
    map['can_comment'] = canComment;
    map['is_ai_generated'] = isAiGenerated;
    map['visibility'] = visibility;
    map['place_title'] = placeTitle;
    map['place_lat'] = placeLat;
    map['place_lon'] = placeLon;
    map['state'] = state;
    map['country'] = country;
    map['is_pinned'] = isPinned;
    map['hide_like_count'] = hideLikeCount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['is_liked'] = isLiked;
    map['is_saved'] = isSaved;
    if (mentionedUsers != null) {
      map['mentioned_users'] = mentionedUsers?.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      map['images'] = images?.map((v) => v.toJson()).toList();
    }

    if (music != null) {
      map['music'] = music?.toJson();
    }

    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (productTags != null) {
      map['product_tags'] = productTags?.map((v) => v.toJson()).toList();
    }
    if (poll != null) {
      map['poll'] = poll?.toJson();
    }
    map['thread_id'] = threadId;
    map['thread_position'] = threadPosition;
    map['thread_count'] = threadCount;
    map['is_quote_repost'] = isQuoteRepost;
    map['quoted_post_id'] = quotedPostId;
    if (quotedPost != null) {
      map['quoted_post'] = quotedPost?.toJson();
    }
    return map;
  }

  Map<String, dynamic> toJsonForChat() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['post_save_id'] = postSaveId;
    map['post_type'] = postType.type;
    map['content_type'] = contentType.value;
    map['content_metadata'] = contentMetadata;
    map['linked_previous_post_id'] = linkedPreviousPostId;
    map['duet_source_post_id'] = duetSourcePostId;
    map['allow_duet'] = allowDuet;
    map['duet_layout'] = duetLayout;
    map['stitch_source_post_id'] = stitchSourcePostId;
    map['stitch_start_ms'] = stitchStartMs;
    map['stitch_end_ms'] = stitchEndMs;
    map['allow_stitch'] = allowStitch;
    map['reply_to_comment_id'] = replyToCommentId;
    map['reply_to_comment_text'] = replyToCommentText;
    map['has_captions'] = hasCaptions;
    if (captions != null) {
      map['captions'] = captions!.map((v) => v.toJson()).toList();
    }
    map['user_id'] = userId;
    map['sound_id'] = soundId;
    map['metadata'] = metadata;
    map['description'] = description;
    map['hashtags'] = hashtags;
    map['video'] = video;
    map['thumbnail'] = thumbnail;
    // map['views'] = views;
    // map['likes'] = likes;
    // map['comments'] = comments;
    // map['saves'] = saves;
    map['shares'] = shares;
    map['mentioned_user_ids'] = mentionedUserIds;
    map['is_trending'] = isTrending;
    map['can_comment'] = canComment;
    map['is_ai_generated'] = isAiGenerated;
    map['visibility'] = visibility;
    map['place_title'] = placeTitle;
    map['place_lat'] = placeLat;
    map['place_lon'] = placeLon;
    map['state'] = state;
    map['country'] = country;
    map['is_pinned'] = isPinned;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    // map['is_liked'] = isLiked;
    // map['is_saved'] = isSaved;
    if (mentionedUsers != null) {
      map['mentioned_users'] = mentionedUsers?.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      map['images'] = images?.map((v) => v.toJson()).toList();
    }

    if (music != null) {
      map['music'] = music?.toJson();
    }

    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

  String get descriptionWithUserName {
    List<String> mentionIds = (mentionedUserIds ?? '').split(',');
    String updatedDescription = description ?? '';

    for (var element in mentionIds) {
      User? user =
          mentionedUsers?.firstWhereOrNull((u) => u.id == int.parse(element));
      if (user != null) {
        updatedDescription =
            updatedDescription.replaceAll('@$element', '@${user.username}');
      }
    }
    return updatedDescription;
  }

  void likeToggle(bool isLike) {
    isLiked = isLike;
    int i = isLike ? 1 : -1;
    likes = ((likes ?? 0) + i).clamp(0, 999999999);
    user?.totalPostLikesCount =
        ((user?.totalPostLikesCount ?? 0) + i).clamp(0, 999999999);
  }

  void saveToggle(bool isSave) {
    isSaved = isSave;
    int i = isSave ? 1 : -1;
    saves = ((saves ?? 0) + i).clamp(0, 999999999);
  }

  void increaseShares(int count) {
    shares = (shares ?? 0) + count;
  }

  void increaseViews() {
    views = (views ?? 0) + 1;
  }

  void updateCommentCount(int i) {
    comments = (comments ?? 0) + i;
  }

  String get getThumbnail {
    return (postType == PostType.image
        ? (images?.first.image ?? '')
        : (thumbnail ?? ''));
  }

  UrlMetadata? get metaData {
    if (metadata == null || metadata?.isEmpty == true) {
      return null;
    } else {
      Map<String, dynamic>? valueMap = jsonDecode(metadata ?? '');
      if (valueMap != null) return UrlMetadata.fromJson(valueMap);
    }
    return null;
  }
}

class Images {
  Images({
    num? id,
    num? postId,
    String? image,
    String? altText,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _postId = postId;
    _image = image;
    _altText = altText;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Images.fromJson(dynamic json) {
    _id = json['id'];
    _postId = json['post_id'];
    _image = json['image'];
    _altText = json['alt_text'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  num? _id;
  num? _postId;
  String? _image;
  String? _altText;
  String? _createdAt;
  String? _updatedAt;

  num? get id => _id;

  num? get postId => _postId;

  String? get image => _image;

  String? get altText => _altText;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['post_id'] = _postId;
    map['image'] = _image;
    map['alt_text'] = _altText;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}

enum ProductButtonType {
  buyNow('buy_now', 'Buy Now'),
  signup('signup', 'Sign Up'),
  contact('contact', 'Contact'),
  register('register', 'Register');

  final String value;
  final String label;
  const ProductButtonType(this.value, this.label);

  static ProductButtonType fromString(String value) {
    return ProductButtonType.values.firstWhereOrNull(
          (e) => e.value == value,
        ) ??
        ProductButtonType.buyNow;
  }
}

class DuetSourceInfo {
  int? id;
  int? userId;
  String? video;
  String? thumbnail;
  String? description;
  User? user;

  DuetSourceInfo({this.id, this.userId, this.video, this.thumbnail, this.description, this.user});

  DuetSourceInfo.fromJson(dynamic json) {
    id = json['id'];
    userId = json['user_id'];
    video = json['video'];
    thumbnail = json['thumbnail'];
    description = json['description'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'video': video,
      'thumbnail': thumbnail,
      'description': description,
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class PostProductTag {
  int? id;
  int? postId;
  int? productId;
  String? label;
  double? displayPositionX;
  double? displayPositionY;
  int? displayTimeStartMs;
  int? displayTimeEndMs;
  bool isAutoAffiliate;
  TaggedProductInfo? product;

  PostProductTag({
    this.id,
    this.postId,
    this.productId,
    this.label,
    this.displayPositionX,
    this.displayPositionY,
    this.displayTimeStartMs,
    this.displayTimeEndMs,
    this.isAutoAffiliate = false,
    this.product,
  });

  factory PostProductTag.fromJson(Map<String, dynamic> json) {
    return PostProductTag(
      id: json['id'],
      postId: json['post_id'],
      productId: json['product_id'],
      label: json['label'],
      displayPositionX: (json['display_position_x'] as num?)?.toDouble(),
      displayPositionY: (json['display_position_y'] as num?)?.toDouble(),
      displayTimeStartMs: json['display_time_start_ms'],
      displayTimeEndMs: json['display_time_end_ms'],
      isAutoAffiliate: json['is_auto_affiliate'] == true,
      product: json['product'] != null
          ? TaggedProductInfo.fromJson(Map<String, dynamic>.from(json['product']))
          : null,
    );
  }

  bool get hasPosition => displayPositionX != null && displayPositionY != null;
  bool get hasTiming => displayTimeStartMs != null && displayTimeEndMs != null;

  bool isVisibleAtTime(int currentMs) {
    if (!hasTiming) return true;
    return currentMs >= displayTimeStartMs! && currentMs <= displayTimeEndMs!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'product_id': productId,
      'label': label,
      if (displayPositionX != null) 'display_position_x': displayPositionX,
      if (displayPositionY != null) 'display_position_y': displayPositionY,
      if (displayTimeStartMs != null) 'display_time_start_ms': displayTimeStartMs,
      if (displayTimeEndMs != null) 'display_time_end_ms': displayTimeEndMs,
      'is_auto_affiliate': isAutoAffiliate,
      if (product != null) 'product': product!.toJson(),
    };
  }
}

class TaggedProductInfo {
  int? id;
  String? name;
  int? priceCoins;
  List<String>? images;
  int? sellerId;
  int? soldCount;
  double? avgRating;
  User? seller;

  TaggedProductInfo({
    this.id,
    this.name,
    this.priceCoins,
    this.images,
    this.sellerId,
    this.soldCount,
    this.avgRating,
    this.seller,
  });

  String get firstImageUrl {
    if (images != null && images!.isNotEmpty) return images!.first.addBaseURL();
    return '';
  }

  factory TaggedProductInfo.fromJson(Map<String, dynamic> json) {
    List<String>? imgs;
    if (json['images'] != null) {
      if (json['images'] is String) {
        final decoded = jsonDecode(json['images']);
        if (decoded is List) imgs = decoded.cast<String>();
      } else if (json['images'] is List) {
        imgs = (json['images'] as List).cast<String>();
      }
    }
    // Use image_urls if available (pre-generated by backend)
    if (json['image_urls'] != null && json['image_urls'] is List) {
      imgs = (json['image_urls'] as List).cast<String>();
    }

    return TaggedProductInfo(
      id: json['id'],
      name: json['name'],
      priceCoins: json['price_coins'],
      images: imgs,
      sellerId: json['seller_id'],
      soldCount: json['sold_count'],
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : null,
      seller: json['seller'] != null ? User.fromJson(json['seller']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_coins': priceCoins,
      'images': images,
      'seller_id': sellerId,
      'sold_count': soldCount,
      'avg_rating': avgRating,
      if (seller != null) 'seller': seller!.toJson(),
    };
  }
}

class ProductLink {
  String? label;
  String? url;
  ProductButtonType buttonType;

  ProductLink({
    this.label,
    this.url,
    this.buttonType = ProductButtonType.buyNow,
  });

  factory ProductLink.fromJson(Map<String, dynamic> json) {
    return ProductLink(
      label: json['label'],
      url: json['url'],
      buttonType: ProductButtonType.fromString(json['button_type'] ?? 'buy_now'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'url': url,
      'button_type': buttonType.value,
    };
  }
}
