import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_tab_switcher.dart';
import 'package:shortzz/common/widget/load_more_widget.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/misc/activity_notification_model.dart';
import 'package:shortzz/model/misc/admin_notification_model.dart';
import 'package:shortzz/screen/notification_screen/notification_screen_controller.dart';
import 'package:shortzz/screen/notification_screen/widget/activity_notification_page.dart';
import 'package:shortzz/screen/notification_screen/widget/system_notification_page.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
              title: LKey.notifications.tr,
              titleStyle: TextStyleCustom.unboundedSemiBold600(
                  fontSize: 15, color: textDarkGrey(context)),
              widget: CustomTabSwitcher(
                  items: [(LKey.activity.tr), (LKey.system.tr)],
                  selectedIndex: controller.selectedTabIndex,
                  margin:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  onTap: (index) {
                    controller.onTabChange(index);
                    controller.pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.linear);
                  })),
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onTabChange,
              children: [
                /// Activity Notifications Page with category filter
                _ActivityNotificationsPage(controller: controller),

                /// Admin Notifications Page
                Obx(() => _NotificationListWrapper<AdminNotificationData>(
                      isLoading: controller.isAdminNotification.value,
                      isEmpty: controller.adminNotifications.isEmpty,
                      items: controller.adminNotifications,
                      itemBuilder: (context, data) =>
                          SystemNotificationPage(data: data),
                      loadMore: controller.fetchAdminNotification,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ActivityNotificationsPage extends StatelessWidget {
  final NotificationScreenController controller;

  const _ActivityNotificationsPage({required this.controller});

  String _categoryLabel(String category) {
    return switch (category) {
      'all' => LKey.allNotifications.tr,
      'likes' => LKey.likesCategory.tr,
      'comments' => LKey.commentsCategory.tr,
      'mentions' => LKey.mentionsCategory.tr,
      'follows' => LKey.followsCategory.tr,
      _ => category,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category chips row
        Obx(() {
          // Read reactive vars synchronously to register Obx dependencies
          final selectedCat = controller.selectedCategory.value;
          final unreadMap = controller.unreadByCategory;
          return SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: NotificationScreenController.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category =
                      NotificationScreenController.categories[index];
                  final isSelected = selectedCat == category;
                  final unread = unreadMap[category] ?? 0;
                  return GestureDetector(
                    onTap: () => controller.onCategoryChange(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeAccentSolid(context)
                            : textLightGrey(context)
                                .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _categoryLabel(category),
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : textDarkGrey(context),
                            ),
                          ),
                          if (unread > 0 && category != 'all') ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: .3)
                                    : themeAccentSolid(context)
                                        .withValues(alpha: .2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$unread',
                                style: TextStyleCustom.outFitMedium500(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white
                                      : themeAccentSolid(context),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
        }),
        // Mark all as read + unread count
        Obx(() {
          if (controller.totalUnreadCount.value == 0) {
            return const SizedBox();
          }
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${controller.totalUnreadCount.value} ${LKey.unreadCount.tr}',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 12,
                    color: textLightGrey(context),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    final cat = controller.selectedCategory.value == 'all'
                        ? null
                        : controller.selectedCategory.value;
                    controller.markAllAsRead(category: cat);
                  },
                  child: Text(
                    LKey.markAllAsRead.tr,
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 12,
                      color: themeAccentSolid(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        // Notification list
        Expanded(
          child: Obx(() {
            final items = controller.activeNotificationsList;
            final isLoading = controller.isActiveLoading;
            return _NotificationListWrapper<ActivityNotification>(
              isLoading: isLoading,
              isEmpty: items.isEmpty,
              items: items,
              itemBuilder: (context, data) => ActivityNotificationPage(
                  data: data, controller: controller),
              loadMore: controller.loadMoreActiveCategory,
            );
          }),
        ),
      ],
    );
  }
}

class _NotificationListWrapper<T> extends StatelessWidget {
  final bool isLoading;
  final bool isEmpty;
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() loadMore;

  const _NotificationListWrapper({
    required this.isLoading,
    required this.isEmpty,
    required this.items,
    required this.itemBuilder,
    required this.loadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && isEmpty) {
      return const LoaderWidget();
    }

    return NoDataView(
      showShow: isEmpty,
      child: LoadMoreWidget(
        loadMore: loadMore,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return itemBuilder(context, items[index]);
          },
        ),
      ),
    );
  }
}
