import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/compliance_service.dart';
import 'package:shortzz/languages/languages_keys.dart';

class AppealScreenController extends BaseController {
  RxList<Map<String, dynamic>> appeals = <Map<String, dynamic>>[].obs;
  RxBool isAppealLoading = false.obs;

  // Submit form
  TextEditingController reasonController = TextEditingController();
  TextEditingController contextController = TextEditingController();
  RxString selectedAppealType = ''.obs;

  static const List<Map<String, String>> appealTypes = [
    {'key': 'post_removal', 'label': 'Post Removal'},
    {'key': 'account_ban', 'label': 'Account Ban'},
    {'key': 'account_freeze', 'label': 'Account Freeze'},
    {'key': 'violation', 'label': 'Violation Dispute'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchAppeals();
  }

  Future<void> fetchAppeals() async {
    isAppealLoading.value = true;
    try {
      final result = await ComplianceService.instance.fetchAppeals();
      if (result['status'] == true && result['data'] != null) {
        final data = result['data'];
        if (data is Map && data['data'] is List) {
          appeals.assignAll(List<Map<String, dynamic>>.from(data['data']));
        } else if (data is List) {
          appeals.assignAll(List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      debugPrint('fetchAppeals error: $e');
    }
    isAppealLoading.value = false;
  }

  Future<void> submitAppeal() async {
    if (selectedAppealType.value.isEmpty) {
      return showSnackBar(LKey.selectCategory.tr);
    }
    if (reasonController.text.trim().isEmpty) {
      return showSnackBar('${LKey.appealReason.tr} is required');
    }

    showLoader();
    try {
      final result = await ComplianceService.instance.submitAppeal(
        appealType: selectedAppealType.value,
        reason: reasonController.text.trim(),
        additionalContext: contextController.text.trim().isEmpty
            ? null
            : contextController.text.trim(),
      );
      stopLoader();

      if (result['status'] == true) {
        showSnackBar(LKey.appealSubmitted.tr);
        reasonController.clear();
        contextController.clear();
        selectedAppealType.value = '';
        Get.back();
        fetchAppeals();
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
      0 => LKey.pending.tr,
      1 => LKey.underReview.tr,
      2 => LKey.upheld.tr,
      3 => LKey.overturned.tr,
      _ => LKey.pending.tr,
    };
  }

  Color statusColor(int status) {
    return switch (status) {
      0 => Colors.orange,
      1 => Colors.blue,
      2 => Colors.red,
      3 => Colors.green,
      _ => Colors.grey,
    };
  }
}
