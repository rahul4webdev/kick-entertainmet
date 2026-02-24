import 'package:flutter/material.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/subscription_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/subscription/creator_subscription_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MySubscribersScreen extends StatefulWidget {
  const MySubscribersScreen({super.key});

  @override
  State<MySubscribersScreen> createState() => _MySubscribersScreenState();
}

class _MySubscribersScreenState extends State<MySubscribersScreen> {
  List<CreatorSubscription> subscribers = [];
  bool isLoading = true;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool loadMore = false}) async {
    try {
      final subs = await SubscriptionService.instance.fetchMySubscribers(
        lastItemId: loadMore && subscribers.isNotEmpty
            ? subscribers.last.id
            : null,
      );
      setState(() {
        if (loadMore) {
          subscribers.addAll(subs);
        } else {
          subscribers = subs;
        }
        hasMore = subs.length >= 20;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'My Subscribers',
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
          : subscribers.isEmpty
              ? Center(
                  child: Text(
                    'No subscribers yet',
                    style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context),
                      fontSize: 14,
                    ),
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification &&
                        notification.metrics.extentAfter < 100 &&
                        hasMore &&
                        !isLoading) {
                      _load(loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: subscribers.length,
                    itemBuilder: (context, index) {
                      return _buildSubscriberItem(
                          context, subscribers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildSubscriberItem(BuildContext context, CreatorSubscription sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomImage(
              fit: BoxFit.cover,
              size: const Size(40, 40),
              image: sub.subscriber?.profilePhoto?.addBaseURL(),
              fullName: sub.subscriber?.fullname,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.subscriber?.fullname ?? '',
                  style: TextStyleCustom.outFitMedium500(
                    color: blackPure(context),
                    fontSize: 14,
                  ),
                ),
                Text(
                  sub.tier?.name ?? '',
                  style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${sub.priceCoins} coins/mo',
            style: TextStyleCustom.outFitMedium500(
              color: themeAccentSolid(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
