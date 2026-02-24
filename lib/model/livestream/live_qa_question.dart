class LiveQAQuestion {
  String? id;
  int? userId;
  String? username;
  String? question;
  String? answer;
  int? createdAt;
  bool? isPinned;
  bool? isAnswered;
  int? upvoteCount;
  List<int>? upvoterIds;

  LiveQAQuestion({
    this.id,
    this.userId,
    this.username,
    this.question,
    this.answer,
    this.createdAt,
    this.isPinned,
    this.isAnswered,
    this.upvoteCount,
    this.upvoterIds,
  });

  LiveQAQuestion.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    username = json['username'];
    question = json['question'];
    answer = json['answer'];
    createdAt = json['created_at'];
    isPinned = json['is_pinned'] ?? false;
    isAnswered = json['is_answered'] ?? false;
    upvoteCount = json['upvote_count'] ?? 0;
    if (json['upvoter_ids'] != null) {
      upvoterIds = List<int>.from(json['upvoter_ids']);
    } else {
      upvoterIds = [];
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'question': question,
        'answer': answer,
        'created_at': createdAt,
        'is_pinned': isPinned,
        'is_answered': isAnswered,
        'upvote_count': upvoteCount,
        'upvoter_ids': upvoterIds,
      };

  bool hasUpvoted(int uid) => upvoterIds?.contains(uid) == true;
}
