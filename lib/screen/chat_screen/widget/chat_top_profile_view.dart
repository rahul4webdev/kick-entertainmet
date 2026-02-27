import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/custom_popup_menu_button.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/livestream/app_user.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/call_screen/call_helper.dart';
import 'package:shortzz/screen/chat_screen/chat_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChatTopProfileView extends StatelessWidget {
  final ChatScreenController controller;

  const ChatTopProfileView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgLightGrey(context),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          ChatThread chatThread = controller.conversationUser.value;
          chatThread.bindChatUser();
          AppUser? chatUser = chatThread.chatUser;
          bool iBlocked = chatThread.iBlocked ?? false;
          return Row(
            spacing: 10,
            children: [
              const CustomBackButton(
                image: AssetRes.icBackArrow_1,
                height: 25,
                width: 25,
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    User user = User(
                      id: chatUser?.userId,
                      fullname: chatUser?.fullname,
                      username: chatUser?.username,
                      profilePhoto: chatUser?.profile,
                      isVerify: chatUser?.isVerify,
                    );
                    NavigationService.shared.openProfileScreen(
                      user,
                      onUserUpdate: (user) {
                        if (controller.otherUser?.id == user?.id) {
                          controller.otherUser = user;
                        }
                      },
                    );
                  },
                  child: Row(
                    spacing: 10,
                    children: [
                      CustomImage(
                          size: const Size(48, 48),
                          image: chatUser?.profile?.addBaseURL(),
                          fullName: chatUser?.fullname),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: FullNameWithBlueTick(
                                      username: chatUser?.username ?? '',
                                      fontSize: 13,
                                      iconSize: 18,
                                      isVerify: chatUser?.isVerify),
                                ),
                                if (controller.isEncryptionEnabled.value)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(Icons.lock,
                                        size: 14, color: themeAccentSolid(context)),
                                  ),
                              ],
                            ),
                            Text(chatUser?.fullname ?? '',
                                style: TextStyleCustom.outFitLight300(
                                    color: textLightGrey(context),
                                    fontSize: 15))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => CallHelper.startCall(
                  userId: chatUser?.userId ?? chatThread.userId ?? 0,
                  fullname: chatUser?.fullname ?? '',
                  username: chatUser?.username,
                  profilePhoto: chatUser?.profile,
                  callType: 1,
                ),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                      color: bgMediumGrey(context), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(Icons.call, size: 18, color: textDarkGrey(context)),
                ),
              ),
              GestureDetector(
                onTap: () => CallHelper.startCall(
                  userId: chatUser?.userId ?? chatThread.userId ?? 0,
                  fullname: chatUser?.fullname ?? '',
                  username: chatUser?.username,
                  profilePhoto: chatUser?.profile,
                  callType: 2,
                ),
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                      color: bgMediumGrey(context), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Icon(Icons.videocam, size: 18, color: textDarkGrey(context)),
                ),
              ),
              CustomPopupMenuButton(
                  items: [
                    MenuItem(
                      controller.isEncryptionEnabled.value
                          ? 'Disable Encryption'
                          : 'Enable Encryption',
                      () {
                        controller.toggleEncryption();
                      },
                    ),
                    MenuItem(
                      controller.isVanishMode.value
                          ? 'Turn Off Vanish Mode'
                          : 'Vanish Mode',
                      () {
                        controller.toggleVanishMode();
                      },
                    ),
                    MenuItem(
                      iBlocked ? LKey.unBlock.tr : LKey.block.tr,
                      () {
                        controller.toggleBlockUnblock(chatThread);
                      },
                    ),
                    MenuItem(
                      LKey.report.tr,
                      () {
                        controller.onReportUser(chatThread);
                      },
                    ),
                  ],
                  child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                          color: bgMediumGrey(context), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child:
                          Image.asset(AssetRes.icMore, width: 25, height: 25)))
            ],
          );
        }),
      ),
    );
  }
}
