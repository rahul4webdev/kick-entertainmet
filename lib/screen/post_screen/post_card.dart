import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/debounce_action.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/widget/custom_divider.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_by_id.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/post_screen_controller.dart';
import 'package:shortzz/screen/post_screen/widget/post_animation_like.dart';
import 'package:shortzz/screen/post_screen/widget/post_view_action_button.dart';
import 'package:shortzz/screen/post_screen/widget/post_view_center.dart';
import 'package:shortzz/screen/post_screen/widget/post_view_info_header.dart';
import 'package:shortzz/screen/subscription_screen/creator_subscribe_sheet.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool shouldShowPinOption;
  final GlobalKey likeKey;
  final PostByIdData? postByIdData;
  final bool isFromSinglePost;

  const PostCard(
      {super.key,
      required this.post,
      required this.shouldShowPinOption,
      required this.likeKey,
      this.postByIdData,
      this.isFromSinglePost = false});

  @override
  Widget build(BuildContext context) {
    PostScreenController controller;

    if (Get.isRegistered<PostScreenController>(tag: '${post.id}')) {
      controller = Get.find<PostScreenController>(tag: '${post.id}');
      controller.isFromSinglePostScreen =
          isFromSinglePost; // Delay update until after current frame to ensure proper UI update without conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updatePost(post);
      });
    } else {
      controller = Get.put(PostScreenController(post.obs, isFromSinglePost),
          tag: '${post.id}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updatePost(post);
      });
    }

    return Obx(
      () {
        Post post = controller.postData.value;
        if (post.id == null) {
          if (isFromSinglePost) {
            Get.back();
          }
          return const SizedBox();
        } else {
          return Container(
            color: scaffoldBackgroundColor(context),
            padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomImage(
                        size: const Size(38, 38),
                        strokeWidth: 2,
                        image: post.user?.profilePhoto?.addBaseURL(),
                        fullName: post.user?.fullname,
                        onTap: () {
                          NavigationService.shared.openProfileScreen(post.user);
                        },
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PostViewInfoHeader(
                              post: post,
                              controller: controller,
                              shouldShowPinOption: shouldShowPinOption,
                            ),
                            if (post.isLocked)
                              _LockedContentOverlay(post: post)
                            else ...[
                              PostViewCenter(
                                post: post,
                                onDoubleTap: (p0) {
                                  PhotoLikeService.instance.like(p0,
                                      likeKey: likeKey,
                                      context: context,
                                      post: post,
                                      size: const Size(35, 35),
                                      leftRightPosition: 6,
                                      onLike: controller.onLike);
                                },
                                onHeartAnimationEnd: () {
                                  controller.triggerLikeAnim.call();
                                  DebounceAction.shared.call(() {
                                    if (post.isLiked == false) {
                                      controller.onLike(post);
                                    }
                                  });
                                },
                              ),
                              PostViewActionButton(
                                  post: post,
                                  controller: controller,
                                  likeKey: likeKey,
                                  onTriggerReady: (trigger) {
                                    controller.triggerLikeAnim = trigger;
                                  }),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const CustomDivider(),
              ],
            ),
          );
        }
      },
    );
  }
}

class _LockedContentOverlay extends StatelessWidget {
  final Post post;

  const _LockedContentOverlay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: textDarkGrey(context).withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 36, color: textLightGrey(context)),
          const SizedBox(height: 10),
          Text(
            LKey.subscribeToView.tr,
            textAlign: TextAlign.center,
            style: TextStyleCustom.outFitRegular400(
              fontSize: 14,
              color: textLightGrey(context),
            ),
          ),
          const SizedBox(height: 12),
          if (post.user != null)
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  CreatorSubscribeSheet(creator: post.user!),
                  isScrollControlled: true,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  LKey.subscribeNow.tr,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
