import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/common/service/live/livestream_events.dart';

/// Reuses the same Socket.IO connection as ChatSocketService.
/// All livestream events go through the same socket (same server/port).
class LivestreamSocketService {
  static final LivestreamSocketService instance = LivestreamSocketService._();
  LivestreamSocketService._();

  // ── Lifecycle ──────────────────────────────────────────────────────

  void startLivestream(Map<String, dynamic> data) {
    Loggers.info('[LiveSocket] startLivestream: ${data['room_id']}');
    ChatSocketService.instance.emit(LivestreamEvents.cLiveStart, data);
  }

  void joinLivestream(String roomId, {String? type, String? audioStatus, String? videoStatus}) {
    Loggers.info('[LiveSocket] joinLivestream: $roomId');
    ChatSocketService.instance.emit(LivestreamEvents.cLiveJoin, {
      'room_id': roomId,
      if (type != null) 'type': type,
      if (audioStatus != null) 'audio_status': audioStatus,
      if (videoStatus != null) 'video_status': videoStatus,
    });
  }

  void leaveLivestream(String roomId) {
    Loggers.info('[LiveSocket] leaveLivestream: $roomId');
    ChatSocketService.instance.emit(LivestreamEvents.cLiveLeave, {
      'room_id': roomId,
    });
  }

  void endLivestream(String roomId) {
    Loggers.info('[LiveSocket] endLivestream: $roomId');
    ChatSocketService.instance.emit(LivestreamEvents.cLiveEnd, {
      'room_id': roomId,
    });
  }

  // ── Metadata Updates ───────────────────────────────────────────────

  void updateLivestream(Map<String, dynamic> data) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveUpdate, data);
  }

  void likeLivestream(String roomId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveLike, {
      'room_id': roomId,
    });
  }

  // ── User State ─────────────────────────────────────────────────────

  void updateUserState(Map<String, dynamic> data) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveUserStateUpdate, data);
  }

  // ── Co-host Management ─────────────────────────────────────────────

  void requestJoin(String roomId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveRequestJoin, {
      'room_id': roomId,
    });
  }

  void respondRequest(String roomId, int targetUserId, bool accepted) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveRespondRequest, {
      'room_id': roomId,
      'target_user_id': targetUserId,
      'accepted': accepted,
    });
  }

  void inviteUser(String roomId, int targetUserId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveInvite, {
      'room_id': roomId,
      'target_user_id': targetUserId,
    });
  }

  void respondInvite(String roomId, bool accepted) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveRespondInvite, {
      'room_id': roomId,
      'accepted': accepted,
    });
  }

  void removeCohost(String roomId, int targetUserId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveRemoveCohost, {
      'room_id': roomId,
      'target_user_id': targetUserId,
    });
  }

  // ── Comments ───────────────────────────────────────────────────────

  void sendComment(Map<String, dynamic> data) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveSendComment, data);
  }

  void deleteComment(String roomId, int commentId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveDeleteComment, {
      'room_id': roomId,
      'comment_id': commentId,
    });
  }

  // ── Polls ──────────────────────────────────────────────────────────

  void createPoll(Map<String, dynamic> data) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveCreatePoll, data);
  }

  void votePoll(String roomId, String pollId, int optionIndex) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveVotePoll, {
      'room_id': roomId,
      'poll_id': pollId,
      'option_index': optionIndex,
    });
  }

  void endPoll(String roomId, String pollId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveEndPoll, {
      'room_id': roomId,
      'poll_id': pollId,
    });
  }

  // ── Q&A ────────────────────────────────────────────────────────────

  void askQuestion(Map<String, dynamic> data) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveAskQuestion, data);
  }

  void upvoteQuestion(String roomId, String questionId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveUpvoteQuestion, {
      'room_id': roomId,
      'question_id': questionId,
    });
  }

  void pinQuestion(String roomId, String questionId, bool isPinned) {
    ChatSocketService.instance.emit(LivestreamEvents.cLivePinQuestion, {
      'room_id': roomId,
      'question_id': questionId,
      'is_pinned': isPinned,
    });
  }

  void answerQuestion(String roomId, String questionId) {
    ChatSocketService.instance.emit(LivestreamEvents.cLiveAnswerQuestion, {
      'room_id': roomId,
      'question_id': questionId,
    });
  }

  // ── Event Listeners ────────────────────────────────────────────────

  void on(String event, Function(dynamic) handler) {
    ChatSocketService.instance.on(event, handler);
  }

  void off(String event) {
    ChatSocketService.instance.off(event);
  }
}
