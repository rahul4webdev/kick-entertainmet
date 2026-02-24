import 'package:shortzz/model/user_model/user_model.dart';

class MarketplaceCampaignListModel {
  bool? status;
  String? message;
  List<MarketplaceCampaign>? data;

  MarketplaceCampaignListModel({this.status, this.message, this.data});

  MarketplaceCampaignListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(MarketplaceCampaign.fromJson(v));
      });
    }
  }
}

class MarketplaceCampaignDetailModel {
  bool? status;
  String? message;
  MarketplaceCampaign? data;

  MarketplaceCampaignDetailModel({this.status, this.message, this.data});

  MarketplaceCampaignDetailModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? MarketplaceCampaign.fromJson(json['data'])
        : null;
  }
}

class MarketplaceCampaign {
  int? id;
  int? brandUserId;
  String? title;
  String? description;
  String? category;
  int? budgetCoins;
  int? minFollowers;
  int? minPosts;
  String? contentType;
  String? requirements;
  String? coverImage;
  String? coverImageUrl;
  int? status;
  int? maxCreators;
  int? acceptedCount;
  int? applicationCount;
  String? deadline;
  String? createdAt;
  String? updatedAt;
  User? brand;
  bool? hasApplied;
  List<MarketplaceProposal>? proposals;

  MarketplaceCampaign({
    this.id,
    this.brandUserId,
    this.title,
    this.description,
    this.category,
    this.budgetCoins,
    this.minFollowers,
    this.minPosts,
    this.contentType,
    this.requirements,
    this.coverImage,
    this.coverImageUrl,
    this.status,
    this.maxCreators,
    this.acceptedCount,
    this.applicationCount,
    this.deadline,
    this.createdAt,
    this.updatedAt,
    this.brand,
    this.hasApplied,
    this.proposals,
  });

  MarketplaceCampaign.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brandUserId = json['brand_user_id'];
    title = json['title'];
    description = json['description'];
    category = json['category'];
    budgetCoins = json['budget_coins'];
    minFollowers = json['min_followers'];
    minPosts = json['min_posts'];
    contentType = json['content_type'];
    requirements = json['requirements'];
    coverImage = json['cover_image'];
    coverImageUrl = json['cover_image_url'];
    status = json['status'];
    maxCreators = json['max_creators'];
    acceptedCount = json['accepted_count'];
    applicationCount = json['application_count'];
    deadline = json['deadline'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    brand = json['brand'] != null ? User.fromJson(json['brand']) : null;
    hasApplied = json['has_applied'];
    if (json['proposals'] != null) {
      proposals = [];
      json['proposals'].forEach((v) {
        proposals!.add(MarketplaceProposal.fromJson(v));
      });
    }
  }

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Draft';
      case 2:
        return 'Active';
      case 3:
        return 'Paused';
      case 4:
        return 'Completed';
      case 5:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  bool get isActive => status == 2;
}

class MarketplaceProposalListModel {
  bool? status;
  String? message;
  List<MarketplaceProposal>? data;

  MarketplaceProposalListModel({this.status, this.message, this.data});

  MarketplaceProposalListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(MarketplaceProposal.fromJson(v));
      });
    }
  }
}

class MarketplaceProposal {
  int? id;
  int? campaignId;
  int? brandUserId;
  int? creatorUserId;
  int? initiatedBy;
  String? message;
  int? offeredCoins;
  int? status;
  String? brandNote;
  String? creatorNote;
  int? deliverablePostId;
  String? createdAt;
  String? updatedAt;
  MarketplaceCampaign? campaign;
  User? brand;
  User? creator;

  MarketplaceProposal({
    this.id,
    this.campaignId,
    this.brandUserId,
    this.creatorUserId,
    this.initiatedBy,
    this.message,
    this.offeredCoins,
    this.status,
    this.brandNote,
    this.creatorNote,
    this.deliverablePostId,
    this.createdAt,
    this.updatedAt,
    this.campaign,
    this.brand,
    this.creator,
  });

  MarketplaceProposal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    campaignId = json['campaign_id'];
    brandUserId = json['brand_user_id'];
    creatorUserId = json['creator_user_id'];
    initiatedBy = json['initiated_by'];
    message = json['message'];
    offeredCoins = json['offered_coins'];
    status = json['status'];
    brandNote = json['brand_note'];
    creatorNote = json['creator_note'];
    deliverablePostId = json['deliverable_post_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    campaign = json['campaign'] != null
        ? MarketplaceCampaign.fromJson(json['campaign'])
        : null;
    brand = json['brand'] != null ? User.fromJson(json['brand']) : null;
    creator = json['creator'] != null ? User.fromJson(json['creator']) : null;
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Accepted';
      case 2:
        return 'Declined';
      case 3:
        return 'Completed';
      case 4:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  bool get isPending => status == 0;
  bool get isAccepted => status == 1;
  bool get isCompleted => status == 3;
  bool get isFromBrand => initiatedBy == 1;
  bool get isFromCreator => initiatedBy == 2;
}
