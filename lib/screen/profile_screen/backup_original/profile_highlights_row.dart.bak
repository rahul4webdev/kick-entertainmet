import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';
import 'package:shortzz/screen/highlight_screen/create_highlight_sheet.dart';
import 'package:shortzz/screen/highlight_screen/highlight_viewer_screen.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileHighlightsRow extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileHighlightsRow({super.key, required this.controller});

  static const double _circleSize = 62;
  static const double _containerWidth = 72;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final highlights = controller.highlights;
      final isMe =
          controller.userData.value?.id?.toInt() == SessionManager.instance.getUserID();

      if (highlights.isEmpty && !isMe) return const SizedBox.shrink();

      return SizedBox(
        height: 95,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: highlights.length + (isMe ? 1 : 0),
          itemBuilder: (context, index) {
            if (isMe && index == 0) {
              return _buildAddButton(context);
            }
            final highlight = highlights[isMe ? index - 1 : index];
            return _buildHighlightCircle(context, highlight, isMe ? index - 1 : index);
          },
        ),
      );
    });
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateHighlightSheet(context),
      child: Container(
        width: _containerWidth,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: textLightGrey(context), width: 1.5),
              ),
              child: Icon(Icons.add, color: textLightGrey(context), size: 28),
            ),
            const SizedBox(height: 4),
            Text(
              'New',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textLightGrey(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCircle(
      BuildContext context, StoryHighlight highlight, int index) {
    return GestureDetector(
      onTap: () => _openHighlightViewer(highlight, index),
      onLongPress: () {
        final isMe = controller.userData.value?.id?.toInt() ==
            SessionManager.instance.getUserID();
        if (isMe) {
          _showHighlightOptions(context, highlight);
        }
      },
      child: Container(
        width: _containerWidth,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _circleSize,
              height: _circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: textLightGrey(context).withValues(alpha: .3),
                    width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: CustomImage(
                    size: const Size(_circleSize - 7, _circleSize - 7),
                    image: highlight.coverImage?.addBaseURL(),
                    fullName: highlight.name,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              highlight.name ?? '',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textDarkGrey(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _openHighlightViewer(StoryHighlight highlight, int index) {
    Get.bottomSheet(
      HighlightViewerScreen(
        highlights: controller.highlights,
        initialIndex: index,
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  void _showCreateHighlightSheet(BuildContext context) {
    Get.bottomSheet(
      CreateHighlightSheet(
        onCreated: (highlight) {
          controller.highlights.insert(0, highlight);
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showHighlightOptions(BuildContext context, StoryHighlight highlight) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text('Edit Highlight',
                    style: TextStyleCustom.outFitRegular400(fontSize: 16)),
                onTap: () {
                  Get.back();
                  Get.bottomSheet(
                    CreateHighlightSheet(
                      existingHighlight: highlight,
                      onCreated: (updated) {
                        final idx = controller.highlights
                            .indexWhere((h) => h.id == updated.id);
                        if (idx != -1) {
                          controller.highlights[idx] = updated;
                        }
                      },
                    ),
                    isScrollControlled: true,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete Highlight',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 16, color: Colors.red)),
                onTap: () {
                  Get.back();
                  controller.deleteHighlight(highlight);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
