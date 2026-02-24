import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';

class DataDownloadScreenController extends BaseController {
  RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  RxBool isDataLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    isDataLoading.value = true;
    requests.value = await UserService.instance.fetchDataDownloadRequests();
    isDataLoading.value = false;
  }

  Future<void> requestDownload() async {
    showLoader();
    final result = await UserService.instance.requestDataDownload();
    stopLoader();
    showSnackBar(result.message);
    if (result.status == true) {
      await _loadRequests();
    }
  }

  String getStatusLabel(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Processing';
      case 2:
        return 'Ready';
      case 3:
        return 'Expired';
      case 4:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  String getTimeLabel(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String formatFileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
