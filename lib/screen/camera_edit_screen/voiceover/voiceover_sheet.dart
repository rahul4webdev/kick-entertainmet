import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class VoiceoverSheet extends StatefulWidget {
  const VoiceoverSheet({super.key});

  @override
  State<VoiceoverSheet> createState() => _VoiceoverSheetState();
}

class _VoiceoverSheetState extends State<VoiceoverSheet> {
  late RecorderController _recorderController;
  final _player = ja.AudioPlayer();

  final _isRecording = false.obs;
  final _hasRecording = false.obs;
  final _isPlaying = false.obs;
  final _recordDuration = 0.obs;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final isGranted = await _recorderController.checkPermission();
    if (!isGranted) return;

    await _recorderController.record();
    _isRecording.value = true;
    _hasRecording.value = false;
    _recordDuration.value = 0;

    // Track duration
    _tickDuration();
  }

  void _tickDuration() async {
    while (_isRecording.value) {
      await Future.delayed(const Duration(seconds: 1));
      if (_isRecording.value) {
        _recordDuration.value++;
      }
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorderController.stop();
    _isRecording.value = false;
    if (path != null) {
      _recordedFilePath = path;
      _hasRecording.value = true;
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordedFilePath == null) return;

    if (_isPlaying.value) {
      await _player.pause();
      _isPlaying.value = false;
    } else {
      await _player.setFilePath(_recordedFilePath!);
      _isPlaying.value = true;
      _player.play();
      _player.playerStateStream.listen((state) {
        if (state.processingState == ja.ProcessingState.completed) {
          _isPlaying.value = false;
        }
      });
    }
  }

  void _deleteRecording() {
    _recorderController.reset();
    _recordedFilePath = null;
    _hasRecording.value = false;
    _isPlaying.value = false;
    _recordDuration.value = 0;
    _player.stop();
  }

  void _applyRecording() {
    if (_recordedFilePath != null) {
      Get.back(result: _recordedFilePath);
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
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
              LKey.voiceover.tr,
              style: TextStyleCustom.outFitMedium500(
                  fontSize: 18, color: whitePure(context)),
            ),
            const SizedBox(height: 8),
            Text(
              LKey.voiceoverDesc.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Waveform display
            Obx(() {
              if (_isRecording.value) {
                return AudioWaveforms(
                  size: Size(MediaQuery.of(context).size.width - 64, 60),
                  recorderController: _recorderController,
                  enableGesture: false,
                  waveStyle: WaveStyle(
                    waveColor: themeAccentSolid(context),
                    middleLineColor: Colors.transparent,
                    showDurationLabel: false,
                    extendWaveform: true,
                    showMiddleLine: false,
                    waveThickness: 3,
                  ),
                );
              }
              return Container(
                height: 60,
                width: double.infinity,
                alignment: Alignment.center,
                child: _hasRecording.value
                    ? Icon(Icons.check_circle,
                        color: Colors.green, size: 40)
                    : Icon(Icons.mic_none,
                        color: textLightGrey(context), size: 40),
              );
            }),
            const SizedBox(height: 12),
            // Duration
            Obx(() => Text(
                  _formatDuration(_recordDuration.value),
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 24, color: whitePure(context)),
                )),
            const SizedBox(height: 24),
            // Controls
            Obx(() {
              if (_hasRecording.value) {
                return _buildPlaybackControls(context);
              }
              return _buildRecordingControls(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingControls(BuildContext context) {
    return Obx(() {
      final recording = _isRecording.value;
      return GestureDetector(
        onTap: recording ? _stopRecording : _startRecording,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: whitePure(context), width: 3),
          ),
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: recording ? 28 : 56,
            height: recording ? 28 : 56,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius:
                  BorderRadius.circular(recording ? 6 : 28),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Delete
            GestureDetector(
              onTap: _deleteRecording,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 22),
              ),
            ),
            const SizedBox(width: 24),
            // Play/Pause
            Obx(() => GestureDetector(
                  onTap: _togglePlayback,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying.value ? Icons.pause : Icons.play_arrow,
                      color: whitePure(context),
                      size: 28,
                    ),
                  ),
                )),
            const SizedBox(width: 24),
            // Re-record
            GestureDetector(
              onTap: () {
                _deleteRecording();
                _startRecording();
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgMediumGrey(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.refresh, color: whitePure(context), size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextButtonCustom(
          onTap: _applyRecording,
          title: LKey.apply.tr,
          btnHeight: 44,
          backgroundColor: themeAccentSolid(context),
          titleColor: whitePure(context),
          horizontalMargin: 40,
        ),
      ],
    );
  }
}
