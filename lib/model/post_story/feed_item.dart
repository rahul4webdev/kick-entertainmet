import 'package:shortzz/model/post_story/post_model.dart';

sealed class FeedItem {
  const FeedItem();
}

class PostFeedItem extends FeedItem {
  final Post post;
  const PostFeedItem(this.post);
}

class NativeAdFeedItem extends FeedItem {
  final String placementId;
  const NativeAdFeedItem(this.placementId);
}

class VastFeedAdItem extends FeedItem {
  final String placementId;
  const VastFeedAdItem(this.placementId);
}
