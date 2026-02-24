import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/favorite_user_model.dart';
import 'package:shortzz/screen/favorite_users_screen/favorite_users_screen_controller.dart';
import 'package:shortzz/screen/profile_screen/profile_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FavoriteUsersScreen extends StatelessWidget {
  const FavoriteUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoriteUsersScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.favorites.tr),
          Expanded(
            child: Obx(
              () => controller.isLoading.value &&
                      controller.favoriteUsers.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.favoriteUsers.isEmpty,
                      title: LKey.favoritesListEmptyTitle.tr,
                      description: LKey.favoritesListEmptyDescription.tr,
                      child: ListView.builder(
                        itemCount: controller.favoriteUsers.length,
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (context, index) {
                          FavoriteUser favorite =
                              controller.favoriteUsers[index];
                          return _FavoriteUserTile(
                            favorite: favorite,
                            onRemove: () =>
                                controller.removeFromFavorites(favorite),
                            onTap: () {
                              Get.to(() => ProfileScreen(
                                    user: favorite.toUser,
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

class _FavoriteUserTile extends StatelessWidget {
  final FavoriteUser favorite;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FavoriteUserTile({
    required this.favorite,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = favorite.toUser;
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
                  LKey.removeFromFavorites.tr,
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
