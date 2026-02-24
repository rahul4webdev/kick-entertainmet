class ChatEvents {
  ChatEvents._();

  // Client → Server
  static const cSendMessage = 'c:send_message';
  static const cMarkRead = 'c:mark_read';
  static const cDeleteForMe = 'c:delete_for_me';
  static const cUnsend = 'c:unsend';
  static const cAcceptRequest = 'c:accept_request';
  static const cRejectRequest = 'c:reject_request';
  static const cDeleteConversation = 'c:delete_conversation';
  static const cSyncBlock = 'c:sync_block';
  static const cTypingStart = 'c:typing_start';
  static const cTypingStop = 'c:typing_stop';
  static const cAddReaction = 'c:add_reaction';
  static const cRemoveReaction = 'c:remove_reaction';
  static const cEditMessage = 'c:edit_message';

  // Scheduled Messages
  static const cScheduleMessage = 'c:schedule_message';
  static const cCancelScheduled = 'c:cancel_scheduled';
  static const cFetchScheduled = 'c:fetch_scheduled';

  // Vanish Mode
  static const cToggleVanish = 'c:toggle_vanish';
  static const cLeaveVanishChat = 'c:leave_vanish_chat';

  // Read receipts + delivery
  static const cMessageDelivered = 'c:message_delivered';
  static const cMarkMessagesRead = 'c:mark_messages_read';

  // Forward
  static const cForwardMessage = 'c:forward_message';

  // Pin
  static const cPinMessage = 'c:pin_message';
  static const cUnpinMessage = 'c:unpin_message';

  // Star
  static const cStarMessage = 'c:star_message';
  static const cUnstarMessage = 'c:unstar_message';

  // Mute/Archive
  static const cMuteConversation = 'c:mute_conversation';
  static const cUnmuteConversation = 'c:unmute_conversation';
  static const cArchiveConversation = 'c:archive_conversation';
  static const cUnarchiveConversation = 'c:unarchive_conversation';

  // E2E Encryption
  static const cEnableEncryption = 'c:enable_encryption';
  static const cDisableEncryption = 'c:disable_encryption';
  static const cKeyExchange = 'c:key_exchange';

  // Group chats
  static const cCreateGroup = 'c:create_group';
  static const cAddGroupMember = 'c:add_group_member';
  static const cRemoveGroupMember = 'c:remove_group_member';
  static const cLeaveGroup = 'c:leave_group';
  static const cUpdateGroup = 'c:update_group';
  static const cMakeAdmin = 'c:make_admin';
  static const cSendGroupMessage = 'c:send_group_message';

  // Server → Client
  static const sNewMessage = 's:new_message';
  static const sConversationUpdate = 's:conversation_update';
  static const sMessageDeleted = 's:message_deleted';
  static const sMessageUnsent = 's:message_unsent';
  static const sTyping = 's:typing';
  static const sOnlineStatus = 's:online_status';
  static const sError = 's:error';
  static const sMessageReaction = 's:message_reaction';
  static const sMessageEdited = 's:message_edited';

  // Scheduled Messages Server → Client
  static const sScheduledConfirmed = 's:scheduled_confirmed';
  static const sScheduledCanceled = 's:scheduled_canceled';
  static const sScheduledList = 's:scheduled_list';

  // Vanish Mode Server → Client
  static const sVanishToggled = 's:vanish_toggled';
  static const sVanishCleared = 's:vanish_cleared';

  // Read receipts + delivery Server → Client
  static const sMessageDelivered = 's:message_delivered';
  static const sMessagesRead = 's:messages_read';

  // Link preview
  static const sLinkPreview = 's:link_preview';

  // Forward
  static const sMessageForwarded = 's:message_forwarded';

  // Pin
  static const sMessagePinned = 's:message_pinned';
  static const sMessageUnpinned = 's:message_unpinned';

  // Star
  static const sMessageStarred = 's:message_starred';
  static const sMessageUnstarred = 's:message_unstarred';

  // Mute/Archive
  static const sConversationMuted = 's:conversation_muted';
  static const sConversationUnmuted = 's:conversation_unmuted';
  static const sConversationArchived = 's:conversation_archived';
  static const sConversationUnarchived = 's:conversation_unarchived';

  // E2E Encryption Server → Client
  static const sEncryptionEnabled = 's:encryption_enabled';
  static const sEncryptionDisabled = 's:encryption_disabled';
  static const sKeyExchanged = 's:key_exchanged';

  // Group chats Server → Client
  static const sGroupCreated = 's:group_created';
  static const sGroupMemberAdded = 's:group_member_added';
  static const sGroupMemberRemoved = 's:group_member_removed';
  static const sGroupLeft = 's:group_left';
  static const sGroupUpdated = 's:group_updated';
  static const sGroupAdminChanged = 's:group_admin_changed';

  // Call Signaling
  static const cCallCreate = 'c:call_create';
  static const cCallUpdateStatus = 'c:call_update_status';
  static const sCallStatusChanged = 's:call_status_changed';
}
