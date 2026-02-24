import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/bank/bank_account_model.dart';
import 'package:shortzz/screen/bank_accounts_screen/bank_accounts_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BankAccountsController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.bankAccounts.tr),
          Expanded(
            child: Obx(() {
              if (controller.isAccountsLoading.value &&
                  controller.accounts.isEmpty) {
                return const LoaderWidget();
              }
              return RefreshIndicator(
                onRefresh: controller.fetchAccounts,
                child: NoDataView(
                  showShow: controller.accounts.isEmpty,
                  title: LKey.noBankAccounts.tr,
                  description: LKey.noBankAccountsDesc.tr,
                  child: ListView.builder(
                    itemCount: controller.accounts.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      return _BankAccountTile(
                        account: controller.accounts[index],
                        controller: controller,
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showAddEditSheet(context),
        backgroundColor: themeAccentSolid(context),
        child: Icon(Icons.add, color: whitePure(context)),
      ),
    );
  }
}

class _BankAccountTile extends StatelessWidget {
  final BankAccount account;
  final BankAccountsController controller;

  const _BankAccountTile({
    required this.account,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: bgLightGrey(context),
        borderRadius: BorderRadius.circular(12),
        border: account.isDefault
            ? Border.all(color: themeAccentSolid(context), width: 1.5)
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: account.isDefault
                ? themeAccentSolid(context).withValues(alpha: 0.1)
                : bgGrey(context),
          ),
          child: Icon(
            Icons.account_balance,
            color: account.isDefault
                ? themeAccentSolid(context)
                : textLightGrey(context),
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                account.displayLabel,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 15,
                  color: textDarkGrey(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (account.isDefault)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  LKey.defaultAccount.tr,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 10,
                    color: whitePure(context),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.gateway ?? '',
              style: TextStyleCustom.outFitRegular400(
                fontSize: 13,
                color: textLightGrey(context),
              ),
            ),
            if (account.accountHolderName?.isNotEmpty == true)
              Text(
                account.accountHolderName!,
                style: TextStyleCustom.outFitLight300(
                  fontSize: 12,
                  color: textLightGrey(context),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textLightGrey(context)),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                controller.showAddEditSheet(context, existing: account);
                break;
              case 'default':
                controller.setDefault(account.id!);
                break;
              case 'delete':
                _showDeleteConfirm(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(LKey.editBankAccount.tr),
            ),
            if (!account.isDefault)
              PopupMenuItem(
                value: 'default',
                child: Text(LKey.setAsDefault.tr),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                LKey.delete.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(LKey.delete.tr),
        content: Text(LKey.deleteAccountConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount(account.id!);
            },
            child: Text(
              LKey.delete.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
