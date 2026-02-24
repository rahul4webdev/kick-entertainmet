import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/paid_series/paid_series_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/paid_series_screen/paid_series_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PaidSeriesDetailScreen extends StatefulWidget {
  final PaidSeries series;
  final PaidSeriesController controller;

  const PaidSeriesDetailScreen({
    super.key,
    required this.series,
    required this.controller,
  });

  @override
  State<PaidSeriesDetailScreen> createState() =>
      _PaidSeriesDetailScreenState();
}

class _PaidSeriesDetailScreenState extends State<PaidSeriesDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchSeriesDetail(widget.series.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (widget.controller.isLoadingDetail.value) {
          return const LoaderWidget();
        }
        final series =
            widget.controller.selectedSeries.value ?? widget.series;
        final isPurchased = widget.controller.isSeriesPurchased.value;
        final videos = widget.controller.seriesVideos;

        return CustomScrollView(
          slivers: [
            // App bar with cover image
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              leading: const CustomBackButton(
                image: AssetRes.icBackArrow_1,
                height: 25,
                width: 25,
                padding: EdgeInsets.zero,
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: series.coverImageUrl != null
                    ? Image.network(series.coverImageUrl!, fit: BoxFit.cover)
                    : Container(
                        color: bgMediumGrey(context),
                        child: Icon(Icons.play_circle_outline,
                            size: 60, color: textLightGrey(context)),
                      ),
              ),
            ),

            // Series info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      series.title ?? '',
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 20, color: textDarkGrey(context)),
                    ),
                    const SizedBox(height: 8),
                    if (series.creator != null)
                      Row(
                        spacing: 8,
                        children: [
                          CustomImage(
                            size: const Size(32, 32),
                            image:
                                series.creator?.profilePhoto?.addBaseURL(),
                            fullName: series.creator?.fullname,
                          ),
                          Text(
                            series.creator?.username ?? '',
                            style: TextStyleCustom.outFitMedium500(
                                color: textDarkGrey(context), fontSize: 14),
                          ),
                        ],
                      ),
                    if (series.description != null &&
                        series.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        series.description!,
                        style: TextStyleCustom.outFitRegular400(
                            color: textLightGrey(context), fontSize: 14),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Stats row
                    Row(
                      spacing: 16,
                      children: [
                        _StatItem(
                            icon: Icons.play_circle_outline,
                            text: '${series.videoCount ?? 0} videos',
                            context: context),
                        _StatItem(
                            icon: Icons.shopping_bag_outlined,
                            text: '${series.purchaseCount ?? 0} ${LKey.purchases}',
                            context: context),
                        _StatItem(
                            icon: Icons.monetization_on_outlined,
                            text: '${series.priceCoins ?? 0} ${LKey.coinsText}',
                            context: context),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Purchase button (if not purchased and not creator)
                    if (!isPurchased)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              widget.controller.purchaseSeries(series),
                          icon: const Icon(Icons.lock_open,
                              color: Colors.white, size: 20),
                          label: Text(
                            LKey.purchaseForCoins
                                .replaceAll('@count', '${series.priceCoins ?? 0}'),
                            style: TextStyleCustom.outFitMedium500(
                                color: Colors.white, fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeAccentSolid(context),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 12, cornerSmoothing: 1),
                            ),
                          ),
                        ),
                      ),
                    if (!isPurchased) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          LKey.purchaseToWatch,
                          style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context), fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Videos header
                    Text(
                      '${LKey.addVideos} (${videos.length})',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Video list
            if (isPurchased && videos.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = videos[index];
                    return _VideoListItem(
                      video: video,
                      index: index,
                      context: context,
                    );
                  },
                  childCount: videos.length,
                ),
              )
            else if (!isPurchased)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: ShapeDecoration(
                      color: bgLightGrey(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 16, cornerSmoothing: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lock_outline,
                            size: 48, color: textLightGrey(context)),
                        const SizedBox(height: 8),
                        Text(
                          LKey.purchaseRequired,
                          style: TextStyleCustom.outFitMedium500(
                              color: textDarkGrey(context), fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LKey.purchaseToWatch,
                          style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final BuildContext context;

  const _StatItem(
      {required this.icon, required this.text, required this.context});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Icon(icon, size: 16, color: textLightGrey(context)),
        Text(text,
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 12)),
      ],
    );
  }
}

class _VideoListItem extends StatelessWidget {
  final Post video;
  final int index;
  final BuildContext context;

  const _VideoListItem(
      {required this.video, required this.index, required this.context});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 80,
              height: 60,
              child: video.thumbnail != null
                  ? Image.network(
                      video.thumbnail!.addBaseURL(),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: bgMediumGrey(context),
                      child: Icon(Icons.play_arrow,
                          color: textLightGrey(context)),
                    ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode ${index + 1}',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 14),
                    ),
                    if (video.description != null &&
                        video.description!.isNotEmpty)
                      Text(
                        video.description!,
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.play_circle_outline,
                  color: themeAccentSolid(context), size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
