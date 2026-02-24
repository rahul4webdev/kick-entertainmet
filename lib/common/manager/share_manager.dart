import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/user_model/user_model.dart';
import 'package:shortzz/screen/share_sheet_widget/share_sheet_widget.dart';
import 'package:shortzz/utilities/const_res.dart';

enum ShareKeys {
  reel('reel'),
  post('post'),
  user("user");

  const ShareKeys(this.value);

  final String value;
}

class ShareManager {
  static var shared = ShareManager();
  var isListenerConfigured = false;

  void listen(Function(String key, int value) completion) {
    if (isListenerConfigured) return;
    isListenerConfigured = true;

    final appLinks = AppLinks();

    // Handle cold start: check for the initial link that launched the app
    appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('[DeepLink] Initial (cold start) link: $uri');
        _handleIncomingUri(uri, completion);
      }
    }).catchError((e) {
      debugPrint('[DeepLink] getInitialLink error: $e');
    });

    // Handle warm start: listen for links while app is already running
    appLinks.uriLinkStream.listen((uri) {
      debugPrint('[DeepLink] Stream (warm start) link: $uri');
      _handleIncomingUri(uri, completion);
    });
  }

  void _handleIncomingUri(Uri uri, Function(String key, int value) completion) {
    Loggers.info('Share Link Opened: $uri ${uri.pathSegments} ${uri.path}');
    if (uri.pathSegments.isNotEmpty) {
      // Try clean URL format first: /p/{id}, /r/{id}, /u/{id}
      final parsed = _parseCleanUrl(uri);
      if (parsed != null) {
        completion(parsed.$1, parsed.$2);
        return;
      }

      // Fall back to legacy base64 encoded format: /s/{encoded}
      try {
        var encoded = uri.pathSegments.last;
        Loggers.success(encoded);
        var decoded = safeBase64Decode(encoded);
        var values = decoded.split('_');
        completion(values.first, int.parse(values.last));
      } catch (e) {
        debugPrint('[DeepLink] Failed to parse legacy link: $e');
      }
    }
  }

  void getValuesFromURL({required String url, required Function(String key, int value) completion}) {
    var uri = Uri.parse(url);
    if (uri.pathSegments.isNotEmpty) {
      // Try clean URL format first
      final parsed = _parseCleanUrl(uri);
      if (parsed != null) {
        completion(parsed.$1, parsed.$2);
        return;
      }

      // Fall back to legacy base64
      var encoded = uri.pathSegments.last;
      Loggers.success(encoded);
      var decoded = safeBase64Decode(encoded);

      var values = decoded.split('_');
      completion(values.first, int.parse(values.last));
    }
  }

  /// Parse clean URL formats: /p/{id}, /r/{id}, /u/{id}
  (String, int)? _parseCleanUrl(Uri uri) {
    if (uri.pathSegments.length >= 2) {
      final prefix = uri.pathSegments[uri.pathSegments.length - 2];
      final idStr = uri.pathSegments.last;
      final id = int.tryParse(idStr);
      if (id != null) {
        switch (prefix) {
          case 'p':
            return ('post', id);
          case 'r':
            return ('reel', id);
        }
      }
      // /u/{username} is handled differently (username, not ID)
      // so we don't parse it here — the deep link listener
      // should handle user profile lookups separately if needed
    }
    // Single segment clean URL: check if it looks like /p/123
    if (uri.pathSegments.length == 2) {
      final prefix = uri.pathSegments.first;
      final idStr = uri.pathSegments.last;
      final id = int.tryParse(idStr);
      if (id != null) {
        switch (prefix) {
          case 'p':
            return ('post', id);
          case 'r':
            return ('reel', id);
          case 'u':
            return ('user', id);
        }
      }
    }
    return null;
  }

  /// Share using clean URL format (preferred)
  void shareTheContent({required ShareKeys key, required int value}) {
    final url = getCleanLink(key: key, value: value);
    final context = Get.context!;

    final box = context.findRenderObject() as RenderBox?;
    final origin = box!.localToGlobal(Offset.zero) & box.size;

    SharePlus.instance.share(ShareParams(uri: Uri.parse(url), sharePositionOrigin: origin));
  }

  /// Get clean URL for sharing (better OG metadata on external platforms)
  String getCleanLink({required ShareKeys key, required int value}) {
    switch (key) {
      case ShareKeys.reel:
        return '${baseURL}r/$value';
      case ShareKeys.post:
        return '${baseURL}p/$value';
      case ShareKeys.user:
        return '${baseURL}u/$value';
    }
  }

  /// Get legacy encoded link (backward compatibility)
  String getLink({required ShareKeys key, required int value}) {
    return getCleanLink(key: key, value: value);
  }

  /// Get legacy base64 encoded link
  String getLegacyLink({required ShareKeys key, required int value}) {
    final encoded = safeBase64Encode('${key.value}_$value');
    return '${baseURL}s/$encoded';
  }

  String safeBase64Encode(String input) {
    // Encode normally
    String encoded = base64.encode(utf8.encode(input));

    // Remove all '=' padding at the end
    return encoded.replaceAll('=', '');
  }

  String safeBase64Decode(String input) {
    // Remove all whitespace
    input = input.trim();
    Loggers.info(input);

    // Remove any invalid padding (> 2 '=' at end)
    input = input.replaceAll(RegExp(r'=+$'), '');

    // Add correct padding (base64 should be multiple of 4)
    while (input.length % 4 != 0) {
      input += '=';
    }

    return utf8.decode(base64.decode(input));
  }

  void showCustomShareSheet({
    User? user,
    Post? post,
    required ShareKeys keys,
    VoidCallback? onShareSuccess,
  }) {
    int? id = keys == ShareKeys.user ? user?.id : post?.id;
    String link = getCleanLink(key: keys, value: id ?? -1);
    Get.bottomSheet(
      ShareSheetWidget(
        onMoreTap: () {
          Get.back();
          if (keys == ShareKeys.post || keys == ShareKeys.reel) {
            shareTheContent(key: keys, value: post?.id ?? -1);
            _increaseShareCount(post?.id, onShareSuccess);
          } else if (keys == ShareKeys.user) {
            shareTheContent(key: keys, value: user?.id ?? -1);
          }
        },
        post: post,
        link: link,
        isDownloadShow: keys == ShareKeys.reel,
        keys: keys,
        onCallBack: onShareSuccess,
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _increaseShareCount(int? postId, VoidCallback? onSuccess) async {
    if (postId == null) return;
    final response = await PostService.instance.increaseShareCount(postId: postId);
    if (response.status == true) {
      onSuccess?.call();
    }
  }
}
