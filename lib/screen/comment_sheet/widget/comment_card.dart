import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/context_menu_widget.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet_controller.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:shortzz/screen/post_screen/widget/post_view_center.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CommentCard extends StatelessWidget {
  final Comment? comment;
  final CommentSheetController controller;
  final bool isLikeButtonVisible;
  final bool isReplyVisible;

  const CommentCard(
      {super.key,
      required this.comment,
      required this.controller,
      required this.isLikeButtonVisible,
      required this.isReplyVisible});

  @override
  Widget build(BuildContext context) {
    bool isLike = comment?.isLiked == true;
    if (comment == null) {
      return const SizedBox();
    }
    return ContextMenuWidget(
      child: Container(
        color: whitePure(context),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImage(
              size: const Size(30, 30),
              strokeWidth: 1.5,
              image: comment?.user?.profilePhoto?.addBaseURL(),
              fullName: comment?.user?.fullname,
              onTap: () {
                NavigationService.shared.openProfileScreen(comment?.user);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FullNameWithBlueTick(
                      onTap: () {
                        NavigationService.shared
                            .openProfileScreen(comment?.user);
                      },
                      username: comment?.user?.username ?? '',
                      isVerify: comment?.user?.isVerify,
                      child: Text(
                          '${comment?.createdAt?.timeAgo ?? ''}${comment?.isPinned == 1 ? AppRes.postPinIcon : ''}',
                          style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context)))),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            switch (comment?.type) {
                              CommentType.text => PostTextView(
                                  description: comment?.commentDescription,
                                  mentionUsers: comment?.mentionedUsers ?? []),
                              CommentType.image => CustomImage(
                                  size: const Size(118, 118),
                                  image: comment?.comment,
                                  isShowPlaceHolder: true,
                                  radius: 0,
                                  fit: BoxFit.contain),
                              null => const SizedBox(),
                            },
                            // Creator liked badge
                            if (comment?.isCreatorLiked == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ColorRes.likeRed.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.favorite,
                                        size: 12, color: ColorRes.likeRed),
                                    const SizedBox(width: 3),
                                    Text(
                                      LKey.creatorLiked.tr,
                                      style: TextStyleCustom.outFitMedium500(
                                          fontSize: 11,
                                          color: ColorRes.likeRed),
                                    ),
                                  ],
                                ),
                              ),
                            if (isReplyVisible)
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (comment != null) {
                                        controller.commentHelper
                                            .onReply(comment);
                                      }
                                    },
                                    child: Text(
                                      LKey.reply.tr,
                                      style: TextStyleCustom.outFitRegular400(
                                          color: textLightGrey(context)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () {
                                      if (comment != null) {
                                        Get.back();
                                        Get.to(() => CameraScreen(
                                              cameraType:
                                                  CameraScreenType.post,
                                              replyToCommentId: comment?.id,
                                              replyToCommentText:
                                                  comment?.comment,
                                            ));
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.videocam_outlined,
                                            size: 16,
                                            color: textLightGrey(context)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Video reply',
                                          style:
                                              TextStyleCustom.outFitRegular400(
                                                  color:
                                                      textLightGrey(context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if ((comment?.videoReplyCount ?? 0) > 0) ...[
                                    const SizedBox(width: 16),
                                    Text(
                                      '${comment?.videoReplyCount?.toInt()} video ${(comment?.videoReplyCount ?? 0) > 1 ? 'replies' : 'reply'}',
                                      style: TextStyleCustom.outFitRegular400(
                                          fontSize: 12,
                                          color: themeAccentSolid(context)),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (isLikeButtonVisible)
                        Column(
                          children: [
                            // Regular like button
                            InkWell(
                              onTap: () {
                                if (isLike) {
                                  controller.unlikeComment(comment);
                                } else {
                                  controller.likeComment(comment);
                                }
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      isLike
                                          ? AssetRes.icFillHeart
                                          : AssetRes.icHeart,
                                      color: isLike
                                          ? ColorRes.likeRed
                                          : textDarkGrey(context),
                                      width: 19,
                                      height: 19,
                                    ),
                                    Opacity(
                                      opacity:
                                          (comment?.likes ?? 0) >= 1 ? 1 : 0,
                                      child: Text(
                                        (comment?.likes ?? 0)
                                            .toInt()
                                            .numberFormat,
                                        style:
                                            TextStyleCustom.outFitRegular400(
                                                fontSize: 13,
                                                color:
                                                    textLightGrey(context)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            // Creator like button (only for post owner, on other people's comments)
                            if (controller.isPostOwner &&
                                comment?.userId !=
                                    SessionManager.instance.getUserID() &&
                                comment?.reply == null)
                              InkWell(
                                onTap: () {
                                  if (comment?.isCreatorLiked == true) {
                                    controller.creatorUnlikeComment(comment);
                                  } else {
                                    controller.creatorLikeComment(comment);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Icon(
                                    comment?.isCreatorLiked == true
                                        ? Icons.star
                                        : Icons.star_border,
                                    size: 18,
                                    color: comment?.isCreatorLiked == true
                                        ? Colors.amber
                                        : textLightGrey(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      menuProvider: (menu) {
        bool isMyPost = controller.post.value?.userId ==
            SessionManager.instance.getUserID();
        bool isMyComment =
            comment?.userId == SessionManager.instance.getUserID();
        if (isMyPost) {
          return Menu(
            children: [
              if (comment?.reply == null)
                MenuAction(
                    title: comment?.isPinned == 1 ? LKey.unpin.tr : LKey.pin.tr,
                    callback: () {
                      if (comment?.isPinned == 1) {
                        controller.onUnPinComment(comment!);
                      } else {
                        controller.onPinnedComment(comment!);
                      }
                    }),
              if (comment?.reply == null)
                MenuAction(
                    title: comment?.isCreatorLiked == true
                        ? LKey.removeCreatorLike.tr
                        : LKey.creatorLike.tr,
                    callback: () {
                      if (comment?.isCreatorLiked == true) {
                        controller.creatorUnlikeComment(comment!);
                      } else {
                        controller.creatorLikeComment(comment!);
                      }
                    }),
              MenuAction(
                title: LKey.delete.tr,
                callback: () => controller.onDeleteComment(comment!),
              ),
            ],
          );
        }
        if (!isMyPost && isMyComment) {
          return Menu(
            children: [
              MenuAction(
                title: LKey.delete.tr,
                callback: () => controller.onDeleteComment(comment!),
              )
            ],
          );
        }
        return null;
      },
    );
  }
}
