import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_toggle.dart';
import 'package:shortzz/screen/instagram_import_screen/instagram_import_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class InstagramImportScreen extends StatelessWidget {
  const InstagramImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InstagramImportScreenController());

    return Scaffold(
      backgroundColor: bgLightGrey(context),
      body: Column(
        children: [
          CustomAppBar(
            title: 'Import from Instagram',
            rowWidget: Obx(() {
              if (!controller.isConnected.value) {
                return const SizedBox(width: 48);
              }
              return IconButton(
                icon: Icon(Icons.refresh, color: textDarkGrey(context)),
                onPressed: controller.refreshData,
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (!controller.isConnected.value) {
                return _buildConnectView(context, controller);
              }
              if (controller.tokenExpired.value) {
                return _buildReconnectView(context, controller);
              }
              return _buildMediaView(context, controller);
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!controller.isConnected.value) return const SizedBox();
        if (controller.selectedCount == 0) return const SizedBox();
        if (controller.isImporting.value) {
          return FloatingActionButton.extended(
            onPressed: null,
            backgroundColor:
                themeAccentSolid(context).withValues(alpha: 0.5),
            label: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          );
        }
        return FloatingActionButton.extended(
          onPressed: controller.importSelected,
          backgroundColor: themeAccentSolid(context),
          icon: const Icon(Icons.download, color: Colors.white),
          label: Text(
            'Import ${controller.selectedCount} Selected',
            style: TextStyleCustom.outFitSemiBold600(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConnectView(
      BuildContext context, InstagramImportScreenController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AssetRes.icInstagram,
              width: 80,
              height: 80,
              color: themeAccentSolid(context),
            ),
            const SizedBox(height: 24),
            Text(
              'Connect your Instagram',
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 20,
                color: textDarkGrey(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Import your Instagram videos and reels directly to your profile. Business or Creator account required.',
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 14,
                color: textLightGrey(context),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.connectInstagram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Connect Instagram',
                  style: TextStyleCustom.outFitSemiBold600(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconnectView(
      BuildContext context, InstagramImportScreenController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded,
                size: 64, color: Colors.orange[400]),
            const SizedBox(height: 24),
            Text(
              'Session Expired',
              style: TextStyleCustom.outFitSemiBold600(
                fontSize: 20,
                color: textDarkGrey(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Instagram connection has expired. Please reconnect to continue importing videos.',
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 14,
                color: textLightGrey(context),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.connectInstagram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 1,
                    ),
                  ),
                ),
                child: Text(
                  'Reconnect Instagram',
                  style: TextStyleCustom.outFitSemiBold600(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaView(
      BuildContext context, InstagramImportScreenController controller) {
    return Column(
      children: [
        _buildConnectionBanner(context, controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingMedia.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.mediaList.isEmpty) {
              return Center(
                child: Text(
                  'No videos found on your Instagram',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 15,
                    color: textLightGrey(context),
                  ),
                ),
              );
            }
            return _buildMediaGrid(context, controller);
          }),
        ),
      ],
    );
  }

  Widget _buildConnectionBanner(
      BuildContext context, InstagramImportScreenController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: bgLightGrey(context),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(() => Text(
                      'Connected${controller.instagramUserId.value.isNotEmpty ? ' (${controller.instagramUserId.value})' : ''}',
                      style: TextStyleCustom.outFitRegular400(
                        fontSize: 14,
                        color: textDarkGrey(context),
                      ),
                    )),
              ),
              TextButton(
                onPressed: controller.disconnectInstagram,
                child: Text(
                  'Disconnect',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-sync every 6 hours',
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 14,
                  color: textDarkGrey(context),
                ),
              ),
              CustomToggle(
                isOn: controller.autoSyncEnabled,
                onChanged: controller.toggleAutoSync,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            if (controller.mediaList.isNotEmpty) {
              final selCount = controller.selectedCount;
              final totalCount = controller.mediaList.length;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$totalCount videos found${selCount > 0 ? ' ($selCount selected)' : ''}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 13,
                      color: textLightGrey(context),
                    ),
                  ),
                  if (selCount > 0)
                    GestureDetector(
                      onTap: controller.deselectAll,
                      child: Text(
                        'Deselect All',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 13,
                          color: themeAccentSolid(context),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: controller.selectAll,
                      child: Text(
                        'Select All',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 13,
                          color: themeAccentSolid(context),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(
      BuildContext context, InstagramImportScreenController controller) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !controller.isLoadingMore.value &&
            controller.nextCursor != null) {
          controller.fetchMedia(loadMore: true);
        }
        return false;
      },
      child: Obx(() => GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: controller.mediaList.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.mediaList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return _buildMediaTile(context, controller, index);
            },
          )),
    );
  }

  Widget _buildMediaTile(BuildContext context,
      InstagramImportScreenController controller, int index) {
    final media = controller.mediaList[index];
    final isImported = media.isImported == true;
    final isSelected = media.isSelected;

    return GestureDetector(
      onTap: () => controller.toggleSelection(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: media.thumbnailUrl ?? media.mediaUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: bgLightGrey(context),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              color: bgLightGrey(context),
              child: Icon(Icons.broken_image,
                  color: textLightGrey(context), size: 32),
            ),
          ),
          if (isSelected || isImported)
            Container(
              color: isImported
                  ? Colors.black.withValues(alpha: 0.5)
                  : themeAccentSolid(context).withValues(alpha: 0.3),
            ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                media.mediaType == 'REELS' ? 'Reel' : 'Video',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 6,
            right: 6,
            child: Icon(Icons.play_circle_outline,
                color: Colors.white70, size: 20),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: isImported
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Imported',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeAccentSolid(context)
                          : Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? themeAccentSolid(context)
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                        : null,
                  ),
          ),
          if (media.caption != null && media.caption!.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Text(
                  media.caption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
