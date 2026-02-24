import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/broadcast/broadcast_channel_model.dart';
import 'package:shortzz/screen/broadcast_screen/broadcast_chat_screen.dart';
import 'package:shortzz/screen/broadcast_screen/broadcast_list_controller.dart';
import 'package:shortzz/screen/broadcast_screen/create_broadcast_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class BroadcastListScreen extends StatelessWidget {
  const BroadcastListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BroadcastListController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LKey.broadcastChannels.tr,
          style: TextStyleCustom.unboundedMedium500(
            fontSize: 15,
            color: textDarkGrey(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Get.to(() => const CreateBroadcastScreen());
              if (result == true) {
                controller.fetchMyChannels();
              }
            },
            icon: Icon(Icons.add_circle_outline, color: textDarkGrey(context)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab switcher: My Channels / Discover
          Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _TabChip(
                      label: LKey.myChannels.tr,
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () {
                        controller.onTabChanged(0);
                        controller.pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear);
                      },
                    ),
                    const SizedBox(width: 10),
                    _TabChip(
                      label: LKey.discoverChannels.tr,
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () {
                        controller.onTabChanged(1);
                        controller.pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.linear);
                      },
                    ),
                  ],
                ),
              )),
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onTabChanged,
              children: [
                _MyChannelsTab(controller: controller),
                _DiscoverTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? themeAccentSolid(context) : bgGrey(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 13,
            color: isSelected ? whitePure(context) : textDarkGrey(context),
          ),
        ),
      ),
    );
  }
}

class _MyChannelsTab extends StatelessWidget {
  final BroadcastListController controller;

  const _MyChannelsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.myChannels.isEmpty) {
        return const LoaderWidget();
      }
      return RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: NoDataView(
          showShow: controller.myChannels.isEmpty,
          title: LKey.noChannelsYet.tr,
          description: LKey.broadcastChannels.tr,
          child: ListView.builder(
            itemCount: controller.myChannels.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              return _ChannelListTile(
                channel: controller.myChannels[index],
                showUnread: true,
              );
            },
          ),
        ),
      );
    });
  }
}

class _DiscoverTab extends StatelessWidget {
  final BroadcastListController controller;

  const _DiscoverTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: controller.searchController,
            onSubmitted: (v) => controller.searchDiscoverChannels(v),
            decoration: InputDecoration(
              hintText: LKey.searchHere.tr,
              hintStyle: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
              ),
              prefixIcon: Icon(Icons.search, color: textLightGrey(context)),
              filled: true,
              fillColor: bgGrey(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isDiscoverLoading.value &&
                controller.discoverChannels.isEmpty) {
              return const LoaderWidget();
            }
            return NoDataView(
              showShow: controller.discoverChannels.isEmpty,
              title: LKey.noChannelsYet.tr,
              description: LKey.discoverChannels.tr,
              child: ListView.builder(
                itemCount: controller.discoverChannels.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final channel = controller.discoverChannels[index];
                  return _ChannelListTile(
                    channel: channel,
                    showUnread: false,
                    trailing: channel.isMember
                        ? Text(
                            LKey.joinChannel.tr,
                            style: TextStyleCustom.outFitMedium500(
                              fontSize: 13,
                              color: textLightGrey(context),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => controller.joinChannel(channel),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeAccentSolid(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                LKey.joinChannel.tr,
                                style: TextStyleCustom.outFitMedium500(
                                  fontSize: 13,
                                  color: whitePure(context),
                                ),
                              ),
                            ),
                          ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ChannelListTile extends StatelessWidget {
  final BroadcastChannel channel;
  final bool showUnread;
  final Widget? trailing;

  const _ChannelListTile({
    required this.channel,
    this.showUnread = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (channel.isMember) {
          Get.to(() => BroadcastChatScreen(channel: channel));
        }
      },
      leading: CustomImage(
        image: channel.image?.addBaseURL(),
        fullName: channel.name,
        size: const Size(48, 48),
      ),
      title: Text(
        channel.name ?? '',
        style: TextStyleCustom.outFitMedium500(
          fontSize: 15,
          color: textDarkGrey(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        showUnread && channel.lastMsg != null && channel.lastMsg!.isNotEmpty
            ? channel.lastMsg!
            : '${channel.memberCount ?? 0} ${LKey.channelMembers.tr}',
        style: TextStyleCustom.outFitRegular400(
          fontSize: 13,
          color: textLightGrey(context),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          (showUnread && channel.unreadCount > 0
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${channel.unreadCount}',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 12,
                      color: whitePure(context),
                    ),
                  ),
                )
              : null),
    );
  }
}
