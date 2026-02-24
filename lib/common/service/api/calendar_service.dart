import 'dart:convert';

import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';

class CalendarEvent {
  final int id;
  final String? description;
  final int? postType;
  final String? thumbnail;
  final int? views;
  final int? likes;
  final int? comments;
  final String calendarStatus; // published, scheduled, draft
  final String calendarDate;
  final String? scheduledAt;
  final String? createdAt;

  CalendarEvent({
    required this.id,
    this.description,
    this.postType,
    this.thumbnail,
    this.views,
    this.likes,
    this.comments,
    required this.calendarStatus,
    required this.calendarDate,
    this.scheduledAt,
    this.createdAt,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] ?? 0,
      description: json['description'],
      postType: json['post_type'],
      thumbnail: json['thumbnail'],
      views: json['views'],
      likes: json['likes'],
      comments: json['comments'],
      calendarStatus: json['calendar_status'] ?? 'published',
      calendarDate: json['calendar_date'] ?? '',
      scheduledAt: json['scheduled_at'],
      createdAt: json['created_at'],
    );
  }
}

class CalendarDay {
  final String date;
  final int count;
  final List<CalendarEvent> events;

  CalendarDay({required this.date, required this.count, required this.events});

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
      events: (json['events'] as List?)
              ?.map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}

class CalendarSummary {
  final int published;
  final int scheduled;
  final int drafts;
  final int total;

  CalendarSummary({
    required this.published,
    required this.scheduled,
    required this.drafts,
    required this.total,
  });

