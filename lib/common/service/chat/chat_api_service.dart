import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/chat/chat_thread.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/model/chat/scheduled_message.dart';
import 'package:shortzz/model/livestream/app_user.dart';

class ChatApiService {
  static final ChatApiService instance = ChatApiService._();
  ChatApiService._();

  Map<String, String> get _headers => {
        'authtoken': SessionManager.instance.getAuthToken(),
        'Content-Type': 'application/json',
      };

  Future<List<ChatThread>> fetchConversations({int? before}) async {
    try {
      String url = WebService.chat.conversations;
      if (before != null) url += '?before=$before';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) {
        final thread = ChatThread.fromJson(json);
        if (json['chat_user'] != null) {
          thread.chatUser = AppUser.fromJson(json['chat_user']);
        }
        return thread;
      }).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchConversations error: $e');
      return [];
    }
  }

  Future<List<MessageData>> fetchMessages(String conversationId, {int? before}) async {
    try {
      String url = WebService.chat.messages(conversationId);
      if (before != null) url += '?before=$before';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => MessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchMessages error: $e');
      return [];
    }
  }

  Future<AppUser?> fetchChatUser(int userId) async {
    try {
      final url = WebService.chat.chatUser(userId);
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return AppUser.fromJson(body['data']);
    } catch (e) {
      Loggers.error('[ChatAPI] fetchChatUser error: $e');
      return null;
    }
  }

  Future<List<ScheduledMessageData>> fetchScheduledMessages(String conversationId) async {
    try {
      final url = WebService.chat.scheduledMessages(conversationId);
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => ScheduledMessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchScheduledMessages error: $e');
      return [];
    }
  }

  Future<bool> cancelScheduledMessage(String scheduledId) async {
    try {
      final url = WebService.chat.cancelScheduled(scheduledId);
      final response = await http.delete(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return false;

      final body = jsonDecode(response.body);
      return body['status'] == true;
    } catch (e) {
      Loggers.error('[ChatAPI] cancelScheduledMessage error: $e');
      return false;
    }
  }

  Future<List<MessageData>> searchMessages(String conversationId, String query) async {
    try {
      final url = WebService.chat.searchMessages(conversationId, query);
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => MessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] searchMessages error: $e');
      return [];
    }
  }

  Future<List<MessageData>> fetchMediaMessages(String conversationId, {String type = 'all', int? before}) async {
    try {
      String url = WebService.chat.mediaMessages(conversationId, type: type);
      if (before != null) url += '&before=$before';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => MessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchMediaMessages error: $e');
      return [];
    }
  }

  Future<List<MessageData>> fetchPinnedMessages(String conversationId) async {
    try {
      final url = WebService.chat.pinnedMessages(conversationId);
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => MessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchPinnedMessages error: $e');
      return [];
    }
  }

  Future<List<MessageData>> fetchStarredMessages({String? conversationId, int? before}) async {
    try {
      String url;
      if (conversationId != null) {
        url = WebService.chat.starredInConversation(conversationId);
      } else {
        url = WebService.chat.starred;
      }
      if (before != null) url += '?before=$before';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => MessageData.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[ChatAPI] fetchStarredMessages error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchGroupInfo(String groupId) async {
    try {
      final url = WebService.chat.groupInfo(groupId);
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return Map<String, dynamic>.from(body['data']);
    } catch (e) {
      Loggers.error('[ChatAPI] fetchGroupInfo error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> exportChat(String conversationId) async {
    try {
      final url = WebService.chat.exportChat(conversationId);
      final response = await http.post(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return Map<String, dynamic>.from(body['data']);
    } catch (e) {
      Loggers.error('[ChatAPI] exportChat error: $e');
      return null;
    }
  }
}
