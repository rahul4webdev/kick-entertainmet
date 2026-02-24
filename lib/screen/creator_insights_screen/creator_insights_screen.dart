import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/model/creator/creator_insight_model.dart';
import 'package:shortzz/screen/creator_insights_screen/creator_insights_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreatorInsightsScreen extends StatelessWidget {
  const CreatorInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatorInsightsController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'AI Insights',
            rowWidget: Obx(() {
              if (controller.unreadCount.value > 0) {
                return GestureDetector(
                  onTap: controller.markAllRead,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Mark all read',
                      style: TextStyleCustom.outFitRegular400(
                        color: themeAccentSolid(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox(width: 48);
            }),
          ),
          // Generate button
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: GestureDetector(
                  onTap: controller.isGenerating.value
                      ? null
                      : controller.generateInsights,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          themeAccentSolid(context),
                          themeAccentSolid(context).withValues(alpha: .7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (controller.isGenerating.value) ...[
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Analyzing your content...',
                            style: TextStyleCustom.outFitMedium500(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Generate New Insights',
                            style: TextStyleCustom.outFitMedium500(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )),
          // Insights list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.insights.isEmpty) {
                return const LoaderWidget();
              }
              if (controller.insights.isEmpty) {
                return NoDataView(
                  title: 'No Insights Yet',
                  description:
                      'Tap "Generate New Insights" to get AI-powered recommendations for your content.',
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchInsights(reset: true),
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  itemCount: controller.insights.length,
                  itemBuilder: (context, index) => _InsightCard(
                    insight: controller.insights[index],
                    onTap: () =>
                        controller.markRead(controller.insights[index]),
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

class _InsightCard extends StatelessWidget {
  final CreatorInsight insight;
  final VoidCallback onTap;

  const _InsightCard({required this.insight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgMediumGrey(context),
          borderRadius: BorderRadius.circular(14),
          border: !insight.isRead
              ? Border.all(
                  color: themeAccentSolid(context).withValues(alpha: .4),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(insight.typeIcon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    insight.title ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context),
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!insight.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              insight.body ?? '',
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InsightTypeBadge(type: insight.insightType),
                const Spacer(),
                if (insight.generatedAt != null)
                  Text(
                    _formatDate(insight.generatedAt!),
                    style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _InsightTypeBadge extends StatelessWidget {
  final String? type;

  const _InsightTypeBadge({this.type});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _typeLabel,
        style: TextStyleCustom.outFitRegular400(
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  String get _typeLabel => switch (type) {
        'growth' => 'Growth',
        'content' => 'Content',
        'engagement' => 'Engagement',
        'timing' => 'Timing',
        'audience' => 'Audience',
        _ => 'Insight',
      };

  Color get _typeColor => switch (type) {
        'growth' => Colors.green,
        'content' => Colors.blue,
        'engagement' => Colors.orange,
        'timing' => Colors.purple,
        'audience' => Colors.teal,
        _ => Colors.grey,
      };
}
