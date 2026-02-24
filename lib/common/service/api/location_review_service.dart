import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/location/location_review_model.dart';

class LocationReviewService {
  LocationReviewService._();

  static final LocationReviewService instance = LocationReviewService._();

  Future<LocationReviewModel> submitReview({
    required String placeTitle,
    required double placeLat,
    required double placeLon,
    required int rating,
    String? reviewText,
  }) async {
    LocationReviewModel response = await ApiService.instance.call(
      url: WebService.locationReview.submit,
      fromJson: LocationReviewModel.fromJson,
      param: {
        'place_title': placeTitle,
        'place_lat': placeLat,
        'place_lon': placeLon,
        'rating': rating,
        if (reviewText != null) 'review_text': reviewText,
      },
    );
    return response;
  }

  Future<LocationReviewsResponse> fetchLocationReviews({
    required String placeTitle,
    required double placeLat,
    required double placeLon,
    int? lastItemId,
  }) async {
    LocationReviewsResponse response = await ApiService.instance.call(
      url: WebService.locationReview.fetch,
      fromJson: LocationReviewsResponse.fromJson,
      param: {
        'place_title': placeTitle,
        'place_lat': placeLat,
        'place_lon': placeLon,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
    );
    return response;
  }

  Future<LocationReviewListModel> fetchMyReviews({int? lastItemId}) async {
    LocationReviewListModel response = await ApiService.instance.call(
      url: WebService.locationReview.fetchMy,
      fromJson: LocationReviewListModel.fromJson,
      param: {
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
    );
    return response;
  }

  Future<StatusModel> deleteReview({required int reviewId}) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.locationReview.delete,
      fromJson: StatusModel.fromJson,
      param: {'review_id': reviewId},
    );
    return response;
  }
}
