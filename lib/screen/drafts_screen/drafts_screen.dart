import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/draft/draft_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/draft/draft_post_model.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen.dart';
import 'package:shortzz/screen/create_feed_screen/create_feed_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List<DraftPost> _drafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  void _loadDrafts() {
    setState(() {
      _drafts = DraftService.instance.getDrafts();
    });
  }

  void _deleteDraft(String draftId) {
    DraftService.instance.deleteDraft(draftId);
    _loadDrafts();
  }

  void _onDraftTap(DraftPost draft) {
    if (draft.draftType == 0 && draft.contentPath != null) {
      // Reel draft — open CreateFeedScreen with content
      final file = File(draft.contentPath!);
      if (!file.existsSync()) {
        Get.snackbar('Error', 'Video file no longer exists',
            snackPosition: SnackPosition.BOTTOM);
        _deleteDraft(draft.id);
        return;
      }

      final content = PostStoryContent(
        type: PostStoryContentType.reel,
        content: draft.contentPath,
        thumbNail: draft.thumbnailPath,
        duration: draft.durationSec,
      );

      Get.to(() => CreateFeedScreen(
            createType: CreateFeedType.reel,
            content: content,
          ))?.then((_) => _loadDrafts());

      // Set draft data on controller after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<CreateFeedScreenController>()) {
          final controller = Get.find<CreateFeedScreenController>();
          controller.draftId = draft.id;
          controller.commentHelper.detectableTextController.text =
              draft.description;
          controller.visibility.value = draft.visibility;
          controller.canComment.value = draft.canComment;
          if (draft.captions != null) {
            controller.captionsList.value = draft.captions!;
          }
        }
      });
    } else {
      // Feed draft — open CreateFeedScreen as feed
      Get.to(() => const CreateFeedScreen(
            createType: CreateFeedType.feed,
          ))?.then((_) => _loadDrafts());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<CreateFeedScreenController>()) {
          final controller = Get.find<CreateFeedScreenController>();
          controller.draftId = draft.id;
          controller.commentHelper.detectableTextController.text =
              draft.description;
          controller.visibility.value = draft.visibility;
          controller.canComment.value = draft.canComment;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_drafts.isEmpty) {
      return Center(
        child: Text(
          LKey.noDrafts.tr,
          style: TextStyleCustom.outFitRegular400(
              fontSize: 15, color: textLightGrey(context)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _drafts.length,
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return _DraftCard(
          draft: draft,
          onTap: () => _onDraftTap(draft),
          onDelete: () => _deleteDraft(draft.id),
        );
      },
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftPost draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgMediumGrey(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: _buildThumbnail(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: themeAccentSolid(context)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            draft.draftTypeLabel,
                            style: TextStyleCustom.outFitRegular400(
                                fontSize: 11,
                                color: themeAccentSolid(context)),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(draft.updatedAt),
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 11, color: textLightGrey(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (draft.description.isNotEmpty)
                      Text(
                        draft.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 13, color: whitePure(context)),
                      ),
                    if (draft.description.isEmpty)
                      Text(
                        LKey.resumeEditing.tr,
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 13, color: textLightGrey(context)),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline,
                      size: 20, color: textLightGrey(context)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final thumbPath = draft.thumbnailPath;
    if (thumbPath != null && File(thumbPath).existsSync()) {
      return Image.file(File(thumbPath), fit: BoxFit.cover);
    }
    return Container(
      color: bgGrey(context),
      child: Icon(
        draft.draftType == 0
            ? Icons.videocam
            : draft.draftType == 1
                ? Icons.image
                : draft.draftType == 2
                    ? Icons.videocam
                    : Icons.text_fields,
        color: textLightGrey(context),
        size: 28,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
