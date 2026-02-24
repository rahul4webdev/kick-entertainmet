import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/ai_translation_service.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TranslationSheet extends StatefulWidget {
  final String text;
  final List<Map<String, dynamic>>? captions;

  const TranslationSheet({super.key, required this.text, this.captions});

  @override
  State<TranslationSheet> createState() => _TranslationSheetState();
}

class _TranslationSheetState extends State<TranslationSheet> {
  final _isTranslating = false.obs;
  final _translatedText = ''.obs;
  final _selectedLanguage = 'Spanish'.obs;

  static const _languages = [
    'Spanish',
    'French',
    'German',
    'Portuguese',
    'Italian',
    'Japanese',
    'Korean',
    'Chinese',
    'Hindi',
    'Arabic',
    'Russian',
    'Turkish',
    'Dutch',
    'Polish',
    'Thai',
    'Vietnamese',
    'Indonesian',
    'Malay',
    'Bengali',
    'Tamil',
  ];

  Future<void> _translate() async {
    if (_isTranslating.value) return;

    _isTranslating.value = true;
    _translatedText.value = '';

    try {
      if (widget.captions != null && widget.captions!.isNotEmpty) {
        final result = await AiTranslationService.instance.translateCaptions(
          captions: widget.captions!,
          targetLanguage: _selectedLanguage.value,
        );
        if (result.status == true && result.data?.captions != null) {
          final texts =
              result.data!.captions!.map((c) => c.text ?? '').join('\n');
          _translatedText.value = texts;
          Get.back(result: {
            'captions': result.data!.captions!.map((c) => c.toJson()).toList(),
            'language': _selectedLanguage.value,
          });
          return;
        }
        _translatedText.value = result.message ?? 'Translation failed';
      } else {
        final result = await AiTranslationService.instance.translateText(
          text: widget.text,
          targetLanguage: _selectedLanguage.value,
        );
        if (result.status == true && result.data?.translated != null) {
          _translatedText.value = result.data!.translated!;
        } else {
          _translatedText.value = result.message ?? 'Translation failed';
        }
      }
    } catch (e) {
      _translatedText.value = 'Translation failed';
    } finally {
      _isTranslating.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.vertical(
            top: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                LKey.translate.tr,
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 18, color: textDarkGrey(context)),
              ),
              const SizedBox(height: 16),

              // Language selector
              Text(
                LKey.selectLanguage.tr,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 13, color: textLightGrey(context)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: Obx(() => ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _languages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final lang = _languages[index];
                        final isSelected =
                            _selectedLanguage.value == lang;
                        return GestureDetector(
                          onTap: () => _selectedLanguage.value = lang,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? themeAccentSolid(context)
                                  : bgMediumGrey(context),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              lang,
                              style: TextStyleCustom.outFitMedium500(
                                fontSize: 13,
                                color: isSelected
                                    ? whitePure(context)
                                    : textLightGrey(context),
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ),
              const SizedBox(height: 16),

              // Original text preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgLightGrey(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LKey.originalText.tr,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 11, color: textLightGrey(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.text.length > 200
                          ? '${widget.text.substring(0, 200)}...'
                          : widget.text,
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 13, color: textDarkGrey(context)),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Translated text result
              Obx(() {
                if (_isTranslating.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: LoaderWidget()),
                  );
                }
                if (_translatedText.value.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              themeAccentSolid(context).withValues(alpha: .3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LKey.translatedText.tr,
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 11, color: themeAccentSolid(context)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _translatedText.value,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 13, color: textDarkGrey(context)),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),

              // Translate button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(() => ElevatedButton(
                      onPressed: _isTranslating.value ? null : _translate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeAccentSolid(context),
                        foregroundColor: whitePure(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isTranslating.value
                            ? LKey.translating.tr
                            : LKey.translate.tr,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 15, color: whitePure(context)),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
