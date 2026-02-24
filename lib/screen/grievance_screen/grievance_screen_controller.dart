import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/compliance_service.dart';
import 'package:shortzz/languages/languages_keys.dart';

class GrievanceScreenController extends BaseController {
  RxList<Map<String, dynamic>> grievances = <Map<String, dynamic>>[].obs;
  RxBool isGrievanceLoading = false.obs;

  // Submit form
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxString selectedCategory = ''.obs;

  // GRO info
  RxMap<String, dynamic> groInfo = <String, dynamic>{}.obs;

  static const List<Map<String, String>> categories = [
    {'key': 'content_removal', 'label': 'Content Removal'},
    {'key': 'account_issue', 'label': 'Account Issue'},
    {'key': 'privacy', 'label': 'Privacy Concern'},
    {'key': 'harassment', 'label': 'Harassment'},
    {'key': 'data_request', 'label': 'Data Request'},
    {'key': 'other', 'label': 'Other'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchGrievances();
    fetchGROInfo();
  }

  Future<void> fetchGrievances() async {
    isGrievanceLoading.value = true;
    try {
      final result = await ComplianceService.instance.fetchGrievances();
      if (result['status'] == true && result['data'] != null) {
        final data = result['data'];
        if (data is Map && data['data'] is List) {
          grievances.assignAll(List<Map<String, dynamic>>.from(data['data']));
        } else if (data is List) {
          grievances.assignAll(List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      debugPrint('fetchGrievances error: $e');
    }
    isGrievanceLoading.value = false;
  }

  Future<void> fetchGROInfo() async {
    try {
      final result = await ComplianceService.instance.fetchGROInfo();
      if (result['status'] == true && result['data'] != null) {
        groInfo.value = Map<String, dynamic>.from(result['data']);
      }
    } catch (e) {
      debugPrint('fetchGROInfo error: $e');
    }
  }

  Future<void> submitGrievance() async {
    if (selectedCategory.value.isEmpty) {
      return showSnackBar(LKey.selectCategory.tr);
    }
    if (subjectController.text.trim().isEmpty) {
      return showSnackBar('${LKey.grievanceSubject.tr} is required');
    }
    if (descriptionController.text.trim().isEmpty) {
      return showSnackBar('${LKey.grievanceDescription.tr} is required');
    }

    showLoader();
    try {
      final result = await ComplianceService.instance.submitGrievance(
        category: selectedCategory.value,
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
      );
      stopLoader();

      if (result['status'] == true) {
        showSnackBar(LKey.grievanceSubmitted.tr);
        subjectController.clear();
        descriptionController.clear();
        selectedCategory.value = '';
        Get.back();
        fetchGrievances();
      } else {
        showSnackBar(result['message'] ?? 'Failed');
      }
    } catch (e) {
      stopLoader();
      showSnackBar('Error: $e');
    }
  }

  String statusLabel(int status) {
    return switch (status) {
      0 => LKey.received.tr,
      1 => LKey.acknowledged.tr,
      2 => LKey.inProgressStatus.tr,
      3 => LKey.resolved.tr,
      4 => LKey.closed.tr,
      _ => LKey.pending.tr,
    };
  }

  Color statusColor(int status) {
    return switch (status) {
      0 => Colors.orange,
      1 => Colors.blue,
      2 => Colors.purple,
      3 => Colors.green,
      4 => Colors.grey,
      _ => Colors.grey,
    };
  }
}
