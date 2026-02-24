import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/content/series_model.dart';
import 'package:shortzz/screen/short_stories_screen/series_detail_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ShortStoriesScreen extends StatefulWidget {
  const ShortStoriesScreen({super.key});

  @override
  State<ShortStoriesScreen> createState() => _ShortStoriesScreenState();
}

class _ShortStoriesScreenState extends State<ShortStoriesScreen> {
  final RxList<SeriesItem> _seriesList = <SeriesItem>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchSeries();
  }

  Future<void> _fetchSeries() async {
    _isLoading.value = true;
    try {
      final result = await PostService.instance.fetchSeries(limit: 30);
      if (result.status == true && result.data != null) {
        _seriesList.value = result.data!;
      }
    } catch (_) {}
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackPure(context),
      appBar: AppBar(
        backgroundColor: blackPure(context),
        title: Text('Short Stories', style: TextStyle(color: whitePure(context), fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: whitePure(context)),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return Center(child: CupertinoActivityIndicator(color: textLightGrey(context)));
        }

        if (_seriesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 64, color: textLightGrey(context)),
                const SizedBox(height: 12),
                Text('No stories yet', style: TextStyle(color: textLightGrey(context), fontSize: 16)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _fetchSeries,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _seriesList.length,
            itemBuilder: (context, index) {
              final series = _seriesList[index];
              return _SeriesCard(
                series: series,
                onTap: () {
                  Get.to(() => SeriesDetailScreen(series: series));
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  final SeriesItem series;
  final VoidCallback onTap;

  const _SeriesCard({required this.series, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Expanded(
              child: series.coverImage != null
                  ? Image.network(
                      series.coverImage!.addBaseURL(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultCover(),
                    )
                  : _defaultCover(),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    series.title ?? '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (series.genre != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(series.genre!, style: const TextStyle(color: Colors.tealAccent, fontSize: 10)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        '${series.episodeCount ?? 0} ep',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                      ),
                    ],
                  ),
                  if (series.user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      series.user!.username ?? '',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade800,
      child: const Icon(Icons.menu_book, color: Colors.white38, size: 48),
    );
  }
}
