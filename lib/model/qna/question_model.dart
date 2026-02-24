class QuestionUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;
  bool isVerify;

  QuestionUser({
    this.id,
    this.username,
    this.fullname,
    this.profilePhoto,
    this.isVerify = false,
  });

  factory QuestionUser.fromJson(Map<String, dynamic> json) {
    return QuestionUser(
      id: json['id'],
      username: json['username'],
      fullname: json['fullname'],
      profilePhoto: json['profile_photo'],
      isVerify: json['is_verify'] ?? false,
    );
  }
}

class QuestionItem {
  int id;
  String question;
  String? answer;
  String? answeredAt;
  bool isPinned;
  bool isHidden;
  int likeCount;
  bool isLiked;
  String? createdAt;
  QuestionUser? askedBy;
  QuestionUser? profileUser;

  QuestionItem({
    required this.id,
    required this.question,
    this.answer,
    this.answeredAt,
    this.isPinned = false,
    this.isHidden = false,
    this.likeCount = 0,
    this.isLiked = false,
    this.createdAt,
    this.askedBy,
    this.profileUser,
  });

  factory QuestionItem.fromJson(Map<String, dynamic> json) {
    return QuestionItem(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'],
      answeredAt: json['answered_at'],
      isPinned: json['is_pinned'] ?? false,
      isHidden: json['is_hidden'] ?? false,
      likeCount: json['like_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'],
      askedBy: json['asked_by'] != null
          ? QuestionUser.fromJson(json['asked_by'])
          : null,
      profileUser: json['profile_user'] != null
          ? QuestionUser.fromJson(json['profile_user'])
          : null,
    );
  }

  bool get isAnswered => answer != null && answer!.isNotEmpty;

  void toggleLike() {
    if (isLiked) {
      isLiked = false;
      likeCount--;
    } else {
      isLiked = true;
      likeCount++;
    }
  }
}
