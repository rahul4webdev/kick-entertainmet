import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/manager/ads/native_ad_manager.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/model/post_story/feed_item.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class FeedItemMerger {
  FeedItemMerger._();

  static List<FeedItem> merge(List<Post> posts, List<int> adPositions) {
    if (isSubscribe.value || adPositions.isEmpty) {
      return posts.map((p) => PostFeedItem(p)).toList();
    }

    // Determine which ad type to use: VAST video ads take priority over native
    final useVastFeedAds = _isVastFeedAdEnabled;
    final useNativeAds = !useVastFeedAds && NativeAdManager.instance.isEnabled;

    if (!useVastFeedAds && !useNativeAds) {
      return posts.map((p) => PostFeedItem(p)).toList();
    }

    final result = <FeedItem>[];
    final sorted = [...adPositions]..sort();
    int adIdx = 0;

    for (int i = 0; i < posts.length; i++) {
      while (adIdx < sorted.length && sorted[adIdx] == result.length) {
        final id = 'ad_${result.length}_${DateTime.now().millisecondsSinceEpoch}';
        if (useVastFeedAds) {
          result.add(VastFeedAdItem(id));
        } else {
          result.add(NativeAdFeedItem(id));
        }
        adIdx++;
      }
      result.add(PostFeedItem(posts[i]));
    }

    return result;
  }

  static bool get _isVastFeedAdEnabled {
    final tagUrl = ImaAdManager.instance.vastFeedAdTagUrl;
    return tagUrl != null && tagUrl.isNotEmpty;
  }
}
