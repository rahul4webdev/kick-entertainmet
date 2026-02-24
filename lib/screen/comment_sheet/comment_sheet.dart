import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/widget/bottom_sheet_top_view.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/comment_sheet/comment_sheet_controller.dart';
import 'package:shortzz/screen/comment_sheet/helper/comment_helper.dart';
import 'package:shortzz/screen/comment_sheet/widget/comment_bottom_text_field_view.dart';
import 'package:shortzz/screen/comment_sheet/widget/comments_view.dart';
import 'package:shortzz/screen/comment_sheet/widget/hashtag_and_mention_view.dart';
import 'package:shortzz/screen/pending_comments_screen/pending_comments_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CommentSheet extends StatelessWidget {
  final Post? post;
  final Comment? comment;
  final Comment? replyComment;
  final bool isFromNotification;
  final bool isFromBottomSheet;

  const CommentSheet(
      {super.key,
      this.post,
      this.comment,
      this.replyComment,
      this.isFromNotification = false,
      this.isFromBottomSheet = true});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommentSheetController(
        post.obs, comment, replyComment, isFromNotification, CommentHelper()));
    return Container(
      margin: isFromBottomSheet
          ? EdgeInsets.only(top: AppBar().preferredSize.height * 2.5)
          : null,
      decoration: ShapeDecoration(
          shape: const SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius.vertical(
                  top: SmoothRadius(cornerRadius: 40, cornerSmoothing: 1))),
          color: scaffoldBackgroundColor(context)),
      child: Column(
        children: [
          if (isFromBottomSheet)
            Obx(() => BottomSheetTopView(
                title:
                    '${(controller.post.value?.comments ?? 0).toInt().numberFormat} ${LKey.comments.tr}',
                sideBtnVisibility: false)),
          if (isFromBottomSheet)
            Obx(() {
              if (!controller.isPostOwner || controller.pendingCount.value == 0) {
                return const SizedBox();
              }
              return GestureDetector(
                onTap: () {
                  Get.to(() => PendingCommentsScreen(
                      postId: controller.post.value?.id?.toInt() ?? -1));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pending_actions, size: 18, color: themeAccentSolid(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${controller.pendingCount.value} ${LKey.pendingComments.tr.toLowerCase()}',
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 13, color: themeAccentSolid(context)),
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: themeAccentSolid(context)),
                    ],
                  ),
                ),
              );
            }),
          // Sort toggle row
          if (isFromBottomSheet)
            Obx(() {
              if (controller.getCommentsList.isEmpty) {
                return const SizedBox();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    InkWell(
                      onTap: controller.toggleSortMode,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: textLightGrey(context).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.sortMode.value == 'top'
                                  ? Icons.trending_up
                                  : Icons.schedule,
                              size: 14,
                              color: textDarkGrey(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              controller.sortMode.value == 'top'
                                  ? LKey.topComments.tr
                                  : LKey.newestComments.tr,
                              style: TextStyleCustom.outFitMedium500(
                                  fontSize: 12, color: textDarkGrey(context)),
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.unfold_more,
                                size: 14, color: textDarkGrey(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          Obx(() {
            final activeList = controller.getActiveCommentsList;
            final isLoadingActive = controller.sortMode.value == 'top'
                ? controller.isLoadingTopComments.value
                : controller.isLoading.value;
            Widget content = Stack(
              key: isFromBottomSheet ? null : controller.commentKey,
              children: [
                activeList.isEmpty && isLoadingActive
                    ? const LoaderWidget()
                    : activeList.isEmpty && !isLoadingActive
                        ? (!isFromBottomSheet
                            ? const SizedBox()
                            : NoDataView(
                                title: LKey.postCommentEmptyTitle.tr,
                                description:
                                    LKey.postCommentEmptyDescription.tr))
                        : CommentsView(controller: controller),
                HashTagAndMentionUserView(helper: controller.commentHelper),
              ],
            );
            return !isFromBottomSheet ? content : Expanded(child: content);
          }),
          if (isFromBottomSheet)
            CommentBottomTextFieldView(
                helper: controller.commentHelper,
                isFromBottomSheet: isFromBottomSheet),
        ],
      ),
    );
  }
}
