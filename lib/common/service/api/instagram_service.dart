import 'dart:convert';

import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/params.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/instagram_media_model.dart';
import 'package:shortzz/model/general/status_model.dart';

class InstagramService {
  InstagramService._();
  static final InstagramService instance = InstagramService._();

  Future<InstagramConnectionModel> getConnectionStatus() async {
    return await ApiService.instance.call(
      url: WebService.instagram.getConnectionStatus,
      fromJson: InstagramConnectionModel.fromJson,
    );
  }

  Future<StatusModel> handleOAuthCallback({required String code}) async {
    return await ApiService.instance.call(
      url: WebService.instagram.connect,
      param: {Params.code: code},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> disconnect() async {
    return await ApiService.instance.call(
      url: WebService.instagram.disconnect,
      fromJson: StatusModel.fromJson,
    );
  }

  Future<InstagramMediaModel> fetchMedia({String? after}) async {
    return await ApiService.instance.call(
      url: WebService.instagram.fetchMedia,
      param: {if (after != null) Params.after: after},
      fromJson: InstagramMediaModel.fromJson,
    );
  }

  Future<StatusModel> importVideo({
    required String instagramMediaId,
    required Map<String, dynamic> mediaData,
  }) async {
    return await ApiService.instance.call(
      url: WebService.instagram.importVideo,
      param: {
        Params.instagramMediaId: instagramMediaId,
        Params.mediaData: jsonEncode(mediaData),
      },
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> importBulk({
    required List<Map<String, dynamic>> mediaList,
  }) async {
    return await ApiService.instance.call(
      url: WebService.instagram.importBulk,
      param: {
        Params.mediaList: jsonEncode(mediaList),
      },
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> toggleAutoSync({required bool enabled}) async {
    return await ApiService.instance.call(
      url: WebService.instagram.toggleAutoSync,
      param: {Params.enabled: enabled ? '1' : '0'},
      fromJson: StatusModel.fromJson,
    );
  }
}
