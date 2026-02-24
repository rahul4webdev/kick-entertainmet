class CommentReactionsModel {
  bool? status;
  String? message;
  CommentReactionsData? data;

  CommentReactionsModel({this.status, this.message, this.data});

  CommentReactionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? CommentReactionsData.fromJson(json['data'])
        : null;
  }
}

class CommentReactionsData {
  Map<String, int>? reactions;
  List<String>? myReactions;

  CommentReactionsData({this.reactions, this.myReactions});

  CommentReactionsData.fromJson(Map<String, dynamic> json) {
    if (json['reactions'] != null) {
      reactions = Map<String, int>.from(
          (json['reactions'] as Map).map((k, v) => MapEntry(k.toString(), v as int)));
    }
    if (json['my_reactions'] != null) {
      myReactions = List<String>.from(json['my_reactions']);
    }
  }
}
