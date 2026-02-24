import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/location/friends_map_model.dart';

class FriendsMapService {
  FriendsMapService._();

  static final FriendsMapService instance = FriendsMapService._();

  Future<StatusModel> updateLocation({
    required double lat,
    required double lon,
  }) async {
    StatusModel response = await ApiService.instance.call(
      url: WebService.friendsMap.updateLocation,
      fromJson: StatusModel.fromJson,
      param: {'lat': lat, 'lon': lon},
    );
    return response;
  }

  Future<ToggleSharingResponse> toggleSharing() async {
    ToggleSharingResponse response = await ApiService.instance.call(
      url: WebService.friendsMap.toggleSharing,
      fromJson: ToggleSharingResponse.fromJson,
      param: {},
    );
    return response;
  }

  Future<SharingStatusResponse> fetchMyStatus() async {
    SharingStatusResponse response = await ApiService.instance.call(
      url: WebService.friendsMap.fetchMyStatus,
      fromJson: SharingStatusResponse.fromJson,
      param: {},
    );
    return response;
  }

  Future<FriendsLocationsResponse> fetchFriendsLocations() async {
    FriendsLocationsResponse response = await ApiService.instance.call(
      url: WebService.friendsMap.fetchFriendsLocations,
      fromJson: FriendsLocationsResponse.fromJson,
      param: {},
    );
    return response;
  }
}
