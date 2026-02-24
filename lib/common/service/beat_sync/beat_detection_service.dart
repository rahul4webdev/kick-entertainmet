import 'dart:math';
import 'package:audio_waveforms/audio_waveforms.dart';

class BeatDetectionService {
  BeatDetectionService._();
  static final BeatDetectionService instance = BeatDetectionService._();

  /// Detects beat positions from an audio file.
  /// Returns a list of beat timestamps in milliseconds.
  Future<List<int>> detectBeats({
    required String audioPath,
    int durationMs = 60000,
  }) async {
    try {
      final controller = PlayerController();
      await controller.preparePlayer(path: audioPath);

      // Extract waveform samples - more samples = better resolution
      final samplesPerSecond = 20;
      final totalSamples = (durationMs / 1000 * samplesPerSecond).toInt();
      final waveformData = await controller.extractWaveformData(
        path: audioPath,
        noOfSamples: totalSamples.clamp(100, 2000),
      );

      controller.dispose();

      if (waveformData.isEmpty) return [];

      return _findBeatsFromWaveform(waveformData, durationMs);
    } catch (e) {
      return [];
    }
  }

  /// Analyzes waveform amplitudes to find beat positions using onset detection.
  List<int> _findBeatsFromWaveform(List<double> waveform, int durationMs) {
    if (waveform.length < 3) return [];

    final beats = <int>[];
    final msPerSample = durationMs / waveform.length;

    // Normalize waveform values to 0-1 range
    final maxVal = waveform.reduce(max);
    if (maxVal == 0) return [];
    final normalized = waveform.map((v) => v.abs() / maxVal).toList();

    // Compute spectral flux (onset strength) — difference between consecutive samples
    final flux = <double>[];
    for (int i = 1; i < normalized.length; i++) {
      final diff = normalized[i] - normalized[i - 1];
      flux.add(diff > 0 ? diff : 0); // Only positive changes (onsets)
    }

    if (flux.isEmpty) return [];

    // Adaptive threshold: moving average * multiplier
    final windowSize = max(4, flux.length ~/ 20);
    final threshold = _movingAverage(flux, windowSize);
    final multiplier = 1.4;

    // Find peaks above threshold (beat onsets)
    final minBeatGapMs = 200; // Minimum 200ms between beats (~300 BPM max)
    int lastBeatMs = -minBeatGapMs;

    for (int i = 1; i < flux.length - 1; i++) {
      final adaptiveThreshold = threshold[i] * multiplier;
      final currentMs = ((i + 1) * msPerSample).toInt();

      // Check if this is a local peak above threshold
      if (flux[i] > adaptiveThreshold &&
          flux[i] >= flux[i - 1] &&
          flux[i] >= (i + 1 < flux.length ? flux[i + 1] : 0) &&
          currentMs - lastBeatMs >= minBeatGapMs) {
        beats.add(currentMs);
        lastBeatMs = currentMs;
      }
    }

    return beats;
  }

  /// Compute moving average of a list
  List<double> _movingAverage(List<double> data, int windowSize) {
    final result = <double>[];
    for (int i = 0; i < data.length; i++) {
      final start = max(0, i - windowSize ~/ 2);
      final end = min(data.length, i + windowSize ~/ 2 + 1);
      final window = data.sublist(start, end);
      result.add(window.reduce((a, b) => a + b) / window.length);
    }
    return result;
  }

  /// Snaps a given timestamp to the nearest beat marker.
  /// Returns the snapped timestamp in milliseconds.
  int snapToBeat(int timestampMs, List<int> beats, {int snapThresholdMs = 150}) {
    if (beats.isEmpty) return timestampMs;

    int nearestBeat = beats.first;
    int minDiff = (timestampMs - nearestBeat).abs();

    for (final beat in beats) {
      final diff = (timestampMs - beat).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearestBeat = beat;
      }
    }

    return minDiff <= snapThresholdMs ? nearestBeat : timestampMs;
  }
}
