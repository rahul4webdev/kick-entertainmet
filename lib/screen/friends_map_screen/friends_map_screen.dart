import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/location/friends_map_model.dart';
import 'package:shortzz/screen/friends_map_screen/friends_map_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FriendsMapScreen extends StatelessWidget {
  const FriendsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FriendsMapController());

    return Scaffold(
      backgroundColor: bgLightGrey(context),
      body: Column(
        children: [
          CustomAppBar(
            title: LKey.friendsMap.tr,
            rowWidget: Obx(() => GestureDetector(
                  onTap: controller.toggleSharing,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      controller.isSharing.value
                          ? Icons.location_on_rounded
                          : Icons.location_off_rounded,
                      color: controller.isSharing.value
                          ? themeAccentSolid(context)
                          : textLightGrey(context),
                      size: 24,
                    ),
                  ),
                )),
          ),
          // Sharing status bar
          Obx(() => Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: controller.isSharing.value
                    ? themeAccentSolid(context).withValues(alpha: 0.1)
                    : bgMediumGrey(context),
                child: Row(
                  children: [
                    Icon(
                      controller.isSharing.value
                          ? Icons.my_location_rounded
                          : Icons.location_disabled_rounded,
                      size: 16,
                      color: controller.isSharing.value
                          ? themeAccentSolid(context)
                          : textLightGrey(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.isSharing.value
                          ? LKey.sharingYourLocation.tr
                          : LKey.notSharingLocation.tr,
                      style: TextStyleCustom.outFitRegular400(
                        color: controller.isSharing.value
                            ? themeAccentSolid(context)
                            : textLightGrey(context),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: controller.toggleSharing,
                      child: Text(
                        controller.isSharing.value ? 'Turn Off' : 'Turn On',
                        style: TextStyleCustom.outFitMedium500(
                          color: themeAccentSolid(context),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          // Map or loading
          Expanded(
            child: Obx(() {
              if (controller.isLoadingData.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final myLoc = controller.myLocation.value;
              if (myLoc == null) {
                return Center(
                  child: NoDataView(
                    title: LKey.noFriendsOnMap.tr,
                    description: LKey.noFriendsOnMapDesc.tr,
                  ),
                );
              }

              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: myLoc,
                      zoom: 13,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: false,
                    markers: _buildMarkers(controller),
                  ),
                  // Friends list at bottom
                  if (controller.friends.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              whitePure(context).withValues(alpha: 0),
                              whitePure(context),
                            ],
                          ),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 30),
                          itemCount: controller.friends.length,
                          itemBuilder: (context, index) {
                            return _FriendChip(
                              friend: controller.friends[index],
                            );
                          },
                        ),
                      ),
                    ),
                  // Refresh button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: controller.refresh,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: whitePure(context),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  blackPure(context).withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.refresh_rounded,
                            color: textDarkGrey(context), size: 22),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(FriendsMapController controller) {
    final markers = <Marker>{};
    for (final friend in controller.friends) {
      if (friend.lat != null && friend.lon != null) {
        markers.add(Marker(
          markerId: MarkerId('friend_${friend.userId}'),
          position: LatLng(friend.lat!, friend.lon!),
          infoWindow: InfoWindow(
            title: friend.user?.fullname ?? friend.user?.username ?? '',
            snippet: LKey.lastUpdated.tr,
          ),
        ));
      }
    }
    return markers;
  }
}

class _FriendChip extends StatelessWidget {
  final FriendLocation friend;

  const _FriendChip({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: whitePure(context),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: blackPure(context).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomImage(
            size: const Size(32, 32),
            image: friend.user?.profilePhoto,
            radius: 16,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                friend.user?.fullname ?? friend.user?.username ?? '',
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 13),
              ),
              Text(
                '@${friend.user?.username ?? ''}',
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
