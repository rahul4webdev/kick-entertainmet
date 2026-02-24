import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shortzz/common/manager/logger.dart';

class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  List<String> _languages = [];
  String selectedLanguage = 'en-US';
  double speechRate = 0.5;
  double pitch = 1.0;
  double volume = 1.0;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final langs = await _flutterTts.getLanguages;
      _languages = List<String>.from(langs.map((l) => l.toString()));
      _languages.sort();

      await _flutterTts.setLanguage(selectedLanguage);
      await _flutterTts.setSpeechRate(speechRate);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setVolume(volume);

      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
          IosTextToSpeechAudioMode.defaultMode,
        );
      }

      _isInitialized = true;
    } catch (e) {
      Loggers.error('TTS init error: $e');
    }
  }

  List<String> get availableLanguages => _languages;

  Future<void> setLanguage(String language) async {
    selectedLanguage = language;
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double p) async {
    pitch = p;
    await _flutterTts.setPitch(p);
  }

  Future<void> speak(String text) async {
    await init();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Generates TTS audio file and returns the file path.
  Future<String?> generateToFile(String text) async {
    await init();

    final dir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (dir == null) return null;

    final fileName =
        'tts_${DateTime.now().millisecondsSinceEpoch}${Platform.isIOS ? '.caf' : '.wav'}';
    final fullPath = '${dir.path}/$fileName';

    try {
      final result = await _flutterTts.synthesizeToFile(text, fileName);
      if (result != 1) {
        Loggers.error('TTS synthesizeToFile returned: $result');
        return null;
      }

      // Wait briefly for file system to flush
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify the file exists
      if (await File(fullPath).exists()) {
        Loggers.info('TTS audio generated: $fullPath');
        return fullPath;
      }

      Loggers.error('TTS file not found at: $fullPath');
      return null;
    } catch (e) {
      Loggers.error('TTS synthesize error: $e');
      return null;
    }
  }
}
