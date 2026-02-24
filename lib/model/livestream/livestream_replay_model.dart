class LivestreamReplayListModel {
  bool? status;
  String? message;
  List<LivestreamReplay>? data;

  LivestreamReplayListModel({this.status, this.message, this.data});

  LivestreamReplayListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(LivestreamReplay.fromJson(v));
      });
    }
  }
}

class LivestreamReplaySingleModel {
  bool? status;
  String? message;
  LivestreamReplay? data;

  LivestreamReplaySingleModel({this.status, this.message, this.data});

  LivestreamReplaySingleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? LivestreamReplay.fromJson(json['data']) : null;
  }
}

class LivestreamReplay {
  int? id;
  int? userId;
  String? roomId;
  String? title;
  String? thumbnail;
  String? recordingUrl;
  int? durationSeconds;
  int? peakViewers;
  int? totalLikes;
  int? totalGiftsCoins;
  int? viewCount;
  bool? isActive;
  String? createdAt;

  LivestreamReplay({
    this.id,
    this.userId,
    this.roomId,
    this.title,
    this.thumbnail,
    this.recordingUrl,
    this.durationSeconds,
    this.peakViewers,
    this.totalLikes,
    this.totalGiftsCoins,
    this.viewCount,
    this.isActive,
    this.createdAt,
  });

  LivestreamReplay.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    roomId = json['room_id'];
    title = json['title'];
    thumbnail = json['thumbnail'];
    recordingUrl = json['recording_url'];
    durationSeconds = json['duration_seconds'];
    peakViewers = json['peak_viewers'];
    totalLikes = json['total_likes'];
    totalGiftsCoins = json['total_gifts_coins'];
    viewCount = json['view_count'];
    isActive = json['is_active'] == true || json['is_active'] == 1;
    createdAt = json['created_at'];
  }

  String get durationFormatted {
    final d = Duration(seconds: durationSeconds ?? 0);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  bool get hasRecording => recordingUrl != null && recordingUrl!.isNotEmpty;
}
