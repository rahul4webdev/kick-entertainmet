class PollModel {
  bool? status;
  String? message;
  Poll? data;

  PollModel({this.status, this.message, this.data});

  PollModel.fromJson(dynamic json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Poll.fromJson(json['data']) : null;
  }
}

class Poll {
  int? id;
  int? postId;
  String? question;
  int pollType;
  bool allowMultiple;
  String? endsAt;
  bool isClosed;
  int totalVotes;
  String? createdAt;
  List<PollOption> options;
  int? userVoteOptionId;

  Poll({
    this.id,
    this.postId,
    this.question,
    this.pollType = 0,
    this.allowMultiple = false,
    this.endsAt,
    this.isClosed = false,
    this.totalVotes = 0,
    this.createdAt,
    this.options = const [],
    this.userVoteOptionId,
  });

  Poll.fromJson(dynamic json)
      : id = json['id'],
        postId = json['post_id'],
        question = json['question'],
        pollType = json['poll_type'] ?? 0,
        allowMultiple = json['allow_multiple'] == true || json['allow_multiple'] == 1,
        endsAt = json['ends_at'],
        isClosed = json['is_closed'] == true || json['is_closed'] == 1,
        totalVotes = json['total_votes'] ?? 0,
        createdAt = json['created_at'],
        options = json['options'] != null
            ? (json['options'] as List).map((e) => PollOption.fromJson(e)).toList()
            : [],
        userVoteOptionId = json['user_vote_option_id'];

  bool get hasVoted => userVoteOptionId != null;
  bool get isExpired => endsAt != null && DateTime.tryParse(endsAt!)?.isBefore(DateTime.now()) == true;
  bool get isActive => !isClosed && !isExpired;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'question': question,
      'poll_type': pollType,
      'allow_multiple': allowMultiple,
      'ends_at': endsAt,
      'is_closed': isClosed,
      'total_votes': totalVotes,
      'created_at': createdAt,
      'options': options.map((e) => e.toJson()).toList(),
      'user_vote_option_id': userVoteOptionId,
    };
  }
}

class PollOption {
  int? id;
  int? pollId;
  String? optionText;
  String? optionImage;
  int voteCount;
  int sortOrder;

  PollOption({
    this.id,
    this.pollId,
    this.optionText,
    this.optionImage,
    this.voteCount = 0,
    this.sortOrder = 0,
  });

  PollOption.fromJson(dynamic json)
      : id = json['id'],
        pollId = json['poll_id'],
        optionText = json['option_text'],
        optionImage = json['option_image'],
        voteCount = json['vote_count'] ?? 0,
        sortOrder = json['sort_order'] ?? 0;

  double votePercentage(int totalVotes) {
    if (totalVotes <= 0) return 0;
    return voteCount / totalVotes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_text': optionText,
      'option_image': optionImage,
      'vote_count': voteCount,
      'sort_order': sortOrder,
    };
  }
}
