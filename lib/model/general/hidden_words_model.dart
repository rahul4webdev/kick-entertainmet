class HiddenWordsModel {
  bool? status;
  String? message;
  List<String>? data;

  HiddenWordsModel({this.status, this.message, this.data});

  HiddenWordsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = List<String>.from(json['data']);
    }
  }
}
