import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';

class CreatorDashboardModel {
  bool? status;
  String? message;
  CreatorDashboardData? data;

  CreatorDashboardModel({this.status, this.message, this.data});

  factory CreatorDashboardModel.fromJson(dynamic json) {
    return CreatorDashboardModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? CreatorDashboardData.fromJson(json['data'])
          : null,
    );
  }
}

class CreatorDashboardData {
  DashboardOverview? overview;
  DashboardPeriod? period;
  AdRevenueEstimate? adRevenue;
  List<Post>? topPosts;
  List<ContentBreakdownItem>? contentBreakdown;
  List<ContentTypeBreakdownItem>? contentTypeBreakdown;
  List<ChartDataPoint>? chartData;
  List<FollowerChartPoint>? followerChart;

  CreatorDashboardData({
    this.overview,
    this.period,
    this.adRevenue,
    this.topPosts,
    this.contentBreakdown,
    this.contentTypeBreakdown,
    this.chartData,
    this.followerChart,
  });

  factory CreatorDashboardData.fromJson(dynamic json) {
    return CreatorDashboardData(
      overview: json['overview'] != null
          ? DashboardOverview.fromJson(json['overview'])
          : null,
      period: json['period'] != null
          ? DashboardPeriod.fromJson(json['period'])
          : null,
      adRevenue: json['ad_revenue'] != null
          ? AdRevenueEstimate.fromJson(json['ad_revenue'])
          : null,
      topPosts: json['top_posts'] != null
          ? (json['top_posts'] as List).map((v) => Post.fromJson(v)).toList()
          : null,
      contentBreakdown: json['content_breakdown'] != null
          ? (json['content_breakdown'] as List)
              .map((v) => ContentBreakdownItem.fromJson(v))
              .toList()
          : null,
      contentTypeBreakdown: json['content_type_breakdown'] != null
          ? (json['content_type_breakdown'] as List)
              .map((v) => ContentTypeBreakdownItem.fromJson(v))
              .toList()
          : null,
      chartData: json['chart_data'] != null
          ? (json['chart_data'] as List)
              .map((v) => ChartDataPoint.fromJson(v))
              .toList()
          : null,
      followerChart: json['follower_chart'] != null
          ? (json['follower_chart'] as List)
              .map((v) => FollowerChartPoint.fromJson(v))
              .toList()
          : null,
    );
  }
}

class DashboardOverview {
  int totalPosts;
  int totalViews;
  int totalLikes;
  int totalComments;
  int totalShares;
  int totalSaves;
  int followerCount;
  int followingCount;
  double engagementRate;

  DashboardOverview({
    this.totalPosts = 0,
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalShares = 0,
    this.totalSaves = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.engagementRate = 0,
  });

  factory DashboardOverview.fromJson(dynamic json) {
    return DashboardOverview(
      totalPosts: json['total_posts'] ?? 0,
      totalViews: json['total_views'] ?? 0,
      totalLikes: json['total_likes'] ?? 0,
      totalComments: json['total_comments'] ?? 0,
      totalShares: json['total_shares'] ?? 0,
      totalSaves: json['total_saves'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0).toDouble(),
    );
  }
}

class DashboardPeriod {
  String label;
  int posts;
  int views;
  int likes;
  int comments;
  int shares;
  int saves;
  int newFollowers;

  DashboardPeriod({
    this.label = '30d',
    this.posts = 0,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.newFollowers = 0,
  });

  factory DashboardPeriod.fromJson(dynamic json) {
    return DashboardPeriod(
      label: json['label'] ?? '30d',
      posts: json['posts'] ?? 0,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      saves: json['saves'] ?? 0,
      newFollowers: json['new_followers'] ?? 0,
    );
  }
}

class ContentBreakdownItem {
  int postType;
  int count;
  int views;
  int likes;

  ContentBreakdownItem({
    this.postType = 0,
    this.count = 0,
    this.views = 0,
    this.likes = 0,
  });

  factory ContentBreakdownItem.fromJson(dynamic json) {
    return ContentBreakdownItem(
      postType: json['post_type'] ?? 0,
      count: json['count'] ?? 0,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }

  String get label => switch (postType) {
        1 => 'Reels',
        2 => 'Images',
        3 => 'Videos',
        4 => 'Text',
        _ => 'Other',
      };
}

class ContentTypeBreakdownItem {
  int contentType;
  int count;
  int views;

  ContentTypeBreakdownItem({
    this.contentType = 0,
    this.count = 0,
    this.views = 0,
  });

  factory ContentTypeBreakdownItem.fromJson(dynamic json) {
    return ContentTypeBreakdownItem(
      contentType: json['content_type'] ?? 0,
      count: json['count'] ?? 0,
      views: json['views'] ?? 0,
    );
  }

