import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/highlight_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';
import 'package:shortzz/screen/highlight_screen/create_highlight_sheet.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AddToHighlightSheet extends StatefulWidget {
  final int storyId;

  const AddToHighlightSheet({super.key, required this.storyId});

  @override
  State<AddToHighlightSheet> createState() => _AddToHighlightSheetState();
}

class _AddToHighlightSheetState extends State<AddToHighlightSheet> {
  List<StoryHighlight> _highlights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    try {
      final items = await HighlightService.instance.fetchHighlights();
      if (mounted) setState(() => _highlights = items);
    } catch (e) {
      Loggers.error('Load highlights error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addToHighlight(StoryHighlight highlight) async {
    try {
      await HighlightService.instance.addStoryToHighlight(
        highlightId: highlight.id!,
        storyId: widget.storyId,
      );
      Get.back();
      Get.snackbar('Success', 'Added to ${highlight.name}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Loggers.error('Add to highlight error: $e');
      Get.snackbar('Error', 'Failed to add to highlight',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      padding: const EdgeInsets.only(top: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add to Highlight',
                      style: TextStyleCustom.unboundedSemiBold600(
                          fontSize: 18, color: textDarkGrey(context)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                      Get.bottomSheet(
                        CreateHighlightSheet(
                          onCreated: (highlight) {
                            _addToHighlight(highlight);
                          },
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: Icon(Icons.add_circle_outline,
                        color: themeAccentSolid(context), size: 28),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else if (_highlights.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No highlights yet. Create one first.',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = _highlights[index];
                    return ListTile(
                      onTap: () => _addToHighlight(highlight),
                      leading: ClipOval(
                        child: CustomImage(
                          size: const Size(44, 44),
                          image: highlight.coverImage?.addBaseURL(),
                          fullName: highlight.name,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        highlight.name ?? '',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 15, color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        '${highlight.itemCount ?? 0} items',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 13, color: textLightGrey(context)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
