import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/screen_time_manager.dart';

class ScreenTimeScreenController extends BaseController {
  final manager = ScreenTimeManager.instance;

  RxInt dailyLimit = 0.obs;
  RxInt breakInterval = 0.obs;
  RxBool bedtimeEnabled = false.obs;
  Rx<TimeOfDay> bedtime = const TimeOfDay(hour: 22, minute: 0).obs;

  final List<int> dailyLimitOptions = [0, 30, 60, 90, 120, 180];
  final List<int> breakIntervalOptions = [0, 15, 30, 45, 60];

  @override
  void onInit() {
    super.onInit();
    dailyLimit.value = manager.dailyLimitMinutes;
    breakInterval.value = manager.breakIntervalMinutes;
    bedtimeEnabled.value = manager.bedtimeEnabled;
    bedtime.value = TimeOfDay(
      hour: manager.bedtimeHour,
      minute: manager.bedtimeMinute,
    );
  }

  void setDailyLimit(int minutes) {
    dailyLimit.value = minutes;
    manager.dailyLimitMinutes = minutes;
  }

  void setBreakInterval(int minutes) {
    breakInterval.value = minutes;
    manager.breakIntervalMinutes = minutes;
  }

  void toggleBedtime(bool value) {
    bedtimeEnabled.value = value;
    manager.bedtimeEnabled = value;
  }

  void pickBedtime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: bedtime.value,
    );
    if (picked != null) {
      bedtime.value = picked;
      manager.bedtimeHour = picked.hour;
      manager.bedtimeMinute = picked.minute;
    }
  }

  String formatLimit(int minutes) {
    if (minutes == 0) return 'Off';
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String formatBedtime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
