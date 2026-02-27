import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/gradient_border.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/creator_dashboard_screen/creator_dashboard_screen.dart';
import 'package:shortzz/screen/edit_profile_screen/edit_profile_screen.dart';
import 'package:shortzz/screen/follow_following_screen/follow_following_screen.dart';
import 'package:shortzz/screen/level_screen/level_screen.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/widget/profile_preview_interactive_screen.dart';
import 'package:shortzz/screen/profile_screen/widget/user_link_sheet.dart';
import 'package:shortzz/screen/subscription_screen/creator_subscribe_sheet.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileUserHeader extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileUserHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        User? user = controller.userData.value;
        bool isUserNotFound = controller.isUserNotFound.value;
        bool isMe = user?.id == SessionManager.instance.getUserID();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Centered stats row: Followers | Profile Pic | Following
              _CenteredStatsRow(
                user: user,
                controller: controller,
                userNotFound: isUserNotFound,
                totalPosts: controller.reels.length + controller.posts.length,
              ),
              const SizedBox(height: 14),
              // Name + Category row with pipe separator
              if (!isUserNotFound)
                _NameCategoryRow(
                  user: user,
                  totalPosts: controller.reels.length + controller.posts.length,
                ),
              const SizedBox(height: 4),
              // Bio
              if (!isUserNotFound) UserBioView(user: user),
              // Links
              if (!isUserNotFound) UserLinkView(user: user),
              const SizedBox(height: 12),
              // Action buttons
              isUserNotFound
                  ? const NoUserFoundButton()
                  : _ActionButtonsRow(
                      user: user, controller: controller, isMe: isMe),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

// ─── CENTERED STATS ROW: Followers | PIC | Following ───
class _CenteredStatsRow extends StatelessWidget {
  final User? user;
  final ProfileScreenController controller;
  final bool userNotFound;
  final int totalPosts;

  const _CenteredStatsRow({
    required this.user,
    required this.controller,
    required this.userNotFound,
    required this.totalPosts,
  });

