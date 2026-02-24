import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/scheduled_live.dart';
import 'package:shortzz/screen/live_stream/scheduled_live_screen/scheduled_live_controller.dart';
import 'package:shortzz/screen/live_stream/scheduled_live_screen/create_scheduled_live_sheet.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ScheduledLiveScreen extends StatelessWidget {
  const ScheduledLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduledLiveController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          LKey.scheduledLives,
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.bottomSheet(
                CreateScheduledLiveSheet(controller: controller),
                isScrollControlled: true,
              );
            },
            icon: Icon(Icons.add_circle_outline,
                color: themeAccentSolid(context)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingList.value &&
            controller.scheduledLives.isEmpty) {
          return const LoaderWidget();
        }
        return NoDataView(
          showShow: !controller.isLoadingList.value &&
              controller.scheduledLives.isEmpty,
          title: LKey.noScheduledLives,
          description: LKey.noScheduledLivesDesc,
          child: RefreshIndicator(
            onRefresh: () async => controller.fetchAll(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.scheduledLives.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final live = controller.scheduledLives[index];
                return _ScheduledLiveCard(
                    live: live, controller: controller);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _ScheduledLiveCard extends StatelessWidget {
  final ScheduledLive live;
  final ScheduledLiveController controller;

  const _ScheduledLiveCard({required this.live, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = live.user;
    final dateStr = live.scheduledAt != null
        ? DateFormat('MMM d, yyyy – h:mm a').format(live.scheduledAt!.toLocal())
        : '';

    return Container(
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              CustomImage(
                size: const Size(44, 44),
                image: user?.profilePhoto?.addBaseURL(),
                fullName: user?.fullname,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user != null)
                      FullNameWithBlueTick(
                        username: user.username ?? '',
                        fontSize: 14,
                        iconSize: 16,
                        isVerify: user.isVerify,
                      ),
                    Text(
                      dateStr,
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: live.isCancelled
                      ? Colors.red.withValues(alpha: .1)
                      : Colors.orange.withValues(alpha: .1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  live.isCancelled
                      ? 'Cancelled'
                      : live.timeUntil,
                  style: TextStyleCustom.outFitMedium500(
                    color:
                        live.isCancelled ? Colors.red : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            live.title ?? '',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 16),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (live.description != null &&
              live.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              live.description!,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.notifications_outlined,
                  size: 16, color: textLightGrey(context)),
              const SizedBox(width: 4),
              Text(
                '${live.reminderCount ?? 0} ${LKey.reminders}',
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 12),
              ),
              const Spacer(),
              if (live.isUpcoming && !live.isCancelled)
                Obx(() {
                  // trigger rebuild on list refresh
                  controller.scheduledLives.length;
                  final reminded = live.isReminded ?? false;
                  return InkWell(
                    onTap: () => controller.toggleReminder(live),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: ShapeDecoration(
                        color: reminded
                            ? themeAccentSolid(context)
                            : bgMediumGrey(context),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 8, cornerSmoothing: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Icon(
                            reminded
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            size: 14,
                            color: reminded
                                ? whitePure(context)
                                : textDarkGrey(context),
                          ),
                          Text(
                            reminded
                                ? LKey.removeReminder
                                : LKey.setReminder,
                            style: TextStyleCustom.outFitMedium500(
                              color: reminded
                                  ? whitePure(context)
                                  : textDarkGrey(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }
}
