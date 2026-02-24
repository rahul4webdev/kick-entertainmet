import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/service/api/api_service.dart';
import 'package:shortzz/common/service/utils/web_service.dart';
import 'package:shortzz/model/general/status_model.dart';
import 'package:shortzz/model/paid_series/paid_series_model.dart';

class PaidSeriesService {
  PaidSeriesService._();
  static final PaidSeriesService instance = PaidSeriesService._();

  Future<PaidSeries?> createPaidSeries({
    required String title,
    required int priceCoins,
    String? description,
    XFile? coverImage,
  }) async {
    if (coverImage != null) {
      final response = await ApiService.instance.multiPartCallApi(
        url: WebService.paidSeries.create,
        param: {
          'title': title,
          'price_coins': priceCoins.toString(),
          if (description != null) 'description': description,
        },
        filesMap: {
          'cover_image': [coverImage],
        },
        fromJson: (json) => json,
      );
      if (response['status'] == true && response['data'] != null) {
        return PaidSeries.fromJson(response['data']);
      }
      return null;
    } else {
      final response = await ApiService.instance.call(
        url: WebService.paidSeries.create,
        param: {
          'title': title,
          'price_coins': priceCoins,
          if (description != null) 'description': description,
        },
        fromJson: (json) => json,
      );
      if (response['status'] == true && response['data'] != null) {
        return PaidSeries.fromJson(response['data']);
      }
      return null;
    }
  }

  Future<StatusModel> updatePaidSeries({
    required int seriesId,
    String? title,
    int? priceCoins,
    String? description,
    XFile? coverImage,
  }) async {
    if (coverImage != null) {
      return await ApiService.instance.multiPartCallApi(
        url: WebService.paidSeries.update,
        param: {
          'series_id': seriesId.toString(),
          if (title != null) 'title': title,
          if (priceCoins != null) 'price_coins': priceCoins.toString(),
          if (description != null) 'description': description,
        },
        filesMap: {
          'cover_image': [coverImage],
        },
        fromJson: StatusModel.fromJson,
      );
    } else {
      return await ApiService.instance.call(
        url: WebService.paidSeries.update,
        param: {
          'series_id': seriesId,
          if (title != null) 'title': title,
          if (priceCoins != null) 'price_coins': priceCoins,
          if (description != null) 'description': description,
        },
        fromJson: StatusModel.fromJson,
      );
    }
  }

  Future<StatusModel> deletePaidSeries({required int seriesId}) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.delete,
      param: {'series_id': seriesId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> addVideoToSeries({
    required int seriesId,
    required int postId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.addVideo,
      param: {'series_id': seriesId, 'post_id': postId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> removeVideoFromSeries({
    required int seriesId,
    required int postId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.removeVideo,
      param: {'series_id': seriesId, 'post_id': postId},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<StatusModel> reorderSeriesVideos({
    required int seriesId,
    required List<int> postIds,
  }) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.reorderVideos,
      param: {'series_id': seriesId, 'post_ids': postIds},
      fromJson: StatusModel.fromJson,
    );
  }

  Future<List<PaidSeries>> fetchPaidSeries({
    int? creatorId,
    int? lastItemId,
    int limit = 20,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.paidSeries.fetch,
      param: {
        'limit': limit,
        if (creatorId != null) 'creator_id': creatorId,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
      fromJson: (json) => json,
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => PaidSeries.fromJson(e)).toList();
  }

  Future<List<PaidSeries>> fetchMyPaidSeries() async {
    final response = await ApiService.instance.call(
      url: WebService.paidSeries.fetchMine,
      param: {},
      fromJson: (json) => json,
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => PaidSeries.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> fetchSeriesVideos({
    required int seriesId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.fetchVideos,
      param: {'series_id': seriesId},
      fromJson: (json) => json,
    );
  }

  Future<Map<String, dynamic>> purchaseSeries({
    required int seriesId,
  }) async {
    return await ApiService.instance.call(
      url: WebService.paidSeries.purchase,
      param: {'series_id': seriesId},
      fromJson: (json) => json,
    );
  }

  Future<List<PaidSeriesPurchase>> fetchMyPurchases({
    int? lastItemId,
    int limit = 20,
  }) async {
    final response = await ApiService.instance.call(
      url: WebService.paidSeries.fetchMyPurchases,
      param: {
        'limit': limit,
        if (lastItemId != null) 'last_item_id': lastItemId,
      },
      fromJson: (json) => json,
    );
    final data = response['data'] as List? ?? [];
    return data.map((e) => PaidSeriesPurchase.fromJson(e)).toList();
  }
}
