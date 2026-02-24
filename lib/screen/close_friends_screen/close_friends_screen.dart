import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/favorite_user_model.dart';
import 'package:shortzz/screen/close_friends_screen/close_friends_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/profile_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CloseFriendsScreen extends StatelessWidget {
  const CloseFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CloseFriendsScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.closeFriends.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              LKey.closeFriendsDesc.tr,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      controller.closeFriends.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.closeFriends.isEmpty,
                      title: LKey.closeFriendsEmptyTitle.tr,
                      description: LKey.closeFriendsEmptyDesc.tr,
                      child: ListView.builder(
                        itemCount: controller.closeFriends.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          FavoriteUser friend =
                              controller.closeFriends[index];
                          return _CloseFriendTile(
                            friend: friend,
                            onRemove: () =>
                                controller.removeCloseFriend(friend),
                            onTap: () {
                              Get.to(() => ProfileScreen(
                                    user: friend.toUser,
                                  ));
                            },
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

class _CloseFriendTile extends StatelessWidget {
  final FavoriteUser friend;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _CloseFriendTile({
    required this.friend,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = friend.toUser;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CustomImage(
              image: user?.profilePhoto?.addBaseURL(),
              fullName: user?.fullname,
              size: const Size(48, 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.username ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 15,
                      color: textDarkGrey(context),
                    ),
                  ),
                  Text(
                    user?.fullname ?? '',
                    style: TextStyleCustom.outFitLight300(
                      fontSize: 13,
                      color: textLightGrey(context),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: bgGrey(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LKey.remove.tr,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: textDarkGrey(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
