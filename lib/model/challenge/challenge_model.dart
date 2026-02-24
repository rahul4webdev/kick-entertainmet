import 'package:shortzz/model/user_model/user_model.dart';

class ChallengeListModel {
  bool? status;
  String? message;
  List<Challenge>? data;

  ChallengeListModel({this.status, this.message, this.data});

  ChallengeListModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Challenge.fromJson(v));
      });
    }
  }
}

class ChallengeDetailModel {
  bool? status;
  String? message;
  Challenge? data;

  ChallengeDetailModel({this.status, this.message, this.data});

  ChallengeDetailModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Challenge.fromJson(json['data']) : null;
  }
}

class Challenge {
  int? id;
  int? creatorId;
  String? title;
  String? description;
  String? hashtag;
  String? rules;
  int challengeType;
  String? coverImage;
  String? previewVideo;
  String? startsAt;
  String? endsAt;
  int prizeType;
  int prizeAmount;
  int entryCount;
  int viewCount;
  bool isFeatured;
  bool isActive;
  int status;
  String? createdAt;
  String? updatedAt;
  User? creator;
  bool hasEntered;

  Challenge({
    this.id,
    this.creatorId,
    this.title,
    this.description,
    this.hashtag,
    this.rules,
    this.challengeType = 0,
    this.coverImage,
    this.previewVideo,
    this.startsAt,
    this.endsAt,
    this.prizeType = 0,
    this.prizeAmount = 0,
    this.entryCount = 0,
    this.viewCount = 0,
    this.isFeatured = false,
    this.isActive = true,
    this.status = 1,
    this.createdAt,
    this.updatedAt,
    this.creator,
    this.hasEntered = false,
  });

  Challenge.fromJson(dynamic json)
      : id = json['id'],
        creatorId = json['creator_id'],
        title = json['title'],
        description = json['description'],
        hashtag = json['hashtag'],
        rules = json['rules'],
        challengeType = json['challenge_type'] ?? 0,
        coverImage = json['cover_image'],
        previewVideo = json['preview_video'],
        startsAt = json['starts_at'],
        endsAt = json['ends_at'],
        prizeType = json['prize_type'] ?? 0,
        prizeAmount = json['prize_amount'] ?? 0,
        entryCount = json['entry_count'] ?? 0,
        viewCount = json['view_count'] ?? 0,
        isFeatured =
            json['is_featured'] == true || json['is_featured'] == 1,
        isActive = json['is_active'] == true || json['is_active'] == 1,
        status = json['status'] ?? 1,
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        creator =
            json['creator'] != null ? User.fromJson(json['creator']) : null,
        hasEntered =
            json['has_entered'] == true || json['has_entered'] == 1;

  bool get isEnded =>
      endsAt != null &&
      DateTime.tryParse(endsAt!)?.isBefore(DateTime.now()) == true;

  bool get isStatusActive => status == 1;
  bool get isStatusEnded => status == 2;
  bool get isStatusJudging => status == 3;
  bool get isStatusCompleted => status == 4;

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Active';
      case 2:
        return 'Ended';
      case 3:
        return 'Judging';
      case 4:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  bool get hasPrize => prizeType > 0 && prizeAmount > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'hashtag': hashtag,
      'rules': rules,
      'challenge_type': challengeType,
      'cover_image': coverImage,
      'preview_video': previewVideo,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'prize_type': prizeType,
      'prize_amount': prizeAmount,
      'entry_count': entryCount,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'is_active': isActive,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ChallengeEntryListModel {
  bool? status;
  String? message;
  List<ChallengeEntry>? data;

  ChallengeEntryListModel({this.status, this.message, this.data});

  ChallengeEntryListModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(ChallengeEntry.fromJson(v));
      });
    }
  }
}

class ChallengeEntry {
  int? id;
  int? challengeId;
  int? postId;
  int? userId;
  int score;
  int? rank;
  bool isWinner;
  String? createdAt;
  User? user;
  dynamic post;

  ChallengeEntry({
    this.id,
    this.challengeId,
    this.postId,
    this.userId,
    this.score = 0,
    this.rank,
    this.isWinner = false,
    this.createdAt,
    this.user,
    this.post,
  });

  ChallengeEntry.fromJson(dynamic json)
      : id = json['id'],
        challengeId = json['challenge_id'],
        postId = json['post_id'],
        userId = json['user_id'],
        score = json['score'] ?? 0,
        rank = json['rank'],
        isWinner = json['is_winner'] == true || json['is_winner'] == 1,
        createdAt = json['created_at'],
        user = json['user'] != null ? User.fromJson(json['user']) : null,
        post = json['post'];
}
