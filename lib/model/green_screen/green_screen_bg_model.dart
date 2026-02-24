class GreenScreenBgResponse {
  bool? status;
  String? message;
  List<GreenScreenBg>? data;
  List<String>? categories;

  GreenScreenBgResponse({this.status, this.message, this.data, this.categories});

  GreenScreenBgResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => GreenScreenBg.fromJson(e))
          .toList();
    }
    if (json['categories'] != null) {
      categories = (json['categories'] as List).map((e) => e.toString()).toList();
    }
  }
}

class GreenScreenBg {
  int? id;
  String? title;
  String? image;
  String? video;
  String? type;
  String? category;
  bool? isActive;
  int? sortOrder;

  GreenScreenBg({
    this.id,
    this.title,
    this.image,
    this.video,
    this.type,
    this.category,
    this.isActive,
    this.sortOrder,
  });

  GreenScreenBg.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    video = json['video'];
    type = json['type'];
    category = json['category'];
    isActive = json['is_active'] == true || json['is_active'] == 1;
    sortOrder = json['sort_order'];
  }
}
