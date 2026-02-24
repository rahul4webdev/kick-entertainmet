import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/highlight_service.dart';
import 'package:shortzz/model/story_highlight/story_highlight_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreateHighlightSheet extends StatefulWidget {
  final StoryHighlight? existingHighlight;
  final Function(StoryHighlight highlight) onCreated;

  const CreateHighlightSheet({
    super.key,
    this.existingHighlight,
    required this.onCreated,
  });

  @override
  State<CreateHighlightSheet> createState() => _CreateHighlightSheetState();
}

class _CreateHighlightSheetState extends State<CreateHighlightSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.existingHighlight != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.existingHighlight?.name ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter a highlight name',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        await HighlightService.instance.updateHighlight(
          highlightId: widget.existingHighlight!.id!,
          name: name,
        );
        final updated = StoryHighlight(
          id: widget.existingHighlight!.id,
          userId: widget.existingHighlight!.userId,
          name: name,
          coverImage: widget.existingHighlight!.coverImage,
          sortOrder: widget.existingHighlight!.sortOrder,
          itemCount: widget.existingHighlight!.itemCount,
          items: widget.existingHighlight!.items,
          createdAt: widget.existingHighlight!.createdAt,
          updatedAt: widget.existingHighlight!.updatedAt,
        );
        widget.onCreated(updated);
      } else {
        final result =
            await HighlightService.instance.createHighlight(name: name);
        if (result.data != null) {
          widget.onCreated(result.data!);
        }
      }
      Get.back();
    } catch (e) {
      Loggers.error('Highlight save error: $e');
      Get.snackbar('Error', 'Failed to save highlight',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textLightGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? 'Edit Highlight' : 'New Highlight',
              style: TextStyleCustom.unboundedSemiBold600(
                  fontSize: 18, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 16, color: textDarkGrey(context)),
              decoration: InputDecoration(
                hintText: 'Highlight name',
                hintStyle: TextStyleCustom.outFitRegular400(
                    fontSize: 16, color: textLightGrey(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: textLightGrey(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeAccentSolid(context)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isEditing ? 'Save' : 'Create',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
