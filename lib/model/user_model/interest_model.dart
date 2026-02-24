class InterestListModel {
  InterestListModel({bool? status, String? message, List<Interest>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  InterestListModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Interest.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<Interest>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<Interest>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Interest {
  Interest({this.id, this.name, this.icon, this.isActive, this.sortOrder});

  Interest.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    isActive = json['is_active'] is bool
        ? json['is_active']
        : (json['is_active'] == 1);
    sortOrder = json['sort_order'];
  }

  int? id;
  String? name;
  String? icon;
  bool? isActive;
  int? sortOrder;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['icon'] = icon;
    map['is_active'] = isActive;
    map['sort_order'] = sortOrder;
    return map;
  }
}
