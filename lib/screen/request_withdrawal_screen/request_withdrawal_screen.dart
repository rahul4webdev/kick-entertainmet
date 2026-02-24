import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_drop_down.dart';
import 'package:shortzz/common/widget/privacy_policy_text.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/common/widget/text_field_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/bank/bank_account_model.dart';
import 'package:shortzz/screen/bank_accounts_screen/bank_accounts_screen.dart';
import 'package:shortzz/screen/request_withdrawal_screen/request_withdrawal_screen_controller.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class RequestWithdrawalScreen extends StatelessWidget {
  const RequestWithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestWithdrawalScreenController());
    return Scaffold(
        body: Column(
      children: [
        CustomAppBar(title: LKey.requestWithdrawal.tr),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: bgLightGrey(context)),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Obx(
                                () => Text(
                                  (controller.myUser.value?.coinWallet ?? 0).numberFormat,
                                  style: TextStyleCustom.outFitExtraBold800(
                                      color: textDarkGrey(context), fontSize: 28),
                                ),
                              ),
                              Text(LKey.coinBalance.tr,
                                  style: TextStyleCustom.outFitLight300(
                                      color: textLightGrey(context))),
                            ],
                          ),
                          Text(AppRes.equal,
                              style: TextStyleCustom.outFitSemiBold600(
                                  color: textDarkGrey(context), fontSize: 26)),
                          Column(
                            children: [
                              Text(
                                controller.myUser.value
                                        ?.coinEstimatedValue(
                                            controller.settings.value?.coinValue?.toDouble())
                                        .currencyFormat ??
                                    '',
                                style: TextStyleCustom.outFitExtraBold800(
                                    color: textDarkGrey(context), fontSize: 28),
                              ),
                              Text(
                                LKey.estimatedValue.tr,
                                style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: bgGrey(context),
                      height: 29,
                      alignment: Alignment.center,
                      child: Obx(
                        () => Text(
                          '${LKey.currentValue.tr} : ${(controller.settings.value?.coinValue ?? 0).currencyFormat}'
                          ' ${AppRes.slash} ${LKey.coin.tr} ',
                          style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context), fontSize: 13),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Obx(() {
                int minCoins = controller.settings.value?.minRedeemCoins ?? 0;
                int currentCoins = controller.myUser.value?.coinWallet?.toInt() ?? 0;
                if (minCoins > 0) {
                  double progress = (currentCoins / minCoins).clamp(0.0, 1.0);
                  bool eligible = currentCoins >= minCoins;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bgLightGrey(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LKey.payoutThreshold.tr,
                              style: TextStyleCustom.outFitMedium500(
                                  color: textDarkGrey(context), fontSize: 14),
                            ),
                            Text(
                              '${currentCoins.numberFormat} / ${minCoins.numberFormat}',
                              style: TextStyleCustom.outFitMedium500(
                                  color: eligible ? Colors.green : textLightGrey(context),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: bgGrey(context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              eligible ? Colors.green : themeColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          eligible
                              ? LKey.eligibleToWithdraw.tr
                              : LKey.needMoreCoins.trParams({
                                  'coins': (minCoins - currentCoins).numberFormat,
                                }),
                          style: TextStyleCustom.outFitLight300(
                            color: eligible ? Colors.green : textLightGrey(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),
              TextFieldCustom(
                onChanged: controller.onChanged,
                controller: controller.amountController,
                title: LKey.amount.tr,
                isPrefixIconShow: true,
                hintText: LKey.enterCoinAmount.tr,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // Allow only numbers
                  LengthLimitingTextInputFormatter(
                      (controller.myUser.value?.coinWallet?.toInt() ?? 0)
                          .toString()
                          .length), // Dynamic limit
                ],
                prefixIcon: Container(
                    height: 49,
                    width: 49,
                    color: textDarkGrey(context),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        right: TextDirection.ltr == Directionality.of(context) ? 13 : 0,
                        left: TextDirection.rtl == Directionality.of(context) ? 13 : 0),
                    child: Image.asset(AssetRes.icCoin, width: 23, height: 23)),
              ),
              Obx(
                () => TextFieldCustom(
                  controller: controller.estimatedAmountController.value,
                  title: LKey.estimatedAmount.tr,
                  enabled: false,
                  hintText: '',
                  isPrefixIconShow: true,
                  prefixIcon: Container(
                      height: 49,
                      width: 49,
                      color: textDarkGrey(context),
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          right: TextDirection.ltr == Directionality.of(context) ? 13 : 0,
                          left: TextDirection.rtl == Directionality.of(context) ? 13 : 0),
                      child: Text(
                        controller.settings.value?.currency ?? AppRes.currency,
                        style:
                            TextStyleCustom.outFitLight300(fontSize: 20, color: whitePure(context)),
                      )),
                ),
              ),
              Obx(() {
                double commPct = controller.settings.value?.commissionPercentage ?? 0;
                if (commPct > 0 && controller.amountController.text.isNotEmpty) {
                  double estimated = double.tryParse(
                          controller.estimatedAmountController.value.text) ?? 0;
                  double commAmount = estimated * (commPct / 100);
                  double net = estimated - commAmount;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgLightGrey(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${LKey.commission.tr} (${commPct.toStringAsFixed(1)}%)',
                                style: TextStyleCustom.outFitLight300(
                                    color: textLightGrey(context), fontSize: 14)),
                            Text('- ${commAmount.toStringAsFixed(2)}',
                                style: TextStyleCustom.outFitMedium500(
                                    color: Colors.red, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(LKey.netPayout.tr,
                                style: TextStyleCustom.outFitMedium500(
                                    color: textDarkGrey(context), fontSize: 14)),
                            Text(net.toStringAsFixed(2),
                                style: TextStyleCustom.outFitBold700(
                                    color: Colors.green, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),
              // Saved Bank Accounts Section
              Obx(() {
                if (controller.savedAccounts.isEmpty) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, bottom: 8, right: 20, top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(LKey.savedAccounts.tr,
                              style: TextStyleCustom.outFitMedium500(
                                  color: textDarkGrey(context), fontSize: 15)),
                          GestureDetector(
                            onTap: () async {
                              await Get.to(
                                  () => const BankAccountsScreen());
                              controller.savedAccounts.value = [];
                              controller.fetchSavedAccounts();
                            },
                            child: Text(LKey.bankAccounts.tr,
                                style: TextStyleCustom.outFitRegular400(
                                    color: themeAccentSolid(context),
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: controller.savedAccounts.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          if (index == controller.savedAccounts.length) {
                            // "Enter Manually" chip
                            return GestureDetector(
                              onTap: () =>
                                  controller.clearSavedAccountSelection(),
                              child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color:
                                          !controller.useSavedAccount.value
                                              ? themeAccentSolid(context)
                                              : bgLightGrey(context),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_note,
                                            size: 20,
                                            color: !controller
                                                    .useSavedAccount.value
                                                ? whitePure(context)
                                                : textLightGrey(context)),
                                        const SizedBox(height: 2),
                                        Text(LKey.enterManually.tr,
                                            style: TextStyleCustom
                                                .outFitRegular400(
                                              fontSize: 11,
                                              color: !controller
                                                      .useSavedAccount
                                                      .value
                                                  ? whitePure(context)
                                                  : textLightGrey(context),
                                            )),
                                      ],
                                    ),
                                  )),
                            );
                          }
                          final BankAccount account =
                              controller.savedAccounts[index];
                          return GestureDetector(
                            onTap: () =>
                                controller.selectSavedAccount(account),
                            child: Obx(() {
                              final isSelected = controller
                                      .selectedSavedAccount.value?.id ==
                                  account.id;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? themeAccentSolid(context)
                                      : bgLightGrey(context),
                                  borderRadius: BorderRadius.circular(10),
                                  border: account.isDefault && !isSelected
                                      ? Border.all(
                                          color:
                                              themeAccentSolid(context),
                                          width: 1)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      account.displayLabel,
                                      style: TextStyleCustom
                                          .outFitMedium500(
                                        fontSize: 13,
                                        color: isSelected
                                            ? whitePure(context)
                                            : textDarkGrey(context),
                                      ),
                                    ),
                                    Text(
                                      account.gateway ?? '',
                                      style: TextStyleCustom
                                          .outFitLight300(
                                        fontSize: 11,
                                        color: isSelected
                                            ? whitePure(context)
                                                .withValues(alpha: 0.7)
                                            : textLightGrey(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              // Gateway & Account Details (shown when entering manually or no saved accounts)
              Obx(() {
                if (controller.useSavedAccount.value) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, bottom: 5, right: 20),
                      child: Text(LKey.selectGateway.tr,
                          style: TextStyleCustom.outFitRegular400(
                              color: textDarkGrey(context), fontSize: 17)),
                    ),
                    Builder(builder: (context) {
                      var listFromApi =
                          (controller.settings.value?.redeemGateways ?? [])
                              .map((e) => e.title ?? '')
                              .toList();
                      var redeemGateways = listFromApi.isEmpty
                          ? [AppRes.emptyGatewayMessage]
                          : listFromApi;
                      if (listFromApi.isNotEmpty &&
                          controller.selectedGateway.value.isEmpty) {
                        controller.selectedGateway.value = listFromApi.first;
                      }
                      return CustomDropDownBtn<String>(
                          items: redeemGateways,
                          selectedValue:
                              controller.selectedGateway.value.isEmpty
                                  ? redeemGateways.first
                                  : controller.selectedGateway.value,
                          getTitle: (value) => value,
                          onChanged: (value) {
                            controller.selectedGateway.value = value ?? '';
                          },
                          bgColor: bgLightGrey(context),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          isExpanded: true,
                          height: 48,
                          style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context), fontSize: 17));
                    }),
                    const SizedBox(height: 10),
                    TextFieldCustom(
                      height: 120,
                      controller: controller.accountDetailsController,
                      title: LKey.accountDetails.tr,
                      hintText: '',
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),
              TextButtonCustom(
                onTap: controller.onSubmit,
                title: LKey.submit.tr,
                horizontalMargin: 15,
                backgroundColor: textDarkGrey(context),
                titleColor: whitePure(context),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: const PrivacyPolicyText()),
            ],
          ),
        ))
      ],
    ));
  }
}
