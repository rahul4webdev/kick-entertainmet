import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/ai_translation_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatTextMessage extends StatelessWidget {
  final bool isMe;
  final MessageData message;

  const ChatTextMessage({super.key, required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          constraints: BoxConstraints(maxWidth: Get.width / 1.3),
          decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                  side: isMe
                      ? BorderSide.none
                      : BorderSide(
                          color: bgGrey(context),
                          strokeAlign: BorderSide.strokeAlignInside)),
              color: isMe ? null : bgLightGrey(context),
              gradient: isMe ? StyleRes.themeGradient : null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.textMessage ?? '',
                style: TextStyleCustom.outFitRegular400(
                    color: isMe ? whitePure(context) : textDarkGrey(context),
                    fontSize: 16),
              ),
              if (message.editedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    'Edited',
                    style: TextStyleCustom.outFitLight300(
                        color: isMe
                            ? whitePure(context).withValues(alpha: 0.6)
                            : textLightGrey(context),
                        fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
        if (message.linkPreview != null)
          _LinkPreviewCard(
              linkPreview: message.linkPreview!, isMe: isMe),
        if ((message.textMessage ?? '').isNotEmpty)
          _TranslateView(message: message, isMe: isMe),
      ],
    );
  }
}

class _TranslateView extends StatefulWidget {
  final MessageData message;
  final bool isMe;

  const _TranslateView({required this.message, required this.isMe});

  @override
  State<_TranslateView> createState() => _TranslateViewState();
}

class _TranslateViewState extends State<_TranslateView> {
  String? _translation;
  bool _isLoading = false;

  Future<void> _translate() async {
    final text = widget.message.textMessage;
    if (text == null || text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final locale = Get.locale?.languageCode ?? 'en';
      final targetLang = _langCodeToName(locale);
      final result = await AiTranslationService.instance.translateText(
        text: text,
        targetLanguage: targetLang,
      );
      if (result.status == true && result.data?.translated != null) {
        setState(() => _translation = result.data!.translated);
      } else {
        Get.snackbar('', result.message ?? 'Translation failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('', 'Translation unavailable',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _langCodeToName(String code) {
    return switch (code) {
      'es' => 'Spanish',
      'fr' => 'French',
      'de' => 'German',
      'hi' => 'Hindi',
      'pt' => 'Portuguese',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'zh' => 'Chinese',
      'ar' => 'Arabic',
      'ru' => 'Russian',
      'it' => 'Italian',
      'nl' => 'Dutch',
      'tr' => 'Turkish',
      'th' => 'Thai',
      'vi' => 'Vietnamese',
      _ => 'English',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_translation != null) {
      return Container(
        constraints: BoxConstraints(maxWidth: Get.width / 1.3),
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LKey.translatedText.tr,
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 10, color: textLightGrey(context)),
            ),
            const SizedBox(height: 2),
            SelectableText(
              _translation!,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textDarkGrey(context)),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _isLoading ? null : _translate,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: textLightGrey(context),
                ),
              )
            else
              Icon(Icons.translate, size: 14, color: textLightGrey(context)),
            const SizedBox(width: 4),
            Text(
              _isLoading ? LKey.translating.tr : LKey.translate.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 11, color: textLightGrey(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkPreviewCard extends StatelessWidget {
  final LinkPreview linkPreview;
  final bool isMe;

  const _LinkPreviewCard({required this.linkPreview, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(linkPreview.url ?? '');
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width / 1.3),
        margin: const EdgeInsets.only(top: 4),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
            side: BorderSide(
                color: bgGrey(context),
                strokeAlign: BorderSide.strokeAlignInside),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (linkPreview.image != null && linkPreview.image!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 120,
                child: Image.network(
                  linkPreview.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (linkPreview.title != null)
                    Text(
                      linkPreview.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 13, color: textDarkGrey(context)),
                    ),
                  if (linkPreview.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      linkPreview.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 11, color: textLightGrey(context)),
                    ),
                  ],
                  if (linkPreview.domain != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      linkPreview.domain!,
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 10, color: textLightGrey(context)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
