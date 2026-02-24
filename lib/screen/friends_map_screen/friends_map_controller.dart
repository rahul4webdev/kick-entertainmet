import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/friends_map_service.dart';
import 'package:shortzz/common/service/location/location_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/location/friends_map_model.dart';

class FriendsMapController extends BaseController {
  RxBool isSharing = false.obs;
  RxBool isLoadingData = true.obs;
  RxList<FriendLocation> friends = <FriendLocation>[].obs;
  Rx<LatLng?> myLocation = Rx(null);

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    isLoadingData.value = true;
    await Future.wait([
      _fetchMyStatus(),
      _fetchMyLocation(),
      fetchFriendsLocations(),
    ]);
    isLoadingData.value = false;
  }

  Future<void> _fetchMyStatus() async {
    try {
      final response = await FriendsMapService.instance.fetchMyStatus();
      if (response.data != null) {
        isSharing.value = response.data!.isSharing;
      }
    } catch (_) {}
  }

  Future<void> _fetchMyLocation() async {
    try {
      Position position = await LocationService.instance.getCurrentLocation();
      myLocation.value = LatLng(position.latitude, position.longitude);
      // Update server with current location
      if (isSharing.value) {
        await FriendsMapService.instance.updateLocation(
          lat: position.latitude,
          lon: position.longitude,
        );
      }
    } catch (_) {}
  }

  Future<void> fetchFriendsLocations() async {
    try {
      final response =
          await FriendsMapService.instance.fetchFriendsLocations();
      if (response.data != null) {
        friends.assignAll(response.data!);
      }
    } catch (_) {}
  }

  Future<void> toggleSharing() async {
    try {
      final response = await FriendsMapService.instance.toggleSharing();
      if (response.status == true && response.data != null) {
        isSharing.value = response.data!.isSharing;
        showSnackBar(isSharing.value
            ? LKey.locationSharingEnabled.tr
            : LKey.locationSharingDisabled.tr);

        // If just enabled, update location on server
        if (isSharing.value && myLocation.value != null) {
          await FriendsMapService.instance.updateLocation(
            lat: myLocation.value!.latitude,
            lon: myLocation.value!.longitude,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> refresh() async {
    await Future.wait([
      _fetchMyLocation(),
      fetchFriendsLocations(),
    ]);
  }
}
