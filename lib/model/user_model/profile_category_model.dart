class ProfileCategoryListModel {
  ProfileCategoryListModel(
      {bool? status, String? message, List<ProfileCategory>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  ProfileCategoryListModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ProfileCategory.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<ProfileCategory>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<ProfileCategory>? get data => _data;

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

class ProfileCategory {
  ProfileCategory(
      {this.id,
      this.name,
      this.accountType,
      this.requiresApproval,
      this.isActive,
      this.sortOrder,
      this.subCategories});

  ProfileCategory.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    accountType = json['account_type'];
    requiresApproval = json['requires_approval'] is bool
        ? json['requires_approval']
        : (json['requires_approval'] == 1);
    isActive = json['is_active'] is bool
        ? json['is_active']
        : (json['is_active'] == 1);
    sortOrder = json['sort_order'];
    if (json['sub_categories'] != null) {
      subCategories = [];
      json['sub_categories'].forEach((v) {
        subCategories?.add(ProfileSubCategory.fromJson(v));
      });
    }
  }

  int? id;
  String? name;
  int? accountType;
  bool? requiresApproval;
  bool? isActive;
  int? sortOrder;
  List<ProfileSubCategory>? subCategories;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['account_type'] = accountType;
    map['requires_approval'] = requiresApproval;
    map['is_active'] = isActive;
    map['sort_order'] = sortOrder;
    if (subCategories != null) {
      map['sub_categories'] =
          subCategories?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ProfileSubCategoryListModel {
  ProfileSubCategoryListModel(
      {bool? status, String? message, List<ProfileSubCategory>? data}) {
    _status = status;
    _message = message;
    _data = data;
  }

  ProfileSubCategoryListModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ProfileSubCategory.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<ProfileSubCategory>? _data;

  bool? get status => _status;
  String? get message => _message;
  List<ProfileSubCategory>? get data => _data;

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

class ProfileSubCategory {
  ProfileSubCategory(
      {this.id, this.categoryId, this.name, this.isActive, this.sortOrder});

  ProfileSubCategory.fromJson(dynamic json) {
    id = json['id'];
    categoryId = json['category_id'];
    name = json['name'];
    isActive = json['is_active'] is bool
        ? json['is_active']
        : (json['is_active'] == 1);
    sortOrder = json['sort_order'];
  }

  int? id;
  int? categoryId;
  String? name;
  bool? isActive;
  int? sortOrder;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['category_id'] = categoryId;
    map['name'] = name;
    map['is_active'] = isActive;
    map['sort_order'] = sortOrder;
    return map;
  }
}
