import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/broadcast/broadcast_channel_model.dart';
import 'package:shortzz/model/broadcast/broadcast_message_model.dart';

class BroadcastService {
  static final BroadcastService instance = BroadcastService._();
  BroadcastService._();

  Map<String, String> get _chatHeaders => {
        'authtoken': SessionManager.instance.getAuthToken(),
        'Content-Type': 'application/json',
      };

  // ── Channel management (Laravel API) ──

  Future<BroadcastChannel?> createChannel({
    required String name,
    String? description,
    String? image,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.createChannel,
      param: {
        'name': name,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
      },
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return BroadcastChannel.fromJson(result['data']);
    }
    return null;
  }

  Future<BroadcastChannel?> updateChannel({
    required int channelId,
    String? name,
    String? description,
    String? image,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.updateChannel,
      param: {
        'channel_id': channelId,
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (image != null) 'image': image,
      },
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return BroadcastChannel.fromJson(result['data']);
    }
    return null;
  }

  Future<bool> deleteChannel({required int channelId}) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.deleteChannel,
      param: {'channel_id': channelId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> joinChannel({required int channelId}) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.joinChannel,
      param: {'channel_id': channelId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> leaveChannel({required int channelId}) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.leaveChannel,
      param: {'channel_id': channelId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> toggleMute({required int channelId}) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.toggleMute,
      param: {'channel_id': channelId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<List<BroadcastChannel>> fetchMyChannels({
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.fetchMyChannels,
      param: {'limit': limit, 'offset': offset},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((c) => BroadcastChannel.fromJson(c))
          .toList();
    }
    return [];
  }

  Future<List<BroadcastChannel>> fetchUserChannels({
    required int userId,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.fetchUserChannels,
      param: {'user_id': userId},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((c) => BroadcastChannel.fromJson(c))
          .toList();
    }
    return [];
  }

  Future<BroadcastChannel?> fetchChannelDetails({
    required int channelId,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.fetchChannelDetails,
      param: {'channel_id': channelId},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return BroadcastChannel.fromJson(result['data']);
    }
    return null;
  }

  Future<List<BroadcastMember>> fetchChannelMembers({
    required int channelId,
    int limit = 30,
    int offset = 0,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.fetchChannelMembers,
      param: {'channel_id': channelId, 'limit': limit, 'offset': offset},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((m) => BroadcastMember.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<List<BroadcastChannel>> searchChannels({
    String query = '',
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await ApiService.instance.call(
      url: WebService.broadcast.searchChannels,
      param: {'query': query, 'limit': limit, 'offset': offset},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((c) => BroadcastChannel.fromJson(c))
          .toList();
    }
    return [];
  }

  // ── Messages (Chat Service REST API) ──

  Future<List<BroadcastMessage>> fetchMessages({
    required int channelId,
    int? before,
  }) async {
    try {
      String url = WebService.chat.broadcastMessages(channelId);
      if (before != null) url += '?before=$before';

      final response = await http.get(Uri.parse(url), headers: _chatHeaders);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((j) => BroadcastMessage.fromJson(j)).toList();
    } catch (e) {
      Loggers.error('[BroadcastService] fetchMessages error: $e');
      return [];
    }
  }

  Future<Map<String, int>> fetchUnreadCounts() async {
    try {
      final response = await http.get(
        Uri.parse(WebService.chat.broadcastUnread),
        headers: _chatHeaders,
      );
      if (response.statusCode != 200) return {};

      final body = jsonDecode(response.body);
      if (body['status'] != true) return {};

      final Map<String, dynamic> data = body['data'] ?? {};
      return data.map((k, v) => MapEntry(k, int.tryParse(v.toString()) ?? 0));
    } catch (e) {
      Loggers.error('[BroadcastService] fetchUnreadCounts error: $e');
      return {};
    }
  }
}
