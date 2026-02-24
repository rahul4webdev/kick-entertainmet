import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/story_view/controller/story_controller.dart';
import 'package:shortzz/common/manager/story_view/widgets/story_view.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class HighlightViewerScreen extends StatefulWidget {
  final List<StoryHighlight> highlights;
  final int initialIndex;

  const HighlightViewerScreen({
    super.key,
    required this.highlights,
    required this.initialIndex,
  });

  @override
  State<HighlightViewerScreen> createState() => _HighlightViewerScreenState();
}

class _HighlightViewerScreenState extends State<HighlightViewerScreen> {
  late PageController _pageController;
  late StoryController _storyController;
  int _currentHighlightIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentHighlightIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _storyController = StoryController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  List<StoryItem> _buildStoryItems(StoryHighlight highlight) {
    final items = highlight.items ?? [];
    return items.map((item) {
      final contentUrl = item.content?.addBaseURL() ?? '';
      final durationSec = int.tryParse(item.duration ?? '5') ?? 5;

      if (item.type == 1) {
        return StoryItem.pageVideo(
          contentUrl,
          story: null,
          controller: _storyController,
          duration: Duration(seconds: durationSec),
          shown: false,
          id: item.id ?? 0,
          viewedByUsersIds: [],
        );
      } else {
        return StoryItem.pageImage(
          story: null,
          url: contentUrl,
          controller: _storyController,
          imageFit: BoxFit.fitWidth,
          duration: Duration(seconds: durationSec),
          shown: false,
          id: item.id ?? 0,
          viewedByUsersIds: [],
        );
      }
    }).toList();
  }

  void _goToNext() {
    if (_currentHighlightIndex < widget.highlights.length - 1) {
      _storyController = StoryController();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void _goToPrevious() {
    if (_currentHighlightIndex > 0) {
      _storyController = StoryController();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: blackPure(context),
      child: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.highlights.length,
          onPageChanged: (index) {
            setState(() {
              _currentHighlightIndex = index;
              _storyController = StoryController();
            });
          },
          itemBuilder: (context, index) {
            final highlight = widget.highlights[index];
            final storyItems = _buildStoryItems(highlight);

            if (storyItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 64, color: whitePure(context).withValues(alpha: .5)),
                    const SizedBox(height: 16),
                    Text(
                      'No items in this highlight',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 16, color: whitePure(context)),
                    ),
                  ],
                ),
              );
            }

            return StoryView(
              storyItems: storyItems,
              inline: true,
              onStoryShow: (_) {},
              onBack: _goToPrevious,
              onComplete: _goToNext,
              progressPosition: ProgressPosition.top,
              repeat: false,
              controller: _storyController,
              overlayWidget: (_) => _HighlightOverlay(
                highlight: highlight,
                onClose: () => Get.back(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HighlightOverlay extends StatelessWidget {
  final StoryHighlight highlight;
  final VoidCallback onClose;

  const _HighlightOverlay({required this.highlight, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: CustomImage(
                fit: BoxFit.cover,
                size: const Size(35, 35),
                image: highlight.coverImage?.addBaseURL(),
                fullName: highlight.name,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                highlight.name ?? '',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 14, color: whitePure(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onClose,
              child: Icon(Icons.close, color: whitePure(context), size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
