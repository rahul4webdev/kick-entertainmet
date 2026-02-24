import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

/// Parsed data from a single VAST ad creative.
class VastAdData {
  final String? adId;
  final String? adSystem;
  final String? adTitle;
  final Duration duration;
  final List<VastMediaFile> mediaFiles;
  final List<String> impressionUrls;
  final String? errorUrl;
  final String? clickThroughUrl;
  final List<String> clickTrackingUrls;
  final Map<String, List<String>> trackingEvents;
  final String? skipOffset;

  const VastAdData({
    this.adId,
    this.adSystem,
    this.adTitle,
    required this.duration,
    required this.mediaFiles,
    required this.impressionUrls,
    this.errorUrl,
    this.clickThroughUrl,
    required this.clickTrackingUrls,
    required this.trackingEvents,
    this.skipOffset,
  });

  /// Get the best progressive MP4 media file for mobile playback.
  /// Prefers 720p, falls back to highest available resolution.
  String? get bestMediaUrl {
    if (mediaFiles.isEmpty) return null;

    // Filter for progressive MP4 files
    final mp4Files = mediaFiles
        .where((f) =>
            f.type == 'video/mp4' && f.delivery == 'progressive')
        .toList();

    if (mp4Files.isEmpty) {
      // Fall back to any MP4
      final anyMp4 = mediaFiles.where((f) => f.type == 'video/mp4').toList();
      if (anyMp4.isEmpty) return mediaFiles.first.url;
      return anyMp4.first.url;
    }

    // Prefer 720p for mobile (good quality, fast download)
    mp4Files.sort((a, b) {
      final aDiff = (a.height - 720).abs();
      final bDiff = (b.height - 720).abs();
      return aDiff.compareTo(bDiff);
    });

    return mp4Files.first.url;
  }

  /// Skip delay in seconds (null = not skippable).
  int? get skipDelaySec {
    if (skipOffset == null) return null;
    if (skipOffset!.contains(':')) {
      return _parseDuration(skipOffset!).inSeconds;
    }
    // Could be a percentage like "50%" — treat as 5 seconds default
    final seconds = int.tryParse(skipOffset!);
    return seconds ?? 5;
  }
}

class VastMediaFile {
  final String url;
  final String type;
  final String delivery;
  final int width;
  final int height;
  final int bitrate;

  const VastMediaFile({
    required this.url,
    required this.type,
    required this.delivery,
    required this.width,
    required this.height,
    required this.bitrate,
  });
}

/// Parses VAST XML and extracts ad data.
/// Supports VAST 2.0, 3.0, 4.0, 4.2.
/// Handles both InLine and Wrapper (redirect) ad types.
class VastParser {
  static const _maxWrapperDepth = 5;

  /// Parse VAST XML string into ad data.
  /// If the VAST is a Wrapper, returns null and the wrapper URL is in [wrapperUrl].
  static VastParseResult parse(String xmlString) {
    try {
      final document = XmlDocument.parse(xmlString);
      final vastElement = document.findElements('VAST').firstOrNull;
      if (vastElement == null) {
        debugPrint('[VAST] No VAST element found');
        return VastParseResult.error('No VAST element');
      }

      final adElement = vastElement.findElements('Ad').firstOrNull;
      if (adElement == null) {
        debugPrint('[VAST] No Ad element — empty VAST response');
        return VastParseResult.empty();
      }

      final adId = adElement.getAttribute('id');

      // Check if this is a Wrapper (redirect)
      final wrapper = adElement.findElements('Wrapper').firstOrNull;
      if (wrapper != null) {
        final wrapperUri =
            wrapper.findAllElements('VASTAdTagURI').firstOrNull?.innerText.trim();
        if (wrapperUri == null || wrapperUri.isEmpty) {
          return VastParseResult.error('Wrapper missing VASTAdTagURI');
        }
        // Collect wrapper-level tracking (merged with inline later)
        final wrapperTracking = _parseTrackingEvents(wrapper);
        final wrapperImpressions = _parseImpressions(wrapper);
        final wrapperClickTracking = _parseClickTracking(wrapper);
        final wrapperError = _parseError(wrapper);

        return VastParseResult.wrapper(
          url: wrapperUri,
          tracking: wrapperTracking,
          impressions: wrapperImpressions,
          clickTracking: wrapperClickTracking,
          errorUrl: wrapperError,
        );
      }

      // InLine ad — parse fully
      final inLine = adElement.findElements('InLine').firstOrNull;
      if (inLine == null) {
        return VastParseResult.error('Ad has neither InLine nor Wrapper');
      }

      return VastParseResult.success(_parseInLine(inLine, adId));
    } catch (e) {
      debugPrint('[VAST] Parse error: $e');
      return VastParseResult.error('Parse error: $e');
    }
  }

