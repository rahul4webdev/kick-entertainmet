class LocationReviewsResponse {
  bool? status;
  String? message;
  LocationReviewsData? data;

  LocationReviewsResponse({this.status, this.message, this.data});

  LocationReviewsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = LocationReviewsData.fromJson(json['data']);
    }
  }
}

class LocationReviewsData {
  List<LocationReview>? reviews;
  int reviewCount;
  double avgRating;

  LocationReviewsData({
    this.reviews,
    this.reviewCount = 0,
    this.avgRating = 0.0,
  });

  LocationReviewsData.fromJson(Map<String, dynamic> json)
      : reviewCount = json['review_count'] ?? 0,
        avgRating = (json['avg_rating'] ?? 0).toDouble() {
    if (json['reviews'] != null) {
      reviews = (json['reviews'] as List)
          .map((e) => LocationReview.fromJson(e))
          .toList();
    }
  }
}

class LocationReviewListModel {
  bool? status;
  String? message;
  List<LocationReview>? data;

  LocationReviewListModel({this.status, this.message, this.data});

  LocationReviewListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => LocationReview.fromJson(e))
          .toList();
    }
  }
}

class LocationReviewModel {
  bool? status;
  String? message;
  LocationReview? data;

  LocationReviewModel({this.status, this.message, this.data});

  LocationReviewModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = LocationReview.fromJson(json['data']);
    }
  }
}

class LocationReview {
  int? id;
  int? userId;
  String? placeTitle;
  double? placeLat;
  double? placeLon;
  int rating;
  String? reviewText;
  List<String>? photos;
  List<String>? photoUrls;
  String? createdAt;
  ReviewerUser? reviewer;

  LocationReview({
    this.id,
    this.userId,
    this.placeTitle,
    this.placeLat,
    this.placeLon,
    this.rating = 0,
    this.reviewText,
    this.photos,
    this.photoUrls,
    this.createdAt,
    this.reviewer,
  });

  LocationReview.fromJson(Map<String, dynamic> json) : rating = json['rating'] ?? 0 {
    id = json['id'];
    userId = json['user_id'];
    placeTitle = json['place_title'];
    placeLat = (json['place_lat'] as num?)?.toDouble();
    placeLon = (json['place_lon'] as num?)?.toDouble();
    reviewText = json['review_text'];
    if (json['photos'] != null) {
      photos = List<String>.from(json['photos']);
    }
    if (json['photo_urls'] != null) {
      photoUrls = List<String>.from(json['photo_urls']);
    }
    createdAt = json['created_at'];
    if (json['reviewer'] != null) {
      reviewer = ReviewerUser.fromJson(json['reviewer']);
    }
  }

  String get starsDisplay => '★' * rating + '☆' * (5 - rating);
}

class ReviewerUser {
  int? id;
  String? username;
  String? fullname;
  String? profilePhoto;

  ReviewerUser({this.id, this.username, this.fullname, this.profilePhoto});

  ReviewerUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullname = json['fullname'];
    profilePhoto = json['profile_photo'];
  }
}
