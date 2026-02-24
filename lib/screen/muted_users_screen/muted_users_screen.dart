import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/muted_user_model.dart';
import 'package:shortzz/screen/muted_users_screen/muted_users_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/profile_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MutedUsersScreen extends StatelessWidget {
  const MutedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MutedUsersScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.mutedAccounts.tr),
          Expanded(
            child: Obx(
              () => controller.isLoading.value && controller.mutedUsers.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.mutedUsers.isEmpty,
                      title: LKey.muteListEmptyTitle.tr,
                      description: LKey.muteListEmptyDescription.tr,
                      child: ListView.builder(
                        itemCount: controller.mutedUsers.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          MutedUsers muted = controller.mutedUsers[index];
                          return _MutedUserTile(
                            muted: muted,
                            onUnmute: () => controller.unmuteUser(muted),
                            onTap: () {
                              Get.to(() => ProfileScreen(
                                    user: muted.toUser,
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

class _MutedUserTile extends StatelessWidget {
  final MutedUsers muted;
  final VoidCallback onUnmute;
  final VoidCallback onTap;

  const _MutedUserTile({
    required this.muted,
    required this.onUnmute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = muted.toUser;
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
              onTap: onUnmute,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: bgGrey(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LKey.unmute.tr,
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
