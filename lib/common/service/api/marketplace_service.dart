import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/marketplace/marketplace_model.dart';

class MarketplaceService {
  MarketplaceService._();

  static final MarketplaceService instance = MarketplaceService._();

  // ─── Campaigns ───────────────────────────────────────────

  Future<StatusModel> createCampaign({
    required String title,
    required int budgetCoins,
    String? description,
    String? category,
    int? minFollowers,
    int? minPosts,
    String? contentType,
    String? requirements,
    int? maxCreators,
    String? deadline,
    String? coverImage,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.createCampaign,
      fromJson: StatusModel.fromJson,
      param: {
        'title': title,
        'budget_coins': budgetCoins,
        'description': description,
        'category': category,
        'min_followers': minFollowers,
        'min_posts': minPosts,
        'content_type': contentType,
        'requirements': requirements,
        'max_creators': maxCreators,
        'deadline': deadline,
        'cover_image': coverImage,
      },
    );
    return response;
  }

  Future<StatusModel> updateCampaign({
    required int campaignId,
    String? title,
    int? budgetCoins,
    String? description,
    String? category,
    int? status,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.updateCampaign,
      fromJson: StatusModel.fromJson,
      param: {
        'campaign_id': campaignId,
        'title': title,
        'budget_coins': budgetCoins,
        'description': description,
        'category': category,
        'status': status,
      },
    );
    return response;
  }

  Future<StatusModel> deleteCampaign({required int campaignId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.deleteCampaign,
      fromJson: StatusModel.fromJson,
      param: {'campaign_id': campaignId},
    );
    return response;
  }

  Future<MarketplaceCampaignListModel> fetchCampaigns({
    String? category,
    String? search,
    int? lastItemId,
    int? limit,
  }) async {
    MarketplaceCampaignListModel response = await ApiService.instance.call(
      url: WebService.marketplace.fetchCampaigns,
      fromJson: MarketplaceCampaignListModel.fromJson,
      param: {
        'category': category,
        'search': search,
        'last_item_id': lastItemId,
        'limit': limit ?? 20,
      },
    );
    return response;
  }

  Future<MarketplaceCampaignListModel> fetchMyCampaigns() async {
    MarketplaceCampaignListModel response = await ApiService.instance.call(
      url: WebService.marketplace.fetchMyCampaigns,
      fromJson: MarketplaceCampaignListModel.fromJson,
    );
    return response;
  }

  Future<MarketplaceCampaignDetailModel> fetchCampaignById({
    required int campaignId,
  }) async {
    MarketplaceCampaignDetailModel response = await ApiService.instance.call(
      url: WebService.marketplace.fetchCampaignById,
      fromJson: MarketplaceCampaignDetailModel.fromJson,
      param: {'campaign_id': campaignId},
    );
    return response;
  }

  // ─── Proposals ───────────────────────────────────────────

  Future<StatusModel> applyToCampaign({
    required int campaignId,
    String? message,
    int? offeredCoins,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.applyToCampaign,
      fromJson: StatusModel.fromJson,
      param: {
        'campaign_id': campaignId,
        'message': message,
        'offered_coins': offeredCoins,
      },
    );
    return response;
  }

  Future<StatusModel> inviteCreator({
    required int campaignId,
    required int creatorUserId,
    String? message,
    int? offeredCoins,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.inviteCreator,
      fromJson: StatusModel.fromJson,
      param: {
        'campaign_id': campaignId,
        'creator_user_id': creatorUserId,
        'message': message,
        'offered_coins': offeredCoins,
      },
    );
    return response;
  }

  Future<StatusModel> respondToProposal({
    required int proposalId,
    required String action,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.respondToProposal,
      fromJson: StatusModel.fromJson,
      param: {
        'proposal_id': proposalId,
        'action': action,
      },
    );
    return response;
  }

  Future<StatusModel> completeProposal({
    required int proposalId,
    int? deliverablePostId,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.marketplace.completeProposal,
      fromJson: StatusModel.fromJson,
      param: {
        'proposal_id': proposalId,
        'deliverable_post_id': deliverablePostId,
      },
    );
    return response;
  }

  Future<MarketplaceProposalListModel> fetchMyProposals({
    int? status,
  }) async {
    MarketplaceProposalListModel response = await ApiService.instance.call(
      url: WebService.marketplace.fetchMyProposals,
      fromJson: MarketplaceProposalListModel.fromJson,
      param: {'status': status},
    );
    return response;
  }

  Future<MarketplaceProposalListModel> fetchCampaignProposals({
    required int campaignId,
  }) async {
    MarketplaceProposalListModel response = await ApiService.instance.call(
      url: WebService.marketplace.fetchCampaignProposals,
      fromJson: MarketplaceProposalListModel.fromJson,
      param: {'campaign_id': campaignId},
    );
    return response;
  }
}
