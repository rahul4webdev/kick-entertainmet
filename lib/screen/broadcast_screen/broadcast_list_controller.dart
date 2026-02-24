import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/broadcast_service.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/model/broadcast/broadcast_channel_model.dart';

class BroadcastListController extends GetxController {
  final RxList<BroadcastChannel> myChannels = <BroadcastChannel>[].obs;
  final RxList<BroadcastChannel> discoverChannels = <BroadcastChannel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isDiscoverLoading = false.obs;
  final RxInt selectedTab = 0.obs;
  final TextEditingController searchController = TextEditingController();
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    fetchMyChannels();
    _listenBroadcastUpdates();
  }

  @override
  void onClose() {
    searchController.dispose();
    pageController.dispose();
    ChatSocketService.instance.off('s:broadcast_message');
    ChatSocketService.instance.off('s:broadcast_update');
    super.onClose();
  }

  void _listenBroadcastUpdates() {
    ChatSocketService.instance.on('s:broadcast_message', (data) {
      if (data is Map<String, dynamic>) {
        final channelId = data['channel_id'];
        final idx = myChannels.indexWhere((c) => c.id == channelId);
        if (idx != -1) {
          myChannels[idx].unreadCount++;
          myChannels[idx].lastMsg = data['text_message'] ?? '';
          myChannels[idx].lastMsgTime = data['id'];
          myChannels.refresh();
        }
      }
    });

    ChatSocketService.instance.on('s:broadcast_update', (data) {
      if (data is Map<String, dynamic>) {
        final channelId = data['channel_id'];
        final idx = myChannels.indexWhere((c) => c.id == channelId);
        if (idx != -1) {
          if (data['last_msg'] != null) {
            myChannels[idx].lastMsg = data['last_msg'];
          }
          if (data['last_msg_time'] != null) {
            myChannels[idx].lastMsgTime = data['last_msg_time'];
          }
          if (data['unread_count'] != null) {
            myChannels[idx].unreadCount = data['unread_count'];
          }
          myChannels.refresh();
        }
      }
    });
  }

  Future<void> fetchMyChannels() async {
    isLoading.value = true;
    final channels = await BroadcastService.instance.fetchMyChannels();
    myChannels.assignAll(channels);

    // Fetch unread counts
    final unreadCounts = await BroadcastService.instance.fetchUnreadCounts();
    for (final channel in myChannels) {
      final key = channel.id.toString();
      if (unreadCounts.containsKey(key)) {
        channel.unreadCount = unreadCounts[key] ?? 0;
      }
    }
    myChannels.refresh();
    isLoading.value = false;
  }

  Future<void> searchDiscoverChannels(String query) async {
    isDiscoverLoading.value = true;
    final channels = await BroadcastService.instance.searchChannels(query: query);
    discoverChannels.assignAll(channels);
    isDiscoverLoading.value = false;
  }

  Future<void> onRefresh() async {
    await fetchMyChannels();
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
    if (index == 1 && discoverChannels.isEmpty) {
      searchDiscoverChannels('');
    }
  }

  Future<void> joinChannel(BroadcastChannel channel) async {
    final success = await BroadcastService.instance.joinChannel(
      channelId: channel.id!,
    );
    if (success) {
      channel.isMember = true;
      channel.memberCount = (channel.memberCount ?? 0) + 1;
      discoverChannels.refresh();
      fetchMyChannels();
    }
  }
}