  String get label => switch (contentType) {
        0 => 'Normal',
        1 => 'Music Videos',
        2 => 'Trailers',
        3 => 'News',
        4 => 'Short Stories',
        _ => 'Other',
      };
}

class AdRevenueEstimate {
  double ecpmRate;
  int revenueSharePercent;
  int totalImpressions;
  int periodImpressions;
  double estimatedTotalRevenue;
  double estimatedPeriodRevenue;

  AdRevenueEstimate({
    this.ecpmRate = 0,
    this.revenueSharePercent = 0,
    this.totalImpressions = 0,
    this.periodImpressions = 0,
    this.estimatedTotalRevenue = 0,
    this.estimatedPeriodRevenue = 0,
  });

  factory AdRevenueEstimate.fromJson(dynamic json) {
    return AdRevenueEstimate(
      ecpmRate: (json['ecpm_rate'] ?? 0).toDouble(),
      revenueSharePercent: json['revenue_share_percent'] ?? 0,
      totalImpressions: json['total_impressions'] ?? 0,
      periodImpressions: json['period_impressions'] ?? 0,
      estimatedTotalRevenue: (json['estimated_total_revenue'] ?? 0).toDouble(),
      estimatedPeriodRevenue: (json['estimated_period_revenue'] ?? 0).toDouble(),
    );
  }
}

class ChartDataPoint {
  String date;
  int posts;
  int views;
  int likes;

  ChartDataPoint({
    this.date = '',
    this.posts = 0,
    this.views = 0,
    this.likes = 0,
  });

  factory ChartDataPoint.fromJson(dynamic json) {
    return ChartDataPoint(
      date: json['date'] ?? '',
      posts: json['posts'] ?? 0,
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }
}

class FollowerChartPoint {
  String date;
  int newFollowers;

  FollowerChartPoint({this.date = '', this.newFollowers = 0});

  factory FollowerChartPoint.fromJson(dynamic json) {
    return FollowerChartPoint(
      date: json['date'] ?? '',
      newFollowers: json['new_followers'] ?? 0,
    );
  }
}

// ─── Audience Insights Model ─────────────────────────────────────

class AudienceInsightsModel {
  bool? status;
  String? message;
  AudienceInsightsData? data;

  AudienceInsightsModel({this.status, this.message, this.data});

  factory AudienceInsightsModel.fromJson(dynamic json) {
    return AudienceInsightsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? AudienceInsightsData.fromJson(json['data'])
          : null,
    );
  }
}

class AudienceInsightsData {
  List<User>? topFollowers;
  List<TopGifter>? topGifters;
  List<FollowerChartPoint>? followerActivity;
  int totalFollowers;
  int totalFollowing;

  AudienceInsightsData({
    this.topFollowers,
    this.topGifters,
    this.followerActivity,
    this.totalFollowers = 0,
    this.totalFollowing = 0,
  });

  factory AudienceInsightsData.fromJson(dynamic json) {
    return AudienceInsightsData(
      topFollowers: json['top_followers'] != null
          ? (json['top_followers'] as List)
              .map((v) => User.fromJson(v))
              .toList()
          : null,
      topGifters: json['top_gifters'] != null
          ? (json['top_gifters'] as List)
              .map((v) => TopGifter.fromJson(v))
              .toList()
          : null,
      followerActivity: json['follower_activity'] != null
          ? (json['follower_activity'] as List)
              .map((v) => FollowerChartPoint.fromJson(v))
              .toList()
          : null,
      totalFollowers: json['total_followers'] ?? 0,
      totalFollowing: json['total_following'] ?? 0,
    );
  }
}

class TopGifter {
  User? user;
  int totalCoins;
  int giftCount;

  TopGifter({this.user, this.totalCoins = 0, this.giftCount = 0});

  factory TopGifter.fromJson(dynamic json) {
    return TopGifter(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      totalCoins: json['total_coins'] ?? 0,
      giftCount: json['gift_count'] ?? 0,
    );
  }
}

// ─── Post Analytics Model ────────────────────────────────────────

class PostAnalyticsModel {
  bool? status;
  String? message;
  PostAnalyticsData? data;

  PostAnalyticsModel({this.status, this.message, this.data});

  factory PostAnalyticsModel.fromJson(dynamic json) {
    return PostAnalyticsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? PostAnalyticsData.fromJson(json['data'])
          : null,
    );
  }
}

class PostAnalyticsData {
  Post? post;
  PostAnalyticsStats? analytics;

  PostAnalyticsData({this.post, this.analytics});

  factory PostAnalyticsData.fromJson(dynamic json) {
    return PostAnalyticsData(
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
      analytics: json['analytics'] != null
          ? PostAnalyticsStats.fromJson(json['analytics'])
          : null,
    );
  }
}

