class LivePoll {
  String? id;
  int? hostId;
  String? question;
  List<PollOption>? options;
  int? createdAt;
  bool? isActive;

  LivePoll({
    this.id,
    this.hostId,
    this.question,
    this.options,
    this.createdAt,
    this.isActive,
  });

  LivePoll.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hostId = json['host_id'];
    question = json['question'];
    createdAt = json['created_at'];
    isActive = json['is_active'] ?? true;
    if (json['options'] != null) {
      options = [];
      (json['options'] as List).forEach((v) {
        options!.add(PollOption.fromJson(Map<String, dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'host_id': hostId,
        'question': question,
        'options': options?.map((e) => e.toJson()).toList(),
        'created_at': createdAt,
        'is_active': isActive,
      };

  int get totalVotes {
    if (options == null) return 0;
    return options!.fold(0, (sum, o) => sum + (o.voterIds?.length ?? 0));
  }

  bool hasVoted(int userId) {
    if (options == null) return false;
    return options!.any((o) => o.voterIds?.contains(userId) == true);
  }

  int? votedOptionIndex(int userId) {
    if (options == null) return null;
    for (int i = 0; i < options!.length; i++) {
      if (options![i].voterIds?.contains(userId) == true) return i;
    }
    return null;
  }
}

class PollOption {
  String? text;
  List<int>? voterIds;

  PollOption({this.text, this.voterIds});

  PollOption.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['voter_ids'] != null) {
      voterIds = List<int>.from(json['voter_ids']);
    } else {
      voterIds = [];
    }
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'voter_ids': voterIds,
      };
}
