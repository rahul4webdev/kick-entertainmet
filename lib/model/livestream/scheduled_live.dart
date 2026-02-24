import 'package:shortzz/model/user_model/user_model.dart';

class ScheduledLive {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? coverImage;
  DateTime? scheduledAt;
  int? status; // 1=upcoming, 2=live, 3=completed, 4=cancelled
  int? reminderCount;
  bool? isReminded;
  User? user;
  DateTime? createdAt;

  ScheduledLive({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.coverImage,
    this.scheduledAt,
    this.status,
    this.reminderCount,
    this.isReminded,
    this.user,
    this.createdAt,
  });

  ScheduledLive.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    coverImage = json['cover_image'];
    scheduledAt = json['scheduled_at'] != null
        ? DateTime.tryParse(json['scheduled_at'])
        : null;
    status = json['status'];
    reminderCount = json['reminder_count'];
    isReminded = json['is_reminded'] == true;
    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    }
    createdAt = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'])
        : null;
  }

  bool get isUpcoming => status == 1;
  bool get isCancelled => status == 4;

  String get timeUntil {
    if (scheduledAt == null) return '';
    final diff = scheduledAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Now';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Soon';
  }
}
