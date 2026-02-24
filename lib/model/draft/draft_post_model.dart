import 'dart:convert';

import 'package:shortzz/model/post_story/caption/caption_model.dart';

class DraftPost {
  String id;
  int draftType; // 0=reel, 1=feed_image, 2=feed_video, 3=feed_text
  String? contentPath;
  String? thumbnailPath;
  String description;
  List<String> hashtags;
  int visibility; // 0=Public, 1=Followers, 2=Only Me
  bool canComment;
  List<double>? colorFilter;
  String? musicTitle;
  int? musicId;
  String? country;
  String? state;
  String? placeTitle;
  double? placeLat;
  double? placeLon;
  List<Caption>? captions;
  int? durationSec;
  DateTime? scheduledAt;
  DateTime createdAt;
  DateTime updatedAt;

  DraftPost({
    required this.id,
    required this.draftType,
    this.contentPath,
    this.thumbnailPath,
    this.description = '',
    this.hashtags = const [],
    this.visibility = 0,
    this.canComment = true,
    this.colorFilter,
    this.musicTitle,
    this.musicId,
    this.country,
    this.state,
    this.placeTitle,
    this.placeLat,
    this.placeLon,
    this.captions,
    this.durationSec,
    this.scheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DraftPost.fromJson(Map<String, dynamic> json) {
    List<Caption>? captions;
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

    return DraftPost(
      id: json['id'] ?? '',
      draftType: json['draft_type'] ?? 0,
      contentPath: json['content_path'],
      thumbnailPath: json['thumbnail_path'],
      description: json['description'] ?? '',
      hashtags: (json['hashtags'] as List?)?.cast<String>() ?? [],
      visibility: json['visibility'] ?? 0,
      canComment: json['can_comment'] ?? true,
      colorFilter: (json['color_filter'] as List?)?.cast<double>(),
      musicTitle: json['music_title'],
      musicId: json['music_id'],
      country: json['country'],
      state: json['state'],
      placeTitle: json['place_title'],
      placeLat: json['place_lat']?.toDouble(),
      placeLon: json['place_lon']?.toDouble(),
      captions: captions,
      durationSec: json['duration_sec'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'draft_type': draftType,
      'content_path': contentPath,
      'thumbnail_path': thumbnailPath,
      'description': description,
      'hashtags': hashtags,
      'visibility': visibility,
      'can_comment': canComment,
      'color_filter': colorFilter,
      'music_title': musicTitle,
      'music_id': musicId,
      'country': country,
      'state': state,
      'place_title': placeTitle,
      'place_lat': placeLat,
      'place_lon': placeLon,
      'captions': captions?.map((c) => c.toJson()).toList(),
      'duration_sec': durationSec,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get draftTypeLabel {
    switch (draftType) {
      case 0:
        return 'Reel';
      case 1:
        return 'Image';
      case 2:
        return 'Video';
      case 3:
        return 'Text';
      default:
        return 'Draft';
    }
  }
}
