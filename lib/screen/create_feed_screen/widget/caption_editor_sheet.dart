import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/model/post_story/caption/caption_model.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CaptionEditorSheet extends StatefulWidget {
  final List<Caption> initialCaptions;
  final int videoDurationMs;

  const CaptionEditorSheet({
    super.key,
    required this.initialCaptions,
    required this.videoDurationMs,
  });

  @override
  State<CaptionEditorSheet> createState() => _CaptionEditorSheetState();
}

class _CaptionEditorSheetState extends State<CaptionEditorSheet> {
  late List<_CaptionEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.initialCaptions
        .map((c) => _CaptionEntry(
              textController: TextEditingController(text: c.text),
              startMs: c.startMs,
              endMs: c.endMs,
            ))
        .toList();
    if (_entries.isEmpty) _addEntry();
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.textController.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    final lastEnd = _entries.isEmpty ? 0 : _entries.last.endMs;
    final newEnd = (lastEnd + 3000).clamp(0, widget.videoDurationMs);
    setState(() {
      _entries.add(_CaptionEntry(
        textController: TextEditingController(),
        startMs: lastEnd,
        endMs: newEnd,
      ));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries[index].textController.dispose();
      _entries.removeAt(index);
    });
  }

  void _save() {
    final captions = <Caption>[];
    for (final entry in _entries) {
      final text = entry.textController.text.trim();
      if (text.isNotEmpty) {
        captions.add(Caption(
          startMs: entry.startMs,
          endMs: entry.endMs,
          text: text,
        ));
      }
    }
    Get.back(result: captions);
  }

  String _formatMs(int ms) {
    final sec = ms ~/ 1000;
    final remainder = (ms % 1000) ~/ 100;
    return '$sec.${remainder}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: textLightGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LKey.captions,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 18, color: whitePure(context)),
                ),
                InkWell(
                  onTap: _addEntry,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+ ${LKey.add}',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 13, color: themeAccentSolid(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bgMediumGrey(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${_formatMs(entry.startMs)} - ${_formatMs(entry.endMs)}',
                                style: TextStyleCustom.outFitRegular400(
                                    fontSize: 12,
                                    color: textLightGrey(context)),
                              ),
                            ),
                            InkWell(
                              onTap: () => _removeEntry(index),
                              child: Icon(Icons.close,
                                  size: 18, color: textLightGrey(context)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _TimeChip(
                              label: _formatMs(entry.startMs),
                              onTap: () => _editTime(index, true),
                              context: context,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text('-',
                                  style: TextStyleCustom.outFitRegular400(
                                      fontSize: 12,
                                      color: textLightGrey(context))),
                            ),
                            _TimeChip(
                              label: _formatMs(entry.endMs),
                              onTap: () => _editTime(index, false),
                              context: context,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: entry.textController,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 14, color: whitePure(context)),
                          decoration: InputDecoration(
                            hintText: LKey.enterTextForSpeech,
                            hintStyle: TextStyleCustom.outFitRegular400(
                                fontSize: 14, color: textLightGrey(context)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: scaffoldBackgroundColor(context),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButtonCustom(
              onTap: _save,
              title: LKey.done,
              btnHeight: 44,
              backgroundColor: themeAccentSolid(context),
              titleColor: whitePure(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTime(int index, bool isStart) async {
    final entry = _entries[index];
    final currentMs = isStart ? entry.startMs : entry.endMs;
    final maxMs = widget.videoDurationMs;

    double sliderValue = currentMs.toDouble();

    final result = await Get.dialog<int>(
      AlertDialog(
        backgroundColor: scaffoldBackgroundColor(Get.context!),
        title: Text(
          isStart ? 'Start Time' : 'End Time',
          style: TextStyleCustom.outFitMedium500(
              fontSize: 16, color: whitePure(Get.context!)),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMs(sliderValue.toInt()),
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 20, color: whitePure(context)),
                ),
                Slider(
                  value: sliderValue,
                  min: 0,
                  max: maxMs.toDouble(),
                  divisions: maxMs ~/ 100,
                  activeColor: themeAccentSolid(context),
                  onChanged: (v) {
                    setDialogState(() => sliderValue = v);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel,
                style: TextStyleCustom.outFitRegular400(
                    color: textLightGrey(Get.context!))),
          ),
          TextButton(
            onPressed: () => Get.back(result: sliderValue.toInt()),
            child: Text(LKey.done,
                style: TextStyleCustom.outFitRegular400(
                    color: themeAccentSolid(Get.context!))),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        if (isStart) {
          _entries[index].startMs = result;
        } else {
          _entries[index].endMs = result;
        }
      });
    }
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final BuildContext context;

  const _TimeChip({
    required this.label,
    required this.onTap,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: themeAccentSolid(context).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitRegular400(
              fontSize: 11, color: themeAccentSolid(context)),
        ),
      ),
    );
  }
}

class _CaptionEntry {
  final TextEditingController textController;
  int startMs;
  int endMs;

  _CaptionEntry({
    required this.textController,
    required this.startMs,
    required this.endMs,
  });
}
