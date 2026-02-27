import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_drop_down.dart';
import 'package:shortzz/common/widget/custom_toggle.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/blocked_user_screen/blocked_user_screen.dart';
import 'package:shortzz/screen/muted_users_screen/muted_users_screen.dart';
import 'package:shortzz/screen/restricted_users_screen/restricted_users_screen.dart';
import 'package:shortzz/screen/favorite_users_screen/favorite_users_screen.dart';
import 'package:shortzz/screen/friends_map_screen/friends_map_screen.dart';
import 'package:shortzz/screen/hidden_words_screen/hidden_words_screen.dart';
import 'package:shortzz/screen/quiet_mode_screen/quiet_mode_screen.dart';
import 'package:shortzz/screen/screen_time_screen/screen_time_screen.dart';
import 'package:shortzz/screen/coin_wallet_screen/coin_wallet_screen.dart';
import 'package:shortzz/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:shortzz/screen/qr_code_screen/qr_code_screen.dart';
import 'package:shortzz/screen/saved_post_screen/saved_post_screen.dart';
import 'package:shortzz/screen/select_language_screen/select_language_screen.dart';
import 'package:shortzz/screen/business_account_screen/business_account_screen.dart';
import 'package:shortzz/screen/follow_request_screen/follow_request_screen.dart';
import 'package:shortzz/screen/instagram_import_screen/instagram_import_screen.dart';
import 'package:shortzz/screen/moderator_panel_screen/moderator_panel_screen.dart';
import 'package:shortzz/screen/trending_hashtags_screen/trending_hashtags_screen.dart';
import 'package:shortzz/screen/interest_selection_screen/interest_selection_screen.dart';
import 'package:shortzz/screen/feed_preferences_screen/feed_preferences_screen.dart';
import 'package:shortzz/screen/sensitive_content_screen/sensitive_content_screen.dart';
import 'package:shortzz/screen/close_friends_screen/close_friends_screen.dart';
import 'package:shortzz/screen/keyword_filters_screen/keyword_filters_screen.dart';
import 'package:shortzz/screen/settings_screen/settings_screen_controller.dart';
import 'package:shortzz/screen/settings_screen/widget/notifications_page.dart';
import 'package:shortzz/screen/settings_screen/widget/setting_icon_text_with_arrow.dart';
import 'package:shortzz/screen/subscription_screen/subscription_screen.dart';
import 'package:shortzz/screen/subscription_screen/my_subscriptions_screen.dart';
import 'package:shortzz/screen/parental_control_screen/parental_control_screen.dart';
import 'package:shortzz/screen/wellbeing_screen/wellbeing_screen.dart';
import 'package:shortzz/screen/term_and_privacy_screen/term_and_privacy_screen.dart';
import 'package:shortzz/screen/two_fa_screen/two_fa_setup_screen.dart';
import 'package:shortzz/screen/two_fa_screen/two_fa_disable_sheet.dart';
import 'package:shortzz/screen/ai_content_ideas_screen/ai_content_ideas_screen.dart';
import 'package:shortzz/screen/ai_video_screen/ai_video_screen.dart';
import 'package:shortzz/screen/account_switcher_sheet/account_switcher_sheet.dart';
import 'package:shortzz/screen/professional_dashboard_screen/professional_dashboard_screen.dart';
import 'package:shortzz/screen/login_activity_screen/login_activity_screen.dart';
import 'package:shortzz/screen/data_download_screen/data_download_screen.dart';
import 'package:shortzz/screen/grievance_screen/grievance_screen.dart';
import 'package:shortzz/screen/appeal_screen/appeal_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SettingsScreen extends StatelessWidget {
  final Function(User? user)? onUpdateUser;

  const SettingsScreen({super.key, this.onUpdateUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.settings.tr),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subscription Card (Become Plus)
                  SubscriptionCard(controller: controller, onUpdateUser: onUpdateUser),

                  // --- PROFESSIONAL TOOLS (right after Plus) ---
                  Obx(() {
                    int accountType = controller.myUser.value?.accountType ?? 0;
                    if (accountType > 0) {
                      return SettingSection(
                        children: [
                          SettingIconTextWithArrow(
                            iconData: Icons.dashboard_customize_outlined,
                            title: LKey.professionalDashboard,
                            iconBgColor: Colors.deepPurple.withValues(alpha: 0.08),
                            iconColor: Colors.deepPurple,
                            onTap: () => Get.to(() => const ProfessionalDashboardScreen()),
                          ),
                        ],
                      );
                    }
                    return SettingSection(
                      children: [
                        SettingIconTextWithArrow(
                          iconData: Icons.storefront_outlined,
                          title: LKey.switchToBusinessAccount,
                          onTap: () => Get.to(() => const BusinessAccountScreen()),
                        ),
                      ],
                    );
                  }),

                  // --- PERSONAL (accordion) ---
                  AccordionSettingSection(
                    title: LKey.personal,
                    icon: Icons.person_outline_rounded,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.person_outline_rounded,
                        title: LKey.editProfile,
                        onTap: () => Get.to(() => EditProfileScreen(onUpdateUser: onUpdateUser)),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.bookmark_outline_rounded,
                        title: LKey.savedPosts,
                        onTap: () => Get.to(() => const SavedPostScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.language_rounded,
                        title: LKey.languages,
                        onTap: () => Get.to(() => const SelectLanguageScreen(languageNavigationType: LanguageNavigationType.fromSetting)),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.qr_code_rounded,
                        title: LKey.myQrCode,
                        onTap: () => Get.to(() => const QrCodeScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.account_balance_wallet_outlined,
                        title: LKey.coinWallet,
                        onTap: () => Get.to(() => const CoinWalletScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.subscriptions_outlined,
                        title: LKey.mySubscriptions,
                        onTap: () => Get.to(() => const MySubscriptionsScreen()),
                      ),
                    ],
                  ),

                  // --- PEOPLE (accordion) ---
                  AccordionSettingSection(
                    title: LKey.peopleSectionTitle,
                    icon: Icons.people_outline_rounded,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.block_rounded,
                        title: LKey.blockedUsers,
                        iconBgColor: Colors.red.withValues(alpha: 0.08),
                        iconColor: Colors.red.shade400,
                        onTap: () => Get.to(() => const BlockedUserScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.volume_off_outlined,
                        title: LKey.mutedAccounts,
                        onTap: () => Get.to(() => const MutedUsersScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.shield_outlined,
                        title: LKey.restrictedAccounts,
                        onTap: () => Get.to(() => const RestrictedUsersScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.star_outline_rounded,
                        title: LKey.favorites,
                        iconBgColor: Colors.amber.withValues(alpha: 0.1),
                        iconColor: Colors.amber.shade700,
                        onTap: () => Get.to(() => const FavoriteUsersScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.favorite_outline_rounded,
                        title: LKey.closeFriends,
                        iconBgColor: Colors.green.withValues(alpha: 0.08),
                        iconColor: Colors.green.shade600,
                        onTap: () => Get.to(() => const CloseFriendsScreen()),
                      ),
                      Obx(() {
                        if (controller.myUser.value?.isPrivate == true) {
                          return SettingIconTextWithArrow(
                            iconData: Icons.person_add_outlined,
                            title: LKey.followRequests,
                            onTap: () => Get.to(() => const FollowRequestScreen()),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      SettingIconTextWithArrow(
                        iconData: Icons.family_restroom_outlined,
                        title: LKey.familyPairing,
                        onTap: () => Get.to(() => const ParentalControlScreen()),
                      ),
                    ],
                  ),

                  // --- CONTENT & FEED (accordion) ---
                  AccordionSettingSection(
                    title: LKey.contentAndFeed,
                    icon: Icons.tune_rounded,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.interests_outlined,
                        title: LKey.myInterests,
                        onTap: () => Get.to(() => const InterestSelectionScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.tune_rounded,
                        title: LKey.feedPreferences,
                        onTap: () => Get.to(() => const FeedPreferencesScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.visibility_outlined,
                        title: LKey.sensitiveContent,
                        onTap: () => Get.to(() => const SensitiveContentScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.text_fields_rounded,
                        title: LKey.hiddenWords,
                        onTap: () => Get.to(() => const HiddenWordsScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.filter_list_rounded,
                        title: LKey.keywordFilters,
                        onTap: () => Get.to(() => const KeywordFiltersScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.refresh_rounded,
                        title: LKey.resetFeed,
                        onTap: controller.onResetFeed,
                      ),
                    ],
                  ),

                  // --- DIGITAL WELLBEING (accordion) ---
                  AccordionSettingSection(
                    title: LKey.digitalWellbeing,
                    icon: Icons.spa_outlined,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.hourglass_empty_rounded,
                        title: LKey.screenTime,
                        iconBgColor: Colors.blue.withValues(alpha: 0.08),
                        iconColor: Colors.blue.shade600,
                        onTap: () => Get.to(() => const ScreenTimeScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.do_not_disturb_on_outlined,
                        title: LKey.quietMode,
                        onTap: () => Get.to(() => const QuietModeScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.spa_outlined,
                        title: LKey.wellbeing,
                        iconBgColor: Colors.teal.withValues(alpha: 0.08),
                        iconColor: Colors.teal,
                        onTap: () => Get.to(() => const WellbeingScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.map_outlined,
                        title: LKey.friendsMap,
                        onTap: () => Get.to(() => const FriendsMapScreen()),
                      ),
                    ],
                  ),

                  // --- AI & DISCOVERY (accordion) ---
                  AccordionSettingSection(
                    title: LKey.aiAndDiscovery,
                    icon: Icons.auto_awesome_outlined,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.trending_up_rounded,
                        title: LKey.trending,
                        iconBgColor: Colors.orange.withValues(alpha: 0.08),
                        iconColor: Colors.orange.shade700,
                        onTap: () => Get.to(() => const TrendingHashtagsScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.lightbulb_outline_rounded,
                        title: LKey.contentIdeas,
                        iconBgColor: Colors.amber.withValues(alpha: 0.08),
                        iconColor: Colors.amber.shade700,
                        onTap: () => Get.to(() => const AiContentIdeasScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.auto_awesome_outlined,
                        title: LKey.aiVideoGenerator,
                        iconBgColor: Colors.indigo.withValues(alpha: 0.08),
                        iconColor: Colors.indigo,
                        onTap: () => Get.to(() => const AiVideoScreen()),
                      ),
                      Obx(() {
                        if (controller.myUser.value?.isModerator == 1) {
                          return SettingIconTextWithArrow(
                            iconData: Icons.admin_panel_settings_outlined,
                            title: LKey.moderatorPanel,
                            iconBgColor: Colors.red.withValues(alpha: 0.08),
                            iconColor: Colors.red.shade600,
                            onTap: () => Get.to(() => const ModeratorPanelScreen()),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Obx(() {
                        final settings = controller.settings.value;
                        if (settings?.instagramImportEnabled != true) return const SizedBox.shrink();
                        return SettingIconTextWithArrow(
                          iconData: Icons.cloud_download_outlined,
                          title: LKey.importFromInstagram,
                          onTap: () => Get.to(() => const InstagramImportScreen()),
                        );
                      }),
                    ],
                  ),

                  // --- PRIVACY & SECURITY (accordion) ---
                  AccordionSettingSection(
                    title: LKey.privacy,
                    icon: Icons.lock_outline_rounded,
                    children: [
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.visibility_outlined,
                          title: LKey.whoCanSeePosts,
                          widget: CustomDropDownBtn<WhoCanSeePost>(
                            items: WhoCanSeePost.values,
                            onChanged: controller.isUpdateApiCalled.value ? null : controller.onChangedWhoCanSeePost,
                            selectedValue: controller.selectedWhoCanSeePost.value,
                            style: TextStyleCustom.outFitRegular400(fontSize: 14, color: textLightGrey(context)),
                            getTitle: (value) => value.title,
                          ),
                        ),
                      ),
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.people_outline_rounded,
                          title: LKey.showMyFollowings,
                          widget: CustomToggle(
                            isOn: (controller.myUser.value?.showMyFollowing == 1).obs,
                            onChanged: (value) => controller.onChangedToggle(value, SettingToggle.showMyFollowings),
                          ),
                        ),
                      ),
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.chat_bubble_outline_rounded,
                          title: LKey.showChatBtn,
                          widget: CustomToggle(
                            isOn: (controller.myUser.value?.receiveMessage == 1).obs,
                            onChanged: (value) async => controller.onChangedToggle(value, SettingToggle.receiveMessage),
                          ),
                        ),
                      ),
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.lock_outline_rounded,
                          title: LKey.privateAccount,
                          widget: CustomToggle(
                            isOn: (controller.myUser.value?.isPrivate == true).obs,
                            onChanged: (value) => controller.onChangedToggle(value, SettingToggle.privateAccount),
                          ),
                        ),
                      ),
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.comment_outlined,
                          title: LKey.commentApprovalMode,
                          widget: CustomToggle(
                            isOn: (controller.myUser.value?.commentApprovalEnabled == true).obs,
                            onChanged: (value) => controller.onChangedToggle(value, SettingToggle.commentApproval),
                          ),
                        ),
                      ),
                      Obx(
                        () => SettingIconTextWithArrow(
                          iconData: Icons.favorite_border_rounded,
                          title: LKey.hideOthersLikeCount,
                          widget: CustomToggle(
                            isOn: (controller.myUser.value?.hideOthersLikeCount == true).obs,
                            onChanged: (value) => controller.onChangedToggle(value, SettingToggle.hideOthersLikeCount),
                          ),
                        ),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.notifications_outlined,
                        title: LKey.notifications,
                        onTap: () => Get.to(() => const NotificationsPage()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.security_rounded,
                        title: LKey.twoFactorAuth,
                        onTap: () {
                          final user = controller.myUser.value;
                          if (user?.twoFaEnabled == true) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => TwoFaDisableSheet(
                                onDisabled: () => controller.myUser.update((val) => val?.twoFaEnabled = false),
                              ),
                            );
                          } else {
                            Get.to(() => const TwoFaSetupScreen())?.then((result) {
                              if (result == true) controller.myUser.update((val) => val?.twoFaEnabled = true);
                            });
                          }
                        },
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.history_rounded,
                        title: LKey.loginActivity,
                        onTap: () => Get.to(() => const LoginActivityScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.download_rounded,
                        title: LKey.downloadMyData,
                        onTap: () => Get.to(() => const DataDownloadScreen()),
                      ),
                    ],
                  ),

                  // --- GENERAL (accordion) ---
                  AccordionSettingSection(
                    title: LKey.general,
                    icon: Icons.settings_outlined,
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.description_outlined,
                        title: LKey.termsOfUse,
                        onTap: () => Get.to(() => const TermAndPrivacyScreen(type: TermAndPrivacyType.termAndCondition)),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.policy_outlined,
                        title: LKey.privacyPolicy,
                        onTap: () => Get.to(() => const TermAndPrivacyScreen(type: TermAndPrivacyType.privacyPolicy)),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.gavel_rounded,
                        title: LKey.grievanceRedressal,
                        onTap: () => Get.to(() => const GrievanceScreen()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.campaign_outlined,
                        title: LKey.appealDecision,
                        onTap: () => Get.to(() => const AppealScreen()),
                      ),
                    ],
                  ),

                  // --- ACCOUNT ACTIONS (not accordion) ---
                  SettingSection(
                    children: [
                      SettingIconTextWithArrow(
                        iconData: Icons.swap_horiz_rounded,
                        title: LKey.switchAccount,
                        onTap: () => Get.bottomSheet(const AccountSwitcherSheet()),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.logout_rounded,
                        title: LKey.logOut,
                        iconBgColor: Colors.orange.withValues(alpha: 0.08),
                        iconColor: Colors.orange.shade700,
                        onTap: controller.onLogout,
                        widget: const SizedBox(),
                      ),
                      SettingIconTextWithArrow(
                        iconData: Icons.delete_outline_rounded,
                        title: LKey.deleteAccount,
                        iconBgColor: Colors.red.withValues(alpha: 0.08),
                        iconColor: Colors.red,
                        onTap: controller.onDeleteAccount,
                        widget: const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatefulWidget {
  final SettingsScreenController controller;
  final Function(User? user)? onUpdateUser;

  const SubscriptionCard({super.key, required this.controller, this.onUpdateUser});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isVerify = widget.controller.myUser.value?.isVerify == 1;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () {
            if (!isVerify) {
              Get.to<bool>(() => SubscriptionScreen(onUpdateUser: widget.onUpdateUser))?.then((value) {
                if (value == true) widget.controller.myUser.update((val) => val?.isVerify = 1);
              });
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 0.8),
              ),
              gradient: StyleRes.themeGradient,
            ),
            child: Row(
              children: [
                Image.asset(AssetRes.icPro, width: 24, height: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: isVerify ? LKey.youAre.tr : LKey.become.tr,
                      style: TextStyleCustom.outFitRegular400(color: whitePure(context), fontSize: 15),
                      children: [
                        TextSpan(
                          text: ' ${LKey.plus.tr} ',
                          style: TextStyleCustom.outFitExtraBold800(color: whitePure(context), fontSize: 15),
                        ),
                        TextSpan(
                          text: isVerify ? LKey.member.tr : '',
                          style: TextStyleCustom.outFitRegular400(color: whitePure(context), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isVerify)
                  Icon(Icons.chevron_right_rounded, size: 22, color: whitePure(context)),
              ],
            ),
          ),
        ),
      );
    });
  }
}
