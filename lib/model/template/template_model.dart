class TemplateResponse {
  bool? status;
  String? message;
  List<VideoTemplate>? data;
  List<String>? categories;

  TemplateResponse({this.status, this.message, this.data, this.categories});

  factory TemplateResponse.fromJson(Map<String, dynamic> json) =>
      TemplateResponse(
        status: json['status'],
        message: json['message'],
        data: json['data'] != null
            ? (json['data'] as List)
                .map((e) => VideoTemplate.fromJson(e))
                .toList()
            : null,
        categories: json['categories'] != null
            ? (json['categories'] as List).map((e) => e.toString()).toList()
            : null,
      );
}

class SingleTemplateResponse {
  bool? status;
  String? message;
  VideoTemplate? data;

  SingleTemplateResponse({this.status, this.message, this.data});

  factory SingleTemplateResponse.fromJson(Map<String, dynamic> json) =>
      SingleTemplateResponse(
        status: json['status'],
        message: json['message'],
        data: json['data'] != null
            ? VideoTemplate.fromJson(json['data'])
            : null,
      );
}

class VideoTemplate {
  int? id;
  String? name;
  String? description;
  String? thumbnail;
  String? previewVideo;
  int? clipCount;
  int? durationSec;
  String? category;
  int? musicId;
  List<dynamic>? transitionData;
  bool? isActive;
  int? useCount;
  int? sortOrder;
  List<TemplateClip>? clips;
  Map<String, dynamic>? music;
  int? creatorId;
  bool isUserCreated;
  int? sourcePostId;
  int trendingScore;
  int likeCount;
  Map<String, dynamic>? creator;
  bool isLiked;

  VideoTemplate({
    this.id,
    this.name,
    this.description,
    this.thumbnail,
    this.previewVideo,
    this.clipCount,
    this.durationSec,
    this.category,
    this.musicId,
    this.transitionData,
    this.isActive,
    this.useCount,
    this.sortOrder,
    this.clips,
    this.music,
    this.creatorId,
    this.isUserCreated = false,
    this.sourcePostId,
    this.trendingScore = 0,
    this.likeCount = 0,
    this.creator,
    this.isLiked = false,
  });

  factory VideoTemplate.fromJson(Map<String, dynamic> json) => VideoTemplate(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        thumbnail: json['thumbnail'],
        previewVideo: json['preview_video'],
        clipCount: json['clip_count'],
        durationSec: json['duration_sec'],
        category: json['category'],
        musicId: json['music_id'],
        transitionData: json['transition_data'],
        isActive: json['is_active'],
        useCount: json['use_count'],
        sortOrder: json['sort_order'],
        clips: json['clips'] != null
            ? (json['clips'] as List)
                .map((e) => TemplateClip.fromJson(e))
                .toList()
            : null,
        music: json['music'],
        creatorId: json['creator_id'],
        isUserCreated: json['is_user_created'] == true ||
            json['is_user_created'] == 1,
        sourcePostId: json['source_post_id'],
        trendingScore: json['trending_score'] ?? 0,
        likeCount: json['like_count'] ?? 0,
        creator: json['creator'] != null
            ? Map<String, dynamic>.from(json['creator'])
            : null,
        isLiked: json['is_liked'] == true || json['is_liked'] == 1,
      );

  int get totalDurationMs => (durationSec ?? 15) * 1000;

  String? get creatorUsername => creator?['username'];
  String? get creatorProfilePhoto => creator?['profile_photo'];
}

class TemplateClip {
  int? id;
  int? templateId;
  int? clipIndex;
  int? durationMs;
  String? label;
  String? transitionToNext;
  int? transitionDurationMs;

  TemplateClip({
    this.id,
    this.templateId,
    this.clipIndex,
    this.durationMs,
    this.label,
    this.transitionToNext,
    this.transitionDurationMs,
  });

  factory TemplateClip.fromJson(Map<String, dynamic> json) => TemplateClip(
        id: json['id'],
        templateId: json['template_id'],
        clipIndex: json['clip_index'],
        durationMs: json['duration_ms'],
        label: json['label'],
        transitionToNext: json['transition_to_next'],
        transitionDurationMs: json['transition_duration_ms'],
      );

  double get durationSec => (durationMs ?? 3000) / 1000.0;
}
