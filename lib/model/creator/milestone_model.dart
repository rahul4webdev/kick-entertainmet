class MilestoneModel {
  int? id;
  String? type;
  String? label;
  String? icon;
  int? dataId;
  Map<String, dynamic>? metadata;
  bool isSeen;
  bool isShared;
  String? createdAt;

  MilestoneModel({
    this.id,
    this.type,
    this.label,
    this.icon,
    this.dataId,
    this.metadata,
    this.isSeen = false,
    this.isShared = false,
    this.createdAt,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      icon: json['icon'],
      dataId: json['data_id'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      isSeen: json['is_seen'] == true,
      isShared: json['is_shared'] == true,
      createdAt: json['created_at'],
    );
  }

  /// Map icon string from backend to Flutter IconData name
  String get iconEmoji => switch (icon) {
        'star' => '\u2B50',
        'fire' => '\uD83D\uDD25',
        'trophy' => '\uD83C\uDFC6',
        'rocket' => '\uD83D\uDE80',
        'cake' => '\uD83C\uDF82',
        'pencil' => '\u270F\uFE0F',
        'grid' => '\uD83D\uDCF0',
        _ => '\u2B50',
      };
}