  static VastAdData _parseInLine(XmlElement inLine, String? adId) {
    final adSystem =
        inLine.findElements('AdSystem').firstOrNull?.innerText.trim();
    final adTitle =
        inLine.findElements('AdTitle').firstOrNull?.innerText.trim();

    // Impressions
    final impressions = _parseImpressions(inLine);

    // Error URL
    final errorUrl = _parseError(inLine);

    // Find Linear creative
    final creatives = inLine.findAllElements('Creative');
    XmlElement? linear;
    for (final creative in creatives) {
      linear = creative.findElements('Linear').firstOrNull;
      if (linear != null) break;
    }

    if (linear == null) {
      return VastAdData(
        adId: adId,
        adSystem: adSystem,
        adTitle: adTitle,
        duration: Duration.zero,
        mediaFiles: [],
        impressionUrls: impressions,
        errorUrl: errorUrl,
        clickTrackingUrls: [],
        trackingEvents: {},
      );
    }

    // Duration
    final durationStr =
        linear.findElements('Duration').firstOrNull?.innerText.trim();
    final duration =
        durationStr != null ? _parseDuration(durationStr) : Duration.zero;

    // Skip offset
    final skipOffset = linear.getAttribute('skipoffset');

    // Media files
    final mediaFiles = <VastMediaFile>[];
    for (final mf in linear.findAllElements('MediaFile')) {
      final url = mf.innerText.trim();
      if (url.isEmpty) continue;
      mediaFiles.add(VastMediaFile(
        url: url,
        type: mf.getAttribute('type') ?? 'video/mp4',
        delivery: mf.getAttribute('delivery') ?? 'progressive',
        width: int.tryParse(mf.getAttribute('width') ?? '0') ?? 0,
        height: int.tryParse(mf.getAttribute('height') ?? '0') ?? 0,
        bitrate: int.tryParse(mf.getAttribute('bitrate') ?? '0') ?? 0,
      ));
    }

    // Click-through
    final clickThrough = linear
        .findAllElements('ClickThrough')
        .firstOrNull
        ?.innerText
        .trim();

    // Click tracking
    final clickTracking = _parseClickTracking(linear);

    // Tracking events
    final trackingEvents = _parseTrackingEvents(linear);

    return VastAdData(
      adId: adId,
      adSystem: adSystem,
      adTitle: adTitle,
      duration: duration,
      mediaFiles: mediaFiles,
      impressionUrls: impressions,
      errorUrl: errorUrl,
      clickThroughUrl: clickThrough,
      clickTrackingUrls: clickTracking,
      trackingEvents: trackingEvents,
      skipOffset: skipOffset,
    );
  }

  static List<String> _parseImpressions(XmlElement parent) {
    return parent
        .findAllElements('Impression')
        .map((e) => e.innerText.trim())
        .where((u) => u.isNotEmpty)
        .toList();
  }

  static String? _parseError(XmlElement parent) {
    return parent.findElements('Error').firstOrNull?.innerText.trim();
  }

  static List<String> _parseClickTracking(XmlElement parent) {
    return parent
        .findAllElements('ClickTracking')
        .map((e) => e.innerText.trim())
        .where((u) => u.isNotEmpty)
        .toList();
  }

  static Map<String, List<String>> _parseTrackingEvents(XmlElement parent) {
    final events = <String, List<String>>{};
    for (final tracking in parent.findAllElements('Tracking')) {
      final event = tracking.getAttribute('event');
      final url = tracking.innerText.trim();
      if (event != null && url.isNotEmpty) {
        events.putIfAbsent(event, () => []).add(url);
      }
    }
    return events;
  }

