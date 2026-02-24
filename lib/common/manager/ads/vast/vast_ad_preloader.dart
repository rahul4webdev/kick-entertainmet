import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:shortzz/common/manager/ads/vast/vast_parser.dart';
import 'package:shortzz/common/manager/ads/vast/vast_tracker.dart';
import 'package:video_player/video_player.dart';

/// Pre-fetches a VAST ad: parses XML, downloads MP4, initializes controller.
/// When ready, the ad can be played instantly with zero delay.
class VastAdPreloader {
  VastAdData? _adData;
  VastTracker? _tracker;
  VideoPlayerController? _controller;
  File? _cachedFile;
  bool _isPreloading = false;
  bool _isReady = false;
  bool _isFailed = false;
  bool _disposed = false;

  /// Whether the ad is fully preloaded and ready for instant playback.
  bool get isReady => _isReady && _controller != null;

  /// Whether preloading failed.
  bool get isFailed => _isFailed;

  /// Whether currently preloading.
  bool get isPreloading => _isPreloading;

  /// The parsed ad data (available after successful preload).
  VastAdData? get adData => _adData;

  /// The VAST tracker (available after successful preload).
  VastTracker? get tracker => _tracker;

  /// The pre-initialized video controller (ready for instant play).
  VideoPlayerController? get controller => _controller;

  /// Pre-load an ad from a VAST tag URL.
  /// Returns true if ad is ready for instant playback.
  Future<bool> preload(String vastTagUrl) async {
    if (_isPreloading) return false;
    if (vastTagUrl.isEmpty) {
      _isFailed = true;
      return false;
    }

    _isPreloading = true;
    _isFailed = false;

    try {
      // Step 1: Fetch and parse VAST XML (resolve wrappers)
      debugPrint('[VastPreloader] Fetching VAST from: ${vastTagUrl.length > 70 ? '${vastTagUrl.substring(0, 70)}...' : vastTagUrl}');
      _adData = await _fetchAndParseVast(vastTagUrl);
      if (_disposed) return false;
      if (_adData == null) {
        debugPrint('[VastPreloader] Failed to parse VAST');
        _isFailed = true;
        _isPreloading = false;
        return false;
      }

      // Step 2: Get best media URL
      final mediaUrl = _adData!.bestMediaUrl;
      if (mediaUrl == null || mediaUrl.isEmpty) {
        debugPrint('[VastPreloader] No media URL found in VAST');
        _isFailed = true;
        _isPreloading = false;
        return false;
      }

      debugPrint('[VastPreloader] Downloading ad: ${mediaUrl.length > 70 ? '${mediaUrl.substring(0, 70)}...' : mediaUrl}');

      // Step 3: Download MP4 to local cache
      final fileInfo = await DefaultCacheManager()
          .downloadFile(mediaUrl)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        throw TimeoutException('Ad download timed out');
      });
      if (_disposed) return false;
      _cachedFile = fileInfo.file;
      debugPrint('[VastPreloader] Downloaded to: ${_cachedFile!.path}');

      // Step 4: Initialize VideoPlayerController from cached file
      debugPrint('[VastPreloader] Initializing controller from: ${_cachedFile!.path}');
      _controller = VideoPlayerController.file(_cachedFile!);
      await _controller!.initialize();
      if (_disposed) {
        _controller?.dispose();
        _controller = null;
        return false;
      }
      debugPrint('[VastPreloader] Controller initialized, size=${_controller!.value.size}');
      await _controller!.seekTo(Duration.zero);
      await _controller!.pause();
      await _controller!.setVolume(1.0);

      // Step 5: Create tracker
      if (_disposed || _adData == null) {
        _controller?.dispose();
        _controller = null;
        return false;
      }
      _tracker = VastTracker(_adData!);

      _isReady = true;
      _isPreloading = false;
      final sz = _controller!.value.size;
      debugPrint('[VastPreloader] Ad ready for instant playback '
          '(${_adData!.duration.inSeconds}s, ${sz.width.toInt()}x${sz.height.toInt()})');
      return true;
    } catch (e, stackTrace) {
      debugPrint('[VastPreloader] Preload failed: $e');
      debugPrint('[VastPreloader] Stack trace: $stackTrace');
      _isFailed = true;
      _isPreloading = false;
      _controller?.dispose();
      _controller = null;
      return false;
    }
  }

  /// Fetch VAST XML, resolve Wrapper redirects, return final InLine ad data.
  Future<VastAdData?> _fetchAndParseVast(String url) async {
    final wrapperTrackingStack = <Map<String, List<String>>>[];
    final wrapperImpressionStack = <List<String>>[];
    final wrapperClickTrackingStack = <List<String>>[];
    final wrapperErrorStack = <String?>[];

    String currentUrl = url;

    for (int depth = 0; depth < VastParser.maxWrapperDepth; depth++) {
      final response = await http
          .get(Uri.parse(currentUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('[VastPreloader] HTTP ${response.statusCode} for VAST URL');
        return null;
      }

      final result = VastParser.parse(response.body);

      switch (result.status) {
        case VastParseStatus.success:
          // Got an InLine ad. Merge any wrapper tracking.
          if (wrapperTrackingStack.isNotEmpty) {
            return VastParser.mergeWrapperTracking(
              result.adData!,
              wrapperTrackingStack,
              wrapperImpressionStack,
              wrapperClickTrackingStack,
              wrapperErrorStack,
            );
          }
          return result.adData;

        case VastParseStatus.wrapper:
          // Follow the wrapper redirect
          debugPrint('[VastPreloader] Following wrapper (depth $depth)');
          if (result.wrapperTracking != null) {
            wrapperTrackingStack.add(result.wrapperTracking!);
          }
          if (result.wrapperImpressions != null) {
            wrapperImpressionStack.add(result.wrapperImpressions!);
          }
          if (result.wrapperClickTracking != null) {
            wrapperClickTrackingStack.add(result.wrapperClickTracking!);
          }
          wrapperErrorStack.add(result.wrapperErrorUrl);
          currentUrl = result.wrapperUrl!;
          continue;

        case VastParseStatus.empty:
          debugPrint('[VastPreloader] Empty VAST response (no ad available)');
          return null;

        case VastParseStatus.error:
          debugPrint('[VastPreloader] VAST parse error: ${result.errorMessage}');
          return null;
      }
    }

    debugPrint('[VastPreloader] Max wrapper depth exceeded');
    return null;
  }

  /// Dispose the preloaded ad controller and clean up.
  void dispose() {
    _disposed = true;
    _controller?.dispose();
    _controller = null;
    _adData = null;
    _tracker = null;
    _isReady = false;
    _isFailed = false;
    _isPreloading = false;
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}
