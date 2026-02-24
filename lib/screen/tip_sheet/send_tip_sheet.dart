import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/gift_wallet_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/model/monetization/tip_amount_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SendTipSheet extends StatefulWidget {
  final int userId;
  final int? postId;
  final String? userName;
  final String? userPhoto;

  const SendTipSheet({
    super.key,
    required this.userId,
    this.postId,
    this.userName,
    this.userPhoto,
  });

  @override
  State<SendTipSheet> createState() => _SendTipSheetState();
}

class _SendTipSheetState extends State<SendTipSheet> {
  List<TipAmount> tipAmounts = [];
  bool isLoading = true;
  bool isSending = false;
  int? selectedTipId;
  final customController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTipAmounts();
  }

  Future<void> _loadTipAmounts() async {
    final amounts = await GiftWalletService.instance.fetchTipAmounts();
    setState(() {
      tipAmounts = amounts;
      isLoading = false;
    });
  }

  Future<void> _sendTip(int coins) async {
    final user = SessionManager.instance.getUser();
    if ((user?.coinWallet ?? 0) < coins) {
      Get.snackbar('Oops', 'Insufficient coins',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => isSending = true);

    final result = await GiftWalletService.instance.sendTip(
      userId: widget.userId,
      coins: coins,
      postId: widget.postId,
    );

    setState(() => isSending = false);

    if (result.status == true) {
      user?.removeCoinFromWallet(coins);
      SessionManager.instance.setUser(user);
      Get.back(result: coins);
    } else {
      Get.snackbar('Oops', result.message ?? 'Failed to send tip',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = SessionManager.instance.getUser()?.coinWallet ?? 0;

    return Container(
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textLightGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CustomImage(
                    image: widget.userPhoto?.addBaseURL(),
                    fullName: widget.userName,
                    size: const Size(44, 44),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Send Tip',
                          style: TextStyleCustom.outFitBold700(
                              fontSize: 18, color: blackPure(context)),
                        ),
                        Text(
                          'to @${widget.userName ?? ''}',
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 14, color: textLightGrey(context)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: ShapeDecoration(
                      color: bgMediumGrey(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AssetRes.icCoin, width: 18, height: 18),
                        const SizedBox(width: 4),
                        Text(
                          '$walletBalance',
                          style: TextStyleCustom.outFitBold700(
                              fontSize: 14, color: blackPure(context)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tipAmounts.map((tip) {
                    final isSelected = selectedTipId == tip.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedTipId = tip.id;
                          customController.clear();
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 70) / 3,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8),
                        decoration: ShapeDecoration(
                          gradient:
                              isSelected ? StyleRes.themeGradient : null,
                          color: isSelected ? null : bgMediumGrey(context),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 12, cornerSmoothing: 1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              tip.emoji ?? '',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AssetRes.icCoin,
                                    width: 16, height: 16),
                                const SizedBox(width: 3),
                                Text(
                                  '${tip.coins ?? 0}',
                                  style: TextStyleCustom.outFitBold700(
                                    fontSize: 15,
                                    color: isSelected
                                        ? whitePure(context)
                                        : blackPure(context),
                                  ),
                                ),
                              ],
                            ),
                            if (tip.label != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                tip.label!,
                                style: TextStyleCustom.outFitRegular400(
                                  fontSize: 11,
                                  color: isSelected
                                      ? whitePure(context)
                                      : textLightGrey(context),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: ShapeDecoration(
                  color: bgMediumGrey(context),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 12, cornerSmoothing: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(AssetRes.icCoin, width: 20, height: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: customController,
                        keyboardType: TextInputType.number,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 16, color: blackPure(context)),
                        decoration: InputDecoration(
                          hintText: 'Custom amount...',
                          hintStyle: TextStyleCustom.outFitRegular400(
                              fontSize: 14, color: textLightGrey(context)),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          if (val.isNotEmpty) {
                            setState(() => selectedTipId = null);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    gradient: StyleRes.themeGradient,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    ),
                  ),
                  child: MaterialButton(
                    onPressed: isSending
                        ? null
                        : () {
                            int coins = 0;
                            if (selectedTipId != null) {
                              coins = tipAmounts
                                      .firstWhereOrNull(
                                          (t) => t.id == selectedTipId)
                                      ?.coins ??
                                  0;
                            } else if (customController.text.isNotEmpty) {
                              coins =
                                  int.tryParse(customController.text) ?? 0;
                            }
                            if (coins > 0) {
                              _sendTip(coins);
                            }
                          },
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 12, cornerSmoothing: 1),
                    ),
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Send Tip',
                            style: TextStyleCustom.outFitBold700(
                                fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class TipManager {
  static Future<void> openTipSheet({
    required int userId,
    int? postId,
    String? userName,
    String? userPhoto,
    required Function(int coins) onCompletion,
  }) async {
    await Get.bottomSheet<int>(
      SendTipSheet(
        userId: userId,
        postId: postId,
        userName: userName,
        userPhoto: userPhoto,
      ),
      isScrollControlled: true,
    ).then((coins) {
      if (coins != null && coins > 0) {
        onCompletion(coins);
      }
    });
  }
}