  /// Merge wrapper-level tracking with inline ad data.
  static VastAdData mergeWrapperTracking(
    VastAdData inline,
    List<Map<String, List<String>>> wrapperTrackingStack,
    List<List<String>> wrapperImpressionStack,
    List<List<String>> wrapperClickTrackingStack,
    List<String?> wrapperErrorStack,
  ) {
    final mergedTracking = <String, List<String>>{};
    // Add inline tracking first
    for (final entry in inline.trackingEvents.entries) {
      mergedTracking.putIfAbsent(entry.key, () => []).addAll(entry.value);
    }
    // Add all wrapper-level tracking
    for (final wrapperTracking in wrapperTrackingStack) {
      for (final entry in wrapperTracking.entries) {
        mergedTracking.putIfAbsent(entry.key, () => []).addAll(entry.value);
      }
    }

    final mergedImpressions = [...inline.impressionUrls];
    for (final wrapperImpressions in wrapperImpressionStack) {
      mergedImpressions.addAll(wrapperImpressions);
    }

    final mergedClickTracking = [...inline.clickTrackingUrls];
    for (final wrapperClickTracking in wrapperClickTrackingStack) {
      mergedClickTracking.addAll(wrapperClickTracking);
    }

    // Use first non-null error URL
    String? mergedError = inline.errorUrl;
    if (mergedError == null || mergedError.isEmpty) {
      for (final e in wrapperErrorStack) {
        if (e != null && e.isNotEmpty) {
          mergedError = e;
          break;
        }
      }
    }

    return VastAdData(
      adId: inline.adId,
      adSystem: inline.adSystem,
      adTitle: inline.adTitle,
      duration: inline.duration,
      mediaFiles: inline.mediaFiles,
      impressionUrls: mergedImpressions,
      errorUrl: mergedError,
      clickThroughUrl: inline.clickThroughUrl,
      clickTrackingUrls: mergedClickTracking,
      trackingEvents: mergedTracking,
      skipOffset: inline.skipOffset,
    );
  }

  /// Maximum wrapper depth for safety.
  static int get maxWrapperDepth => _maxWrapperDepth;
}

/// Parse HH:MM:SS or HH:MM:SS.mmm duration string.
Duration _parseDuration(String str) {
  final parts = str.split(':');
  if (parts.length != 3) return Duration.zero;
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final secondsParts = parts[2].split('.');
  final seconds = int.tryParse(secondsParts[0]) ?? 0;
  final millis = secondsParts.length > 1
      ? int.tryParse(secondsParts[1].padRight(3, '0').substring(0, 3)) ?? 0
      : 0;
  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: millis,
  );
}

/// Result of parsing a VAST XML document.
class VastParseResult {
  final VastParseStatus status;
  final VastAdData? adData;
  final String? wrapperUrl;
  final String? errorMessage;

  // Wrapper-level tracking to merge later
  final Map<String, List<String>>? wrapperTracking;
  final List<String>? wrapperImpressions;
  final List<String>? wrapperClickTracking;
  final String? wrapperErrorUrl;

  const VastParseResult._({
    required this.status,
    this.adData,
    this.wrapperUrl,
    this.errorMessage,
    this.wrapperTracking,
    this.wrapperImpressions,
    this.wrapperClickTracking,
    this.wrapperErrorUrl,
  });

  factory VastParseResult.success(VastAdData data) =>
      VastParseResult._(status: VastParseStatus.success, adData: data);

  factory VastParseResult.wrapper({
    required String url,
    Map<String, List<String>>? tracking,
    List<String>? impressions,
    List<String>? clickTracking,
    String? errorUrl,
  }) =>
      VastParseResult._(
        status: VastParseStatus.wrapper,
        wrapperUrl: url,
        wrapperTracking: tracking,
        wrapperImpressions: impressions,
        wrapperClickTracking: clickTracking,
        wrapperErrorUrl: errorUrl,
      );

  factory VastParseResult.empty() =>
      const VastParseResult._(status: VastParseStatus.empty);

  factory VastParseResult.error(String message) =>
      VastParseResult._(status: VastParseStatus.error, errorMessage: message);
}

enum VastParseStatus { success, wrapper, empty, error }
