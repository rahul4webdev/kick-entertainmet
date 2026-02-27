import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/chat_screen/chat_screen_controller.dart';
import 'package:shortzz/screen/chat_screen/widget/chat_bottom_action_view.dart';
import 'package:shortzz/screen/chat_screen/widget/chat_center_message_view.dart';
import 'package:shortzz/screen/chat_screen/widget/chat_top_profile_view.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChatScreen extends StatefulWidget {
  final ChatThread conversationUser;
  final User? user;

  const ChatScreen({super.key, required this.conversationUser, this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatScreenController controller;

  @override
  void initState() {
    super.initState();
    final tag = '${widget.conversationUser.conversationId}';
    // Always delete any cached controller so we get a fresh one with the
    // correct chatType (request vs approved). Without this, GetX may return
    // a stale controller from a previous visit where chatType was 'approved',
    // causing the request accept/reject/block buttons to not appear.
    if (Get.isRegistered<ChatScreenController>(tag: tag)) {
      Get.delete<ChatScreenController>(tag: tag, force: true);
    }
    controller = Get.put(ChatScreenController(widget.conversationUser.obs), tag: tag);
  }

  @override
  void dispose() {
    final tag = '${widget.conversationUser.conversationId}';
    Get.delete<ChatScreenController>(tag: tag, force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vanish = controller.isVanishMode.value;
      return Scaffold(
        backgroundColor: vanish
            ? const Color(0xFF1A1A2E)
            : scaffoldBackgroundColor(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatTopProfileView(controller: controller),
            if (vanish)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                color: Colors.deepPurple.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_off,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Vanish Mode On',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: controller.toggleVanishMode,
                      child: Text(
                        'Turn Off',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ChatMessageView(controller: controller),
            ChatBottomActionView(controller: controller),
          ],
        ),
      );
    });
  }
}
