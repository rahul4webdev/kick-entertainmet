class ContentLanguagesModel {
  ContentLanguagesModel({bool? status, String? message, List<ContentLanguageItem>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  ContentLanguagesModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ContentLanguageItem.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<ContentLanguageItem>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<ContentLanguageItem>? get data => _data;
}

class ContentLanguageItem {
  ContentLanguageItem({this.id, this.name, this.code, this.isActive, this.sortOrder});

  ContentLanguageItem.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    isActive = json['is_active'];
    sortOrder = json['sort_order'];
  }

  int? id;
  String? name;
  String? code;
  bool? isActive;
  int? sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
