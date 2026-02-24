import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/challenge/challenge_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class ChallengeService {
  ChallengeService._();
  static final ChallengeService instance = ChallengeService._();

  Future<ChallengeDetailModel> createChallenge({
    required String title,
    required String description,
    required String hashtag,
    required String startsAt,
    required String endsAt,
    String? rules,
    int challengeType = 0,
    String? coverImage,
    String? previewVideo,
    int prizeType = 0,
    int prizeAmount = 0,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.createChallenge,
      fromJson: ChallengeDetailModel.fromJson,
      param: {
        'title': title,
        'description': description,
        'hashtag': hashtag,
        'starts_at': startsAt,
        'ends_at': endsAt,
        if (rules != null) 'rules': rules,
        'challenge_type': challengeType,
        if (coverImage != null) 'cover_image': coverImage,
        if (previewVideo != null) 'preview_video': previewVideo,
        'prize_type': prizeType,
        'prize_amount': prizeAmount,
      },
    );
  }

  Future<ChallengeListModel> fetchChallenges({
    int? status,
    int? lastItemId,
    int limit = 20,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.fetchChallenges,
      fromJson: ChallengeListModel.fromJson,
      param: {
        if (status != null) 'status': status,
        if (lastItemId != null) 'last_item_id': lastItemId,
        'limit': limit,
      },
    );
  }

  Future<ChallengeDetailModel> fetchChallengeById({
    required int challengeId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.fetchChallengeById,
      fromJson: ChallengeDetailModel.fromJson,
      param: {'challenge_id': challengeId},
    );
  }

  Future<StatusModel> enterChallenge({
    required int challengeId,
    required int postId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.enterChallenge,
      fromJson: StatusModel.fromJson,
      param: {
        'challenge_id': challengeId,
        'post_id': postId,
      },
    );
  }

  Future<ChallengeEntryListModel> fetchEntries({
    required int challengeId,
    int limit = 20,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.fetchEntries,
      fromJson: ChallengeEntryListModel.fromJson,
      param: {
        'challenge_id': challengeId,
        'limit': limit,
      },
    );
  }

  Future<ChallengeEntryListModel> fetchLeaderboard({
    required int challengeId,
    int limit = 50,
  }) async {
    return await ApiService.instance.call(
      url: WebService.challenge.fetchLeaderboard,
      fromJson: ChallengeEntryListModel.fromJson,
      param: {
        'challenge_id': challengeId,
        'limit': limit,
      },
    );
  }

  Future<StatusModel> endChallenge({required int challengeId}) async {
    return await ApiService.instance.call(
      url: WebService.challenge.endChallenge,
      fromJson: StatusModel.fromJson,
      param: {'challenge_id': challengeId},
    );
  }

  Future<StatusModel> awardPrizes({required int challengeId}) async {
    return await ApiService.instance.call(
      url: WebService.challenge.awardPrizes,
      fromJson: StatusModel.fromJson,
      param: {'challenge_id': challengeId},
    );
  }
}
