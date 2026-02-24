class AiStickerListModel {
  bool? status;
  String? message;
  List<AiSticker>? data;

  AiStickerListModel({this.status, this.message, this.data});

  AiStickerListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(AiSticker.fromJson(v));
      });
    }
  }
}

class AiStickerSingleModel {
  bool? status;
  String? message;
  AiSticker? data;

  AiStickerSingleModel({this.status, this.message, this.data});

  AiStickerSingleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? AiSticker.fromJson(json['data']) : null;
  }
}

class AiSticker {
  int? id;
  String? prompt;
  String? imageUrl;
  int? useCount;
  String? createdAt;

  AiSticker({
    this.id,
    this.prompt,
    this.imageUrl,
    this.useCount,
    this.createdAt,
  });

  AiSticker.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    prompt = json['prompt'];
    imageUrl = json['image_url'];
    useCount = json['use_count'];
    createdAt = json['created_at'];
  }
}
