import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/scheduled_live_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/scheduled_live.dart';

class ScheduledLiveController extends BaseController {
  RxList<ScheduledLive> scheduledLives = <ScheduledLive>[].obs;
  RxList<ScheduledLive> myScheduledLives = <ScheduledLive>[].obs;
  RxBool isLoadingList = false.obs;

  // Create form
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  Rx<DateTime?> selectedDateTime = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void fetchAll() {
    fetchScheduledLives();
    fetchMyScheduledLives();
  }

  Future<void> fetchScheduledLives() async {
    isLoadingList.value = true;
    try {
      final lives = await ScheduledLiveService.instance.fetchScheduledLives();
      scheduledLives.assignAll(lives);
    } catch (_) {}
    isLoadingList.value = false;
  }

  Future<void> fetchMyScheduledLives() async {
    try {
      final lives = await ScheduledLiveService.instance.fetchMyScheduledLives();
      myScheduledLives.assignAll(lives);
    } catch (_) {}
  }

  Future<void> pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.value ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date == null) return;

    if (!context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: selectedDateTime.value != null
          ? TimeOfDay.fromDateTime(selectedDateTime.value!)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    final scheduled =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (scheduled.isBefore(DateTime.now())) {
      showSnackBar(LKey.scheduledTimePast);
      return;
    }
    selectedDateTime.value = scheduled;
  }

  Future<void> createScheduledLive() async {
    if (titleController.text.trim().isEmpty) {
      showSnackBar(LKey.liveTitle);
      return;
    }
    if (selectedDateTime.value == null) {
      showSnackBar(LKey.selectDateTime);
      return;
    }

    showLoader();
    try {
      final result = await ScheduledLiveService.instance.createScheduledLive(
        title: titleController.text.trim(),
        scheduledAt: selectedDateTime.value!,
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
      );
      stopLoader();

      if (result != null) {
        titleController.clear();
        descriptionController.clear();
        selectedDateTime.value = null;
        showSnackBar(LKey.liveScheduled);
        fetchAll();
        Get.back();
      }
    } catch (e) {
      stopLoader();
    }
  }

  Future<void> toggleReminder(ScheduledLive live) async {
    final success = await ScheduledLiveService.instance.toggleReminder(
      scheduledLiveId: live.id!,
    );
    if (success) {
      live.isReminded = !(live.isReminded ?? false);
      if (live.isReminded == true) {
        live.reminderCount = (live.reminderCount ?? 0) + 1;
        showSnackBar(LKey.reminderSet);
      } else {
        live.reminderCount = (live.reminderCount ?? 1) - 1;
        showSnackBar(LKey.reminderRemoved);
      }
      scheduledLives.refresh();
    }
  }

  Future<void> cancelScheduledLive(ScheduledLive live) async {
    showLoader();
    final success = await ScheduledLiveService.instance.cancelScheduledLive(
      scheduledLiveId: live.id!,
    );
    stopLoader();
    if (success) {
      myScheduledLives.removeWhere((e) => e.id == live.id);
      scheduledLives.removeWhere((e) => e.id == live.id);
      showSnackBar(LKey.liveCancelled);
    }
  }
}
