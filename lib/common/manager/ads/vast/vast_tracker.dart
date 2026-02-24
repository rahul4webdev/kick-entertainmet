import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/ads/vast/vast_parser.dart';

/// Fires VAST tracking pixels (impressions, quartiles, clicks, etc.)
/// All calls are fire-and-forget — never blocks UI or ad playback.
class VastTracker {
  final VastAdData adData;
  bool _impressionFired = false;
  bool _startFired = false;
  bool _firstQuartileFired = false;
  bool _midpointFired = false;
  bool _thirdQuartileFired = false;
  bool _completeFired = false;

  VastTracker(this.adData);

  /// Fire all impression pixels. Call when ad playback starts (first frame).
  void fireImpressions() {
    if (_impressionFired) return;
    _impressionFired = true;
    for (final url in adData.impressionUrls) {
      _firePixel(url, 'impression');
    }
  }

  /// Update tracking based on current playback position.
  /// Call this periodically during ad playback.
  void updatePosition(Duration position, Duration total) {
    if (total.inMilliseconds <= 0) return;
    final progress = position.inMilliseconds / total.inMilliseconds;

    if (!_startFired && progress > 0) {
      _startFired = true;
      _fireEvent('start');
    }
    if (!_firstQuartileFired && progress >= 0.25) {
      _firstQuartileFired = true;
      _fireEvent('firstQuartile');
    }
    if (!_midpointFired && progress >= 0.50) {
      _midpointFired = true;
      _fireEvent('midpoint');
    }
    if (!_thirdQuartileFired && progress >= 0.75) {
      _thirdQuartileFired = true;
      _fireEvent('thirdQuartile');
    }
    if (!_completeFired && progress >= 0.97) {
      _completeFired = true;
      _fireEvent('complete');
    }
  }

  /// Fire click tracking pixels. Call when user taps the ad.
  void fireClick() {
    for (final url in adData.clickTrackingUrls) {
      _firePixel(url, 'click');
    }
  }

  /// Fire skip event. Call when user taps skip button.
  void fireSkip() {
    _fireEvent('skip');
  }

  /// Fire pause event.
  void firePause() {
    _fireEvent('pause');
  }

  /// Fire resume event.
  void fireResume() {
    _fireEvent('resume');
  }

  /// Fire error tracking. Call if ad fails to play.
  void fireError() {
    final errorUrl = adData.errorUrl;
    if (errorUrl != null && errorUrl.isNotEmpty) {
      _firePixel(errorUrl, 'error');
    }
  }

  void _fireEvent(String eventName) {
    final urls = adData.trackingEvents[eventName];
    if (urls == null) return;
    for (final url in urls) {
      _firePixel(url, eventName);
    }
  }

  /// Fire a single tracking pixel — non-blocking, silent on failure.
  static void _firePixel(String url, String label) {
    try {
      debugPrint('[VAST Tracker] Firing $label: ${url.length > 80 ? '${url.substring(0, 80)}...' : url}');
      http.get(Uri.parse(url)).catchError((_) {
        // Tracking failures are always silent
        return http.Response('', 200);
      });
    } catch (_) {
      // Never let tracking break ad playback
    }
  }
}
