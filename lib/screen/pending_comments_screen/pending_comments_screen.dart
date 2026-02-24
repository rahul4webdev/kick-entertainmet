import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';
import 'package:shortzz/screen/pending_comments_screen/pending_comments_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PendingCommentsScreen extends StatelessWidget {
  final int postId;

  const PendingCommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PendingCommentsScreenController(postId));
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.pendingComments.tr),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      controller.pendingComments.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.pendingComments.isEmpty,
                      title: LKey.noPendingComments.tr,
                      description: LKey.noPendingCommentsDesc.tr,
                      child: ListView.builder(
                        itemCount: controller.pendingComments.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          Comment comment =
                              controller.pendingComments[index];
                          return _PendingCommentTile(
                            comment: comment,
                            onApprove: () =>
                                controller.approveComment(comment),
                            onReject: () =>
                                controller.rejectComment(comment),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCommentTile extends StatelessWidget {
  final Comment comment;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingCommentTile({
    required this.comment,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImage(
                image: user?.profilePhoto?.addBaseURL(),
                fullName: user?.fullname,
                size: const Size(40, 40),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? '',
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 14,
                        color: textDarkGrey(context),
                      ),
                    ),
                    Text(
                      comment.comment ?? '',
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 14,
                        color: textDarkGrey(context),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onReject,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgGrey(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    LKey.reject.tr,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 13,
                      color: textDarkGrey(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onApprove,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    LKey.approve.tr,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Divider(color: bgGrey(context), height: 1),
        ],
      ),
    );
  }
}
