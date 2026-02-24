import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shortzz/common/extensions/common_extension.dart';
import 'package:shortzz/common/widget/custom_divider.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/custom_tab_switcher.dart';
import 'package:shortzz/common/widget/load_more_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/post_list.dart';
import 'package:shortzz/common/widget/reel_list.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/location/location_review_model.dart';
import 'package:shortzz/screen/location_screen/location_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LocationScreen extends StatelessWidget {
  final LatLng latLng;
  final String placeTitle;

  const LocationScreen(
      {super.key, required this.latLng, required this.placeTitle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
        LocationScreenController(latLng.obs, placeTitle.obs),
        tag: DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => GoogleMap(
                onTap: controller.onMapTap,
                initialCameraPosition:
                    CameraPosition(target: latLng, zoom: 14.4746),
                onMapCreated: controller.onMapCreated,
                markers: controller.marker.values.toSet(),
                compassEnabled: false),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: Get.back,
                  child: Container(
                    width: 37,
                    height: 37,
                    margin: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: whitePure(context),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: blackPure(context).withValues(alpha: .15),
                            offset: const Offset(0, 4),
                            blurRadius: 11.6)
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(AssetRes.icClose,
                        color: textLightGrey(context), height: 20, width: 20),
                  ),
                ),
                Expanded(
                  child: SizedBox.expand(
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      maxChildSize: 1,
                      minChildSize: 0.5,
                      builder: (context, scrollController) {
                        return Container(
                          margin: EdgeInsets.only(
                              top: AppBar().preferredSize.height),
                          decoration: BoxDecoration(
                            color: whitePure(context),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30)),
                            boxShadow: [
                              BoxShadow(
                                  color: blackPure(context)
                                      .withValues(alpha: 0.15),
                                  offset: const Offset(0, 4),
                                  blurRadius: 11.6)
                            ],
                          ),
                          child: ClipSmoothRect(
                            radius: const SmoothBorderRadius.vertical(
                                top: SmoothRadius(
                                    cornerRadius: 40, cornerSmoothing: 1)),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Make customWidget draggable
                                // Ensuring customWidget allows dragging of DraggableScrollableSheet
                                SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    controller: scrollController,
                                    child: customWidget(context, controller)),
                                // Scrollable content
                                Expanded(
                                  child: LoadMoreWidget(
                                    loadMore: controller.fetchMoreData,
                                    child: ListView(
                                      controller: scrollController,
                                      children: [
                                        ExpandablePageView(
                                          controller: controller.pageController,
                                          onPageChanged: (value) {
                                            controller.selectedTabIndex.value =
                                                value;
                                          },
                                          children: [
                                            ReelList(
                                                onFetchMoreData:
                                                    controller.fetchReels,
                                                shrinkWrap: true,
                                                reels: controller.reels,
                                                isLoading:
                                                    controller.isReelLoading),
                                            PostList(
                                              shrinkWrap: true,
                                              posts: controller.posts,
                                              isLoading:
                                                  controller.isPostLoading,
                                              onFetchMoreData:
                                                  controller.fetchPosts,
                                            ),
                                            _ReviewsTab(controller: controller),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget customWidget(
      BuildContext context, LocationScreenController controller) {
    return Container(
      height: 155,
      color: whitePure(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CustomDivider(
                color: bgGrey(context),
                margin: const EdgeInsets.only(top: 10, bottom: 15),
                height: 1,
                width: 100),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.placeTitle.value,
                      style: TextStyleCustom.unboundedSemiBold600(
                          color: textDarkGrey(context), fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${controller.latLng.value.getDistance} ${LKey.km.tr}',
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomTabSwitcher(
            items: [LKey.reels.tr, LKey.feed.tr, LKey.locationReviews.tr],
            onTap: (index) {
              controller.onPageChanged(index);
              controller.pageController.animateToPage(index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.linear);
            },
            selectedIndex: controller.selectedTabIndex,
            margin: const EdgeInsets.all(15),
          )
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final LocationScreenController controller;

  const _ReviewsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isReviewLoading.value && controller.reviews.isEmpty) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary + Write Review button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final avg = controller.avgRating.value;
                    final count = controller.reviewCount.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (count > 0) ...[
                          Row(
                            children: [
                              Text(
                                avg.toStringAsFixed(1),
                                style: TextStyleCustom.unboundedSemiBold600(
                                    color: textDarkGrey(context), fontSize: 22),
                              ),
                              const SizedBox(width: 6),
                              ...List.generate(5, (i) {
                                return Icon(
                                  i < avg.round()
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 18,
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            LKey.basedOnReviews.tr
                                .replaceAll('@count', '$count'),
                            style: TextStyleCustom.outFitLight300(
                                color: textLightGrey(context), fontSize: 12),
                          ),
                        ] else
                          Text(
                            LKey.noReviewsYet.tr,
                            style: TextStyleCustom.outFitRegular400(
                                color: textLightGrey(context), fontSize: 14),
                          ),
                      ],
                    );
                  }),
                ),
                GestureDetector(
                  onTap: () => _showWriteReviewSheet(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      LKey.writeLocationReview.tr,
                      style: TextStyleCustom.outFitMedium500(
                          color: whitePure(context), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomDivider(
              color: bgGrey(context),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1),
          // Reviews list
          if (controller.reviews.isEmpty && !controller.isReviewLoading.value)
            SizedBox(
              height: 150,
              child: Center(
                child: NoDataView(
                  title: LKey.noReviewsYet.tr,
                  description: LKey.noReviewsYetDesc.tr,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.reviews.length,
              separatorBuilder: (_, __) => CustomDivider(
                  color: bgGrey(context),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1),
              itemBuilder: (context, index) {
                final review = controller.reviews[index];
                return _ReviewCard(review: review, controller: controller);
              },
            ),
        ],
      );
    });
  }

  void _showWriteReviewSheet(BuildContext context) {
    int selectedRating = 0;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whitePure(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CustomDivider(
                        color: bgGrey(ctx),
                        margin: const EdgeInsets.only(bottom: 15),
                        height: 4,
                        width: 40),
                  ),
                  Text(
                    LKey.writeLocationReview.tr,
                    style: TextStyleCustom.unboundedSemiBold600(
                        color: textDarkGrey(ctx), fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    LKey.yourRating.tr,
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(ctx), fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () => setState(() => selectedRating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            i < selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 36,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(ctx), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: LKey.reviewHint.tr,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(ctx), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: bgGrey(ctx)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: bgGrey(ctx)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: themeAccentSolid(ctx)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: selectedRating == 0
                          ? null
                          : () async {
                              final success = await controller.submitReview(
                                rating: selectedRating,
                                reviewText: textController.text.trim().isEmpty
                                    ? null
                                    : textController.text.trim(),
                              );
                              if (success) {
                                Navigator.of(ctx).pop();
                                Get.snackbar(
                                  '',
                                  LKey.reviewSubmitted.tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeAccentSolid(ctx),
                        foregroundColor: whitePure(ctx),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor:
                            bgMediumGrey(ctx),
                      ),
                      child: Text(
                        LKey.submitReview.tr,
                        style: TextStyleCustom.outFitMedium500(
                          color: whitePure(ctx),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final LocationReview review;
  final LocationScreenController controller;

  const _ReviewCard({required this.review, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomImage(
                size: const Size(34, 34),
                image: review.reviewer?.profilePhoto,
                radius: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.fullname ??
                          review.reviewer?.username ??
                          '',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 13),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          return Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        if (review.createdAt != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            review.createdAt!,
                            style: TextStyleCustom.outFitLight300(
                                color: textLightGrey(context), fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.reviewText != null &&
              review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.reviewText!,
              style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
