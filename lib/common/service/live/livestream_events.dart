class LivestreamEvents {
  LivestreamEvents._();

  // Client → Server
  static const cLiveStart = 'c:live_start';
  static const cLiveJoin = 'c:live_join';
  static const cLiveLeave = 'c:live_leave';
  static const cLiveEnd = 'c:live_end';
  static const cLiveUpdate = 'c:live_update';
  static const cLiveLike = 'c:live_like';
  static const cLiveUserStateUpdate = 'c:live_user_state_update';
  static const cLiveRequestJoin = 'c:live_request_join';
  static const cLiveRespondRequest = 'c:live_respond_request';
  static const cLiveInvite = 'c:live_invite';
  static const cLiveRespondInvite = 'c:live_respond_invite';
  static const cLiveRemoveCohost = 'c:live_remove_cohost';
  static const cLiveSendComment = 'c:live_send_comment';
  static const cLiveDeleteComment = 'c:live_delete_comment';
  static const cLiveCreatePoll = 'c:live_create_poll';
  static const cLiveVotePoll = 'c:live_vote_poll';
  static const cLiveEndPoll = 'c:live_end_poll';
  static const cLiveAskQuestion = 'c:live_ask_question';
  static const cLiveUpvoteQuestion = 'c:live_upvote_question';
  static const cLivePinQuestion = 'c:live_pin_question';
  static const cLiveAnswerQuestion = 'c:live_answer_question';

  // Server → Client
  static const sLiveStarted = 's:live_started';
  static const sLiveUpdated = 's:live_updated';
  static const sLiveEnded = 's:live_ended';
  static const sLiveUserJoined = 's:live_user_joined';
  static const sLiveUserLeft = 's:live_user_left';
  static const sLiveUserStateChanged = 's:live_user_state_changed';
  static const sLiveLike = 's:live_like';
  static const sLiveJoinRequest = 's:live_join_request';
  static const sLiveRequestResponse = 's:live_request_response';
  static const sLiveInvite = 's:live_invite';
  static const sLiveInviteResponse = 's:live_invite_response';
  static const sLiveCohostRemoved = 's:live_cohost_removed';
  static const sLiveNewComment = 's:live_new_comment';
  static const sLiveCommentDeleted = 's:live_comment_deleted';
  static const sLivePollCreated = 's:live_poll_created';
  static const sLivePollUpdated = 's:live_poll_updated';
  static const sLivePollEnded = 's:live_poll_ended';
  static const sLiveQuestionAsked = 's:live_question_asked';
  static const sLiveQuestionUpdated = 's:live_question_updated';
  static const sLiveQuestionPinned = 's:live_question_pinned';
}
