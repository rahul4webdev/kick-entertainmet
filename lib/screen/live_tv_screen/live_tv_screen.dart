import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/live/live_channel_model.dart';
import 'package:shortzz/screen/live_tv_screen/live_tv_player_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  final RxList<LiveChannel> _channels = <LiveChannel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  Future<void> _fetchChannels() async {
    _isLoading.value = true;
    try {
      final result = await PostService.instance.fetchLiveChannels(limit: 50);
      if (result.status == true && result.data != null) {
        _channels.value = result.data!;
      }
    } catch (_) {}
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackPure(context),
      appBar: AppBar(
        backgroundColor: blackPure(context),
        title: Text('Live TV', style: TextStyle(color: whitePure(context), fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: whitePure(context)),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(child: CupertinoActivityIndicator(color: textLightGrey(context)));
        }

        if (_channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.live_tv_rounded, size: 64, color: textLightGrey(context)),
                const SizedBox(height: 12),
                Text('No live channels available', style: TextStyle(color: textLightGrey(context), fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchChannels,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _channels.length,
            itemBuilder: (context, index) {
              final channel = _channels[index];
              return _ChannelCard(
                channel: channel,
                onTap: () {
                  Get.to(() => LiveTvPlayerScreen(channel: channel));
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final LiveChannel channel;
  final VoidCallback onTap;

  const _ChannelCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Channel logo
            if (channel.channelLogo != null && channel.channelLogo!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  channel.channelLogo!.addBaseURL(),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _defaultLogo(),
                ),
              )
            else
              _defaultLogo(),

            const SizedBox(height: 10),

            // Channel name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                channel.channelName ?? '',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Live badge + category
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (channel.isLive == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                if (channel.isLive == true && channel.category != null) const SizedBox(width: 6),
                if (channel.category != null)
                  Text(
                    channel.category!,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.live_tv, color: Colors.white54, size: 32),
    );
  }
}
