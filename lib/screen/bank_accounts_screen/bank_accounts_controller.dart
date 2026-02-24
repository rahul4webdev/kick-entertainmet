import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/bank_account_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/bank/bank_account_model.dart';
import 'package:shortzz/model/general/settings_model.dart';

class BankAccountsController extends BaseController {
  RxList<BankAccount> accounts = <BankAccount>[].obs;
  RxBool isAccountsLoading = true.obs;

  Setting? get settings => SessionManager.instance.getSettings();

  List<String> get gatewayNames =>
      (settings?.redeemGateways ?? []).map((e) => e.title ?? '').toList();

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    isAccountsLoading.value = true;
    accounts.value = await BankAccountService.instance.fetchBankAccounts();
    isAccountsLoading.value = false;
  }

  Future<void> addAccount({
    required String gateway,
    required String accountDetails,
    String? label,
    String? accountHolderName,
    bool isDefault = false,
  }) async {
    showLoader();
    final result = await BankAccountService.instance.addBankAccount(
      gateway: gateway,
      accountDetails: accountDetails,
      label: label,
      accountHolderName: accountHolderName,
      isDefault: isDefault,
    );
    stopLoader();
    if (result != null) {
      showSnackBar(LKey.channelCreated.tr);
      await fetchAccounts();
      Get.back();
    }
  }

  Future<void> updateAccount({
    required int id,
    String? label,
    String? gateway,
    String? accountHolderName,
    String? accountDetails,
    bool? isDefault,
  }) async {
    showLoader();
    final result = await BankAccountService.instance.updateBankAccount(
      id: id,
      label: label,
      gateway: gateway,
      accountHolderName: accountHolderName,
      accountDetails: accountDetails,
      isDefault: isDefault,
    );
    stopLoader();
    if (result.status == true) {
      showSnackBar(result.message);
      await fetchAccounts();
      Get.back();
    }
  }

  Future<void> deleteAccount(int id) async {
    showLoader();
    final result = await BankAccountService.instance.deleteBankAccount(id: id);
    stopLoader();
    if (result.status == true) {
      showSnackBar(result.message);
      await fetchAccounts();
    }
  }

  Future<void> setDefault(int id) async {
    showLoader();
    final result =
        await BankAccountService.instance.setDefaultBankAccount(id: id);
    stopLoader();
    if (result.status == true) {
      await fetchAccounts();
    }
  }

  void showAddEditSheet(BuildContext context, {BankAccount? existing}) {
    final labelC = TextEditingController(text: existing?.label ?? '');
    final holderC =
        TextEditingController(text: existing?.accountHolderName ?? '');
    final detailsC =
        TextEditingController(text: existing?.accountDetails ?? '');
    final selectedGateway = (existing?.gateway ?? gatewayNames.firstOrNull ?? '')
        .obs;
    final makeDefault = (existing?.isDefault ?? false).obs;

    Get.bottomSheet(
      _AddEditSheet(
        controller: this,
        labelC: labelC,
        holderC: holderC,
        detailsC: detailsC,
        selectedGateway: selectedGateway,
        makeDefault: makeDefault,
        existing: existing,
      ),
      isScrollControlled: true,
    );
  }
}

class _AddEditSheet extends StatelessWidget {
  final BankAccountsController controller;
  final TextEditingController labelC;
  final TextEditingController holderC;
  final TextEditingController detailsC;
  final RxString selectedGateway;
  final RxBool makeDefault;
  final BankAccount? existing;

  const _AddEditSheet({
    required this.controller,
    required this.labelC,
    required this.holderC,
    required this.detailsC,
    required this.selectedGateway,
    required this.makeDefault,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEdit ? LKey.editBankAccount.tr : LKey.addBankAccount.tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelC,
              decoration: InputDecoration(
                labelText: LKey.accountLabel.tr,
                hintText: 'e.g. My PayPal',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (controller.gatewayNames.isNotEmpty)
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: controller.gatewayNames
                            .contains(selectedGateway.value)
                        ? selectedGateway.value
                        : controller.gatewayNames.first,
                    items: controller.gatewayNames
                        .map((g) =>
                            DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) =>
                        selectedGateway.value = v ?? '',
                    decoration: InputDecoration(
                      labelText: LKey.selectGateway.tr,
                      border: const OutlineInputBorder(),
                    ),
                  )),
            const SizedBox(height: 12),
            TextField(
              controller: holderC,
              decoration: InputDecoration(
                labelText: LKey.accountHolderName.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailsC,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: LKey.accountDetails.tr,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => CheckboxListTile(
                  value: makeDefault.value,
                  onChanged: (v) => makeDefault.value = v ?? false,
                  title: Text(LKey.setAsDefault.tr),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (detailsC.text.trim().isEmpty) return;
                  if (isEdit) {
                    controller.updateAccount(
                      id: existing!.id!,
                      label: labelC.text.trim(),
                      gateway: selectedGateway.value,
                      accountHolderName: holderC.text.trim(),
                      accountDetails: detailsC.text.trim(),
                      isDefault: makeDefault.value ? true : null,
                    );
                  } else {
                    controller.addAccount(
                      gateway: selectedGateway.value,
                      accountDetails: detailsC.text.trim(),
                      label: labelC.text.trim().isEmpty
                          ? null
                          : labelC.text.trim(),
                      accountHolderName: holderC.text.trim().isEmpty
                          ? null
                          : holderC.text.trim(),
                      isDefault: makeDefault.value,
                    );
                  }
                },
                child: Text(isEdit ? LKey.save.tr : LKey.addBankAccount.tr),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
