import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/livestream/livestream.dart';

class LivestreamApiService {
  static final LivestreamApiService instance = LivestreamApiService._();
  LivestreamApiService._();

  Map<String, String> get _headers => {
        'authtoken': SessionManager.instance.getAuthToken(),
        'Content-Type': 'application/json',
      };

  /// Fetch all active livestreams (for search screen)
  Future<List<Livestream>> fetchActiveLivestreams() async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.active),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      final List data = body['data'] ?? [];
      return data.map((json) => Livestream.fromJson(json)).toList();
    } catch (e) {
      Loggers.error('[LiveAPI] fetchActiveLivestreams error: $e');
      return [];
    }
  }

  /// Fetch single livestream with user states
  Future<Map<String, dynamic>?> fetchLivestream(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.room(roomId)),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return body['data'];
    } catch (e) {
      Loggers.error('[LiveAPI] fetchLivestream error: $e');
      return null;
    }
  }

  /// Fetch user states for a room
  Future<List<Map<String, dynamic>>> fetchUserStates(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.users(roomId)),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    } catch (e) {
      Loggers.error('[LiveAPI] fetchUserStates error: $e');
      return [];
    }
  }

  /// Fetch paginated comments for a room
  Future<List<Map<String, dynamic>>> fetchComments(String roomId, {int limit = 50, int? before}) async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.comments(roomId, limit: limit, before: before)),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    } catch (e) {
      Loggers.error('[LiveAPI] fetchComments error: $e');
      return [];
    }
  }

  /// Fetch active poll for a room
  Future<Map<String, dynamic>?> fetchActivePoll(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.poll(roomId)),
        headers: _headers,
      );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return body['data'];
    } catch (e) {
      Loggers.error('[LiveAPI] fetchActivePoll error: $e');
      return null;
    }
  }

  /// Fetch Q&A questions for a room
  Future<List<Map<String, dynamic>>> fetchQuestions(String roomId, {int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse(WebService.live.questions(roomId, limit: limit)),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body);
      if (body['status'] != true) return [];

      return List<Map<String, dynamic>>.from(body['data'] ?? []);
    } catch (e) {
      Loggers.error('[LiveAPI] fetchQuestions error: $e');
      return [];
    }
  }

  /// Create/update dummy livestream
  Future<Map<String, dynamic>?> createDummyLivestream(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(WebService.live.dummy),
        headers: _headers,
        body: jsonEncode(data),
      );
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;

      return body['data'];
    } catch (e) {
      Loggers.error('[LiveAPI] createDummyLivestream error: $e');
      return null;
    }
  }

  /// Delete dummy livestream
  Future<bool> deleteDummyLivestream(String roomId) async {
    try {
      final response = await http.delete(
        Uri.parse(WebService.live.deleteDummy(roomId)),
        headers: _headers,
      );
      if (response.statusCode != 200) return false;

      final body = jsonDecode(response.body);
      return body['status'] == true;
    } catch (e) {
      Loggers.error('[LiveAPI] deleteDummyLivestream error: $e');
      return false;
    }
  }
}
