import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/calendar_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/screen/content_calendar_screen/content_calendar_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ContentCalendarScreen extends StatelessWidget {
  const ContentCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ContentCalendarController());

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Content Calendar'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.calendarData.value == null) {
                return const Center(child: CupertinoActivityIndicator());
              }
              return MyRefreshIndicator(
                onRefresh: controller.refreshAll,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      if (controller.calendarData.value?.summary != null)
                        _SummaryRow(
                            summary: controller.calendarData.value!.summary),
                      const SizedBox(height: 16),

                      // Month navigation + calendar grid
                      _MonthNavigation(controller: controller),
                      const SizedBox(height: 12),
                      _CalendarGrid(controller: controller),
                      const SizedBox(height: 16),

                      // Selected day events
                      if (controller.selectedDay.value != null) ...[
                        _DayEventsSection(controller: controller),
                        const SizedBox(height: 20),
                      ],

                      // Best time to post
                      _BestTimeSection(controller: controller),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Row ────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final CalendarSummary summary;

  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
          label: 'Published',
          count: summary.published,
          color: Colors.green,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Scheduled',
          count: summary.scheduled,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          label: 'Drafts',
          count: summary.drafts,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyleCustom.outFitLight300(
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Month Navigation ───────────────────────────────────────────────

class _MonthNavigation extends StatelessWidget {
  final ContentCalendarController controller;

  const _MonthNavigation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: controller.goToPreviousMonth,
              icon: Icon(Icons.chevron_left,
                  color: textDarkGrey(context), size: 24),
            ),
            Text(
              controller.monthLabel,
              style: TextStyleCustom.unboundedMedium500(
                fontSize: 16,
                color: textDarkGrey(context),
              ),
            ),
            IconButton(
              onPressed: controller.goToNextMonth,
              icon: Icon(Icons.chevron_right,
                  color: textDarkGrey(context), size: 24),
            ),
          ],
        ));
  }
}

