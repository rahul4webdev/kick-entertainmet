import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/restricted_user_model.dart';
import 'package:shortzz/screen/profile_screen/profile_screen.dart';
import 'package:shortzz/screen/restricted_users_screen/restricted_users_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class RestrictedUsersScreen extends StatelessWidget {
  const RestrictedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestrictedUsersScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.restrictedAccounts.tr),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      controller.restrictedUsers.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.restrictedUsers.isEmpty,
                      title: LKey.restrictListEmptyTitle.tr,
                      description: LKey.restrictListEmptyDescription.tr,
                      child: ListView.builder(
                        itemCount: controller.restrictedUsers.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          RestrictedUsers restricted =
                              controller.restrictedUsers[index];
                          return _RestrictedUserTile(
                            restricted: restricted,
                            onUnrestrict: () =>
                                controller.unrestrictUser(restricted),
                            onTap: () {
                              Get.to(() => ProfileScreen(
                                    user: restricted.toUser,
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

class _RestrictedUserTile extends StatelessWidget {
  final RestrictedUsers restricted;
  final VoidCallback onUnrestrict;
  final VoidCallback onTap;

  const _RestrictedUserTile({
    required this.restricted,
    required this.onUnrestrict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = restricted.toUser;
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
              onTap: onUnrestrict,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: bgGrey(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LKey.unrestrict.tr,
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
