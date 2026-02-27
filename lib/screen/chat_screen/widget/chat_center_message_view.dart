import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/context_menu_widget.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/load_more_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/screen/chat_screen/chat_screen_controller.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_audio_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_g_i_f_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_gift_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_media_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_post_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_story_reply_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_call_log_message.dart';
import 'package:shortzz/screen/chat_screen/message_type_widget/chat_text_message.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

const List<String> _reactionEmojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

class ChatMessageView extends StatelessWidget {
  final ChatScreenController controller;

  const ChatMessageView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Obx(
      () {
        return LoadMoreWidget(
          loadMore: controller.fetchMoreChatList,
          child: ListView.builder(
            itemCount: controller.chatList.length,
            reverse: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              MessageData message = controller.chatList[index];
              bool isMe = message.userId == SessionManager.instance.getUserID();
              return Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 7, bottom: 7),
                decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 15, cornerSmoothing: 1))),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    ContextMenuWidget(
                      menuProvider: (_) {
                        return Menu(
                          children: [
                            MenuAction(
                                title: 'Reply',
                                callback: () =>
                                    controller.startReply(message)),
                            if (controller.canEditMessage(message))
                              MenuAction(
                                  title: LKey.edit.tr,
                                  callback: () =>
                                      controller.startEditMessage(message)),
                            MenuAction(
                                title: 'Pin',
                                callback: () =>
                                    controller.pinMessage(message)),
                            MenuAction(
                                title: 'Star',
                                callback: () =>
                                    controller.starMessage(message)),
                            MenuAction(
                                title: LKey.deleteForYou.tr,
                                callback: () =>
                                    controller.onDeleteForYou(message)),
                            if (isMe)
                              MenuAction(
                                  title: LKey.unSend.tr,
                                  callback: () => controller.onUnSend(message)),
                          ],
                        );
                      },
                      child: GestureDetector(
                        onDoubleTap: () =>
                            _showReactionPicker(context, message),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Group sender name
                            if (!isMe &&
                                message.senderName != null &&
                                message.senderName!.isNotEmpty &&
                                controller.conversationUser.value.isGroup)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  message.senderName!,
                                  style: TextStyleCustom.outFitMedium500(
                                      fontSize: 12,
                                      color: themeAccentSolid(context)),
                                ),
                              ),
                            // Forwarded label
                            if (message.forwarded == true)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.reply,
                                        size: 14,
                                        color: textLightGrey(context)),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Forwarded',
                                      style: TextStyleCustom.outFitLight300(
                                          fontSize: 11,
                                          color: textLightGrey(context)),
                                    ),
                                  ],
                                ),
                              ),
                            // Quoted reply preview
                            if (message.replyTo != null &&
                                message.replyTo!.messageId != null)
                              _QuotedReplyPreview(
                                  replyTo: message.replyTo!, isMe: isMe),
                            Container(
                              decoration: ShapeDecoration(
                                  color: scaffoldBackgroundColor(context),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                        cornerRadius: 15,
                                        cornerSmoothing: 1),
                                  )),
                              child: switch (message.messageType) {
                                MessageType.image => ChatMediaMessage(
                                    isMe: isMe,
                                    message: message,
                                    controller: controller),
                                MessageType.video => ChatMediaMessage(
                                    isMe: isMe,
                                    message: message,
                                    controller: controller),
                                MessageType.post => ChatPostMessage(
                                    message: message, controller: controller),
                                MessageType.audio => ChatAudioMessage(
                                    message: message, controller: controller),
                                MessageType.text =>
                                  ChatTextMessage(isMe: isMe, message: message),
                                MessageType.gift =>
                                  ChatGiftMessage(message: message, isMe: isMe),
                                MessageType.gif =>
                                  ChatGIFMessage(message: message),
                                MessageType.storyReply =>
                                  ChatStoryReplyMessage(
                                      controller: controller,
                                      message: message,
                                      isMe: isMe),
                                MessageType.document =>
                                  ChatTextMessage(isMe: isMe, message: message),
                                MessageType.callLog =>
                                  ChatCallLogMessage(isMe: isMe, message: message),
                                null => const SizedBox(),
                              },
                            ),
                            if (message.reactions != null &&
                                message.reactions!.isNotEmpty)
                              _MessageReactionBar(
                                  message: message, controller: controller),
                          ],
                        ),
                      ),
                    ),
                    _ChatDateAndStatus(message: message, isMe: isMe),
                  ],
                ),
              );
            },
          ),
        );
      },
    ));
  }

  void _showReactionPicker(BuildContext context, MessageData message) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => _ReactionPickerDialog(
          message: message, controller: controller),
    );
  }
}

