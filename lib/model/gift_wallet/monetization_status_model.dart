class MonetizationStatusModel {
  bool? status;
  String? message;
  MonetizationStatusData? data;

  MonetizationStatusModel({this.status, this.message, this.data});

  MonetizationStatusModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? MonetizationStatusData.fromJson(json['data'])
        : null;
  }
}

class MonetizationStatusData {
  int? isMonetized;
  int? monetizationStatus;
  int? followerCount;
  int? minFollowersRequired;
  int? businessStatus;
  bool? hasKycDocuments;
  List<VerificationDoc>? verificationDocuments;
  MonetizationRequirements? requirements;

  MonetizationStatusData({
    this.isMonetized,
    this.monetizationStatus,
    this.followerCount,
    this.minFollowersRequired,
    this.businessStatus,
    this.hasKycDocuments,
    this.verificationDocuments,
    this.requirements,
  });

  MonetizationStatusData.fromJson(Map<String, dynamic> json) {
    isMonetized = json['is_monetized'];
    monetizationStatus = json['monetization_status'];
    followerCount = json['follower_count'];
    minFollowersRequired = json['min_followers_required'];
    businessStatus = json['business_status'];
    hasKycDocuments = json['has_kyc_documents'];
    if (json['verification_documents'] != null) {
      verificationDocuments = [];
      json['verification_documents'].forEach((v) {
        verificationDocuments?.add(VerificationDoc.fromJson(v));
      });
    }
    requirements = json['requirements'] != null
        ? MonetizationRequirements.fromJson(json['requirements'])
        : null;
  }
}

class MonetizationRequirements {
  bool? hasMinFollowers;
  bool? hasApprovedBusiness;
  bool? hasKycUploaded;

  MonetizationRequirements({
    this.hasMinFollowers,
    this.hasApprovedBusiness,
    this.hasKycUploaded,
  });

  MonetizationRequirements.fromJson(Map<String, dynamic> json) {
    hasMinFollowers = json['has_min_followers'];
    hasApprovedBusiness = json['has_approved_business'];
    hasKycUploaded = json['has_kyc_uploaded'];
  }
}

class VerificationDoc {
  int? id;
  int? userId;
  String? documentType;
  String? documentUrl;
  int? status;
  String? rejectionReason;
  String? verifiedAt;
  String? createdAt;
  String? updatedAt;

  VerificationDoc({
    this.id,
    this.userId,
    this.documentType,
    this.documentUrl,
    this.status,
    this.rejectionReason,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  VerificationDoc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    documentType = json['document_type'];
    documentUrl = json['document_url'];
    status = json['status'];
    rejectionReason = json['rejection_reason'];
    verifiedAt = json['verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Approved';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
