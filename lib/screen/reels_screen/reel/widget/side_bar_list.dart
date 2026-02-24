import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/gradient_icon.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/music/music_model.dart';
import 'package:shortzz/screen/ai_translation_screen/translation_sheet.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SideBarList extends StatelessWidget {
  final ReelController controller;
  final GlobalKey likeKey;

  const SideBarList(
      {super.key, required this.controller, required this.likeKey});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Post reel = controller.reelData.value;
      final isPlaceholder = reel.id == -1;
      Music? music = reel.music;
      if (music?.addedBy == 0) {
        music?.user = reel.user;
      } else {
        music?.user = null;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            CustomImage(
              image: reel.user?.profilePhoto?.addBaseURL(),
              fullName: reel.user?.fullname,
              size: const Size(40, 40),
              strokeWidth: 1.5,
              onTap: () => controller.onUserTap(reel.user),
            ),
            const SizedBox(height: 7.5),
            IconWithLabel(
                likeKey: likeKey,
                onTap: () {
                  isPlaceholder ? () {} : controller.onLikeTap();
                },
                image: (reel.isLiked ?? false)
                    ? AssetRes.icFillHeart
                    : AssetRes.icHeart,
                text: isPlaceholder
                    ? '1'
                    : (reel.hideLikeCount == true ||
                            SessionManager.instance.getUser()?.hideOthersLikeCount == true)
                        ? ''
                        : (reel.likes ?? 0).toString()),
            if (reel.canComment == 1)
              IconWithLabel(
                onTap: isPlaceholder ? () {} : controller.onCommentTap,
                image: AssetRes.icComment,
                text: isPlaceholder ? '1' : (reel.comments ?? 0).toString(),
              ),
            IconWithLabel(
              onTap: isPlaceholder ? () {} : controller.onSaved,
              image: (reel.isSaved ?? false)
                  ? AssetRes.icFillBookmark1
                  : AssetRes.icBookmark,
              text: isPlaceholder ? '1' : (reel.saves ?? 0).toString(),
              iconColor: whitePure(context),
            ),
            IconWithLabel(
              onTap: isPlaceholder ? () {} : controller.onShareTap,
              image: AssetRes.icShare,
              text: isPlaceholder ? '1' : (reel.shares ?? 0).toString(),
            ),
            Visibility(
              visible: reel.user?.id != SessionManager.instance.getUserID(),
              child: IconWithLabel(
                onTap: isPlaceholder ? () {} : controller.onRepostTap,
                image: AssetRes.icShare2,
                text: isPlaceholder ? '' : (reel.repostCount ?? 0).toString(),
              ),
            ),
            Visibility(
              visible: reel.user?.id != SessionManager.instance.getUserID() &&
                  reel.allowDuet &&
                  reel.postType == PostType.reel,
              child: IconWithLabel(
                onTap: isPlaceholder ? () {} : controller.onDuetTap,
                image: AssetRes.icDuet,
                text: '',
              ),
            ),
            Visibility(
              visible: reel.user?.id != SessionManager.instance.getUserID() &&
                  reel.allowStitch &&
                  reel.postType == PostType.reel,
              child: IconWithLabel(
                onTap: isPlaceholder ? () {} : controller.onStitchTap,
                image: AssetRes.icStitch,
                text: '',
              ),
            ),
            Visibility(
              visible: controller.reelData.value.user?.id !=
                  SessionManager.instance.getUserID(),
              child: IconWithGift(onTap: controller.onGiftTap),
            ),
            Visibility(
              visible: controller.reelData.value.user?.id !=
                  SessionManager.instance.getUserID(),
              child: IconWithTip(onTap: controller.onTipTap),
            ),
            Visibility(
              visible: music != null,
              child: IconWithMusic(
                  onAudioTap: () => controller.onAudioTap(music), music: music),
            ),
            // Use This Audio button
            Visibility(
              visible: music != null &&
                  reel.user?.id != SessionManager.instance.getUserID(),
              child: _UseAudioButton(
                onTap: () => controller.onUseAudioTap(music),
              ),
            ),
            Visibility(
              visible: reel.user?.id != SessionManager.instance.getUserID() && !isPlaceholder,
              child: IconWithMore(
                onTap: () => _showMoreSheet(context, controller),
              ),
            ),
          ],
        ),
      );
    });
  }
}

