import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/single_post_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Embedded card showing a quoted/reposted post within another post.
class QuotedPostCard extends StatelessWidget {
  final Post quotedPost;

  const QuotedPostCard({super.key, required this.quotedPost});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SinglePostScreen(
            post: quotedPost, isFromNotification: false));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
              color: textLightGrey(context).withValues(alpha: .3), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quoted post author
            Row(
              children: [
                CustomImage(
                  size: const Size(20, 20),
                  image: quotedPost.user?.profilePhoto?.addBaseURL(),
                  strokeWidth: 0,
                  fullName: quotedPost.user?.fullname,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '@${quotedPost.user?.username ?? ''}',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 13, color: textDarkGrey(context)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if ((quotedPost.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                quotedPost.description ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 13, color: textDarkGrey(context)),
              ),
            ],
            // Show thumbnail if it's a media post
            if ((quotedPost.images ?? []).isNotEmpty ||
                (quotedPost.thumbnail ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomImage(
                  size: const Size(double.infinity, 120),
                  image: (quotedPost.images?.firstOrNull?.image ??
                          quotedPost.thumbnail)
                      ?.addBaseURL(),
                  radius: 6,
                  isShowPlaceHolder: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