// ─── Calendar Grid ──────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final ContentCalendarController controller;

  const _CalendarGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final month = controller.selectedMonth.value;
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final startWeekday = firstDay.weekday % 7; // 0=Sun
      final daysInMonth = lastDay.day;
      final today = DateTime.now();
      final selectedDay = controller.selectedDay.value;
      final eventsByDate = controller.eventsByDate;

      return Column(
        children: [
          // Day headers
          Row(
            children: ContentCalendarController.dayNames.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 11,
                      color: textLightGrey(context),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Calendar cells
          ...List.generate(
            ((startWeekday + daysInMonth + 6) / 7).ceil(),
            (week) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: List.generate(7, (weekday) {
                    final dayIndex = week * 7 + weekday - startWeekday + 1;
                    if (dayIndex < 1 || dayIndex > daysInMonth) {
                      return const Expanded(child: SizedBox(height: 44));
                    }

                    final date =
                        DateTime(month.year, month.month, dayIndex);
                    final dateStr = DateFormat('yyyy-MM-dd').format(date);
                    final events = eventsByDate[dateStr] ?? [];
                    final isToday = date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final isSelected = selectedDay != null &&
                        date.year == selectedDay.year &&
                        date.month == selectedDay.month &&
                        date.day == selectedDay.day;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectDay(date),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeAccentSolid(context)
                                : isToday
                                    ? themeAccentSolid(context)
                                        .withValues(alpha: 0.15)
                                    : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayIndex',
                                style: TextStyleCustom.outFitRegular400(
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : textDarkGrey(context),
                                ),
                              ),
                              if (events.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: events.take(3).map((e) {
                                    final color = switch (e.calendarStatus) {
                                      'published' => Colors.green,
                                      'scheduled' => Colors.blue,
                                      'draft' => Colors.orange,
                                      _ => Colors.grey,
                                    };
                                    return Container(
                                      width: 5,
                                      height: 5,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? Colors.white
                                            : color,
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

// ─── Day Events Section ─────────────────────────────────────────────

class _DayEventsSection extends StatelessWidget {
  final ContentCalendarController controller;

  const _DayEventsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final events = controller.selectedDayEvents;
      final dayLabel = controller.selectedDay.value != null
          ? DateFormat('EEEE, MMM d').format(controller.selectedDay.value!)
          : '';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayLabel,
            style: TextStyleCustom.unboundedMedium500(
              fontSize: 15,
              color: textDarkGrey(context),
            ),
          ),
          const SizedBox(height: 8),
          if (events.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No posts on this day',
                textAlign: TextAlign.center,
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 13,
                  color: textLightGrey(context),
                ),
              ),
            )
          else
            ...events.map((event) => _EventTile(event: event)),
        ],
      );
    });
  }
}

class _EventTile extends StatelessWidget {
  final CalendarEvent event;

  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (event.calendarStatus) {
      'published' => Colors.green,
      'scheduled' => Colors.blue,
      'draft' => Colors.orange,
      _ => Colors.grey,
    };
    final statusLabel = switch (event.calendarStatus) {
      'published' => 'Published',
      'scheduled' => 'Scheduled',
      'draft' => 'Draft',
      _ => '',
    };
    final typeLabel = switch (event.postType) {
      1 => 'Reel',
      2 => 'Image',
      3 => 'Video',
      4 => 'Text',
      _ => 'Post',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: statusColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          if (event.thumbnail != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomImage(
                  size: const Size(44, 44),
                  radius: 6,
                  image: event.thumbnail?.addBaseURL(),
                  isShowPlaceHolder: true,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description ?? 'No description',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 13,
                    color: textDarkGrey(context),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 10,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      typeLabel,
                      style: TextStyleCustom.outFitLight300(
                        fontSize: 10,
                        color: textLightGrey(context),
                      ),
                    ),
                    if (event.views != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.visibility,
                          size: 12, color: textLightGrey(context)),
                      const SizedBox(width: 3),
                      Text(
                        '${event.views}',
                        style: TextStyleCustom.outFitLight300(
                          fontSize: 10,
                          color: textLightGrey(context),
                        ),
                      ),
                    ],
                    if (event.likes != null) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.favorite,
                          size: 12, color: Colors.redAccent.withValues(alpha: 0.6)),
                      const SizedBox(width: 3),
                      Text(
                        '${event.likes}',
                        style: TextStyleCustom.outFitLight300(
                          fontSize: 10,
                          color: textLightGrey(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Best Time Section ──────────────────────────────────────────────

class _BestTimeSection extends StatelessWidget {
  final ContentCalendarController controller;

  const _BestTimeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isBestTimeLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }

      final data = controller.bestTimeData.value;
      if (data == null || data.totalSamples == 0) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgMediumGrey(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.schedule,
                  size: 28, color: textLightGrey(context)),
              const SizedBox(height: 8),
              Text(
                'Best Time Analytics',
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 14,
                  color: textDarkGrey(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Post more content to unlock posting time insights',
                textAlign: TextAlign.center,
                style: TextStyleCustom.outFitLight300(
                  fontSize: 12,
                  color: textLightGrey(context),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: themeAccentSolid(context)),
              const SizedBox(width: 8),
              Text(
                'Best Time to Post',
                style: TextStyleCustom.unboundedMedium500(
                  fontSize: 16,
                  color: textDarkGrey(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Top 3 best times
          if (data.bestTimes.isNotEmpty) ...[
            ...data.bestTimes.map((slot) => _BestTimeSlotTile(
                  slot: slot,
                  controller: controller,
                )),
            const SizedBox(height: 16),
          ],

          // Hourly engagement chart
          if (data.hourly.isNotEmpty) ...[
            Text(
              'Engagement by Hour',
              style: TextStyleCustom.outFitRegular400(
                fontSize: 13,
                color: textLightGrey(context),
              ),
            ),
            const SizedBox(height: 8),
            _HourlyChart(
              hourly: data.hourly,
              controller: controller,
            ),
            const SizedBox(height: 16),
          ],

          // Daily engagement
          if (data.daily.isNotEmpty) ...[
            Text(
              'Engagement by Day',
              style: TextStyleCustom.outFitRegular400(
                fontSize: 13,
                color: textLightGrey(context),
              ),
            ),
            const SizedBox(height: 8),
            _DailyChart(daily: data.daily),
          ],
        ],
      );
    });
  }
}

class _BestTimeSlotTile extends StatelessWidget {
  final BestTimeSlot slot;
  final ContentCalendarController controller;

  const _BestTimeSlotTile({required this.slot, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: themeAccentSolid(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded,
              size: 18, color: themeAccentSolid(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${ContentCalendarController.dayNames[slot.day]} at ${controller.hourLabel(slot.hour)}',
              style: TextStyleCustom.outFitMedium500(
                fontSize: 14,
                color: textDarkGrey(context),
              ),
            ),
          ),
          Text(
            '${slot.avgEngagementRate.toStringAsFixed(1)}% engagement',
            style: TextStyleCustom.outFitLight300(
              fontSize: 11,
              color: themeAccentSolid(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyChart extends StatelessWidget {
  final List<HourlyAnalytics> hourly;
  final ContentCalendarController controller;

  const _HourlyChart({required this.hourly, required this.controller});

  @override
  Widget build(BuildContext context) {
    final maxRate =
        hourly.fold(0.0, (m, h) => h.avgEngagementRate > m ? h.avgEngagementRate : m);
    final safeMax = maxRate > 0 ? maxRate : 1.0;

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final h = hourly[index];
          final ratio = h.avgEngagementRate / safeMax;
          return SizedBox(
            width: 36,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: (70 * ratio).clamp(4, 70),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context)
                        .withValues(alpha: 0.3 + ratio * 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${h.hour}',
                  style: TextStyleCustom.outFitLight300(
                    fontSize: 9,
                    color: textLightGrey(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<DailyAnalytics> daily;

  const _DailyChart({required this.daily});

  @override
  Widget build(BuildContext context) {
    final maxRate =
        daily.fold(0.0, (m, d) => d.avgEngagementRate > m ? d.avgEngagementRate : m);
    final safeMax = maxRate > 0 ? maxRate : 1.0;

    return Row(
      children: daily.map((d) {
        final ratio = d.avgEngagementRate / safeMax;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 60,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 28,
                  height: (50 * ratio).clamp(4, 50),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context)
                        .withValues(alpha: 0.3 + ratio * 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                d.dayName,
                style: TextStyleCustom.outFitLight300(
                  fontSize: 10,
                  color: textLightGrey(context),
                ),
              ),
              Text(
                '${d.avgEngagementRate.toStringAsFixed(1)}%',
                style: TextStyleCustom.outFitLight300(
                  fontSize: 9,
                  color: textLightGrey(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