class _QuotedReplyPreview extends StatelessWidget {
  final ReplyTo replyTo;
  final bool isMe;

  const _QuotedReplyPreview({required this.replyTo, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: BoxConstraints(maxWidth: Get.width / 1.4),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
          side: BorderSide(
            color: themeAccentSolid(context).withValues(alpha: 0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            replyTo.messageType == 'text' ? 'Reply' : (replyTo.messageType ?? 'Reply'),
            style: TextStyleCustom.outFitMedium500(
                fontSize: 10, color: themeAccentSolid(context)),
          ),
          const SizedBox(height: 2),
          Text(
            replyTo.textPreview ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyleCustom.outFitLight300(
                fontSize: 12, color: textDarkGrey(context)),
          ),
        ],
      ),
    );
  }
}

class _ReactionPickerDialog extends StatelessWidget {
  final MessageData message;
  final ChatScreenController controller;

  const _ReactionPickerDialog(
      {required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ShapeDecoration(
              color: bgLightGrey(context),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                    cornerRadius: 24, cornerSmoothing: 1),
              ),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _reactionEmojis.map((emoji) {
                final myReaction = message.reactions?.firstWhereOrNull(
                    (r) =>
                        r.userId ==
                        SessionManager.instance.getUserID());
                final isSelected = myReaction?.emoji == emoji;
                return GestureDetector(
                  onTap: () {
                    controller.addReaction(message, emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: themeAccentSolid(context)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(emoji, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageReactionBar extends StatelessWidget {
  final MessageData message;
  final ChatScreenController controller;

  const _MessageReactionBar(
      {required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    final reactionCounts = <String, int>{};
    for (var r in message.reactions!) {
      final emoji = r.emoji ?? '';
      reactionCounts[emoji] = (reactionCounts[emoji] ?? 0) + 1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Wrap(
        spacing: 4,
        children: reactionCounts.entries.map((entry) {
          final myId = SessionManager.instance.getUserID();
          final isMyReaction = message.reactions!
              .any((r) => r.emoji == entry.key && r.userId == myId);
          return GestureDetector(
            onTap: () {
              if (isMyReaction) {
                controller.removeReaction(message);
              } else {
                controller.addReaction(message, entry.key);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: ShapeDecoration(
                color: isMyReaction
                    ? themeAccentSolid(context).withValues(alpha: 0.15)
                    : bgLightGrey(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 10, cornerSmoothing: 1),
                  side: isMyReaction
                      ? BorderSide(
                          color: themeAccentSolid(context)
                              .withValues(alpha: 0.4),
                          width: 1)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14)),
                  if (entry.value > 1) ...[
                    const SizedBox(width: 2),
                    Text('${entry.value}',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 11,
                            color: textDarkGrey(context))),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ChatDateAndStatus extends StatelessWidget {
  final MessageData message;
  final bool isMe;

  const _ChatDateAndStatus({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5, top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.isEncrypted == true)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(Icons.lock, size: 10, color: textLightGrey(context)),
            ),
          Text(
            '${message.id ?? 0}'.chatTimeFormat,
            style: TextStyleCustom.outFitLight300(
                fontSize: 12, color: textLightGrey(context)),
          ),
          if (isMe) ...[
            const SizedBox(width: 4),
            _MessageStatusIcon(status: message.status),
          ],
        ],
      ),
    );
  }
}

class _MessageStatusIcon extends StatelessWidget {
  final String? status;

  const _MessageStatusIcon({this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'read':
        return Icon(Icons.done_all, size: 14, color: themeAccentSolid(context));
      case 'delivered':
        return Icon(Icons.done_all, size: 14, color: textLightGrey(context));
      case 'sent':
      default:
        return Icon(Icons.done, size: 14, color: textLightGrey(context));
    }
  }
}

final List<BoxShadow> messageBubbleShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.10),
    offset: const Offset(0, 4),
    blurRadius: 10,
  ),
];
