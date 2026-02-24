import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/replay_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/livestream_replay_model.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveReplaysController extends BaseController {
  RxList<LivestreamReplay> replays = <LivestreamReplay>[].obs;
  RxBool isLoadingReplays = false.obs;
  final int? userId;
  final bool isMyReplays;

  LiveReplaysController({this.userId, this.isMyReplays = true});

  @override
  void onInit() {
    super.onInit();
    fetchReplays();
  }

  Future<void> fetchReplays() async {
    isLoadingReplays.value = true;
    try {
      final response = isMyReplays
          ? await ReplayService.instance.fetchMyReplays()
          : await ReplayService.instance.fetchUserReplays(userId: userId ?? 0);
      if (response.status == true && response.data != null) {
        replays.assignAll(response.data!);
      }
    } catch (_) {}
    isLoadingReplays.value = false;
  }

  Future<void> deleteReplay(LivestreamReplay replay) async {
    if (replay.id == null) return;
    try {
      final response =
          await ReplayService.instance.deleteReplay(replayId: replay.id!);
      if (response.status == true) {
        replays.removeWhere((r) => r.id == replay.id);
        showSnackBar(LKey.replayDeleted);
      }
    } catch (_) {}
  }
}

class LiveReplaysScreen extends StatelessWidget {
  final int? userId;
  final bool isMyReplays;

  const LiveReplaysScreen({
    super.key,
    this.userId,
    this.isMyReplays = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveReplaysController(
      userId: userId,
      isMyReplays: isMyReplays,
    ));

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          LKey.liveReplays,
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingReplays.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.replays.isEmpty) {
          return NoDataView(
            title: LKey.noReplays,
            description: LKey.noReplaysDesc,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchReplays,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.replays.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final replay = controller.replays[index];
              return _ReplayCard(
                replay: replay,
                isOwner: isMyReplays,
                onDelete: () {
                  Get.bottomSheet(ConfirmationSheet(
                    title: LKey.deleteReplayTitle,
                    description: LKey.deleteReplayDesc,
                    onTap: () => controller.deleteReplay(replay),
                  ));
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _ReplayCard extends StatelessWidget {
  final LivestreamReplay replay;
  final bool isOwner;
  final VoidCallback? onDelete;

  const _ReplayCard({
    required this.replay,
    required this.isOwner,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle_outline,
                  size: 20, color: ColorRes.themeAccentSolid),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  replay.title ?? 'Live Replay',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isOwner)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.delete_outline,
                      size: 18, color: ColorRes.likeRed),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 16,
            children: [
              _StatChip(
                icon: Icons.timer_outlined,
                label: replay.durationFormatted,
              ),
              _StatChip(
                icon: Icons.visibility_outlined,
                label: '${replay.peakViewers ?? 0}',
              ),
              _StatChip(
                icon: Icons.favorite_outline,
                label: '${replay.totalLikes ?? 0}',
              ),
              if ((replay.totalGiftsCoins ?? 0) > 0)
                _StatChip(
                  icon: Icons.monetization_on_outlined,
                  label: '${replay.totalGiftsCoins}',
                ),
            ],
          ),
          if ((replay.viewCount ?? 0) > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${replay.viewCount} ${LKey.views}',
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 12),
            ),
          ],
          if (replay.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              replay.createdAt ?? '',
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 14, color: textLightGrey(context)),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context), fontSize: 12),
        ),
      ],
    );
  }
}
