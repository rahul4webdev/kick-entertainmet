import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/broadcast_service.dart';
import 'package:shortzz/common/service/chat/chat_socket_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/broadcast/broadcast_channel_model.dart';
import 'package:shortzz/model/broadcast/broadcast_message_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class BroadcastChatScreen extends StatefulWidget {
  final BroadcastChannel channel;

  const BroadcastChatScreen({super.key, required this.channel});

  @override
  State<BroadcastChatScreen> createState() => _BroadcastChatScreenState();
}

class _BroadcastChatScreenState extends State<BroadcastChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<BroadcastMessage> _messages = [];
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _markAsRead();
    _listenForNewMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ChatSocketService.instance.off('s:broadcast_message');
    super.dispose();
  }

  void _listenForNewMessages() {
    ChatSocketService.instance.on('s:broadcast_message', (data) {
      if (data is Map<String, dynamic> &&
          data['channel_id'] == widget.channel.id) {
        final msg = BroadcastMessage.fromJson(data);
        setState(() {
          _messages.insert(0, msg);
        });
        _markAsRead();
      }
    });
  }

  void _markAsRead() {
    ChatSocketService.instance.emit('c:broadcast_read', {
      'channel_id': widget.channel.id,
    });
  }

  Future<void> _fetchMessages() async {
    final msgs = await BroadcastService.instance.fetchMessages(
      channelId: widget.channel.id!,
    );
    setState(() {
      _messages.addAll(msgs);
      _isLoading = false;
      _hasMore = msgs.length >= 40;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        _hasMore &&
        !_isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_messages.isEmpty) return;
    setState(() => _isLoading = true);
    final lastId = _messages.last.id;
    final msgs = await BroadcastService.instance.fetchMessages(
      channelId: widget.channel.id!,
      before: lastId,
    );
    setState(() {
      _messages.addAll(msgs);
      _isLoading = false;
      _hasMore = msgs.length >= 40;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _messageController.clear();

    ChatSocketService.instance.emit('c:broadcast_send', {
      'channel_id': widget.channel.id,
      'message_type': 'text',
      'text_message': text,
    });

    setState(() => _isSending = false);
  }

  Future<void> _onLeaveChannel() async {
    final success = await BroadcastService.instance.leaveChannel(
      channelId: widget.channel.id!,
    );
    if (success) {
      Get.back();
    }
  }

  Future<void> _onToggleMute() async {
    final success = await BroadcastService.instance.toggleMute(
      channelId: widget.channel.id!,
    );
    if (success) {
      setState(() {
        widget.channel.isMuted = !widget.channel.isMuted;
      });
      Get.snackbar(
        widget.channel.isMuted ? LKey.muted.tr : LKey.unmuted.tr,
        widget.channel.name ?? '',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
        title: Row(
          children: [
            CustomImage(
              image: widget.channel.image?.addBaseURL(),
              fullName: widget.channel.name,
              size: const Size(32, 32),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.channel.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      fontSize: 15,
                      color: textDarkGrey(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.channel.memberCount ?? 0} ${LKey.channelMembers.tr}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: textLightGrey(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: textDarkGrey(context)),
            onSelected: (value) {
              if (value == 'mute') _onToggleMute();
              if (value == 'leave') _onLeaveChannel();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mute',
                child: Text(
                  widget.channel.isMuted ? LKey.unmuted.tr : LKey.muted.tr,
                ),
              ),
              if (!widget.channel.isCreator)
                PopupMenuItem(
                  value: 'leave',
                  child: Text(LKey.leaveChannel.tr),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(height: 0.5, color: textLightGrey(context)),
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: _messages.length,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemBuilder: (context, index) {
                      return _MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          if (widget.channel.isCreator) _buildMessageInput(context),
          if (!widget.channel.isCreator) _buildReadOnlyBar(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          border: Border(
            top: BorderSide(color: textLightGrey(context), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: LKey.typeMessage.tr,
                  hintStyle: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                  ),
                  filled: true,
                  fillColor: bgGrey(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: whitePure(context), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          border: Border(
            top: BorderSide(color: textLightGrey(context), width: 0.5),
          ),
        ),
        child: Text(
          LKey.onlyCreatorCanSend.tr,
          textAlign: TextAlign.center,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 13,
            color: textLightGrey(context),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final BroadcastMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final time = message.id != null
        ? DateTime.fromMillisecondsSinceEpoch(message.id!)
        : DateTime.now();
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgGrey(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.textMessage != null &&
                  message.textMessage!.isNotEmpty)
                Text(
                  message.textMessage!,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 15,
                    color: textDarkGrey(context),
                  ),
                ),
              if (message.imageMessage != null &&
                  message.imageMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      message.imageMessage!,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                timeStr,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 11,
                  color: textLightGrey(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
