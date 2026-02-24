import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_search_text_field.dart';
import 'package:shortzz/common/widget/custom_tab_switcher.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/screen/message_screen/message_screen_controller.dart';
import 'package:shortzz/screen/message_screen/widget/chat_conversation_user_card.dart';
import 'package:shortzz/screen/message_screen/widget/notes_list_view.dart';
import 'package:shortzz/screen/ai_chat_screen/ai_chat_screen.dart';
import 'package:shortzz/screen/broadcast_screen/broadcast_list_screen.dart';
import 'package:shortzz/screen/call_screen/call_history_screen.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MessageScreenController());
    return Column(
      children: [
        Container(
          color: scaffoldBackgroundColor(context),
          child: SafeArea(
            minimum: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 32),
                      Text(LKey.messages.tr,
                          style: TextStyleCustom.unboundedMedium500(
                              fontSize: 15, color: textDarkGrey(context))),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.to(() => const CallHistoryScreen()),
                            child: Icon(Icons.call,
                                size: 22, color: textDarkGrey(context)),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => Get.to(() => const BroadcastListScreen()),
                            child: Icon(Icons.campaign_outlined,
                                size: 24, color: textDarkGrey(context)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CustomTabSwitcher(
                  items: controller.chatCategories,
                  onTap: (index) {
                    controller.onPageChanged(index);
                    controller.pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  },
                  selectedIndex: controller.selectedChatCategory,
                  widget: Obx(() {
                    int length = controller.dashboardController.requestUnReadCount.value;
                    if (length <= 0) {
                      return const SizedBox();
                    }
                    return Container(
                      height: 22,
                      width: 22,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: ColorRes.likeRed),
                      alignment: Alignment.center,
                      child: Text(
                        '$length',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 12, color: whitePure(context)),
                      ),
                    );
                  }),
                  widgetTabIndex: 1,
                  margin: const EdgeInsets.all(10),
                ),
              ],
            ),
          ),
        ),
        const CustomSearchTextField(),
        const NotesListView(),
        Expanded(
          child: Obx(
            () => controller.isLoading.value &&
                    (controller.selectedChatCategory.value == 0
                        ? controller.chatsUsers.isEmpty
                        : controller.requestsUsers.isEmpty)
                ? const LoaderWidget()
                : PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      ChatsListView(),
                      RequestsListView(),
                    ],
                  ),
          ),
        )
      ],
    );
  }
}

class ChatsListView extends StatelessWidget {
  const ChatsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageScreenController controller = Get.find();
    return Obx(() {
      return NoDataView(
        showShow: controller.chatsUsers.isEmpty,
        title: LKey.chatListEmptyTitle.tr,
        description: LKey.chatListEmptyDescription.tr,
        child: ListView.builder(
          itemCount: controller.chatsUsers.length + 1,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _AiAssistantCard();
            }
            ChatThread chatConversation = controller.chatsUsers[index - 1];
            chatConversation.bindChatUser();
            return ChatConversationUserCard(chatConversation: chatConversation);
          },
        ),
      );
    });
  }
}

class RequestsListView extends StatelessWidget {
  const RequestsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final MessageScreenController controller = Get.find();

    return Obx(
      () => NoDataView(
        showShow: controller.requestsUsers.isEmpty,
        title: LKey.chatRequestEmptyTitle.tr,
        description: LKey.chatRequestEmptyDescription.tr,
        child: ListView.builder(
          itemCount: controller.requestsUsers.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            ChatThread chatConversation = controller.requestsUsers[index];
            chatConversation.bindChatUser();
            return ChatConversationUserCard(chatConversation: chatConversation);
          },
        ),
      ),
    );
  }
}

class _AiAssistantCard extends StatelessWidget {
  const _AiAssistantCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => const AiChatScreen()),
      child: Container(
        color: bgLightGrey(context),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 47, cornerSmoothing: 1),
                ),
              ),
              child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LKey.aiAssistant,
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 13, color: textDarkGrey(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    LKey.aiChatEmptyDesc,
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 13, color: textLightGrey(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textLightGrey(context), size: 20),
          ],
        ),
      ),
    );
  }
}
