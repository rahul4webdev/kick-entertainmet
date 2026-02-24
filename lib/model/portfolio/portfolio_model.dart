class PortfolioResponse {
  bool? status;
  String? message;
  PortfolioData? data;

  PortfolioResponse({this.status, this.message, this.data});

  PortfolioResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? PortfolioData.fromJson(json['data']) : null;
  }
}

class PortfolioData {
  Portfolio? portfolio;

  PortfolioData({this.portfolio});

  PortfolioData.fromJson(Map<String, dynamic> json) {
    portfolio = json['portfolio'] != null
        ? Portfolio.fromJson(json['portfolio'])
        : null;
  }
}

class Portfolio {
  int? id;
  int? userId;
  String? slug;
  bool? isActive;
  String? theme;
  Map<String, dynamic>? customColors;
  String? headline;
  String? bioOverride;
  List<int>? featuredPostIds;
  bool? showProducts;
  bool? showLinks;
  bool? showSubscriptionCta;
  int? viewCount;
  String? portfolioUrl;
  List<PortfolioSection>? sections;
  String? createdAt;
  String? updatedAt;

  Portfolio({
    this.id,
    this.userId,
    this.slug,
    this.isActive,
    this.theme,
    this.customColors,
    this.headline,
    this.bioOverride,
    this.featuredPostIds,
    this.showProducts,
    this.showLinks,
    this.showSubscriptionCta,
    this.viewCount,
    this.portfolioUrl,
    this.sections,
    this.createdAt,
    this.updatedAt,
  });

  Portfolio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    slug = json['slug'];
    isActive = json['is_active'];
    theme = json['theme'];
    customColors = json['custom_colors'] != null
        ? Map<String, dynamic>.from(json['custom_colors'])
        : null;
    headline = json['headline'];
    bioOverride = json['bio_override'];
    if (json['featured_post_ids'] != null) {
      featuredPostIds = List<int>.from(
        (json['featured_post_ids'] as List).map((e) => e is int ? e : int.parse(e.toString())),
      );
    }
    showProducts = json['show_products'];
    showLinks = json['show_links'];
    showSubscriptionCta = json['show_subscription_cta'];
    viewCount = json['view_count'];
    portfolioUrl = json['portfolio_url'];
    if (json['sections'] != null) {
      sections = (json['sections'] as List)
          .map((e) => PortfolioSection.fromJson(e))
          .toList();
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class PortfolioSection {
  int? id;
  String? sectionType;
  String? title;
  String? content;
  Map<String, dynamic>? data;
  int? sortOrder;
  bool? isVisible;

  PortfolioSection({
    this.id,
    this.sectionType,
    this.title,
    this.content,
    this.data,
    this.sortOrder,
    this.isVisible,
  });

  PortfolioSection.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sectionType = json['section_type'];
    title = json['title'];
    content = json['content'];
    data = json['data'] != null ? Map<String, dynamic>.from(json['data']) : null;
    sortOrder = json['sort_order'];
    isVisible = json['is_visible'];
  }
}
