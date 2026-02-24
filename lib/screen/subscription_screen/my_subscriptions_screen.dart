import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/subscription_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/subscription/creator_subscription_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MySubscriptionsScreen extends StatefulWidget {
  const MySubscriptionsScreen({super.key});

  @override
  State<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends State<MySubscriptionsScreen> {
  List<CreatorSubscription> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final subs = await SubscriptionService.instance.fetchMySubscriptions();
      setState(() {
        subscriptions = subs;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancel(CreatorSubscription sub) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Text(
            'Cancel your subscription to ${sub.creator?.fullname ?? 'this creator'}? '
            'You will keep access until the current period ends.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Keep')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SubscriptionService.instance.cancelSubscription(
          creatorId: sub.creatorId ?? 0);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'My Subscriptions',
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 18,
          ),
        ),
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: blackPure(context)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriptions.isEmpty
              ? Center(
                  child: Text(
                    'No active subscriptions',
                    style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    return _buildSubItem(context, subscriptions[index]);
                  },
                ),
    );
  }

  Widget _buildSubItem(BuildContext context, CreatorSubscription sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: CustomImage(
              fit: BoxFit.cover,
              size: const Size(44, 44),
              image: sub.creator?.profilePhoto?.addBaseURL(),
              fullName: sub.creator?.fullname,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.creator?.fullname ?? '',
                  style: TextStyleCustom.outFitMedium500(
                    color: blackPure(context),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sub.tier?.name ?? ''} · ${sub.priceCoins} coins/mo',
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 13,
                  ),
                ),
                if (sub.expiresAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Renews: ${sub.expiresAt?.substring(0, 10) ?? ''}',
                    style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () => _cancel(sub),
            child: Text(
              'Cancel',
              style: TextStyleCustom.outFitMedium500(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
