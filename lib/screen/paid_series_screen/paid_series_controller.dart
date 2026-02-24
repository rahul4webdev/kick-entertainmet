import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/paid_series_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/paid_series/paid_series_model.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class PaidSeriesController extends BaseController {
  RxList<PaidSeries> seriesList = <PaidSeries>[].obs;
  RxList<PaidSeries> mySeriesList = <PaidSeries>[].obs;
  RxList<PaidSeriesPurchase> myPurchases = <PaidSeriesPurchase>[].obs;
  RxBool isLoadingList = false.obs;

  // Detail screen state
  Rx<PaidSeries?> selectedSeries = Rx(null);
  RxList<Post> seriesVideos = <Post>[].obs;
  RxBool isSeriesPurchased = false.obs;
  RxBool isLoadingDetail = false.obs;

  // Create form
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Rx<XFile?> coverImage = Rx(null);

  // Creator ID filter (for viewing a specific creator's series)
  int? creatorId;

  @override
  void onInit() {
    super.onInit();
    fetchSeriesList();
    fetchMySeriesList();
    fetchMyPurchasesList();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  Future<void> fetchSeriesList({int? forCreatorId}) async {
    isLoadingList.value = true;
    try {
      final list = await PaidSeriesService.instance.fetchPaidSeries(
        creatorId: forCreatorId ?? creatorId,
      );
      seriesList.assignAll(list);
    } catch (_) {}
    isLoadingList.value = false;
  }

  Future<void> fetchMySeriesList() async {
    try {
      final list = await PaidSeriesService.instance.fetchMyPaidSeries();
      mySeriesList.assignAll(list);
    } catch (_) {}
  }

  Future<void> fetchMyPurchasesList() async {
    try {
      final list = await PaidSeriesService.instance.fetchMyPurchases();
      myPurchases.assignAll(list);
    } catch (_) {}
  }

  Future<void> fetchSeriesDetail(int seriesId) async {
    isLoadingDetail.value = true;
    try {
      final response =
          await PaidSeriesService.instance.fetchSeriesVideos(seriesId: seriesId);
      final data = response['data'] as Map<String, dynamic>?;
      if (data != null) {
        selectedSeries.value = PaidSeries.fromJson(data['series']);
        isSeriesPurchased.value = data['is_purchased'] == true;
        final videos = data['videos'] as List? ?? [];
        seriesVideos.assignAll(videos.map((e) => Post.fromJson(e)).toList());
      }
    } catch (_) {}
    isLoadingDetail.value = false;
  }

  Future<void> pickCoverImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      coverImage.value = picked;
    }
  }

  Future<void> createSeries() async {
    if (titleController.text.trim().isEmpty) {
      showSnackBar(LKey.seriesTitle);
      return;
    }
    final price = int.tryParse(priceController.text.trim());
    if (price == null || price < 1) {
      showSnackBar(LKey.priceInCoins);
      return;
    }

    showLoader();
    try {
      final result = await PaidSeriesService.instance.createPaidSeries(
        title: titleController.text.trim(),
        priceCoins: price,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        coverImage: coverImage.value,
      );
      stopLoader();

      if (result != null) {
        titleController.clear();
        descriptionController.clear();
        priceController.clear();
        coverImage.value = null;
        showSnackBar(LKey.seriesCreated);
        fetchMySeriesList();
        Get.back();
      }
    } catch (e) {
      stopLoader();
    }
  }

  Future<void> purchaseSeries(PaidSeries series) async {
    showLoader();
    try {
      final response = await PaidSeriesService.instance.purchaseSeries(
        seriesId: series.id!,
      );
      stopLoader();

      if (response['status'] == true) {
        showSnackBar(LKey.seriesPurchased);
        isSeriesPurchased.value = true;
        // Refresh detail to get unlocked videos
        fetchSeriesDetail(series.id!);
        fetchMyPurchasesList();
        // Update browse list
        final idx = seriesList.indexWhere((s) => s.id == series.id);
        if (idx != -1) {
          seriesList[idx].isPurchased = true;
          seriesList.refresh();
        }
      } else {
        showSnackBar(response['message'] ?? LKey.somethingWentWrong);
      }
    } catch (e) {
      stopLoader();
      showSnackBar(LKey.somethingWentWrong);
    }
  }

  Future<void> addVideoToSeries(int seriesId, int postId) async {
    showLoader();
    try {
      final result = await PaidSeriesService.instance.addVideoToSeries(
        seriesId: seriesId,
        postId: postId,
      );
      stopLoader();
      if (result.status == true) {
        showSnackBar(LKey.videoAdded);
        fetchSeriesDetail(seriesId);
        fetchMySeriesList();
      } else {
        showSnackBar(result.message);
      }
    } catch (e) {
      stopLoader();
    }
  }

  Future<void> removeVideoFromSeries(int seriesId, int postId) async {
    showLoader();
    try {
      final result = await PaidSeriesService.instance.removeVideoFromSeries(
        seriesId: seriesId,
        postId: postId,
      );
      stopLoader();
      if (result.status == true) {
        showSnackBar(LKey.videoRemoved);
        seriesVideos.removeWhere((v) => v.id == postId);
        fetchMySeriesList();
      } else {
        showSnackBar(result.message);
      }
    } catch (e) {
      stopLoader();
    }
  }

  Future<void> deleteSeries(PaidSeries series) async {
    showLoader();
    try {
      final result = await PaidSeriesService.instance.deletePaidSeries(
        seriesId: series.id!,
      );
      stopLoader();
      if (result.status == true) {
        showSnackBar(LKey.seriesDeleted);
        mySeriesList.removeWhere((s) => s.id == series.id);
      }
    } catch (e) {
      stopLoader();
    }
  }
}
