import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/livestream/scheduled_live.dart';

class ScheduledLiveService {
  ScheduledLiveService._();
  static final ScheduledLiveService instance = ScheduledLiveService._();

  Future<ScheduledLive?> createScheduledLive({
    required String title,
    required DateTime scheduledAt,
    String? description,
    XFile? coverImage,
  }) async {
    final params = <String, dynamic>{
      'title': title,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
    };
    if (description != null && description.isNotEmpty) {
      params['description'] = description;
    }

    if (coverImage != null) {
      final result = await ApiService.instance.multiPartCallApi(
        url: WebService.scheduledLive.create,
        param: params,
        filesMap: {
          'cover_image': [coverImage]
        },
        fromJson: (json) => json,
      );
      if (result['status'] == true && result['data'] != null) {
        return ScheduledLive.fromJson(
            Map<String, dynamic>.from(result['data']));
      }
      return null;
    }

    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.create,
      param: params,
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return ScheduledLive.fromJson(Map<String, dynamic>.from(result['data']));
    }
    return null;
  }

  Future<List<ScheduledLive>> fetchScheduledLives({
    int limit = 20,
    int? lastItemId,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (lastItemId != null) params['last_item_id'] = lastItemId;

    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.fetch,
      param: params,
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((e) => ScheduledLive.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<ScheduledLive>> fetchMyScheduledLives() async {
    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.fetchMine,
      param: {},
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return (result['data'] as List)
          .map((e) => ScheduledLive.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<bool> toggleReminder({required int scheduledLiveId}) async {
    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.toggleReminder,
      param: {'scheduled_live_id': scheduledLiveId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<bool> cancelScheduledLive({required int scheduledLiveId}) async {
    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.cancel,
      param: {'scheduled_live_id': scheduledLiveId},
      fromJson: (json) => json,
    );
    return result['status'] == true;
  }

  Future<ScheduledLive?> updateScheduledLive({
    required int scheduledLiveId,
    String? title,
    String? description,
    DateTime? scheduledAt,
    XFile? coverImage,
  }) async {
    final params = <String, dynamic>{
      'scheduled_live_id': scheduledLiveId,
    };
    if (title != null) params['title'] = title;
    if (description != null) params['description'] = description;
    if (scheduledAt != null) {
      params['scheduled_at'] = scheduledAt.toUtc().toIso8601String();
    }

    if (coverImage != null) {
      final result = await ApiService.instance.multiPartCallApi(
        url: WebService.scheduledLive.update,
        param: params,
        filesMap: {
          'cover_image': [coverImage]
        },
        fromJson: (json) => json,
      );
      if (result['status'] == true && result['data'] != null) {
        return ScheduledLive.fromJson(
            Map<String, dynamic>.from(result['data']));
      }
      return null;
    }

    final result = await ApiService.instance.call(
      url: WebService.scheduledLive.update,
      param: params,
      fromJson: (json) => json,
    );
    if (result['status'] == true && result['data'] != null) {
      return ScheduledLive.fromJson(Map<String, dynamic>.from(result['data']));
    }
    return null;
  }
}
