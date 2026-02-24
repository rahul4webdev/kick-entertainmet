import 'package:shortzz/model/user_model/user_model.dart';

class UserNote {
  int? id;
  int? userId;
  String? content;
  String? emoji;
  DateTime? expiresAt;
  DateTime? createdAt;
  User? user;

  UserNote({
    this.id,
    this.userId,
    this.content,
    this.emoji,
    this.expiresAt,
    this.createdAt,
    this.user,
  });

  factory UserNote.fromJson(Map<String, dynamic> json) {
    return UserNote(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      emoji: json['emoji'],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());
}
