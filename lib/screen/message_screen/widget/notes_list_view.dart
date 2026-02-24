import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/notes/user_note_model.dart';
import 'package:shortzz/screen/message_screen/message_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class NotesListView extends StatelessWidget {
  const NotesListView({super.key});

  static const double _noteSize = 62;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageScreenController>();
    return Obx(() {
      final notes = controller.followerNotes;
      if (notes.isEmpty && controller.myNote.value == null) {
        return const SizedBox();
      }
      return Container(
        height: 90,
        margin: const EdgeInsets.only(top: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: notes.length + 1, // +1 for "Your note"
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildMyNoteItem(context, controller);
            }
            return _buildNoteItem(context, notes[index - 1]);
          },
        ),
      );
    });
  }

  Widget _buildMyNoteItem(
      BuildContext context, MessageScreenController controller) {
    return Obx(() {
      final myNote = controller.myNote.value;
      return GestureDetector(
        onTap: () => controller.onMyNoteTap(),
        child: Container(
          width: 72,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: _noteSize,
                    height: _noteSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: myNote != null
                          ? Border.all(
                              color: themeAccentSolid(context), width: 2)
                          : Border.all(
                              color: textLightGrey(context), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: myNote != null
                        ? Text(myNote.emoji ?? '💬',
                            style: const TextStyle(fontSize: 24))
                        : Icon(Icons.add,
                            size: 24, color: textLightGrey(context)),
                  ),
                  if (myNote != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeAccentSolid(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        myNote.content ?? '',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 8, color: whitePure(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      constraints: const BoxConstraints(maxWidth: 60),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                myNote != null ? LKey.you.tr : LKey.you.tr,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 11, color: textLightGrey(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNoteItem(BuildContext context, UserNote note) {
    return GestureDetector(
      onTap: () => _showNoteDetail(context, note),
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: _noteSize,
              height: _noteSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: themeAccentSolid(context), width: 2),
              ),
              alignment: Alignment.center,
              child: note.user?.profilePhoto != null
                  ? CustomImage(
                      size: Size(_noteSize - 6, _noteSize - 6),
                      image: note.user!.profilePhoto!.addBaseURL(),
                      strokeWidth: 0,
                      fit: BoxFit.cover,
                      fullName: note.user?.fullname,
                    )
                  : Text(note.emoji ?? '💬',
                      style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 4),
            Text(
              note.user?.username ?? '',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 11, color: textLightGrey(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetail(BuildContext context, UserNote note) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 16),
              if (note.user?.profilePhoto != null)
                CustomImage(
                  size: const Size(56, 56),
                  image: note.user!.profilePhoto!.addBaseURL(),
                  strokeWidth: 0,
                  fit: BoxFit.cover,
                  fullName: note.user?.fullname,
                ),
              const SizedBox(height: 12),
              Text(
                note.user?.username ?? '',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 16, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 16),
              if (note.emoji != null)
                Text(note.emoji!,
                    style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                note.content ?? '',
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 18, color: textDarkGrey(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