  @override
  Widget build(BuildContext context) {
    bool isStoryAvailable = (user?.stories ?? []).isNotEmpty;
    bool isWatch = isStoryAvailable &&
        (user?.stories ?? []).every((element) => element.isWatchedByMe());
    bool isMe = user?.id == SessionManager.instance.getUserID();
    RxBool isHeroEnable = false.obs;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Followers (left)
        Expanded(
          child: InkWell(
            onTap: () {
              if (userNotFound) return;
              user?.checkIsBlocked(() {
                Get.to(() => FollowFollowingScreen(
                    type: FollowFollowingType.follower, user: user));
              });
            },
            child: Column(
              children: [
                Text(
                  (user?.followerCount ?? 0).toInt().numberFormat,
                  style: TextStyleCustom.unboundedSemiBold600(
                    color: blackPure(context),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LKey.followers.tr.capitalize ?? '',
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Profile Picture (center) with gradient ring and "+" badge
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (userNotFound)
                Center(
                  child: Image.asset(AssetRes.icUserPlaceholder,
                      width: 90, height: 90, fit: BoxFit.cover),
                )
              else
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Show options: View Story (if available) + View Profile Picture
                      if (isMe) {
                        _showProfilePicOptions(context, user, isStoryAvailable, controller);
                      } else {
                        // For other users: tap opens story if available, else profile pic
                        if (isStoryAvailable) {
                          controller.onStoryTap(isStoryAvailable);
                        } else {
                          _openProfilePicPreview(context, user);
                        }
                      }
                    },
                    onLongPressStart: (_) => isHeroEnable.value = true,
                    onLongPressEnd: (_) => isHeroEnable.value = false,
                    onLongPress: () {
                      user?.checkIsBlocked(() {
                        _openProfilePicPreview(context, user);
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isStoryAvailable
                            ? (isWatch
                                ? StyleRes.disabledGreyGradient(opacity: .5)
                                : StyleRes.themeGradient)
                            : null,
                        border: !isStoryAvailable
                            ? Border.all(
                                color:
                                    textLightGrey(context).withValues(alpha: .2),
                                width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: whitePure(context),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Obx(
                          () => HeroMode(
                            enabled: isHeroEnable.value,
                            child: Hero(
                              tag: 'profile-${user?.id}',
                              child: CustomImage(
                                size: const Size(78, 78),
                                image: user?.isBlock == true
                                    ? ''
                                    : user?.profilePhoto?.addBaseURL(),
                                fullName: user?.fullname,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // "+" badge for adding story (own profile only)
              if (isMe && !userNotFound)
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => Get.to(() => const CameraScreen(
                          cameraType: CameraScreenType.story)),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: StyleRes.themeGradient as LinearGradient,
                          border: Border.all(color: whitePure(context), width: 2),
                        ),
                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Following (right)
        Expanded(
          child: InkWell(
            onTap: () {
              if (userNotFound) return;
              user?.checkIsBlocked(() {
                Get.to(() => FollowFollowingScreen(
                    type: FollowFollowingType.following, user: user));
              });
            },
            child: Column(
              children: [
                Text(
                  (user?.followingCount ?? 0).toInt().numberFormat,
                  style: TextStyleCustom.unboundedSemiBold600(
                    color: blackPure(context),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LKey.following.tr.capitalize ?? '',
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openProfilePicPreview(BuildContext context, User? user) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) =>
            ProfilePreviewInteractiveScreen(user: user),
      ),
    );
  }

  void _showProfilePicOptions(BuildContext context, User? user,
      bool isStoryAvailable, ProfileScreenController controller) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStoryAvailable)
                ListTile(
                  leading: Icon(Icons.play_circle_outline_rounded,
                      color: themeAccentSolid(context)),
                  title: Text(LKey.viewStory.tr,
                      style: TextStyleCustom.outFitRegular400(fontSize: 16)),
                  onTap: () {
                    Get.back();
                    controller.onStoryTap(true);
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle_outlined,
                    color: themeAccentSolid(context)),
                title: Text(LKey.viewProfilePicture.tr,
                    style: TextStyleCustom.outFitRegular400(fontSize: 16)),
                onTap: () {
                  Get.back();
                  _openProfilePicPreview(context, user);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined,
                    color: themeAccentSolid(context)),
                title: Text(LKey.addStory.tr,
                    style: TextStyleCustom.outFitRegular400(fontSize: 16)),
                onTap: () {
                  Get.back();
                  Get.to(() => const CameraScreen(
                      cameraType: CameraScreenType.story));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NAME + CATEGORY ROW ───
class _NameCategoryRow extends StatelessWidget {
  final User? user;
  final int totalPosts;

  const _NameCategoryRow({required this.user, required this.totalPosts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name row with verification and level
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user?.isVerify == 1)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child:
                    Image.asset(AssetRes.icBlueTick, width: 17, height: 17),
              ),
            Flexible(
              child: Text(
                user?.fullname ?? '',
                style: TextStyleCustom.outFitSemiBold600(
                    color: blackPure(context), fontSize: 17),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user?.pronouns != null &&
                (user?.pronouns ?? '').isNotEmpty)
              Text(
                '  ${user?.pronouns ?? ''}',
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context).withValues(alpha: 0.6),
                    fontSize: 13),
              ),
            if (user?.getLevel.id != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () =>
                    Get.to(() => LevelScreen(userLevels: user?.getLevel)),
                child: GradientBorder(
                  strokeWidth: 1.2,
                  radius: 30,
                  gradient: StyleRes.themeGradient,
                  child: Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: SmoothBorderRadius(cornerRadius: 30),
                      color: themeAccentSolid(context).withValues(alpha: .1),
                    ),
                    alignment: Alignment.center,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => StyleRes.themeGradient
                          .createShader(Rect.fromLTWH(
                              0, 0, bounds.width, bounds.height)),
                      child: RichText(
                        text: TextSpan(
                          text: LKey.lvl.tr,
                          style: TextStyleCustom.outFitLight300(fontSize: 11),
                          children: [
                            TextSpan(
                              text: ' ${user?.getLevel.level ?? 0}',
                              style:
                                  TextStyleCustom.outFitBold700(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        // Category | Posts count | Account type — centered row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user?.isPrivate == true)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.lock_outline,
                    size: 13, color: textLightGrey(context)),
              ),
            if (user?.profileCategory != null)
              Flexible(
                child: Text(
                  user!.profileCategory!['name'] ?? '',
                  style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (user?.profileCategory != null && totalPosts > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('|',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context).withValues(alpha: 0.4),
                        fontSize: 14)),
              ),
            if (totalPosts > 0)
              Text(
                '$totalPosts ${LKey.posts.tr}',
                style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context), fontSize: 14),
              ),
            if (user?.accountType != null && (user?.accountType ?? 0) > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('|',
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context).withValues(alpha: 0.4),
                        fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _accountTypeLabel(user!.accountType!),
                  style: TextStyleCustom.outFitMedium500(
                      color: themeAccentSolid(context), fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _accountTypeLabel(int type) {
    switch (type) {
      case 1:
        return LKey.creatorLabel.tr;
      case 2:
        return LKey.businessText.tr;
      case 3:
        return LKey.productionHouse.tr;
      case 4:
        return LKey.newsMedia.tr;
      default:
        return '';
    }
  }
}

// ─── ACTION BUTTONS ROW ───
class _ActionButtonsRow extends StatelessWidget {
  final User? user;
  final ProfileScreenController controller;
  final bool isMe;

  const _ActionButtonsRow({
    required this.user,
    required this.controller,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    if (user?.isBlock == true &&
        user?.id != SessionManager.instance.getUserID()) {
      return UnblockButton(onTap: () => controller.toggleBlockUnblock(true));
    }

    if (isMe) {
      return _OwnProfileButtons(controller: controller);
    }
    return _OtherProfileButtons(user: user, controller: controller);
  }
}

// ─── OWN PROFILE: Edit Profile | Statistics | Publish ───
class _OwnProfileButtons extends StatelessWidget {
  final ProfileScreenController controller;

  const _OwnProfileButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Edit Profile — outlined
        Expanded(
          child: _OutlinedButton(
            title: LKey.editProfile.tr,
            onTap: () {
              Get.to(() => EditProfileScreen(
                    onUpdateUser: controller.onUpdateUser,
                  ));
            },
          ),
        ),
        const SizedBox(width: 8),
        // Statistics — outlined
        Expanded(
          child: _OutlinedButton(
            title: LKey.statistics.tr,
            onTap: () => Get.to(() => const CreatorDashboardScreen()),
          ),
        ),
        const SizedBox(width: 8),
        // Publish — filled accent
        Expanded(
          child: _FilledAccentButton(
            title: LKey.publish.tr,
            onTap: () => controller.handlePublishOrMessageBtn(true),
          ),
        ),
      ],
    );
  }
}

// ─── OTHER PROFILE: Follow | Message | Subscribe ───
class _OtherProfileButtons extends StatelessWidget {
  final User? user;
  final ProfileScreenController controller;

  const _OtherProfileButtons({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Follow/Unfollow
        Expanded(
          child: Obx(() {
            bool isFollowProgress =
                controller.isFollowUnFollowInProcess.value;
            bool isFollowing = user?.isFollowing == true;
            return isFollowing
                ? _OutlinedButton(
                    title: LKey.unFollow.tr,
                    onTap: () {
                      if (!isFollowProgress) {
                        controller.followUnFollowUser();
                      }
                    },
                    child: isFollowProgress
                        ? CupertinoActivityIndicator(
                            radius: 8, color: textLightGrey(context))
                        : null,
                  )
                : _FilledAccentButton(
                    title: LKey.follow.tr,
                    onTap: () {
                      if (!isFollowProgress) {
                        controller.followUnFollowUser();
                      }
                    },
                    child: isFollowProgress
                        ? const CupertinoActivityIndicator(
                            radius: 8, color: Colors.white)
                        : null,
                  );
          }),
        ),
        const SizedBox(width: 8),
        // Message
        Expanded(
          child: _OutlinedButton(
            title: LKey.message.tr,
            onTap: () => controller.handlePublishOrMessageBtn(false),
          ),
        ),
        // Subscribe (if creator has subscriptions)
        if (user?.subscriptionsEnabled == true) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _FilledAccentButton(
              title: LKey.subscribe.tr,
              onTap: () {
                if (user != null) {
                  Get.bottomSheet(
                    CreatorSubscribeSheet(
                      creator: user!,
                      onSubscribed: () => controller.fetchUserDetail(),
                    ),
                    isScrollControlled: true,
                  );
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}

// ─── OUTLINED BUTTON COMPONENT ───
class _OutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? child;

  const _OutlinedButton({
    required this.title,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: textLightGrey(context).withValues(alpha: 0.3), width: 1),
        ),
        child: child ??
            Text(
              title,
              style: TextStyleCustom.outFitMedium500(
                  color: blackPure(context), fontSize: 14),
            ),
      ),
    );
  }
}

// ─── FILLED ACCENT BUTTON COMPONENT ───
class _FilledAccentButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Widget? child;

  const _FilledAccentButton({
    required this.title,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: blueFollow(context),
        ),
        child: child ??
            Text(
              title,
              style: TextStyleCustom.outFitMedium500(
                  color: Colors.white, fontSize: 14),
            ),
      ),
    );
  }
}

// ─── BIO VIEW ───
class UserBioView extends StatelessWidget {
  final User? user;

  const UserBioView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if ((user?.bio ?? '').isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        user?.bio ?? '',
        textAlign: TextAlign.center,
        style: TextStyleCustom.outFitRegular400(
            color: textDarkGrey(context), fontSize: 14),
      ),
    );
  }
}

// ─── LINK VIEW ───
class UserLinkView extends StatelessWidget {
  final User? user;

  const UserLinkView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    List<Link> links = user?.links ?? [];
    if (links.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: InkWell(
        onTap: () {
          user?.checkIsBlocked(() {
            if (links.length > 1) {
              Get.bottomSheet(UserLinkSheet(links: links),
                  isScrollControlled: true,
                  barrierColor: blackPure(context).withValues(alpha: .7));
            } else {
              (links.first.url ?? '').lunchUrlWithHttps;
            }
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link_rounded,
                size: 16, color: themeAccentSolid(context)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                shortUrl,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 13, color: themeAccentSolid(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get shortUrl {
    List<Link> links = user?.links ?? [];
    String firstLink = links.first.url ?? '';
    String andMore = '';
    if (firstLink.length >= 40) {
      int endCount = links.length > 1 ? 25 : 35;
      firstLink = '${firstLink.substring(0, endCount)}...';
    }
    if (links.length > 1) {
      andMore = ' & ${links.length - 1} ${LKey.more.tr.toLowerCase()}';
    }
    return '$firstLink$andMore';
  }
}

// ─── NO USER FOUND ───
class NoUserFoundButton extends StatelessWidget {
  const NoUserFoundButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButtonCustom(
      onTap: () {},
      title: LKey.userNotFound.tr,
      btnHeight: 40,
      backgroundColor: bgMediumGrey(context),
      fontSize: 15,
      radius: 8,
      titleColor: textLightGrey(context),
      margin: const EdgeInsets.only(bottom: 10, left: 40, right: 40, top: 20),
    );
  }
}

// ─── UNBLOCK BUTTON ───
class UnblockButton extends StatelessWidget {
  final VoidCallback onTap;

  const UnblockButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButtonCustom(
      onTap: onTap,
      title: LKey.unBlock.tr,
      fontSize: 16,
      backgroundColor: blueFollow(context),
      titleColor: whitePure(context),
      horizontalMargin: 0,
      btnHeight: 42,
    );
  }
}

// ─── STAT ITEM MODEL ───
class StatItem {
  final num value;
  final String label;

  StatItem({required this.value, required this.label});
}

// ─── STAT COLUMN (kept for backward compatibility) ───
class StatColumn extends StatelessWidget {
  final num value;
  final String label;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const StatColumn(
      {super.key,
      required this.value,
      required this.label,
      this.labelStyle,
      this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toInt().numberFormat,
          style: valueStyle ??
              TextStyleCustom.unboundedSemiBold600(
                color: blackPure(context),
                fontSize: 16,
              ),
        ),
        Text(label.capitalize ?? '',
            style: labelStyle ??
                TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context),
                  fontSize: 13,
                )),
      ],
    );
  }
}