void _showMoreSheet(BuildContext context, ReelController controller) {
  Get.bottomSheet(
    SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.not_interested, color: blackPure(context)),
              title: Text(
                LKey.notInterested.tr,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 15,
                  color: blackPure(context),
                ),
              ),
              onTap: () {
                Get.back();
                controller.onNotInterestedTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.translate, color: blackPure(context)),
              title: Text(
                LKey.translate.tr,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 15,
                  color: blackPure(context),
                ),
              ),
              onTap: () {
                Get.back();
                final post = controller.reelData.value;
                final text = post.description ?? '';
                final captions = post.captions
                    ?.map((c) => {
                          'start_ms': c.startMs,
                          'end_ms': c.endMs,
                          'text': c.text,
                        })
                    .toList();
                Get.bottomSheet(
                  TranslationSheet(
                    text: text,
                    captions: captions,
                  ),
                  isScrollControlled: true,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.code, color: blackPure(context)),
              title: Text(
                LKey.getEmbedCode.tr,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 15,
                  color: blackPure(context),
                ),
              ),
              onTap: () {
                Get.back();
                controller.onGetEmbedCode();
              },
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class IconWithMore extends StatelessWidget {
  final VoidCallback onTap;

  const IconWithMore({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: Image.asset(AssetRes.icMore, width: 34, height: 34, color: whitePure(context)),
      ),
    );
  }
}

class IconWithGift extends StatelessWidget {
  final VoidCallback onTap;

  const IconWithGift({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 37,
        width: 37,
        margin: const EdgeInsets.symmetric(vertical: 7.5),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: whitePure(context),
          shape: BoxShape.circle,
        ),
        child: GradientIcon(
            child: Image.asset(AssetRes.icGift, width: 22, height: 22)),
      ),
    );
  }
}

class IconWithTip extends StatelessWidget {
  final VoidCallback onTap;

  const IconWithTip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 37,
        width: 37,
        margin: const EdgeInsets.symmetric(vertical: 7.5),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: whitePure(context),
          shape: BoxShape.circle,
        ),
        child: GradientIcon(
            child: Image.asset(AssetRes.icCoin, width: 22, height: 22)),
      ),
    );
  }
}

class IconWithMusic extends StatelessWidget {
  final VoidCallback onAudioTap;
  final Music? music;

  const IconWithMusic({super.key, required this.onAudioTap, this.music});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onAudioTap,
      child: Container(
        height: 37,
        width: 37,
        margin: const EdgeInsets.only(top: 7.5),
        padding: const EdgeInsets.all(3),
        decoration:
            BoxDecoration(color: whitePure(context), shape: BoxShape.circle),
        child: DottedBorder(
          options: OvalDottedBorderOptions(
              strokeWidth: 1.5, gradient: StyleRes.themeGradient),
          child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: GradientIcon(child: Image.asset(AssetRes.icMusic))),
        ),
      ),
    );
  }
}

class _UseAudioButton extends StatelessWidget {
  final VoidCallback onTap;

  const _UseAudioButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: Column(
          children: [
            const Icon(Icons.music_note_outlined, color: Colors.white, size: 28),
            Text(
              'Use Audio',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconWithLabel extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  final String text;
  final Color? iconColor;
  final Key? likeKey;

  const IconWithLabel({
    super.key,
    required this.onTap,
    required this.image,
    required this.text,
    this.iconColor,
    this.likeKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.5),
      child: Column(
        children: [
          InkWell(
              onTap: onTap,
              key: likeKey,
              child:
                  Image.asset(image, width: 34, height: 34, color: iconColor)),
          if (text.isNotEmpty)
            Text(
              text,
              style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: whitePure(context))
                  .copyWith(
                shadows: <Shadow>[
                  Shadow(
                    offset: const Offset(0.0, 1.0),
                    blurRadius: 3.0,
                    color: textLightGrey(context),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
