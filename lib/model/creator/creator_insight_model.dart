class CreatorInsightListModel {
  bool? status;
  String? message;
  List<CreatorInsight>? data;
  int unreadCount;

  CreatorInsightListModel({
    this.status,
    this.message,
    this.data,
    this.unreadCount = 0,
  });

  CreatorInsightListModel.fromJson(dynamic json)
      : status = json['status'],
        message = json['message'],
        unreadCount = json['unread_count'] ?? 0,
        data = json['data'] != null
            ? (json['data'] as List)
                .map((e) => CreatorInsight.fromJson(e))
                .toList()
            : null;
}

class CreatorInsight {
  int? id;
  int? userId;
  String? insightType;
  String? title;
  String? body;
  Map<String, dynamic>? data;
  bool isRead;
  String? generatedAt;
  String? expiresAt;

  CreatorInsight({
    this.id,
    this.userId,
    this.insightType,
    this.title,
    this.body,
    this.data,
    this.isRead = false,
    this.generatedAt,
    this.expiresAt,
  });

  CreatorInsight.fromJson(dynamic json)
      : id = json['id'],
        userId = json['user_id'],
        insightType = json['insight_type'],
        title = json['title'],
        body = json['body'],
        data = json['data'] != null
            ? Map<String, dynamic>.from(json['data'])
            : null,
        isRead = json['is_read'] == true || json['is_read'] == 1,
        generatedAt = json['generated_at'],
        expiresAt = json['expires_at'];

  int get priority => data?['priority'] ?? 3;

  String get typeIcon {
    switch (insightType) {
      case 'growth':
        return '📈';
      case 'content':
        return '🎬';
      case 'engagement':
        return '💬';
      case 'timing':
        return '⏰';
      case 'audience':
        return '👥';
      default:
        return '💡';
    }
  }
}
