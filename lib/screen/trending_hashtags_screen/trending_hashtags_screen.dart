import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/social_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/model/social/trending_hashtag_model.dart';
import 'package:shortzz/screen/hashtag_screen/hashtag_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TrendingHashtagsScreen extends StatefulWidget {
  const TrendingHashtagsScreen({super.key});

  @override
  State<TrendingHashtagsScreen> createState() =>
      _TrendingHashtagsScreenState();
}

class _TrendingHashtagsScreenState extends State<TrendingHashtagsScreen> {
  List<TrendingHashtag> hashtags = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final result = await SocialService.instance.fetchTrendingHashtags();
    setState(() {
      hashtags = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Trending'),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hashtags.isEmpty
                    ? Center(
                        child: Text('No trending hashtags yet',
                            style: TextStyleCustom.outFitRegular400(
                                fontSize: 14,
                                color: textLightGrey(context))),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: hashtags.length,
                          itemBuilder: (context, index) {
                            final tag = hashtags[index];
                            return _buildHashtagTile(context, tag, index);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHashtagTile(
      BuildContext context, TrendingHashtag tag, int index) {
    return InkWell(
      onTap: () {
        Get.to(() => HashtagScreen(hashtag: tag.hashtag ?? ''));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: bgMediumGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor(context).withValues(alpha: 0.15),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyleCustom.outFitBold700(
                    fontSize: 14, color: themeColor(context)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${tag.hashtag ?? ''}',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 15, color: blackPure(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatCount(tag.postCount ?? 0)} posts',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: textLightGrey(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 20, color: textLightGrey(context)),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
