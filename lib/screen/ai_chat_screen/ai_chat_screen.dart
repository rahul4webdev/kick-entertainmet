import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/ai_chat_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/ai/ai_chat_message.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:uuid/uuid.dart';

class AiChatController extends BaseController {
  RxList<AiChatMessage> messages = <AiChatMessage>[].obs;
  RxBool isAiTyping = false.obs;
  RxBool isLoadingHistory = false.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  String sessionId = const Uuid().v4();

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await AiChatService.instance.fetchHistory(
        sessionId: sessionId,
      );
      if (response.status == true && response.data != null) {
        messages.assignAll(response.data!);
      }
    } catch (_) {}
    isLoadingHistory.value = false;
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty || isAiTyping.value) return;

    textController.clear();

    // Add user message locally
    final userMsg = AiChatMessage(
      userMessage: text,
      sessionId: sessionId,
      createdAt: DateTime.now().toIso8601String(),
    );
    messages.add(userMsg);
    _scrollToBottom();

    isAiTyping.value = true;

    try {
      final response = await AiChatService.instance.sendMessage(
        message: text,
        sessionId: sessionId,
      );
      if (response.status == true && response.data != null) {
        // Replace the local message with the server response
        messages.removeLast();
        messages.add(response.data!);
      } else {
        // Mark last message as failed
        messages.last = AiChatMessage(
          userMessage: text,
          aiResponse: LKey.aiUnavailable,
          sessionId: sessionId,
        );
        messages.refresh();
      }
    } catch (_) {
      messages.last = AiChatMessage(
        userMessage: text,
        aiResponse: LKey.aiUnavailable,
        sessionId: sessionId,
      );
      messages.refresh();
    }

    isAiTyping.value = false;
    _scrollToBottom();
  }

  void startNewChat() {
    sessionId = const Uuid().v4();
    messages.clear();
  }

  Future<void> clearAllHistory() async {
    try {
      final response = await AiChatService.instance.clearHistory();
      if (response.status == true) {
        messages.clear();
        sessionId = const Uuid().v4();
        showSnackBar(LKey.aiChatCleared);
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiChatController());

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                ),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              LKey.aiAssistant,
              style: TextStyleCustom.unboundedMedium500(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textDarkGrey(context)),
            onSelected: (value) {
              if (value == 'new') {
                controller.startNewChat();
              } else if (value == 'clear') {
                Get.bottomSheet(ConfirmationSheet(
                  title: LKey.clearChat,
                  description: LKey.clearChatDesc,
                  onTap: () => controller.clearAllHistory(),
                ));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    const Icon(Icons.add_comment_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text(LKey.newChat),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: ColorRes.likeRed),
                    const SizedBox(width: 8),
                    Text(LKey.clearChat,
                        style: TextStyle(color: ColorRes.likeRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value &&
                  controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return _EmptyState();
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: controller.messages.length +
                    (controller.isAiTyping.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) {
                    return _TypingIndicator();
                  }
                  final msg = controller.messages[index];
                  return _MessageBubblePair(message: msg);
                },
              );
            }),
          ),
          _ChatInputBar(controller: controller),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 22, cornerSmoothing: 1),
                ),
              ),
              child: const Icon(Icons.auto_awesome, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              LKey.aiChatEmpty,
              style: TextStyleCustom.unboundedMedium500(
                  color: textDarkGrey(context), fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              LKey.aiChatEmptyDesc,
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(label: 'Content ideas'),
                _SuggestionChip(label: 'Write a caption'),
                _SuggestionChip(label: 'Trending hashtags'),
                _SuggestionChip(label: 'Grow my audience'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;

  const _SuggestionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AiChatController>();
    return GestureDetector(
      onTap: () {
        controller.textController.text = label;
        controller.sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 1),
            side: BorderSide(color: bgMediumGrey(context)),
          ),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context), fontSize: 13),
        ),
      ),
    );
  }
}

class _MessageBubblePair extends StatelessWidget {
  final AiChatMessage message;

  const _MessageBubblePair({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // User message
        if (message.userMessage != null) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: ShapeDecoration(
                color: ColorRes.themeAccentSolid,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius.only(
                    topLeft:
                        const SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
                    topRight:
                        const SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
                    bottomLeft:
                        const SmoothRadius(cornerRadius: 16, cornerSmoothing: 1),
                    bottomRight:
                        const SmoothRadius(cornerRadius: 4, cornerSmoothing: 1),
                  ),
                ),
              ),
              child: Text(
                message.userMessage!,
                style: TextStyleCustom.outFitRegular400(
                    color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
        // AI response
        if (message.aiResponse != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: ShapeDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 8, cornerSmoothing: 1),
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: ShapeDecoration(
                      color: bgLightGrey(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius.only(
                          topLeft: const SmoothRadius(
                              cornerRadius: 4, cornerSmoothing: 1),
                          topRight: const SmoothRadius(
                              cornerRadius: 16, cornerSmoothing: 1),
                          bottomLeft: const SmoothRadius(
                              cornerRadius: 16, cornerSmoothing: 1),
                          bottomRight: const SmoothRadius(
                              cornerRadius: 16, cornerSmoothing: 1),
                        ),
                      ),
                    ),
                    child: SelectableText(
                      message.aiResponse!,
                      style: TextStyleCustom.outFitRegular400(
                          color: textDarkGrey(context), fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
              ),
            ),
            child:
                const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: bgLightGrey(context),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.only(
                  topLeft: const SmoothRadius(
                      cornerRadius: 4, cornerSmoothing: 1),
                  topRight: const SmoothRadius(
                      cornerRadius: 16, cornerSmoothing: 1),
                  bottomLeft: const SmoothRadius(
                      cornerRadius: 16, cornerSmoothing: 1),
                  bottomRight: const SmoothRadius(
                      cornerRadius: 16, cornerSmoothing: 1),
                ),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textLightGrey(context),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  LKey.aiThinking,
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final AiChatController controller;

  const _ChatInputBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        border: Border(
          top: BorderSide(color: bgMediumGrey(context), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: bgLightGrey(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 22, cornerSmoothing: 1),
                ),
              ),
              child: TextField(
                controller: controller.textController,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyleCustom.outFitRegular400(
                    color: textDarkGrey(context), fontSize: 14),
                decoration: InputDecoration(
                  hintText: LKey.typeAMessage,
                  hintStyle: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
                onTap:
                    controller.isAiTyping.value ? null : controller.sendMessage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: controller.isAiTyping.value
                        ? Colors.grey
                        : ColorRes.themeAccentSolid,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    ),
                  ),
                  child: const Icon(Icons.send_rounded,
                      size: 20, color: Colors.white),
                ),
              )),
        ],
      ),
    );
  }
}
