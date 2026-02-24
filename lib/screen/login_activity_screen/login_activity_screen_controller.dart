import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';

class LoginActivityScreenController extends BaseController {
  RxList<Map<String, dynamic>> sessions = <Map<String, dynamic>>[].obs;
  RxBool isDataLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    isDataLoading.value = true;
    sessions.value = await UserService.instance.fetchLoginSessions();
    isDataLoading.value = false;
  }

  Future<void> removeSession(int sessionId) async {
    showLoader();
    final result = await UserService.instance.logOutSession(sessionId: sessionId);
    stopLoader();
    if (result.status == true) {
      sessions.removeWhere((s) => s['id'] == sessionId);
      showSnackBar(result.message);
    } else {
      showSnackBar(result.message);
    }
  }

  String getDeviceLabel(Map<String, dynamic> session) {
    final brand = session['device_brand'] ?? '';
    final model = session['device_model'] ?? '';
    if (brand.isNotEmpty && model.isNotEmpty) {
      return '$brand $model';
    }
    if (model.isNotEmpty) return model;
    if (brand.isNotEmpty) return brand;
    final device = session['device'];
    return device == '0' ? 'Android' : device == '1' ? 'iOS' : 'Unknown Device';
  }

  String getOsLabel(Map<String, dynamic> session) {
    final os = session['device_os'] ?? '';
    final version = session['device_os_version'] ?? '';
    if (os.isNotEmpty && version.isNotEmpty) return '$os $version';
    if (os.isNotEmpty) return os;
    return '';
  }

  String getTimeLabel(Map<String, dynamic> session) {
    final loggedIn = session['logged_in_at'];
    if (loggedIn == null) return '';
    try {
      final dt = DateTime.parse(loggedIn);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return loggedIn.toString();
    }
  }
}
