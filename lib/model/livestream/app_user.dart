class AppUser {
  int? userId;
  String? username;
  String? fullname;
  String? profile;
  int? isVerify;
  String? identity;

  AppUser(
      {this.userId,
      this.username,
      this.fullname,
      this.profile,
      this.isVerify,
      this.identity});

  AppUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'] is String ? int.tryParse(json['user_id']) : json['user_id'] as int?;
    identity = json['identity'];
    username = json['username'];
    fullname = json['fullname'];
    profile = json['profile'];
    final iv = json['is_verify'];
    isVerify = iv is bool ? (iv ? 1 : 0) : iv is String ? int.tryParse(iv) : iv as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['identity'] = identity;
    data['username'] = username;
    data['fullname'] = fullname;
    data['profile'] = profile;
    data['is_verify'] = isVerify;
    return data;
  }
}


