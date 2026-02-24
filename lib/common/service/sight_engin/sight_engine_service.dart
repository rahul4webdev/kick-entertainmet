import 'dart:io';

import 'package:flutter_native_video_trimmer/flutter_native_video_trimmer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/app_res.dart';

class SightEngineService {
  static var shared = SightEngineService();

  Future<void> checkImagesInSightEngine({
    required List<XFile> xFiles,
    required Function() completion,
  }) async {
    if (SessionManager.instance.getSettings()?.isContentModeration == 0) {
      completion();
      return;
    }
    BaseController.share.showLoader();

    try {
      final response = await ApiService.instance.multiPartCallApi<Map<String, dynamic>>(
        url: WebService.contentModeration.check,
        filesMap: {'file': xFiles},
        param: {'type': 'image'},
      );

      BaseController.share.stopLoader();

      final action = response['data']?['action'] ?? 'accept';
      if (action == 'accept') {
        completion();
      } else {
        final reasons = List<String>.from(response['data']?['reasons'] ?? []);
        BaseController.share.showSnackBar(
            '${LKey.mediaRejectedAndContainsSuchThings.tr} ${reasons.join(', ')}');
      }
    } catch (e) {
      Loggers.error('Content moderation error: $e');
      BaseController.share.stopLoader();
      completion();
    }
  }

  Future<void> checkVideoInSightEngine({
    required XFile xFile,
    required int duration,
    required Function() completion,
  }) async {
    if (SessionManager.instance.getSettings()?.isContentModeration == 0) {
      completion();
      return;
    }

    File file = File(xFile.path);
    BaseController.share.showLoader();

    try {
      if (duration > AppRes.sightEngineCropSec) {
        final videoTrimmer = VideoTrimmer();
        try {
          await videoTrimmer.loadVideo(file.path);
        } catch (e) {
          Loggers.error(e);
        }
        final trimmedPath = await videoTrimmer.trimVideo(
          startTimeMs: 0,
          endTimeMs: AppRes.sightEngineCropSec * 1000,
          includeAudio: false,
        );
        file = File(trimmedPath ?? '');
      }

      final response = await ApiService.instance.multiPartCallApi<Map<String, dynamic>>(
        url: WebService.contentModeration.check,
        filesMap: {'file': [XFile(file.path)]},
        param: {'type': 'video'},
      );

      BaseController.share.stopLoader();

      final action = response['data']?['action'] ?? 'accept';
      if (action == 'accept') {
        completion();
      } else {
        final reasons = List<String>.from(response['data']?['reasons'] ?? []);
        BaseController.share.showSnackBar(
            '${LKey.mediaRejectedAndContainsSuchThings.tr} ${reasons.join(', ')}');
      }
    } catch (e) {
      Loggers.error('Content moderation error: $e');
      BaseController.share.stopLoader();
      completion();
    }
  }

  Future<void> chooseTextModeration({
    required String text,
    required Function() completion,
  }) async {
    if (SessionManager.instance.getSettings()?.isContentModeration == 0) {
      completion();
      return;
    }
    if (text.isEmpty) {
      completion();
      return;
    }
    BaseController.share.showLoader();

    try {
      final response = await ApiService.instance.multiPartCallApi<Map<String, dynamic>>(
        url: WebService.contentModeration.check,
        filesMap: {},
        param: {'type': 'text', 'content': text},
      );

      BaseController.share.stopLoader();

      final action = response['data']?['action'] ?? 'accept';
      if (action == 'accept') {
        completion();
      } else {
        final reasons = List<String>.from(response['data']?['reasons'] ?? []);
        BaseController.share.showSnackBar(
            '${LKey.textRejectedAndContainsSuchThings.tr} ${reasons.join(', ')}');
      }
    } catch (e) {
      Loggers.error('Content moderation error: $e');
      BaseController.share.stopLoader();
      completion();
    }
  }
}