class PostAnalyticsStats {
  int views;
  int likes;
  int comments;
  int shares;
  int saves;
  double engagementRate;
  double avgDailyViews;
  int daysSinceCreation;
  String? createdAt;
  double estimatedRevenue;

  PostAnalyticsStats({
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.engagementRate = 0,
    this.avgDailyViews = 0,
    this.daysSinceCreation = 0,
    this.createdAt,
    this.estimatedRevenue = 0,
  });

  factory PostAnalyticsStats.fromJson(dynamic json) {
    return PostAnalyticsStats(
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      saves: json['saves'] ?? 0,
      engagementRate: (json['engagement_rate'] ?? 0).toDouble(),
      avgDailyViews: (json['avg_daily_views'] ?? 0).toDouble(),
      daysSinceCreation: json['days_since_creation'] ?? 0,
      createdAt: json['created_at'],
      estimatedRevenue: (json['estimated_revenue'] ?? 0).toDouble(),
    );
  }
}

// ─── Search Insights ─────────────────────────────────────────

class SearchInsightsModel {
  bool? status;
  String? message;
  SearchInsightsData? data;

  SearchInsightsModel({this.status, this.message, this.data});

  factory SearchInsightsModel.fromJson(dynamic json) {
    return SearchInsightsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? SearchInsightsData.fromJson(json['data'])
          : null,
    );
  }
}

class SearchInsightsData {
  String? period;
  int totalSearches;
  int uniqueSearchers;
  List<TrendingSearch>? trendingSearches;
  List<SearchVolumePoint>? searchVolume;
  List<RisingSearch>? risingSearches;
  List<LowResultSearch>? lowResultSearches;

  SearchInsightsData({
    this.period,
    this.totalSearches = 0,
    this.uniqueSearchers = 0,
    this.trendingSearches,
    this.searchVolume,
    this.risingSearches,
    this.lowResultSearches,
  });

  factory SearchInsightsData.fromJson(dynamic json) {
    return SearchInsightsData(
      period: json['period'],
      totalSearches: json['total_searches'] ?? 0,
      uniqueSearchers: json['unique_searchers'] ?? 0,
      trendingSearches: json['trending_searches'] != null
          ? (json['trending_searches'] as List)
              .map((v) => TrendingSearch.fromJson(v))
              .toList()
          : null,
      searchVolume: json['search_volume'] != null
          ? (json['search_volume'] as List)
              .map((v) => SearchVolumePoint.fromJson(v))
              .toList()
          : null,
      risingSearches: json['rising_searches'] != null
          ? (json['rising_searches'] as List)
              .map((v) => RisingSearch.fromJson(v))
              .toList()
          : null,
      lowResultSearches: json['low_result_searches'] != null
          ? (json['low_result_searches'] as List)
              .map((v) => LowResultSearch.fromJson(v))
              .toList()
          : null,
    );
  }
}

class TrendingSearch {
  String? term;
  int searchCount;
  int uniqueUsers;
  int avgResults;

  TrendingSearch({
    this.term,
    this.searchCount = 0,
    this.uniqueUsers = 0,
    this.avgResults = 0,
  });

  factory TrendingSearch.fromJson(dynamic json) {
    return TrendingSearch(
      term: json['term'],
      searchCount: json['search_count'] ?? 0,
      uniqueUsers: json['unique_users'] ?? 0,
      avgResults: (json['avg_results'] ?? 0).toInt(),
    );
  }
}

class SearchVolumePoint {
  String? date;
  int searches;
  int uniqueSearchers;

  SearchVolumePoint({
    this.date,
    this.searches = 0,
    this.uniqueSearchers = 0,
  });

  factory SearchVolumePoint.fromJson(dynamic json) {
    return SearchVolumePoint(
      date: json['date'],
      searches: json['searches'] ?? 0,
      uniqueSearchers: json['unique_searchers'] ?? 0,
    );
  }
}

class RisingSearch {
  String? term;
  int recentCount;
  int olderCount;
  int totalCount;

  RisingSearch({
    this.term,
    this.recentCount = 0,
    this.olderCount = 0,
    this.totalCount = 0,
  });

  factory RisingSearch.fromJson(dynamic json) {
    return RisingSearch(
      term: json['term'],
      recentCount: json['recent_count'] ?? 0,
      olderCount: json['older_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
    );
  }
}

class LowResultSearch {
  String? term;
  int searchCount;
  int avgResults;

  LowResultSearch({
    this.term,
    this.searchCount = 0,
    this.avgResults = 0,
  });

  factory LowResultSearch.fromJson(dynamic json) {
    return LowResultSearch(
      term: json['term'],
      searchCount: json['search_count'] ?? 0,
      avgResults: (json['avg_results'] ?? 0).toInt(),
    );
  }
}
