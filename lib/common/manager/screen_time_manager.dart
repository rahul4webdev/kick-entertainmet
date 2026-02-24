import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ScreenTimeManager with WidgetsBindingObserver {
  static final ScreenTimeManager instance = ScreenTimeManager._();
  ScreenTimeManager._();

  final _storage = GetStorage('shortzz');
  Timer? _ticker;
  DateTime? _sessionStart;
  bool _isActive = false;
  bool _dailyLimitShown = false;
  DateTime? _lastBreakShown;

  // Reactive value for live UI updates
  final RxInt todayUsageSeconds = 0.obs;

  // Storage keys
  static const _keyDailyLimit = 'screen_time_daily_limit';
  static const _keyBreakInterval = 'screen_time_break_interval';
  static const _keyBedtimeEnabled = 'screen_time_bedtime_enabled';
  static const _keyBedtimeHour = 'screen_time_bedtime_hour';
  static const _keyBedtimeMinute = 'screen_time_bedtime_minute';

  String _todayKey() =>
      'screen_time_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

  // --- Settings getters ---

  /// Daily limit in minutes. 0 = disabled.
  int get dailyLimitMinutes => _storage.read<int>(_keyDailyLimit) ?? 0;
  set dailyLimitMinutes(int v) => _storage.write(_keyDailyLimit, v);

  /// Break reminder interval in minutes. 0 = disabled.
  int get breakIntervalMinutes => _storage.read<int>(_keyBreakInterval) ?? 0;
  set breakIntervalMinutes(int v) => _storage.write(_keyBreakInterval, v);

  bool get bedtimeEnabled => _storage.read<bool>(_keyBedtimeEnabled) ?? false;
  set bedtimeEnabled(bool v) => _storage.write(_keyBedtimeEnabled, v);

  int get bedtimeHour => _storage.read<int>(_keyBedtimeHour) ?? 22;
  set bedtimeHour(int v) => _storage.write(_keyBedtimeHour, v);

  int get bedtimeMinute => _storage.read<int>(_keyBedtimeMinute) ?? 0;
  set bedtimeMinute(int v) => _storage.write(_keyBedtimeMinute, v);

  // --- Lifecycle ---

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    todayUsageSeconds.value = _readTodaySeconds();
    _startSession();
  }

  void dispose() {
    _stopSession();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSession();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopSession();
    }
  }

  // --- Session tracking ---

  void _startSession() {
    if (_isActive) return;
    _isActive = true;
    _sessionStart = DateTime.now();
    _dailyLimitShown = false;
    _lastBreakShown = DateTime.now();

    // Reset if new day
    todayUsageSeconds.value = _readTodaySeconds();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  void _stopSession() {
    if (!_isActive) return;
    _isActive = false;
    _ticker?.cancel();
    _ticker = null;
    _flushSession();
  }

  void _flushSession() {
    if (_sessionStart == null) return;
    final elapsed = DateTime.now().difference(_sessionStart!).inSeconds;
    if (elapsed > 0) {
      final current = _readTodaySeconds();
      _writeTodaySeconds(current + elapsed);
      todayUsageSeconds.value = current + elapsed;
    }
    _sessionStart = DateTime.now();
  }

  void _onTick() {
    _flushSession();
    _checkDailyLimit();
    _checkBreakReminder();
    _checkBedtime();
  }

  int _readTodaySeconds() => _storage.read<int>(_todayKey()) ?? 0;

  void _writeTodaySeconds(int seconds) =>
      _storage.write(_todayKey(), seconds);

  // --- Checks ---

  void _checkDailyLimit() {
    final limit = dailyLimitMinutes;
    if (limit <= 0 || _dailyLimitShown) return;
    if (todayUsageSeconds.value >= limit * 60) {
      _dailyLimitShown = true;
      _showDialog(
        title: 'Daily Limit Reached',
        message:
            'You\'ve spent ${_formatDuration(Duration(seconds: todayUsageSeconds.value))} on the app today. Consider taking a break.',
        buttonText: 'OK',
      );
    }
  }

  void _checkBreakReminder() {
    final interval = breakIntervalMinutes;
    if (interval <= 0 || _lastBreakShown == null) return;
    if (DateTime.now().difference(_lastBreakShown!).inMinutes >= interval) {
      _lastBreakShown = DateTime.now();
      _showDialog(
        title: 'Time for a Break',
        message:
            'You\'ve been using the app for $interval minutes. Stretch, rest your eyes, or grab some water.',
        buttonText: 'Got it',
      );
    }
  }

  void _checkBedtime() {
    if (!bedtimeEnabled) return;
    final now = TimeOfDay.now();
    final bt = TimeOfDay(hour: bedtimeHour, minute: bedtimeMinute);
    // Show if within the bedtime minute
    if (now.hour == bt.hour && now.minute == bt.minute) {
      // Only show once per minute
      final key = 'screen_time_bedtime_shown_${DateFormat('yyyy-MM-dd-HH-mm').format(DateTime.now())}';
      if (_storage.read<bool>(key) == true) return;
      _storage.write(key, true);
      _showDialog(
        title: 'Bedtime Reminder',
        message:
            'It\'s ${_formatTime(bt)}. Time to wind down and get some rest.',
        buttonText: 'OK',
      );
    }
  }

  // --- UI helpers ---

  void _showDialog({
    required String title,
    required String message,
    required String buttonText,
  }) {
    if (!Get.isOverlaysOpen) {
      Get.dialog(
        AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(buttonText),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }
  }

  static String formatDuration(Duration d) => _formatDuration(d);

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  /// Returns usage for last 7 days as a list of (date label, seconds).
  List<MapEntry<String, int>> weeklyUsage() {
    final result = <MapEntry<String, int>>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = 'screen_time_${DateFormat('yyyy-MM-dd').format(date)}';
      final seconds = _storage.read<int>(key) ?? 0;
      final label = DateFormat('EEE').format(date);
      result.add(MapEntry(label, seconds));
    }
    return result;
  }
}
