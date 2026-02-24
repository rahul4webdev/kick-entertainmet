import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/portfolio/portfolio_model.dart';

class PortfolioService {
  PortfolioService._();
  static final PortfolioService instance = PortfolioService._();

  Future<PortfolioResponse> createOrUpdate({
    String? slug,
    bool? isActive,
    String? theme,
    Map<String, dynamic>? customColors,
    String? headline,
    String? bioOverride,
    List<int>? featuredPostIds,
    bool? showProducts,
    bool? showLinks,
    bool? showSubscriptionCta,
  }) async {
    return await ApiService.instance.call(
      url: WebService.portfolio.createOrUpdate,
      fromJson: PortfolioResponse.fromJson,
      param: {
        if (slug != null) 'slug': slug,
        if (isActive != null) 'is_active': isActive,
        if (theme != null) 'theme': theme,
        if (customColors != null) 'custom_colors': customColors,
        if (headline != null) 'headline': headline,
        if (bioOverride != null) 'bio_override': bioOverride,
        if (featuredPostIds != null) 'featured_post_ids': featuredPostIds,
        if (showProducts != null) 'show_products': showProducts,
        if (showLinks != null) 'show_links': showLinks,
        if (showSubscriptionCta != null) 'show_subscription_cta': showSubscriptionCta,
      },
    );
  }

  Future<PortfolioResponse> fetchMine() async {
    return await ApiService.instance.call(
      url: WebService.portfolio.fetchMine,
      fromJson: PortfolioResponse.fromJson,
      param: {},
    );
  }

  Future<PortfolioResponse> addSection({
    required String sectionType,
    String? title,
    String? content,
    Map<String, dynamic>? data,
    int? sortOrder,
  }) async {
    return await ApiService.instance.call(
      url: WebService.portfolio.addSection,
      fromJson: PortfolioResponse.fromJson,
      param: {
        'section_type': sectionType,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (data != null) 'data': data,
        if (sortOrder != null) 'sort_order': sortOrder,
      },
    );
  }

  Future<PortfolioResponse> updateSection({
    required int sectionId,
    String? sectionType,
    String? title,
    String? content,
    Map<String, dynamic>? data,
    int? sortOrder,
    bool? isVisible,
  }) async {
    return await ApiService.instance.call(
      url: WebService.portfolio.updateSection,
      fromJson: PortfolioResponse.fromJson,
      param: {
        'section_id': sectionId,
        if (sectionType != null) 'section_type': sectionType,
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (data != null) 'data': data,
        if (sortOrder != null) 'sort_order': sortOrder,
        if (isVisible != null) 'is_visible': isVisible,
      },
    );
  }

  Future<PortfolioResponse> removeSection({required int sectionId}) async {
    return await ApiService.instance.call(
      url: WebService.portfolio.removeSection,
      fromJson: PortfolioResponse.fromJson,
      param: {'section_id': sectionId},
    );
  }

  Future<PortfolioResponse> reorderSections({
    required List<Map<String, int>> orders,
  }) async {
    return await ApiService.instance.call(
      url: WebService.portfolio.reorderSections,
      fromJson: PortfolioResponse.fromJson,
      param: {'orders': orders},
    );
  }
}
