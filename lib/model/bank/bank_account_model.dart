class BankAccount {
  int? id;
  int? userId;
  String? label;
  String? gateway;
  String? accountHolderName;
  String? accountDetails;
  bool isDefault;

  BankAccount({
    this.id,
    this.userId,
    this.label,
    this.gateway,
    this.accountHolderName,
    this.accountDetails,
    this.isDefault = false,
  });

  BankAccount.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userId = json['user_id'],
        label = json['label'],
        gateway = json['gateway'],
        accountHolderName = json['account_holder_name'],
        accountDetails = json['account_details'],
        isDefault = json['is_default'] == true || json['is_default'] == 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'label': label,
        'gateway': gateway,
        'account_holder_name': accountHolderName,
        'account_details': accountDetails,
        'is_default': isDefault,
      };

  String get displayLabel =>
      label?.isNotEmpty == true ? label! : gateway ?? 'Account';
}

class BankAccountListModel {
  bool? status;
  String? message;
  List<BankAccount>? data;

  BankAccountListModel({this.status, this.message, this.data});

  BankAccountListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => BankAccount.fromJson(e))
          .toList();
    }
  }
}

class BankAccountSingleModel {
  bool? status;
  String? message;
  BankAccount? data;

  BankAccountSingleModel({this.status, this.message, this.data});

  BankAccountSingleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = BankAccount.fromJson(json['data']);
    }
  }
}
