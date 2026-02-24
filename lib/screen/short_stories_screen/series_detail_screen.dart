import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/content/series_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/content_screen/widget/content_reel_page.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SeriesDetailScreen extends StatefulWidget {
  final SeriesItem series;

  const SeriesDetailScreen({super.key, required this.series});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  final RxList<Post> _episodes = <Post>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    _isLoading.value = true;
    try {
      final result = await PostService.instance.fetchSeriesEpisodes(
        seriesId: widget.series.id ?? 0,
        limit: 50,
      );
      if (result.status == true && result.data != null) {
        _episodes.value = result.data!;
      }
    } catch (_) {}
    _isLoading.value = false;
  }

  void _playEpisode(int index) {
    // Open a full-screen vertical PageView starting at the selected episode
    Get.to(() => _EpisodePlayerScreen(
      episodes: _episodes,
      initialIndex: index,
      seriesTitle: widget.series.title ?? '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackPure(context),
      body: CustomScrollView(
        slivers: [
          // App bar with cover image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: blackPure(context),
            iconTheme: IconThemeData(color: whitePure(context)),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.series.title ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              background: widget.series.coverImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.series.coverImage!.addBaseURL(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade900),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(color: Colors.grey.shade900),
            ),
          ),

          // Series info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta tags
                  Row(
                    children: [
                      if (widget.series.genre != null)
                        _metaTag(widget.series.genre!, Colors.tealAccent),
                      if (widget.series.language != null) ...[
                        const SizedBox(width: 8),
                        _metaTag(widget.series.language!, Colors.blueAccent),
                      ],
                      const SizedBox(width: 8),
                      _metaTag('${widget.series.episodeCount ?? 0} Episodes', Colors.grey),
                    ],
                  ),
                  if (widget.series.description != null && widget.series.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.series.description!,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text('Episodes', style: TextStyle(color: whitePure(context), fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Episodes list
          Obx(() {
            if (_isLoading.value) {
              return SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator(color: textLightGrey(context))),
              );
            }

            if (_episodes.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text('No episodes yet', style: TextStyle(color: textLightGrey(context))),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final episode = _episodes[index];
                  final episodeNum = episode.episodeNumber ?? (index + 1);
                  return _EpisodeTile(
                    episode: episode,
                    episodeNumber: episodeNum,
                    onTap: () => _playEpisode(index),
                  );
                },
                childCount: _episodes.length,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _metaTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Post episode;
  final int episodeNumber;
  final VoidCallback onTap;

  const _EpisodeTile({required this.episode, required this.episodeNumber, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: episode.thumbnail != null
            ? Image.network(
                episode.thumbnail!.addBaseURL(),
                width: 80,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 80, height: 56, color: Colors.grey.shade800),
              )
            : Container(
                width: 80,
                height: 56,
                color: Colors.grey.shade800,
                child: const Icon(Icons.play_circle_outline, color: Colors.white54),
              ),
      ),
      title: Text(
        'Episode $episodeNumber',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: episode.description != null && episode.description!.isNotEmpty
          ? Text(
              episode.description!,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white54),
    );
  }
}

/// Full-screen PageView for playing episodes sequentially
class _EpisodePlayerScreen extends StatefulWidget {
  final List<Post> episodes;
  final int initialIndex;
  final String seriesTitle;

  const _EpisodePlayerScreen({
    required this.episodes,
    required this.initialIndex,
    required this.seriesTitle,
  });

  @override
  State<_EpisodePlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends State<_EpisodePlayerScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const CustomPageViewScrollPhysics(),
            itemCount: widget.episodes.length,
            itemBuilder: (context, index) {
              return ContentReelPage(
                post: widget.episodes[index],
                autoPlay: index == widget.initialIndex,
              );
            },
          ),

          // Back button + series title
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  widget.seriesTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
