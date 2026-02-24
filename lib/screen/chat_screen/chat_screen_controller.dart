import 'dart:async';
import 'dart:convert';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/enum/chat_enum.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/common_service.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/common/service/chat/chat_api_service.dart';
import 'package:shortzz/common/service/chat/chat_encryption_service.dart';
import 'package:shortzz/common/service/chat/chat_events.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/model/chat/scheduled_message.dart';
import 'package:shortzz/model/general/settings_model.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/blocked_user_screen/block_user_controller.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_audio_message.dart';
import 'package:shortzz/screen/chat_screen/widget/select_media_sheet.dart';
import 'package:shortzz/screen/chat_screen/widget/send_media_sheet.dart';
import 'package:shortzz/screen/gif_sheet/gif_sheet.dart';
import 'package:shortzz/screen/gift_sheet/send_gift_sheet_controller.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/screen/report_sheet/report_sheet.dart';
import 'package:shortzz/screen/story_view_screen/story_view_screen.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/style_res.dart';

class ChatScreenController extends BlockUserController
    with GetTickerProviderStateMixin {
  List<UserRequestAction> requestType = UserRequestAction.values;
  User? myUser = SessionManager.instance.getUser();
  final Setting? setting = SessionManager.instance.getSettings();
  User? otherUser;

  RxBool isTextEmpty = true.obs;
  RxBool hasMore = true.obs;
  RxBool isExpanded = false.obs;
  bool isPostAPiCalling = false;

  // Edit message state
  Rx<MessageData?> editingMessage = Rx<MessageData?>(null);
  bool get isEditing => editingMessage.value != null;

  // Reply state
  Rx<MessageData?> replyingToMessage = Rx<MessageData?>(null);
  bool get isReplying => replyingToMessage.value != null;

  // Search state
  RxBool isSearching = false.obs;
  RxList<MessageData> searchResults = <MessageData>[].obs;
  TextEditingController searchController = TextEditingController();

  // Scheduled messages
  RxList<ScheduledMessageData> scheduledMessages = <ScheduledMessageData>[].obs;

  // Vanish mode
  RxBool isVanishMode = false.obs;

  // E2E Encryption
  RxBool isEncryptionEnabled = false.obs;

  RxBool isOtherUserTyping = false.obs;
  RxBool isOtherUserOnline = false.obs;

  TextEditingController textController = TextEditingController();
  TextEditingController mediaTextController = TextEditingController();
  Rx<ChatThread> conversationUser;
  ChatThread? myConversationUser;

  late AnimationController audioAnimationController;
  Animation<double>? audioWidthAnimation;

  MessageType chatType = MessageType.text;

  RxList<MessageData> chatList = <MessageData>[].obs;

  StreamSubscription<PlayerState>? playerControllerListen;

  int? _lastMessageId;

  RecorderController recorderController = RecorderController();
  PlayerController playerController = PlayerController();
  Rx<PlayerValue> playerValue =
      PlayerValue(state: PlayerState.stopped, id: 0).obs;

  ChatScreenController(this.conversationUser);

  static String chatId = '';

  Timer? _typingDebounce;

  @override
  void onInit() {
    super.onInit();
    chatId = conversationUser.value.conversationId ?? 'No CONVERSATION';
  }

  @override
  void onReady() {
    super.onReady();
    _init();
    _loadInitialMessages();
    _listenToSocketEvents();
    isEncryptionEnabled.value =
        conversationUser.value.encryptionEnabled == true;
  }

  @override
  void onClose() {
    _leaveVanishChat();
    super.onClose();
    chatId = '';
    _removeSocketListeners();
    _typingDebounce?.cancel();
    playerControllerListen?.cancel();
    audioAnimationController.dispose();
    recorderController.dispose();
    playerController.dispose();
    textController.dispose();
    mediaTextController.dispose();
    searchController.dispose();
    _markAsRead();
  }

  _init() {
    _initAudioAnimationController();
    _initializePlayerStateListener();
    _fetchOtherUser();
  }

  _initAudioAnimationController() {
    audioAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    final double maxWidth = Get.width - 30;

    audioWidthAnimation = Tween<double>(
      begin: 0,
      end: maxWidth,
    ).animate(CurvedAnimation(
        parent: audioAnimationController, curve: Curves.easeInOut));
  }

  _initializePlayerStateListener() {
    playerControllerListen =
        playerController.onPlayerStateChanged.listen((event) {
      playerValue.update((val) => val?.state = event);
      Loggers.success('Player State: $event');
    });
  }

  _fetchOtherUser() async {
    int userId = conversationUser.value.userId ?? -1;
    if (userId != -1) {
      otherUser = await UserService.instance.fetchUserDetails(userId: userId);
      Loggers.info('Other User Device Token: ${otherUser?.deviceToken}');
    }
  }

  void _listenToSocketEvents() {
    final socket = ChatSocketService.instance;

    socket.on(ChatEvents.sNewMessage, (data) {
      if (data is! Map) return;
      final message = MessageData.fromJson(Map<String, dynamic>.from(data));
      if (message.conversationId != conversationUser.value.conversationId) return;

      // Avoid duplicates
      if (!chatList.any((m) => m.id == message.id)) {
        chatList.insert(0, message);
      }

      // Auto-confirm delivery for messages from other user
      final myId = SessionManager.instance.getUserID();
      if (message.userId != myId && message.id != null) {
        socket.emit(ChatEvents.cMessageDelivered, {
          'conversation_id': message.conversationId,
          'message_ids': [message.id],
        });
      }
    });

    socket.on(ChatEvents.sConversationUpdate, (data) {
      if (data is! Map) return;
      final thread = ChatThread.fromJson(Map<String, dynamic>.from(data));
      if (thread.conversationId != conversationUser.value.conversationId) return;

      // Preserve chatUser if not in update
      final existingChatUser = conversationUser.value.chatUser;
      conversationUser.value = thread;
      if (thread.chatUser == null && existingChatUser != null) {
        conversationUser.value.chatUser = existingChatUser;
      }
      Loggers.info('Chat Updated: ${thread.toJson()}');
    });

    socket.on(ChatEvents.sMessageDeleted, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      chatList.removeWhere((m) => m.id == map['message_id']);
    });

    socket.on(ChatEvents.sMessageUnsent, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      chatList.removeWhere((m) => m.id == map['message_id']);
    });

    socket.on(ChatEvents.sTyping, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      isOtherUserTyping.value = map['is_typing'] == true;
    });

    socket.on(ChatEvents.sOnlineStatus, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['user_id'] == conversationUser.value.userId) {
        isOtherUserOnline.value = map['is_online'] == true;
      }
    });

    socket.on(ChatEvents.sMessageReaction, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) {
        return;
      }
      final messageId = map['message_id'];
      final index = chatList.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final reactions = <MessageReaction>[];
        if (map['reactions'] != null) {
          for (var r in map['reactions']) {
            reactions.add(
                MessageReaction.fromJson(Map<String, dynamic>.from(r)));
          }
        }
        chatList[index].reactions = reactions;
        chatList.refresh();
      }
    });

    socket.on(ChatEvents.sMessageEdited, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) {
        return;
      }
      final messageId = map['message_id'];
      final index = chatList.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        chatList[index].textMessage = map['text_message'];
        chatList[index].editedAt = map['edited_at'];
        chatList.refresh();
      }
    });

    socket.on(ChatEvents.sScheduledConfirmed, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      final scheduled = ScheduledMessageData.fromJson(map);
      scheduledMessages.add(scheduled);
      showSnackBar('Message scheduled');
    });

    socket.on(ChatEvents.sScheduledCanceled, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      scheduledMessages.removeWhere((m) => m.id == map['scheduled_id']);
    });

    socket.on(ChatEvents.sVanishToggled, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      isVanishMode.value = map['vanish_mode'] == true;
    });

    socket.on(ChatEvents.sVanishCleared, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      isVanishMode.value = false;
      chatList.removeWhere((m) => m.isVanish == true);
    });

    // Read receipts + delivery
    socket.on(ChatEvents.sMessageDelivered, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      final messageIds = (map['message_ids'] as List?)?.cast<int>() ?? [];
      final deliveredAt = map['delivered_at'];
      for (final msgId in messageIds) {
        final idx = chatList.indexWhere((m) => m.id == msgId);
        if (idx != -1 && chatList[idx].status == 'sent') {
          chatList[idx].status = 'delivered';
          chatList[idx].deliveredAt = deliveredAt;
        }
      }
      chatList.refresh();
    });

    socket.on(ChatEvents.sMessagesRead, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      final readAt = map['read_at'];
      final myId = SessionManager.instance.getUserID();
      // Mark all my sent messages as read
      for (var i = 0; i < chatList.length; i++) {
        if (chatList[i].userId == myId && chatList[i].status != 'read') {
          chatList[i].status = 'read';
          chatList[i].readAt = readAt;
        }
      }
      chatList.refresh();
    });

    // Link preview
    socket.on(ChatEvents.sLinkPreview, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      final messageId = map['message_id'];
      final idx = chatList.indexWhere((m) => m.id == messageId);
      if (idx != -1 && map['link_preview'] != null) {
        chatList[idx].linkPreview = LinkPreview.fromJson(
            Map<String, dynamic>.from(map['link_preview']));
        chatList.refresh();
      }
    });

    // Pin/Unpin
    socket.on(ChatEvents.sMessagePinned, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      showSnackBar('Message pinned');
    });

    socket.on(ChatEvents.sMessageUnpinned, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      showSnackBar('Message unpinned');
    });

    // Star/Unstar
    socket.on(ChatEvents.sMessageStarred, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      showSnackBar('Message starred');
    });

    socket.on(ChatEvents.sMessageUnstarred, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      showSnackBar('Star removed');
    });

    // E2E Encryption
    socket.on(ChatEvents.sEncryptionEnabled, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      isEncryptionEnabled.value = true;
      showSnackBar('End-to-end encryption enabled');
    });

    socket.on(ChatEvents.sEncryptionDisabled, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      isEncryptionEnabled.value = false;
      _deleteEncryptionKey();
      showSnackBar('End-to-end encryption disabled');
    });

    socket.on(ChatEvents.sKeyExchanged, (data) {
      if (data is! Map) return;
      final map = Map<String, dynamic>.from(data);
      if (map['conversation_id'] != conversationUser.value.conversationId) return;
      final encryptedKey = map['encrypted_key'] as String?;
      if (encryptedKey != null) {
        _storeReceivedKey(encryptedKey);
      }
    });
  }

  void _removeSocketListeners() {
    final socket = ChatSocketService.instance;
    socket.off(ChatEvents.sNewMessage);
    socket.off(ChatEvents.sConversationUpdate);
    socket.off(ChatEvents.sMessageDeleted);
    socket.off(ChatEvents.sMessageUnsent);
    socket.off(ChatEvents.sTyping);
    socket.off(ChatEvents.sOnlineStatus);
    socket.off(ChatEvents.sMessageReaction);
    socket.off(ChatEvents.sMessageEdited);
    socket.off(ChatEvents.sScheduledConfirmed);
    socket.off(ChatEvents.sScheduledCanceled);
    socket.off(ChatEvents.sVanishToggled);
    socket.off(ChatEvents.sVanishCleared);
    socket.off(ChatEvents.sMessageDelivered);
    socket.off(ChatEvents.sMessagesRead);
    socket.off(ChatEvents.sLinkPreview);
    socket.off(ChatEvents.sMessagePinned);
    socket.off(ChatEvents.sMessageUnpinned);
    socket.off(ChatEvents.sMessageStarred);
    socket.off(ChatEvents.sMessageUnstarred);
    socket.off(ChatEvents.sEncryptionEnabled);
    socket.off(ChatEvents.sEncryptionDisabled);
    socket.off(ChatEvents.sKeyExchanged);
  }

  void _loadInitialMessages() async {
    final conversationId = conversationUser.value.conversationId;
    if (conversationId == null) return;

    final messages = await ChatApiService.instance.fetchMessages(conversationId);
    chatList.assignAll(messages);

    if (messages.isNotEmpty) {
      _lastMessageId = messages.last.id;
    }
    if (messages.length < 40) {
      hasMore.value = false;
    }
  }

  Future<void> fetchMoreChatList() async {
    if (!hasMore.value || isLoading.value) return;
    isLoading.value = true;

    try {
      final conversationId = conversationUser.value.conversationId;
      if (conversationId == null) return;

      final messages = await ChatApiService.instance.fetchMessages(
        conversationId,
        before: _lastMessageId,
      );

      if (messages.isEmpty) {
        hasMore.value = false;
        return;
      }

      _lastMessageId = messages.last.id;

      for (var msg in messages) {
        if (!chatList.any((m) => m.id == msg.id)) {
          chatList.add(msg);
        }
      }
    } catch (e) {
      Loggers.error("Error fetching more messages: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSendTextMessage() async {
    if (isEditing) {
      onSendEditMessage();
      return;
    }
    String text = textController.text.trim();
    textController.clear();
    isTextEmpty.value = true;
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar(
          'You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }

    // Build reply_to if replying
    Map<String, dynamic>? replyTo;
    if (isReplying) {
      final msg = replyingToMessage.value!;
      replyTo = {
        'message_id': msg.id,
        'user_id': msg.userId,
        'text_preview': (msg.textMessage ?? msg.messageType?.value ?? '').length > 100
            ? (msg.textMessage ?? msg.messageType?.value ?? '').substring(0, 100)
            : (msg.textMessage ?? msg.messageType?.value ?? ''),
        'message_type': msg.messageType?.value,
      };
      replyingToMessage.value = null;
    }

    // Encrypt text if E2E is enabled
    if (isEncryptionEnabled.value) {
      final encrypted = await _encryptText(text);
      if (encrypted != null) {
        sendMessage(
          type: MessageType.text,
          textMessage: encrypted,
          replyTo: replyTo,
          isEncrypted: true,
        );
        return;
      }
    }
    sendMessage(type: MessageType.text, textMessage: text, replyTo: replyTo);
  }

  void sendMessage(
      {required MessageType type,
      String? textMessage,
      String? imageMessage,
      String? videoMessage,
      String? audioMessage,
      String? postMessage,
      String? storyReplyMessage,
      List<double>? waveData,
      Map<String, dynamic>? replyTo,
      bool isEncrypted = false}) {
    final isGroup = conversationUser.value.isGroup;
    final event = isGroup
        ? ChatEvents.cSendGroupMessage
        : ChatEvents.cSendMessage;
    ChatSocketService.instance.emit(event, {
      'conversation_id': conversationUser.value.conversationId,
      if (!isGroup) 'recipient_id': conversationUser.value.userId,
      'message_type': type.value,
      if (textMessage != null) 'text_message': textMessage,
      if (imageMessage != null) 'image_message': imageMessage,
      if (videoMessage != null) 'video_message': videoMessage,
      if (audioMessage != null) 'audio_message': audioMessage,
      if (postMessage != null) 'post_message': postMessage,
      if (storyReplyMessage != null) 'story_reply_message': storyReplyMessage,
      if (waveData != null) 'wave_data': waveData.join(','),
      if (replyTo != null) 'reply_to': replyTo,
      if (isEncrypted) 'is_encrypted': true,
      if (isEncrypted) 'encryption_version': ChatEncryptionService.instance.encryptionVersion,
    });
  }

  String getLastMessage(MessageType type, MessageData message,
      {bool isSender = true}) {
    String prefix = isSender ? "You: " : "";
    String sentPrefix = isSender ? "You sent " : "Sent you ";

    switch (type) {
      case MessageType.text:
        return "$prefix${message.textMessage ?? ''}";
      case MessageType.image:
        return '${sentPrefix}an Image';
      case MessageType.video:
        return '${sentPrefix}a Video';
      case MessageType.gift:
        return '${sentPrefix}a Gift';
      case MessageType.audio:
        return '${sentPrefix}a voice message';
      case MessageType.gif:
        return '${sentPrefix}a GIF';
      case MessageType.post:
        Post post = Post.fromJson(jsonDecode(message.postMessage ?? ''));
        return '$sentPrefix@${post.user?.username ?? ''}\'s post';
      case MessageType.storyReply:
        return '${sentPrefix}a Story Reply';
      case MessageType.document:
        return '${sentPrefix}a Document';
    }
  }

  void onTextFieldChanged(String value) {
    if (value.trim().isNotEmpty) {
      isTextEmpty.value = false;
      ChatSocketService.instance.emit(ChatEvents.cTypingStart, {
        'conversation_id': conversationUser.value.conversationId,
      });
      _typingDebounce?.cancel();
      _typingDebounce = Timer(const Duration(seconds: 3), () {
        ChatSocketService.instance.emit(ChatEvents.cTypingStop, {
          'conversation_id': conversationUser.value.conversationId,
        });
      });
    } else {
      isTextEmpty.value = true;
      ChatSocketService.instance.emit(ChatEvents.cTypingStop, {
        'conversation_id': conversationUser.value.conversationId,
      });
    }
  }

  onChatActionTap(ChatAction action) {
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar(
          'You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }
    FocusManager.instance.primaryFocus?.unfocus();
    switch (action) {
      case ChatAction.gift:
        pickGift();
        break;
      case ChatAction.audio:
        _pickAudio();
        break;
      case ChatAction.sticker:
        pickSticker();
        break;
      case ChatAction.media:
        pickAndSendMedia();
        break;
    }
  }

  void onCameraTap() {
    if (conversationUser.value.iAmBlocked ?? false) {
      return showSnackBar(
          'You cannot message ${conversationUser.value.chatUser?.username} because you are blocked by them.');
    }
    FocusManager.instance.primaryFocus?.unfocus();
    Get.bottomSheet(SelectMediaSheet(
      onSelectMedia: (mediaFile) {
        Get.back();
        _showSendMediaSheet(mediaFile);
      },
    ), isScrollControlled: true);
  }

  void pickGift() {
    int? userId = conversationUser.value.chatUser?.userId;

    GiftManager.openGiftSheet(
        userId: userId ?? -1,
        onCompletion: (giftManager) {
          sendMessage(
              type: MessageType.gift,
              textMessage: giftManager.gift.coinPrice.toString(),
              imageMessage: giftManager.gift.image);
        });
  }

  void pickSticker() {
    Get.bottomSheet<String?>(const GifSheet(), isScrollControlled: true)
        .then((value) {
      if (value != null) {
        sendMessage(type: MessageType.gif, imageMessage: value);
      }
    });
  }

  void pickAndSendMedia() async {
    MediaFile? mediaFile = await MediaPickerHelper.shared.pickMedia();
    if (mediaFile == null) return;
    mediaTextController.clear();
    _showSendMediaSheet(mediaFile);
  }

  void _showSendMediaSheet(MediaFile mediaFile) {
    Get.bottomSheet(
      SendMediaSheet(
          controller: this,
          image: mediaFile.thumbNail.path,
          onSendBtnClick: () {
            Get.back();
            _uploadAndSendMessage(mediaFile);
          }),
      isScrollControlled: true,
    );
  }

  Future<void> _uploadAndSendMessage(MediaFile mediaFile) async {
    showLoader();

    String filePath = await _uploadFile(mediaFile.file);

    Loggers.success(filePath);

    String thumbnailPath = mediaFile.type == MediaType.video
        ? await _uploadFile(mediaFile.thumbNail)
        : '';
    stopLoader();
    bool isImageMessage = mediaFile.type == MediaType.image;
    Loggers.success('THIS IS IMAGE MESSAGE : $isImageMessage');
    if (filePath == '') {
      return Loggers.error('Filepath Not Found Please try Again');
    }
    if (!isImageMessage && thumbnailPath == '') {
      return Loggers.error('ThumbnailPath Not Found Please try Again');
    }

    sendMessage(
      type: isImageMessage ? MessageType.image : MessageType.video,
      imageMessage: isImageMessage ? filePath : thumbnailPath,
      videoMessage: !isImageMessage ? filePath : thumbnailPath,
      textMessage: mediaTextController.text.trim(),
    );
  }

  Future<String> _uploadFile(XFile file) async {
    return (await CommonService.instance.uploadFileGivePath(file)).data ?? '';
  }

  void toggleAnimation() {
    if (isExpanded.value) {
      audioAnimationController.reverse();
    } else {
      audioAnimationController.forward();
    }
    isExpanded.value = !isExpanded.value;
  }

  void _pickAudio() async {
    recorderController = RecorderController();
    bool isGranted = await recorderController.checkPermission();
    if (isGranted) {
      audioAnimationController.forward();
      recorderController.record(
          androidEncoder: AndroidEncoder.aac,
          androidOutputFormat: AndroidOutputFormat.mpeg4,
          iosEncoder: IosEncoder.kAudioFormatMPEG4AAC);
    } else {
      Get.bottomSheet(
          ConfirmationSheet(
              title: LKey.enableMicrophoneAccessTitle.tr,
              description: LKey.enableMicrophoneAccessDescription.tr,
              onTap: openAppSettings,
              positiveText: LKey.settings.tr),
          isScrollControlled: true);
    }
  }

  void deleteRecordedAudio() async {
    audioAnimationController.reverse();
    recorderController.reset();
    recorderController.dispose();
  }

  void sendRecordedAudio() async {
    audioAnimationController.reverse();
    showLoader();

    try {
      String? recordedFilePath = await recorderController.stop();
      if (recordedFilePath != null) {
        List<double> waveData = await playerController.extractWaveformData(
          path: recordedFilePath,
          noOfSamples: playerWaveStyle.getSamplesForWidth(wavesWidth),
        );

        Loggers.info('Recorded file path: $recordedFilePath');

        String audioUrl = await _uploadFile(XFile(recordedFilePath));
        sendMessage(
          type: MessageType.audio,
          audioMessage: audioUrl,
          waveData: waveData,
        );
      } else {
        Loggers.error('Audio path not found');
      }
    } catch (e) {
      Loggers.error('Audio recording error: $e');
    } finally {
      stopLoader();
      recorderController.dispose();
    }
  }

  void startAudioPlayback() async {
    await playerController.startPlayer();
    playerController.setFinishMode(finishMode: FinishMode.pause);
  }

  void pauseAudioPlayback() async {
    await playerController.pausePlayer();
  }

  void toggleAudioPlayback(MessageData message) {
    if (playerValue.value.id == message.id) {
      switch (playerValue.value.state) {
        case PlayerState.initialized:
        case PlayerState.playing:
          pauseAudioPlayback();
          break;
        case PlayerState.paused:
          startAudioPlayback();
          break;
        case PlayerState.stopped:
          break;
      }
    } else {
      playAudioMessage(message);
    }
  }

  void playAudioMessage(MessageData message) async {
    String audioUrl = message.audioMessage?.addBaseURL() ?? '';
    if (audioUrl.isEmpty) return;

    DefaultCacheManager().getSingleFile(audioUrl).then((file) async {
      playerController.release();
      await playerController.preparePlayer(
        path: file.path,
        noOfSamples: playerWaveStyle.getSamplesForWidth(wavesWidth),
      );

      playerValue.value =
          PlayerValue(state: PlayerState.initialized, id: message.id ?? 0);
      startAudioPlayback();
    });
  }

  void onDeleteForYou(MessageData message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    ChatSocketService.instance.emit(ChatEvents.cDeleteForMe, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
  }

  void onUnSend(MessageData message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    ChatSocketService.instance.emit(ChatEvents.cUnsend, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
    _deleteAssociatedFiles(message);
  }

  void addReaction(MessageData message, String emoji) {
    final myId = SessionManager.instance.getUserID();
    final existing = message.reactions?.firstWhereOrNull(
        (r) => r.userId == myId);
    if (existing?.emoji == emoji) {
      removeReaction(message);
      return;
    }
    ChatSocketService.instance.emit(ChatEvents.cAddReaction, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
      'emoji': emoji,
    });
  }

  void removeReaction(MessageData message) {
    ChatSocketService.instance.emit(ChatEvents.cRemoveReaction, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
  }

  bool canEditMessage(MessageData message) {
    if (message.userId != SessionManager.instance.getUserID()) return false;
    if (message.messageType != MessageType.text) return false;
    final fifteenMinutes = 15 * 60 * 1000;
    return (DateTime.now().millisecondsSinceEpoch - (message.id ?? 0)) <
        fifteenMinutes;
  }

  void startEditMessage(MessageData message) {
    editingMessage.value = message;
    textController.text = message.textMessage ?? '';
    isTextEmpty.value = false;
  }

  void cancelEditMessage() {
    editingMessage.value = null;
    textController.clear();
    isTextEmpty.value = true;
  }

  void onSendEditMessage() {
    final text = textController.text.trim();
    if (text.isEmpty || editingMessage.value == null) return;
    ChatSocketService.instance.emit(ChatEvents.cEditMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': editingMessage.value!.id,
      'text_message': text,
    });
    editingMessage.value = null;
    textController.clear();
    isTextEmpty.value = true;
  }

  Future<void> _deleteAssociatedFiles(MessageData message) async {
    switch (message.messageType) {
      case MessageType.text:
        break;
      case MessageType.image:
        await deleteFile(message.imageMessage ?? '');
        break;
      case MessageType.video:
        await deleteFile(message.videoMessage ?? '');
        await deleteFile(message.imageMessage ?? '');
        break;
      case MessageType.audio:
        await deleteFile(message.audioMessage ?? '');
        break;
      case MessageType.gift:
        break;
      case MessageType.gif:
        break;
      case MessageType.post:
        break;
      case MessageType.storyReply:
        break;
      case MessageType.document:
        break;
      case null:
        break;
    }
  }

  Future<bool> deleteFile(String file) async {
    StatusModel response = await CommonService.instance.deleteFile(file);
    if (response.status == true) return true;
    return false;
  }

  void onChatRequestTap(
      UserRequestAction requestType, ChatThread conversation) async {
    switch (requestType) {
      case UserRequestAction.block:
        AppUser? user = conversation.chatUser;
        blockUser(
            User(
                id: user?.userId,
                profilePhoto: user?.profile,
                username: user?.username,
                fullname: user?.fullname,
                isVerify: user?.isVerify),
            () {});
        break;
      case UserRequestAction.reject:
        ChatSocketService.instance.emit(ChatEvents.cRejectRequest, {
          'conversation_id': conversationUser.value.conversationId,
        });
        Get.back();
        break;
      case UserRequestAction.accept:
        ChatSocketService.instance.emit(ChatEvents.cAcceptRequest, {
          'conversation_id': conversationUser.value.conversationId,
        });
        break;
    }
  }

  void onPostTap(Post post) async {
    PostType type = post.postType;
    playerController.pausePlayer();
    fetchPost(postType: post.postType, post: post);
    switch (type) {
      case PostType.reel:
      case PostType.video:
        Get.to(() =>
            ReelsScreen(reels: [post].obs, position: 0, isFromChat: true));
        break;
      case PostType.image:
      case PostType.text:
        Get.to(() => SinglePostScreen(post: post, isFromNotification: false));
        break;
      case PostType.none:
        break;
    }
  }

  void fetchPost({required PostType postType, Post? post}) async {
    Post? _post =
        (await PostService.instance.fetchPostById(postId: post?.id ?? -1))
            .data
            ?.post;
    if (_post == null) return;
    switch (postType) {
      case PostType.image:
      case PostType.text:
        Get.find<PostScreenController>(tag: _post.id.toString())
            .updatePost(_post);
        break;
      case PostType.reel:
      case PostType.video:
        Get.find<ReelController>(tag: _post.id.toString())
            .updateReelData(reel: _post);
        break;
      case PostType.none:
        break;
    }
  }

  void onReportUser(ChatThread chatThread) {
    Get.bottomSheet(
        ReportSheet(
            reportType: ReportType.user, id: chatThread.chatUser?.userId),
        isScrollControlled: true);
  }

  void toggleBlockUnblock(ChatThread chatThread) {
    if (chatThread.iBlocked ?? false) {
      unblockUser(otherUser, () {});
    } else {
      blockUser(otherUser, () {});
    }
  }

  void sendStoryReply(
      {required Story story, required String textReply, String? imageReply}) {
    sendMessage(
        type: MessageType.storyReply,
        imageMessage: imageReply,
        textMessage: textReply,
        storyReplyMessage: jsonEncode(story.toJsonWithUser()));
  }

  void scheduleMessage({
    required DateTime scheduledTime,
    required MessageType type,
    String? textMessage,
    String? imageMessage,
    String? videoMessage,
    String? audioMessage,
    List<double>? waveData,
  }) {
    ChatSocketService.instance.emit(ChatEvents.cScheduleMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'recipient_id': conversationUser.value.userId,
      'message_type': type.value,
      'scheduled_at': scheduledTime.millisecondsSinceEpoch,
      if (textMessage != null) 'text_message': textMessage,
      if (imageMessage != null) 'image_message': imageMessage,
      if (videoMessage != null) 'video_message': videoMessage,
      if (audioMessage != null) 'audio_message': audioMessage,
      if (waveData != null) 'wave_data': waveData.join(','),
    });
  }

  void cancelScheduled(String scheduledId) async {
    final success = await ChatApiService.instance.cancelScheduledMessage(scheduledId);
    if (success) {
      scheduledMessages.removeWhere((m) => m.id == scheduledId);
      showSnackBar('Scheduled message canceled');
    }
  }

  void fetchScheduled() async {
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;
    final messages = await ChatApiService.instance.fetchScheduledMessages(convId);
    scheduledMessages.assignAll(messages);
  }

  void onScheduleTextMessage(DateTime scheduledTime) {
    String text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();
    isTextEmpty.value = true;
    scheduleMessage(
      scheduledTime: scheduledTime,
      type: MessageType.text,
      textMessage: text,
    );
  }

  void toggleVanishMode() {
    ChatSocketService.instance.emit(ChatEvents.cToggleVanish, {
      'conversation_id': conversationUser.value.conversationId,
    });
  }

  void _leaveVanishChat() {
    if (!isVanishMode.value) return;
    ChatSocketService.instance.emit(ChatEvents.cLeaveVanishChat, {
      'conversation_id': conversationUser.value.conversationId,
    });
  }

  _markAsRead() {
    ChatSocketService.instance.emit(ChatEvents.cMarkRead, {
      'conversation_id': conversationUser.value.conversationId,
    });
  }

  void removeStoryFromChat(MessageData message) {
    final index = chatList.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      chatList[index].storyReplyMessage = jsonEncode(Story());
      chatList.refresh();
    }
  }

  void onStoryTap(MessageData message, Story story) {
    final createdAtStr = story.createdAt;
    if (createdAtStr == null || createdAtStr.isEmpty) {
      removeStoryFromChat(message);
      return;
    }

    DateTime? storyDate;
    try {
      storyDate = DateTime.parse(createdAtStr);
    } catch (e) {
      removeStoryFromChat(message);
      return;
    }

    final isExpired = DateTime.now().difference(storyDate).inHours >= 24;
    if (isExpired) {
      removeStoryFromChat(message);
      return;
    }

    if (story.id == null) {
      removeStoryFromChat(message);
      return;
    }

    final user = User(
      id: story.userId,
      username: story.user?.username ?? '',
      fullname: story.user?.fullname ?? '',
      profilePhoto: story.user?.profilePhoto ?? '',
      isVerify: story.user?.isVerify,
      bio: story.user?.bio ?? '',
      stories: [story],
    );

    Get.bottomSheet(
      StoryViewSheet(
        stories: [user],
        userIndex: 0,
        onUpdateDeleteStory: (_) {},
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      useRootNavigator: true,
    );
  }

  // --- Reply ---

  void startReply(MessageData message) {
    replyingToMessage.value = message;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  // --- Read receipts ---

  void markMessagesAsRead() {
    final myId = SessionManager.instance.getUserID();
    final unreadIds = chatList
        .where((m) => m.userId != myId && m.status != 'read')
        .map((m) => m.id)
        .whereType<int>()
        .toList();
    if (unreadIds.isEmpty) return;

    ChatSocketService.instance.emit(ChatEvents.cMarkMessagesRead, {
      'conversation_id': conversationUser.value.conversationId,
      'message_ids': unreadIds,
    });
  }

  // --- Search ---

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchResults.clear();
    }
  }

  void onSearchMessages(String query) async {
    if (query.length < 2) {
      searchResults.clear();
      return;
    }
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;
    final results = await ChatApiService.instance.searchMessages(convId, query);
    searchResults.assignAll(results);
  }

  void jumpToMessage(int messageId) {
    final idx = chatList.indexWhere((m) => m.id == messageId);
    if (idx != -1) {
      isSearching.value = false;
      searchController.clear();
      searchResults.clear();
    }
  }

  // --- Pin ---

  void pinMessage(MessageData message) {
    ChatSocketService.instance.emit(ChatEvents.cPinMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
  }

  void unpinMessage(int messageId) {
    ChatSocketService.instance.emit(ChatEvents.cUnpinMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': messageId,
    });
  }

  // --- Star ---

  void starMessage(MessageData message) {
    ChatSocketService.instance.emit(ChatEvents.cStarMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
  }

  void unstarMessage(MessageData message) {
    ChatSocketService.instance.emit(ChatEvents.cUnstarMessage, {
      'conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
    });
  }

  // --- Forward ---

  void forwardMessage(MessageData message, List<String> targetConversationIds) {
    ChatSocketService.instance.emit(ChatEvents.cForwardMessage, {
      'source_conversation_id': conversationUser.value.conversationId,
      'message_id': message.id,
      'target_conversation_ids': targetConversationIds,
    });
    showSnackBar('Message forwarded');
  }

  // --- Mute ---

  void muteConversation({int? mutedUntil}) {
    ChatSocketService.instance.emit(ChatEvents.cMuteConversation, {
      'conversation_id': conversationUser.value.conversationId,
      if (mutedUntil != null) 'muted_until': mutedUntil,
    });
  }

  void unmuteConversation() {
    ChatSocketService.instance.emit(ChatEvents.cUnmuteConversation, {
      'conversation_id': conversationUser.value.conversationId,
    });
  }

  // --- Archive ---

  void archiveConversation() {
    ChatSocketService.instance.emit(ChatEvents.cArchiveConversation, {
      'conversation_id': conversationUser.value.conversationId,
    });
    Get.back();
  }

  void unarchiveConversation() {
    ChatSocketService.instance.emit(ChatEvents.cUnarchiveConversation, {
      'conversation_id': conversationUser.value.conversationId,
    });
  }

  // --- Group chat methods ---

  void createGroup({
    required String name,
    String? avatar,
    String? description,
    required List<int> memberIds,
  }) {
    ChatSocketService.instance.emit(ChatEvents.cCreateGroup, {
      'name': name,
      'avatar': avatar,
      'description': description,
      'member_ids': memberIds,
    });
  }

  void addGroupMember(int userId) {
    final groupId = conversationUser.value.groupId;
    if (groupId == null) return;
    ChatSocketService.instance.emit(ChatEvents.cAddGroupMember, {
      'group_id': groupId,
      'user_id': userId,
    });
  }

  void removeGroupMember(int userId) {
    final groupId = conversationUser.value.groupId;
    if (groupId == null) return;
    ChatSocketService.instance.emit(ChatEvents.cRemoveGroupMember, {
      'group_id': groupId,
      'user_id': userId,
    });
  }

  void leaveGroup() {
    final groupId = conversationUser.value.groupId;
    if (groupId == null) return;
    ChatSocketService.instance.emit(ChatEvents.cLeaveGroup, {
      'group_id': groupId,
    });
    Get.back();
  }

  void updateGroup({String? name, String? avatar, String? description}) {
    final groupId = conversationUser.value.groupId;
    if (groupId == null) return;
    ChatSocketService.instance.emit(ChatEvents.cUpdateGroup, {
      'group_id': groupId,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (description != null) 'description': description,
    });
  }

  void makeAdmin(int userId, bool isAdmin) {
    final groupId = conversationUser.value.groupId;
    if (groupId == null) return;
    ChatSocketService.instance.emit(ChatEvents.cMakeAdmin, {
      'group_id': groupId,
      'user_id': userId,
      'is_admin': isAdmin,
    });
  }

  Future<Map<String, dynamic>?> exportChat() async {
    return ChatApiService.instance.exportChat(
      conversationUser.value.conversationId ?? '',
    );
  }

  // --- E2E Encryption ---

  final _encryptionService = ChatEncryptionService.instance;

  void toggleEncryption() async {
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;

    if (isEncryptionEnabled.value) {
      // Disable encryption
      ChatSocketService.instance.emit(ChatEvents.cDisableEncryption, {
        'conversation_id': convId,
      });
    } else {
      // Enable encryption — generate a new key and share it
      final keyBase64 = await _encryptionService.generateConversationKey(convId);
      ChatSocketService.instance.emit(ChatEvents.cEnableEncryption, {
        'conversation_id': convId,
        'public_key': keyBase64,
      });
      // Send key to other participants via key exchange
      ChatSocketService.instance.emit(ChatEvents.cKeyExchange, {
        'conversation_id': convId,
        'encrypted_key': keyBase64,
      });
    }
  }

  Future<void> _storeReceivedKey(String keyBase64) async {
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;
    await _encryptionService.storeConversationKey(convId, keyBase64);
  }

  Future<void> _deleteEncryptionKey() async {
    final convId = conversationUser.value.conversationId;
    if (convId == null) return;
    await _encryptionService.deleteConversationKey(convId);
  }

  /// Encrypt text before sending if encryption is enabled.
  Future<String?> _encryptText(String text) async {
    if (!isEncryptionEnabled.value) return null;
    final convId = conversationUser.value.conversationId;
    if (convId == null) return null;
    return _encryptionService.encrypt(convId, text);
  }

  /// Decrypt message text if it's encrypted.
  Future<String?> decryptMessageText(MessageData message) async {
    if (message.isEncrypted != true) return message.textMessage;
    final convId = message.conversationId ?? conversationUser.value.conversationId;
    if (convId == null) return message.textMessage;
    final decrypted =
        await _encryptionService.decrypt(convId, message.textMessage ?? '');
    return decrypted ?? message.textMessage;
  }
}

final playerWaveStyle = PlayerWaveStyle(
    fixedWaveColor: ColorRes.bgGrey,
    spacing: 3,
    waveThickness: 1.5,
    scaleFactor: 50,
    liveWaveGradient: StyleRes.wavesGradient);

class PlayerValue {
  PlayerState state;
  int id;

  PlayerValue({required this.state, required this.id});
}
