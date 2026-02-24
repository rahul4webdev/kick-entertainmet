import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/tts/tts_service.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TtsSheet extends StatefulWidget {
  final String initialText;

  const TtsSheet({super.key, required this.initialText});

  @override
  State<TtsSheet> createState() => _TtsSheetState();
}

class _TtsSheetState extends State<TtsSheet> {
  final _tts = TtsService.instance;
  late TextEditingController _textController;

  final _isGenerating = false.obs;
  final _isPreviewing = false.obs;
  final _speechRate = 0.5.obs;
  final _pitch = 1.0.obs;
  final _selectedLanguage = 'en-US'.obs;
  final _languages = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    await _tts.init();
    _languages.value = _tts.availableLanguages;
    _selectedLanguage.value = _tts.selectedLanguage;
    _speechRate.value = _tts.speechRate;
    _pitch.value = _tts.pitch;
  }

  @override
  void dispose() {
    _textController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _preview() async {
    if (_textController.text.trim().isEmpty) return;

    if (_isPreviewing.value) {
      await _tts.stop();
      _isPreviewing.value = false;
      return;
    }

    _isPreviewing.value = true;
    await _tts.setLanguage(_selectedLanguage.value);
    await _tts.setSpeechRate(_speechRate.value);
    await _tts.setPitch(_pitch.value);
    await _tts.speak(_textController.text.trim());
    _isPreviewing.value = false;
  }

  Future<void> _generate() async {
    if (_textController.text.trim().isEmpty || _isGenerating.value) return;

    _isGenerating.value = true;
    await _tts.stop();

    await _tts.setLanguage(_selectedLanguage.value);
    await _tts.setSpeechRate(_speechRate.value);
    await _tts.setPitch(_pitch.value);

    final filePath = await _tts.generateToFile(_textController.text.trim());
    _isGenerating.value = false;

    if (filePath != null) {
      Get.back(result: filePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Text(
              LKey.textToSpeech,
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 18, color: whitePure(context)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 3,
              minLines: 2,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 14, color: whitePure(context)),
              decoration: InputDecoration(
                hintText: LKey.enterTextForSpeech,
                hintStyle: TextStyleCustom.outFitRegular400(
                    fontSize: 14, color: textLightGrey(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: textLightGrey(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: textLightGrey(context).withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeAccentSolid(context)),
                ),
                filled: true,
                fillColor: bgMediumGrey(context),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (_languages.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LKey.language,
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 13, color: textLightGrey(context)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: bgMediumGrey(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: _languages.contains(_selectedLanguage.value)
                          ? _selectedLanguage.value
                          : _languages.first,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: bgMediumGrey(context),
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: whitePure(context)),
                      items: _languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _selectedLanguage.value = value;
                      },
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            Obx(() => _buildSlider(
                  context,
                  label:
                      '${LKey.speed}: ${_speechRate.value.toStringAsFixed(1)}x',
                  value: _speechRate.value,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (v) => _speechRate.value = v,
                )),
            const SizedBox(height: 8),
            Obx(() => _buildSlider(
                  context,
                  label: '${LKey.pitch}: ${_pitch.value.toStringAsFixed(1)}',
                  value: _pitch.value,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (v) => _pitch.value = v,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextButtonCustom(
                        onTap: _preview,
                        title: _isPreviewing.value ? LKey.stop : LKey.preview,
                        btnHeight: 44,
                        backgroundColor: bgMediumGrey(context),
                        titleColor: whitePure(context),
                        horizontalMargin: 4,
                      )),
                ),
                Expanded(
                  child: Obx(() => _isGenerating.value
                      ? const SizedBox(
                          height: 44, child: Center(child: LoaderWidget()))
                      : TextButtonCustom(
                          onTap: _generate,
                          title: LKey.apply,
                          btnHeight: 44,
                          backgroundColor: themeAccentSolid(context),
                          titleColor: whitePure(context),
                          horizontalMargin: 4,
                        )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyleCustom.outFitRegular400(
                fontSize: 13, color: textLightGrey(context))),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: themeAccentSolid(context),
            inactiveColor: textLightGrey(context).withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
