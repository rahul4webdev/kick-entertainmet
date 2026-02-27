import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/screen/call_screen/call_helper.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChatCallLogMessage extends StatelessWidget {
  final bool isMe;
  final MessageData message;

  const ChatCallLogMessage(
      {super.key, required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    final callType = message.callType ?? 'voice';
    final callStatus = message.callStatus ?? 'completed';
    final isVideo = callType == 'video';
    final isMissed = callStatus == 'missed' || callStatus == 'rejected';

    final IconData callIcon = isVideo ? Icons.videocam : Icons.call;
    final Color iconColor =
        isMissed ? Colors.red : themeAccentSolid(context);

    String displayText;
    if (isMissed) {
      displayText = isMe
          ? 'No answer'
          : 'Missed ${isVideo ? 'video' : 'voice'} call';
    } else {
      displayText =
          '${isVideo ? 'Video' : 'Voice'} call  ${message.callDuration ?? ''}';
    }

    return GestureDetector(
      onTap: () {
        // Tapping a call log lets you call back
        if (!isMe && message.userId != null) {
          final chatUser = message.chatUser;
          CallHelper.startCall(
            userId: message.userId!,
            fullname: chatUser?.fullname ?? '',
            username: chatUser?.username,
            profilePhoto: chatUser?.profile,
            callType: isVideo ? 2 : 1,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width / 1.5),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMissed
                ? Colors.red.withValues(alpha: 0.2)
                : bgGrey(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(callIcon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayText,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 13,
                      color: isMissed ? Colors.red : textDarkGrey(context),
                    ),
                  ),
                  if (!isMe && isMissed)
                    Text(
                      'Tap to call back',
                      style: TextStyleCustom.outFitLight300(
                        fontSize: 11,
                        color: textLightGrey(context),
                      ),
                    ),
                ],
              ),
            ),
            if (isMe)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isMissed ? Icons.call_missed_outgoing : Icons.call_made,
                  size: 16,
                  color: isMissed ? Colors.red : textLightGrey(context),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  isMissed ? Icons.call_missed : Icons.call_received,
                  size: 16,
                  color: isMissed ? Colors.red : textLightGrey(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
