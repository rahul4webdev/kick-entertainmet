import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/subscription_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/model/subscription/subscription_tier_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Bottom sheet displaying a creator's subscription tiers for subscribing
class CreatorSubscribeSheet extends StatefulWidget {
  final User creator;
  final VoidCallback? onSubscribed;

  const CreatorSubscribeSheet({
    super.key,
    required this.creator,
    this.onSubscribed,
  });

  @override
  State<CreatorSubscribeSheet> createState() => _CreatorSubscribeSheetState();
}

class _CreatorSubscribeSheetState extends State<CreatorSubscribeSheet> {
  List<SubscriptionTier> tiers = [];
  int? currentTierId;
  int? selectedTierId;
  bool isLoading = true;
  bool isSubscribing = false;

  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  Future<void> _loadTiers() async {
    try {
      final response = await SubscriptionService.instance.fetchTiers(
        creatorId: widget.creator.id ?? 0,
      );
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final tiersList = data['tiers'] as List? ?? [];
      final currentSub = data['current_subscription'] as Map<String, dynamic>?;

      setState(() {
        tiers = tiersList.map((e) => SubscriptionTier.fromJson(e)).toList();
        currentTierId = currentSub?['tier_id'];
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _subscribe() async {
    if (selectedTierId == null || isSubscribing) return;

    setState(() => isSubscribing = true);
    try {
      final response = await SubscriptionService.instance.subscribe(
        tierId: selectedTierId!,
      );
      if (response['status'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final remaining = data['coins_remaining'];

        // Update local user coins
        if (remaining != null) {
          SessionManager.instance.getUser()?.coinWallet = remaining;
        }

        widget.onSubscribed?.call();
        Get.back();
        Get.snackbar('Subscribed', response['message'] ?? 'Subscribed successfully');
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to subscribe');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      setState(() => isSubscribing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Creator info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: CustomImage(
                    fit: BoxFit.cover,
                    size: const Size(50, 50),
                    image: widget.creator.profilePhoto?.addBaseURL(),
                    fullName: widget.creator.fullname,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscribe to',
                      style: TextStyleCustom.outFitRegular400(
                        color: textLightGrey(context),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      widget.creator.fullname ?? '',
                      style: TextStyleCustom.outFitMedium500(
                        color: blackPure(context),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tiers list
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: CircularProgressIndicator(),
              )
            else if (tiers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  'No subscription tiers available',
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...tiers.map((tier) => _buildTierCard(context, tier)),

            // Subscribe button
            if (selectedTierId != null && currentTierId == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubscribing ? null : _subscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeAccentSolid(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubscribing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Subscribe',
                            style: TextStyleCustom.outFitMedium500(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),

            if (currentTierId != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'You are already subscribed',
                  style: TextStyleCustom.outFitRegular400(
                    color: themeAccentSolid(context),
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(BuildContext context, SubscriptionTier tier) {
    final isSelected = selectedTierId == tier.id;
    final isCurrent = currentTierId == tier.id;

    return GestureDetector(
      onTap: currentTierId != null
          ? null
          : () => setState(() => selectedTierId = tier.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgGrey(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected || isCurrent
                ? themeAccentSolid(context)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(AssetRes.icCrown, width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tier.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      color: blackPure(context),
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  '${tier.priceCoins} coins/mo',
                  style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (tier.description != null && tier.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                tier.description!,
                style: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context),
                  fontSize: 13,
                ),
              ),
            ],
            if (tier.benefits != null && tier.benefits!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...tier.benefits!.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: themeAccentSolid(context)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyleCustom.outFitRegular400(
                            color: blackPure(context),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (isCurrent) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Current Plan',
                  style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
