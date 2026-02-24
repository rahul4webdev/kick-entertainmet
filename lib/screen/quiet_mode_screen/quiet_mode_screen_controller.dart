import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/user_service.dart';

class QuietModeScreenController extends BaseController {
  RxBool isQuietMode = false.obs;
  RxInt selectedDurationMinutes = 0.obs;
  RxString autoReply = ''.obs;
  Rx<DateTime?> quietUntil = Rx(null);
  final TextEditingController autoReplyController = TextEditingController();

  final List<int> durationOptions = [30, 60, 120, 240, 480, 0]; // 0 = until turned off

  @override
  void onInit() {
    super.onInit();
    final user = SessionManager.instance.getUser();
    isQuietMode.value = user?.quietModeEnabled == true;
    autoReply.value = user?.quietModeAutoReply ?? '';
    autoReplyController.text = autoReply.value;

    if (user?.quietModeUntil != null) {
      quietUntil.value = DateTime.tryParse(user!.quietModeUntil!);
    }
  }

  @override
  void onClose() {
    autoReplyController.dispose();
    super.onClose();
  }

  String formatDuration(int minutes) {
    if (minutes == 0) return 'Until I turn it off';
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    return '${h}h';
  }

  Future<void> enableQuietMode(int durationMinutes) async {
    selectedDurationMinutes.value = durationMinutes;
    isQuietMode.value = true;

    String? until;
    if (durationMinutes > 0) {
      final endTime = DateTime.now().add(Duration(minutes: durationMinutes));
      quietUntil.value = endTime;
      until = endTime.toUtc().toIso8601String();
    } else {
      quietUntil.value = null;
      until = '';
    }

    await UserService.instance.updateUserDetails(
      quietModeEnabled: true,
      quietModeUntil: until,
    );
  }

  Future<void> disableQuietMode() async {
    isQuietMode.value = false;
    quietUntil.value = null;
    selectedDurationMinutes.value = 0;

    await UserService.instance.updateUserDetails(
      quietModeEnabled: false,
      quietModeUntil: '',
    );
  }

  Future<void> saveAutoReply() async {
    final text = autoReplyController.text.trim();
    autoReply.value = text;
    await UserService.instance.updateUserDetails(
      quietModeAutoReply: text,
    );
    showSnackBar('Auto-reply saved');
  }

  String get remainingTime {
    if (quietUntil.value == null) return 'Until turned off';
    final remaining = quietUntil.value!.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m remaining';
    return '${minutes}m remaining';
  }
}
