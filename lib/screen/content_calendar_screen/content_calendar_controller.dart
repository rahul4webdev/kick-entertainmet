import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/service/api/calendar_service.dart';

class ContentCalendarController extends GetxController {
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final Rx<DateTime?> selectedDay = Rx(null);
  final Rx<CalendarData?> calendarData = Rx(null);
  final Rx<BestTimeData?> bestTimeData = Rx(null);
  final RxBool isLoading = true.obs;
  final RxBool isBestTimeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCalendarEvents();
    fetchBestTime();
  }

  Future<void> fetchCalendarEvents() async {
    isLoading.value = true;
    final data = await CalendarService.instance.fetchCalendarEvents(
      year: selectedMonth.value.year,
      month: selectedMonth.value.month,
    );
    calendarData.value = data;
    isLoading.value = false;
  }

  Future<void> fetchBestTime() async {
    isBestTimeLoading.value = true;
    bestTimeData.value = await CalendarService.instance.fetchBestTimeToPost();
    isBestTimeLoading.value = false;
  }

  void goToPreviousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
    );
    selectedDay.value = null;
    fetchCalendarEvents();
  }

  void goToNextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
    );
    selectedDay.value = null;
    fetchCalendarEvents();
  }

  void selectDay(DateTime day) {
    selectedDay.value = day;
  }

  String get monthLabel =>
      DateFormat('MMMM yyyy').format(selectedMonth.value);

  List<CalendarEvent> get selectedDayEvents {
    if (selectedDay.value == null || calendarData.value == null) return [];
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDay.value!);
    for (final day in calendarData.value!.days) {
      if (day.date == dateStr) return day.events;
    }
    return [];
  }

  int eventsForDay(DateTime day) {
    if (calendarData.value == null) return 0;
    final dateStr = DateFormat('yyyy-MM-dd').format(day);
    for (final d in calendarData.value!.days) {
      if (d.date == dateStr) return d.count;
    }
    return 0;
  }

  Map<String, List<CalendarEvent>> get eventsByDate {
    if (calendarData.value == null) return {};
    final map = <String, List<CalendarEvent>>{};
    for (final day in calendarData.value!.days) {
      map[day.date] = day.events;
    }
    return map;
  }

  String hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }

  static const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  Future<void> refreshAll() async {
    await fetchCalendarEvents();
    await fetchBestTime();
  }
}
