import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/ai_voice_service.dart';
import 'package:shortzz/common/widget/gradient_icon.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/chat/message_data.dart';
import 'package:shortzz/screen/chat_screen/chat_screen_controller.dart';
import 'package:shortzz/screen/chat_screen/widget/chat_center_message_view.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChatAudioMessage extends StatelessWidget {
  final MessageData message;
  final ChatScreenController controller;

  const ChatAudioMessage(
      {super.key, required this.message, required this.controller});

  @override
  Widget build(BuildContext context) {
    List<double> waves =
        message.waveData?.split(',').map((e) => double.parse(e)).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: cardTotalHeight,
          width: cardTotalWidth,
          decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 15, cornerSmoothing: 1),
              ),
              shadows: messageBubbleShadow,
              color: textDarkGrey(context)),
          padding: EdgeInsets.symmetric(horizontal: cardMargin),
          child: Obx(() {
            PlayerValue playerValue = controller.playerValue.value;
            bool isPlaying = (playerValue.state == PlayerState.playing) &&
                (playerValue.id == message.id);
            return Row(
              spacing: 5,
              children: [
                InkWell(
                  onTap: () => controller.toggleAudioPlayback(message),
                  child: Container(
                      height: buttonSize,
                      width: buttonSize,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: whitePure(context)),
                      alignment: const Alignment(.1, 0),
                      child: GradientIcon(
                          child: Image.asset(
                              isPlaying ? AssetRes.icPause : AssetRes.icPlay,
                              width: 25,
                              height: 25))),
                ),
                SizedBox(
                  width: wavesWidth,
                  height: 50,
                  child: controller.playerValue.value.id == message.id
                      ? AudioFileWaveforms(
                          size: Size(wavesWidth, cardTotalHeight),
                          playerController: controller.playerController,
                          waveformType: WaveformType.fitWidth,
                          playerWaveStyle: PlayerWaveStyle(
                            fixedWaveColor: bgGrey(context),
                            liveWaveGradient: StyleRes.wavesGradient,
                            spacing: 3,
                            waveThickness: 1.5,
                          ))
                      : Row(
                          children: List.generate(waves.length, (index) {
                          var height = waves[index] * 200;
                          return Expanded(
                            child: Container(
                              decoration: ShapeDecoration(
                                shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                        cornerRadius: 15,
                                        cornerSmoothing: 0)),
                                color: bgGrey(context),
                              ),
                              margin: const EdgeInsets.all(1),
                              height: max(2, height),
                            ),
                          );
                        })),
                )
              ],
            );
          }),
        ),
        _TranscriptionView(message: message),
      ],
    );
  }
}

class _TranscriptionView extends StatefulWidget {
  final MessageData message;

  const _TranscriptionView({required this.message});

  @override
  State<_TranscriptionView> createState() => _TranscriptionViewState();
}

class _TranscriptionViewState extends State<_TranscriptionView> {
  String? _transcription;
  bool _isLoading = false;

  Future<void> _transcribe() async {
    final audioUrl = widget.message.audioMessage;
    if (audioUrl == null || audioUrl.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final result = await AiVoiceService.instance.transcribeAudio(
        audioUrl: audioUrl,
      );
      if (result.status == true && result.data?.transcription != null) {
        setState(() => _transcription = result.data!.transcription);
      } else {
        Get.snackbar('', result.message ?? 'Transcription failed',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      Get.snackbar('', 'Transcription unavailable',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_transcription != null) {
      return Container(
        width: cardTotalWidth,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(
          _transcription!,
          style: TextStyleCustom.outFitRegular400(
              fontSize: 12, color: textDarkGrey(context)),
        ),
      );
    }

    return GestureDetector(
      onTap: _isLoading ? null : _transcribe,
      child: Container(
        width: cardTotalWidth,
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              Icon(Icons.text_fields, size: 14, color: textLightGrey(context)),
            const SizedBox(width: 4),
            Text(
              _isLoading ? LKey.translating.tr : 'Transcribe',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 11, color: textLightGrey(context)),
            ),
          ],
        ),
      ),
    );
  }
}

double get cardTotalWidth => 220;

double get cardTotalHeight => 70;

double get cardMargin => 12;

double get buttonSize => 36;
double wavesWidth = cardTotalWidth - ((cardMargin * 2) + buttonSize + 5);
