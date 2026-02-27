import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_popup_menu_button.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/favorite_users_screen/favorite_users_screen.dart';
import 'package:shortzz/screen/login_activity_screen/login_activity_screen.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/screen/qr_code_screen/qr_code_screen.dart';
import 'package:shortzz/screen/saved_post_screen/saved_post_screen.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_highlights_row.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_page_view.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_tab_bar_view.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_user_header.dart';
import 'package:shortzz/screen/settings_screen/settings_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  final bool isTopBarVisible;
  final bool isDashBoard;
  final Function(User? user)? onUserUpdate;

  const ProfileScreen(
      {super.key,
      this.user,
      this.isTopBarVisible = true,
      this.isDashBoard = false,
      this.onUserUpdate});

  @override
  Widget build(BuildContext context) {
    ProfileScreenController controller = Get.put(
        ProfileScreenController(user.obs, onUserUpdate),
        tag: isDashBoard
            ? ProfileScreenController.tag
            : "${DateTime.now().millisecondsSinceEpoch}");

    return Scaffold(
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          controller.adsController
              .showInterstitialAdIfAvailable(isPopScope: true);
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Obx(() {
                final isMe = controller.userData.value?.id ==
                    SessionManager.instance.getUserID();
                return _ProfileTopBar(
                  user: controller.userData.value,
                  isTopBarVisible: isTopBarVisible,
                  controller: controller,
                  isMe: isMe,
                );
              }),
              Expanded(
                child: Stack(
                  children: [
                    Obx(() {
                      final isMe = controller.userData.value?.id ==
                          SessionManager.instance.getUserID();
                      final hasExclusive = controller.hasExclusiveTab;
                      int tabCount = 4; // reels, posts, playlists, Q&A
                      if (hasExclusive) tabCount++;
                      if (isMe) tabCount++;
                      return DefaultTabController(
                      length: tabCount,
                      child: MyRefreshIndicator(
                        depth: 2,
                        onRefresh: controller.onRefresh,
                        child: NestedScrollView(
                          headerSliverBuilder: (context, _) {
                            return [
                              SliverList(
                                delegate: SliverChildListDelegate([
                                  ProfileUserHeader(controller: controller)
                                ]),
                              ),
                            ];
                          },
                          body: Column(
                            children: [
                              ProfileHighlightsRow(controller: controller),
                              ProfileTabs(controller: controller),
                              ProfilePageView(controller: controller)
                            ],
                          ),
                        ),
                      ),
                    );
                    }),
                    Obx(() {
                      User? user = controller.userData.value;
                      if (user?.isFreez != 1) {
                        return const SizedBox();
                      }
                      return Container(
                        color: scaffoldBackgroundColor(context)
                            .withValues(alpha: 0.4),
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_person_rounded,
                                    size: 80, color: textLightGrey(context)),
                                const SizedBox(height: 20),
                                Text(
                                  LKey.profileUnavailable.tr,
                                  style: TextStyleCustom.unboundedSemiBold600(
                                      color: textLightGrey(context),
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30.0),
                                  child: Text(
                                    LKey.profileTemporarilyFrozen.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyleCustom.outFitMedium500(
                                        color: textLightGrey(context),
                                        fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Obx(() {
                                  bool isModerator = SessionManager
                                          .instance.isModerator.value ==
                                      1;
                                  if (!isModerator) {
                                    return const SizedBox();
                                  }
                                  return TextButtonCustom(
                                    onTap: () =>
                                        controller.freezeUnfreezeUser(true),
                                    title: LKey.unFreeze.tr,
                                    titleColor: whitePure(context),
                                    backgroundColor: textDarkGrey(context),
                                  );
                                })
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  final User? user;
  final bool isTopBarVisible;
  final ProfileScreenController controller;
  final bool isMe;

  const _ProfileTopBar({
    this.user,
    required this.isTopBarVisible,
    required this.controller,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTopBarVisible && !isMe) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          // Left: Settings gear (own) or Back button (other)
          if (isMe)
            IconButton(
              onPressed: () => Get.to(() => SettingsScreen(onUpdateUser: controller.onUpdateUser)),
              icon: Icon(Icons.settings_outlined, size: 24, color: blackPure(context)),
            )
          else if (isTopBarVisible)
            CustomBackButton(
              onTap: () => controller.adsController.showInterstitialAdIfAvailable(),
              padding: const EdgeInsets.all(10),
            )
          else
            const SizedBox(width: 44),

          // Center: Username with dropdown chevron
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      user?.username ?? '',
                      style: TextStyleCustom.unboundedSemiBold600(
                          color: blackPure(context), fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (isMe)
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 22, color: blackPure(context)),
                ],
              ),
            ),
          ),

          // Right: Menu (own) or More options (other)
          if (isMe)
            IconButton(
              onPressed: () => _showHamburgerMenu(context),
              icon: Icon(Icons.menu_rounded, size: 24, color: blackPure(context)),
            )
          else if (isTopBarVisible)
            Obx(
              () => CustomPopupMenuButton(
                items: [
                  MenuItem(LKey.shareProfile.tr, () {
                    controller.shareProfile();
                  }),
                  MenuItem(
                    user?.isFavorite == true
                        ? LKey.removeFromFavorites.tr
                        : LKey.addToFavorites.tr,
                    () => controller.toggleFavorite(user?.isFavorite ?? false),
                  ),
                  MenuItem(
                    user?.isMuted == true
                        ? LKey.unmuteAccount.tr
                        : LKey.muteAccount.tr,
                    () => controller.toggleMuteUnmute(user?.isMuted ?? false),
                  ),
                  MenuItem(
                    user?.isRestricted == true
                        ? LKey.unrestrict.tr
                        : LKey.restrict.tr,
                    () => controller.toggleRestrictUnrestrict(user?.isRestricted ?? false),
                  ),
                  MenuItem(
                    user?.isBlock == true ? LKey.unBlock.tr : LKey.block.tr,
                    () => controller.toggleBlockUnblock(user?.isBlock ?? false),
                  ),
                  MenuItem(LKey.report.tr, () => controller.reportUser(user)),
                  if (SessionManager.instance.isModerator.value == 1)
                    MenuItem(
                      user?.isFreez == 1 ? LKey.unFreeze.tr : LKey.freeze.tr,
                      () => controller.freezeUnfreezeUser(user?.isFreez == 1),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.more_horiz_rounded, size: 24, color: blackPure(context)),
                ),
              ),
            )
          else
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  void _showHamburgerMenu(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: textLightGrey(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _menuTile(
                context,
                icon: Icons.bookmark_outline_rounded,
                title: LKey.savedPosts.tr,
                onTap: () {
                  Get.back();
                  Get.to(() => const SavedPostScreen());
                },
              ),
              _menuTile(
                context,
                icon: Icons.qr_code_rounded,
                title: LKey.myQrCode.tr,
                onTap: () {
                  Get.back();
                  Get.to(() => const QrCodeScreen());
                },
              ),
              _menuTile(
                context,
                icon: Icons.star_outline_rounded,
                title: LKey.favorites.tr,
                onTap: () {
                  Get.back();
                  Get.to(() => const FavoriteUsersScreen());
                },
              ),
              _menuTile(
                context,
                icon: Icons.devices_outlined,
                title: LKey.loginActivity.tr,
                onTap: () {
                  Get.back();
                  Get.to(() => const LoginActivityScreen());
                },
              ),
              _menuTile(
                context,
                icon: Icons.share_outlined,
                title: LKey.shareProfile.tr,
                onTap: () {
                  Get.back();
                  controller.shareProfile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 24, color: blackPure(context)),
      title: Text(title,
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: blackPure(context))),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
