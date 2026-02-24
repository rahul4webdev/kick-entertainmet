class ContentGenresModel {
  ContentGenresModel({bool? status, String? message, List<ContentGenre>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  ContentGenresModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ContentGenre.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<ContentGenre>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<ContentGenre>? get data => _data;
}

class ContentGenre {
  ContentGenre({this.id, this.name, this.contentType, this.isActive, this.sortOrder});

  ContentGenre.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    contentType = json['content_type'];
    isActive = json['is_active'];
    sortOrder = json['sort_order'];
  }

  int? id;
  String? name;
  int? contentType;
  bool? isActive;
  int? sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'content_type': contentType,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }
}
