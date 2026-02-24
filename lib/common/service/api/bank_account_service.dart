import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/bank/bank_account_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class BankAccountService {
  BankAccountService._();
  static final BankAccountService instance = BankAccountService._();

  Future<List<BankAccount>> fetchBankAccounts() async {
    BankAccountListModel response = await ApiService.instance.call(
      url: WebService.bank.fetchBankAccounts,
      fromJson: BankAccountListModel.fromJson,
      param: {},
    );
    return response.data ?? [];
  }

  Future<BankAccount?> addBankAccount({
    required String gateway,
    required String accountDetails,
    String? label,
    String? accountHolderName,
    bool isDefault = false,
  }) async {
    BankAccountSingleModel response = await ApiService.instance.call(
      url: WebService.bank.addBankAccount,
      fromJson: BankAccountSingleModel.fromJson,
      param: {
        'gateway': gateway,
        'account_details': accountDetails,
        if (label != null) 'label': label,
        if (accountHolderName != null) 'account_holder_name': accountHolderName,
        'is_default': isDefault,
      },
    );
    return response.data;
  }

  Future<StatusModel> updateBankAccount({
    required int id,
    String? label,
    String? gateway,
    String? accountHolderName,
    String? accountDetails,
    bool? isDefault,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.bank.updateBankAccount,
      fromJson: StatusModel.fromJson,
      param: {
        'id': id,
        if (label != null) 'label': label,
        if (gateway != null) 'gateway': gateway,
        if (accountHolderName != null) 'account_holder_name': accountHolderName,
        if (accountDetails != null) 'account_details': accountDetails,
        if (isDefault != null) 'is_default': isDefault,
      },
    );
    return response;
  }

  Future<StatusModel> deleteBankAccount({required int id}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.bank.deleteBankAccount,
      fromJson: StatusModel.fromJson,
      param: {'id': id},
    );
    return response;
  }

  Future<StatusModel> setDefaultBankAccount({required int id}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.bank.setDefaultBankAccount,
      fromJson: StatusModel.fromJson,
      param: {'id': id},
    );
    return response;
  }
}
