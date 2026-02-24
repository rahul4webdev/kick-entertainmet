import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/livestream/livestream_replay_model.dart';

class ReplayService {
  ReplayService._();

  static final ReplayService instance = ReplayService._();

  Future<LivestreamReplaySingleModel> saveReplay({
    required String roomId,
    String? title,
    String? thumbnail,
    String? recordingUrl,
    int? durationSeconds,
    int? peakViewers,
    int? totalLikes,
    int? totalGiftsCoins,
  }) async {
    LivestreamReplaySingleModel response = await ApiService.instance.call(
      url: WebService.replays.saveReplay,
      fromJson: LivestreamReplaySingleModel.fromJson,
      param: {
        'room_id': roomId,
        'title': title,
        'thumbnail': thumbnail,
        'recording_url': recordingUrl,
        'duration_seconds': durationSeconds,
        'peak_viewers': peakViewers,
        'total_likes': totalLikes,
        'total_gifts_coins': totalGiftsCoins,
      },
    );
    return response;
  }

  Future<LivestreamReplayListModel> fetchMyReplays() async {
    LivestreamReplayListModel response = await ApiService.instance.call(
      url: WebService.replays.fetchMyReplays,
      fromJson: LivestreamReplayListModel.fromJson,
    );
    return response;
  }

  Future<LivestreamReplayListModel> fetchUserReplays({
    required int userId,
  }) async {
    LivestreamReplayListModel response = await ApiService.instance.call(
      url: WebService.replays.fetchUserReplays,
      fromJson: LivestreamReplayListModel.fromJson,
      param: {'user_id': userId},
    );
    return response;
  }

  Future<StatusModel> deleteReplay({required int replayId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.replays.deleteReplay,
      fromJson: StatusModel.fromJson,
      param: {'replay_id': replayId},
    );
    return response;
  }

  Future<StatusModel> updateReplay({
    required int replayId,
    String? title,
    String? thumbnail,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.replays.updateReplay,
      fromJson: StatusModel.fromJson,
      param: {
        'replay_id': replayId,
        'title': title,
        'thumbnail': thumbnail,
      },
    );
    return response;
  }

  Future<StatusModel> incrementViewCount({required int replayId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.replays.viewReplay,
      fromJson: StatusModel.fromJson,
      param: {'replay_id': replayId},
    );
    return response;
  }
}
