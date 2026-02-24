import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/playlist_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/playlist/playlist_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/reels_screen/reels_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistItem playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    isLoading.value = true;
    final result = await PlaylistService.instance
        .fetchPlaylistPosts(playlistId: widget.playlist.id!);
    posts.value = result.data ?? [];
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: widget.playlist.name ?? ''),
          if (widget.playlist.description?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                widget.playlist.description!,
                style: TextStyleCustom.outFitLight300(
                  fontSize: 13,
                  color: textLightGrey(context),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            child: Obx(() {
              if (isLoading.value && posts.isEmpty) {
                return const LoaderWidget();
              }
              return RefreshIndicator(
                onRefresh: _fetchPosts,
                child: NoDataView(
                  showShow: posts.isEmpty,
                  title: LKey.noPlaylistPosts.tr,
                  description: LKey.noPlaylistPostsDesc.tr,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(2),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 9 / 16,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ReelsScreen(
                                reels: posts,
                                position: index,
                              ));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (post.thumbnail != null)
                              Image.network(
                                post.thumbnail!.addBaseURL(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: bgGrey(context),
                                  child: Icon(Icons.play_circle_outline,
                                      color: textLightGrey(context)),
                                ),
                              )
                            else
                              Container(
                                color: bgGrey(context),
                                child: Icon(Icons.play_circle_outline,
                                    color: textLightGrey(context)),
                              ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${post.views ?? 0}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 4,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
