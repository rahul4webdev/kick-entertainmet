class TipAmountsModel {
  bool? status;
  String? message;
  List<TipAmount>? data;

  TipAmountsModel({this.status, this.message, this.data});

  TipAmountsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List).map((e) => TipAmount.fromJson(e)).toList();
    }
  }
}

class TipAmount {
  int? id;
  int? coins;
  String? label;
  String? emoji;

  TipAmount({this.id, this.coins, this.label, this.emoji});

  TipAmount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    coins = json['coins'];
    label = json['label'];
    emoji = json['emoji'];
  }
}
