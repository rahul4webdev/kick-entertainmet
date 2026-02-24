import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/moderation_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/model/moderation/moderation_log_model.dart';
import 'package:shortzz/model/moderation/moderation_stats_model.dart';
import 'package:shortzz/model/moderation/pending_report_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/style_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ModeratorPanelScreen extends StatefulWidget {
  const ModeratorPanelScreen({super.key});

  @override
  State<ModeratorPanelScreen> createState() => _ModeratorPanelScreenState();
}

class _ModeratorPanelScreenState extends State<ModeratorPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ModerationStats? stats;
  List<PendingReport> postReports = [];
  List<PendingReport> userReports = [];
  List<ModerationLogEntry> activityLog = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final results = await Future.wait([
      ModerationService.instance.fetchModerationStats(),
      ModerationService.instance.fetchPendingReports(type: 'post'),
      ModerationService.instance.fetchPendingReports(type: 'user'),
      ModerationService.instance.fetchModerationLog(),
    ]);
    setState(() {
      stats = results[0] as ModerationStats?;
      postReports = results[1] as List<PendingReport>;
      userReports = results[2] as List<PendingReport>;
      activityLog = results[3] as List<ModerationLogEntry>;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Moderator Panel'),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: themeColor(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: themeColor(context),
            labelStyle: TextStyleCustom.outFitMedium500(fontSize: 13),
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Dashboard${stats != null ? ' (${stats!.totalPending ?? 0})' : ''}'),
              Tab(text: 'Post Reports (${postReports.length})'),
              Tab(text: 'User Reports (${userReports.length})'),
              const Tab(text: 'Activity Log'),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboard(context),
                      _buildPostReports(context),
                      _buildUserReports(context),
                      _buildActivityLog(context),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Dashboard Tab ──────────────────────────────────────

  Widget _buildDashboard(BuildContext context) {
    if (stats == null) {
      return Center(
        child: Text('Unable to load stats',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context))),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              context,
              title: 'Pending Reports',
              items: [
                _StatItem('Post Reports', '${stats!.pendingPostReports ?? 0}',
                    const Color(0xFFEF4444)),
                _StatItem('User Reports', '${stats!.pendingUserReports ?? 0}',
                    const Color(0xFFF59E0B)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              title: 'My Activity',
              items: [
                _StatItem('Today', '${stats!.myActionsToday ?? 0}',
                    const Color(0xFF10B981)),
                _StatItem('Total Actions', '${stats!.myTotalActions ?? 0}',
                    const Color(0xFF6366F1)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              icon: AssetRes.icAlert,
              label: 'Violations (Last 7 Days)',
              value: '${stats!.recentViolations7d ?? 0}',
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context,
      {required String title, required List<_StatItem> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyleCustom.outFitBold700(
                  fontSize: 14, color: blackPure(context))),
          const SizedBox(height: 12),
          Row(
            children: items
                .map((item) => Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: ShapeDecoration(
                          color: scaffoldBackgroundColor(context),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 10, cornerSmoothing: 1),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(item.value,
                                style: TextStyleCustom.outFitBold700(
                                    fontSize: 24, color: item.color)),
                            const SizedBox(height: 4),
                            Text(item.label,
                                style: TextStyleCustom.outFitRegular400(
                                    fontSize: 12,
                                    color: textLightGrey(context))),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required String icon,
      required String label,
      required String value,
      required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 24, height: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 14, color: blackPure(context))),
          ),
          Text(value,
              style: TextStyleCustom.outFitBold700(fontSize: 24, color: color)),
        ],
      ),
    );
  }

  // ─── Post Reports Tab ──────────────────────────────────

  Widget _buildPostReports(BuildContext context) {
    if (postReports.isEmpty) {
      return Center(
        child: Text('No pending post reports',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context))),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: postReports.length,
        itemBuilder: (context, index) {
          final report = postReports[index];
          return _buildPostReportCard(context, report);
        },
      ),
    );
  }

  Widget _buildPostReportCard(BuildContext context, PendingReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AssetRes.icReport, width: 18, height: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Post #${report.postId ?? '?'} reported by @${report.byUser?.username ?? 'unknown'}',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: blackPure(context)),
                ),
              ),
            ],
          ),
          if (report.reason != null && report.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Reason: ${report.reason}',
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 12, color: textLightGrey(context))),
          ],
          if (report.post?.description != null &&
              report.post!.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              report.post!.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 12, color: textLightGrey(context)),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context,
                  label: 'Accept',
                  color: const Color(0xFFEF4444),
                  onTap: () => _resolveReport(report, 'post', 'accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  context,
                  label: 'Dismiss',
                  color: disableGrey(context),
                  textColor: blackPure(context),
                  onTap: () => _resolveReport(report, 'post', 'dismiss'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── User Reports Tab ──────────────────────────────────

  Widget _buildUserReports(BuildContext context) {
    if (userReports.isEmpty) {
      return Center(
        child: Text('No pending user reports',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context))),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: userReports.length,
        itemBuilder: (context, index) {
          final report = userReports[index];
          return _buildUserReportCard(context, report);
        },
      ),
    );
  }

  Widget _buildUserReportCard(BuildContext context, PendingReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AssetRes.icBlock, width: 18, height: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '@${report.user?.username ?? 'unknown'} reported by @${report.byUser?.username ?? 'unknown'}',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: blackPure(context)),
                ),
              ),
            ],
          ),
          if (report.reason != null && report.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Reason: ${report.reason}',
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 12, color: textLightGrey(context))),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  context,
                  label: 'Ban User',
                  color: const Color(0xFFEF4444),
                  onTap: () => _resolveReport(report, 'user', 'accept'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  context,
                  label: 'Dismiss',
                  color: disableGrey(context),
                  textColor: blackPure(context),
                  onTap: () => _resolveReport(report, 'user', 'dismiss'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Activity Log Tab ──────────────────────────────────

  Widget _buildActivityLog(BuildContext context) {
    if (activityLog.isEmpty) {
      return Center(
        child: Text('No activity yet',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context))),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: activityLog.length,
        itemBuilder: (context, index) {
          final entry = activityLog[index];
          return _buildLogEntry(context, entry);
        },
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, ModerationLogEntry entry) {
    final actionLabel = _formatAction(entry.action ?? '');
    final icon = _iconForAction(entry.action ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: bgMediumGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(icon, width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(actionLabel,
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 13, color: blackPure(context))),
                if (entry.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(entry.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 11, color: textLightGrey(context))),
                ],
              ],
            ),
          ),
          Text(
            _formatDate(entry.createdAt),
            style: TextStyleCustom.outFitRegular400(
                fontSize: 11, color: textLightGrey(context)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────

  Widget _actionButton(
    BuildContext context, {
    required String label,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: ShapeDecoration(
          gradient: textColor == null ? StyleRes.themeGradient : null,
          color: textColor != null ? color : null,
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 12, color: textColor ?? Colors.white)),
      ),
    );
  }

  Future<void> _resolveReport(
      PendingReport report, String type, String action) async {
    final result = await ModerationService.instance.resolveReport(
      reportId: report.id ?? 0,
      type: type,
      action: action,
    );
    if (result.status == true) {
      Get.snackbar('Done',
          action == 'accept' ? 'Report accepted' : 'Report dismissed',
          snackPosition: SnackPosition.BOTTOM);
      _loadData();
    } else {
      Get.snackbar('Error', result.message ?? 'Failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _formatAction(String action) {
    return action.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }

  String _iconForAction(String action) {
    if (action.contains('delete')) return AssetRes.icDelete;
    if (action.contains('freeze') || action.contains('ban')) {
      return AssetRes.icBlock;
    }
    if (action.contains('report')) return AssetRes.icReport;
    if (action.contains('violation')) return AssetRes.icAlert;
    return AssetRes.icEye;
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.month}/${dt.day}';
    } catch (_) {
      return '';
    }
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}