  factory CalendarSummary.fromJson(Map<String, dynamic> json) {
    return CalendarSummary(
      published: json['published'] ?? 0,
      scheduled: json['scheduled'] ?? 0,
      drafts: json['drafts'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class CalendarData {
  final int year;
  final int month;
  final CalendarSummary summary;
  final List<CalendarDay> days;

  CalendarData({
    required this.year,
    required this.month,
    required this.summary,
    required this.days,
  });
}

class BestTimeSlot {
  final int hour;
  final int day;
  final double avgViews;
  final double avgLikes;
  final double avgEngagementRate;
  final int sampleCount;

  BestTimeSlot({
    required this.hour,
    required this.day,
    required this.avgViews,
    required this.avgLikes,
    required this.avgEngagementRate,
    required this.sampleCount,
  });

  factory BestTimeSlot.fromJson(Map<String, dynamic> json) {
    return BestTimeSlot(
      hour: json['hour'] ?? 0,
      day: json['day'] ?? 0,
      avgViews: (json['avg_views'] ?? 0).toDouble(),
      avgLikes: (json['avg_likes'] ?? 0).toDouble(),
      avgEngagementRate: (json['avg_engagement_rate'] ?? 0).toDouble(),
      sampleCount: json['sample_count'] ?? 0,
    );
  }
}

class HourlyAnalytics {
  final int hour;
  final double avgEngagementRate;
  final double avgViews;
  final int sampleCount;

  HourlyAnalytics({
    required this.hour,
    required this.avgEngagementRate,
    required this.avgViews,
    required this.sampleCount,
  });

  factory HourlyAnalytics.fromJson(Map<String, dynamic> json) {
    return HourlyAnalytics(
      hour: json['hour'] ?? 0,
      avgEngagementRate: (json['avg_engagement_rate'] ?? 0).toDouble(),
      avgViews: (json['avg_views'] ?? 0).toDouble(),
      sampleCount: json['sample_count'] ?? 0,
    );
  }
}

class DailyAnalytics {
  final int day;
  final String dayName;
  final double avgEngagementRate;
  final double avgViews;
  final int sampleCount;

  DailyAnalytics({
    required this.day,
    required this.dayName,
    required this.avgEngagementRate,
    required this.avgViews,
    required this.sampleCount,
  });

  factory DailyAnalytics.fromJson(Map<String, dynamic> json) {
    return DailyAnalytics(
      day: json['day'] ?? 0,
      dayName: json['day_name'] ?? '',
      avgEngagementRate: (json['avg_engagement_rate'] ?? 0).toDouble(),
      avgViews: (json['avg_views'] ?? 0).toDouble(),
      sampleCount: json['sample_count'] ?? 0,
    );
  }
}

class BestTimeData {
  final List<BestTimeSlot> bestTimes;
  final List<HourlyAnalytics> hourly;
  final List<DailyAnalytics> daily;
  final int totalSamples;

  BestTimeData({
    required this.bestTimes,
    required this.hourly,
    required this.daily,
    required this.totalSamples,
  });
}

class _CalendarResponse {
  final bool status;
  final CalendarData? data;

  _CalendarResponse({required this.status, this.data});

  factory _CalendarResponse.fromJson(Map<String, dynamic> json) {
    CalendarData? data;
    if (json['status'] == true && json['data'] != null) {
      final d = json['data'];
      data = CalendarData(
        year: d['year'] ?? 0,
        month: d['month'] ?? 0,
        summary: CalendarSummary.fromJson(
            Map<String, dynamic>.from(d['summary'] ?? {})),
        days: (d['days'] as List?)
                ?.map(
                    (e) => CalendarDay.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
      );
    }
    return _CalendarResponse(status: json['status'] == true, data: data);
  }
}

class _BestTimeResponse {
  final bool status;
  final BestTimeData? data;

  _BestTimeResponse({required this.status, this.data});

  factory _BestTimeResponse.fromJson(Map<String, dynamic> json) {
    BestTimeData? data;
    if (json['status'] == true && json['data'] != null) {
      final d = json['data'];
      data = BestTimeData(
        bestTimes: (d['best_times'] as List?)
                ?.map((e) =>
                    BestTimeSlot.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        hourly: (d['hourly'] as List?)
                ?.map((e) =>
                    HourlyAnalytics.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        daily: (d['daily'] as List?)
                ?.map((e) =>
                    DailyAnalytics.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [],
        totalSamples: d['total_samples'] ?? 0,
      );
    }
    return _BestTimeResponse(status: json['status'] == true, data: data);
  }
}

class _SimpleResponse {
  final bool status;
  final String? message;
  final Map<String, dynamic>? data;

  _SimpleResponse({required this.status, this.message, this.data});

  factory _SimpleResponse.fromJson(Map<String, dynamic> json) {
    return _SimpleResponse(
      status: json['status'] == true,
      message: json['message'],
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}

class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  Future<CalendarData?> fetchCalendarEvents({
    required int year,
    required int month,
  }) async {
    try {
      final result = await ApiService.instance.call(
        url: WebService.calendar.fetchCalendarEvents,
        fromJson: _CalendarResponse.fromJson,
        param: {'year': year, 'month': month},
      );
      return result.data;
    } catch (_) {}
    return null;
  }

  Future<BestTimeData?> fetchBestTimeToPost() async {
    try {
      final result = await ApiService.instance.call(
        url: WebService.calendar.fetchBestTimeToPost,
        fromJson: _BestTimeResponse.fromJson,
      );
      return result.data;
    } catch (_) {}
    return null;
  }

  Future<bool> updateDraftDate({
    required int postId,
    String? draftDate,
  }) async {
    try {
      final result = await ApiService.instance.call(
        url: WebService.calendar.updateDraftDate,
        fromJson: _SimpleResponse.fromJson,
        param: {
          'post_id': postId,
          if (draftDate != null) 'draft_date': draftDate,
        },
      );
      return result.status;
    } catch (_) {}
    return false;
  }

  Future<Map<String, int>?> bulkSchedule({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final result = await ApiService.instance.call(
        url: WebService.calendar.bulkSchedule,
        fromJson: _SimpleResponse.fromJson,
        param: {'items': jsonEncode(items)},
      );
      if (result.status && result.data != null) {
        return {
          'scheduled': result.data!['scheduled'] ?? 0,
          'failed': result.data!['failed'] ?? 0,
        };
      }
    } catch (_) {}
    return null;
  }
}
