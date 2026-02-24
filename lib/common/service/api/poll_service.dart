import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/post_story/poll_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class PollService {
  PollService._();
  static final PollService instance = PollService._();

  Future<PostModel> createPollPost({
    required String question,
    required List<Map<String, dynamic>> options,
    int pollType = 0,
    bool allowMultiple = false,
    String? endsAt,
    int visibility = 0,
    int canComment = 1,
  }) async {
    return await ApiService.instance.call(
      url: WebService.poll.createPollPost,
      fromJson: PostModel.fromJson,
      param: {
        'question': question,
        'options': options,
        'poll_type': pollType,
        'allow_multiple': allowMultiple ? 1 : 0,
        if (endsAt != null) 'ends_at': endsAt,
        'visibility': visibility,
        'can_comment': canComment,
      },
    );
  }

  Future<PollModel> voteOnPoll({
    required int pollId,
    required int optionId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.poll.voteOnPoll,
      fromJson: PollModel.fromJson,
      param: {
        'poll_id': pollId,
        'option_id': optionId,
      },
    );
  }

  Future<PollModel> fetchPollResults({required int postId}) async {
    return await ApiService.instance.call(
      url: WebService.poll.fetchPollResults,
      fromJson: PollModel.fromJson,
      param: {'post_id': postId},
    );
  }

  Future<StatusModel> closePoll({required int pollId}) async {
    return await ApiService.instance.call(
      url: WebService.poll.closePoll,
      fromJson: StatusModel.fromJson,
      param: {'poll_id': pollId},
    );
  }
}
