import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/family/family_link_model.dart';
import 'package:shortzz/screen/parental_control_screen/parental_control_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ParentalControlScreen extends StatelessWidget {
  const ParentalControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ParentalControlController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.familyPairing),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingData.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: themeAccentSolid(context),
                      unselectedLabelColor: textLightGrey(context),
                      indicatorColor: themeAccentSolid(context),
                      tabs: [
                        Tab(text: LKey.familyPairAsParent),
                        Tab(text: LKey.familyPairAsTeen),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _ParentTab(controller: controller),
                          _TeenTab(controller: controller),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ParentTab extends StatelessWidget {
  final ParentalControlController controller;
  const _ParentTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final teens = controller.linkedTeens;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showGenerateCodeSheet(context),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: Text(LKey.familyGenerateCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeAccentSolid(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: teens.isEmpty
                ? NoDataView(
                    title: LKey.familyNoTeens,
                    description: LKey.familyNoTeensDesc,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: teens.length,
                    itemBuilder: (context, index) {
                      return _LinkedTeenCard(
                        link: teens[index],
                        controller: controller,
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  void _showGenerateCodeSheet(BuildContext context) async {
    await controller.generatePairingCode();
    final code = controller.currentPairingCode.value;
    if (code == null) return;
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: scaffoldBackgroundColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LKey.familyGenerateCode,
              style: TextStyleCustom.outFitMedium500(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                code,
                style: TextStyleCustom.outFitMedium500(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              LKey.familyShareCode,
              style: TextStyleCustom.outFitRegular400(
                fontSize: 14,
                color: textLightGrey(context),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Get.back();
                Get.snackbar('Copied', 'Pairing code copied to clipboard');
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copy Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TeenTab extends StatelessWidget {
  final ParentalControlController controller;
  const _TeenTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final parents = controller.linkedParents;
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEnterCodeSheet(context),
                    icon: const Icon(Icons.link, size: 18),
                    label: Text(LKey.familyEnterCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeAccentSolid(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: parents.isEmpty
                ? NoDataView(
                    title: LKey.familyNoParents,
                    description: LKey.familyNoParentsDesc,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: parents.length,
                    itemBuilder: (context, index) {
                      return _LinkedParentCard(
                        link: parents[index],
                        controller: controller,
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  void _showEnterCodeSheet(BuildContext context) {
    final codeController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: scaffoldBackgroundColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LKey.familyEnterCode,
              style: TextStyleCustom.outFitMedium500(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              textAlign: TextAlign.center,
              style: TextStyleCustom.outFitMedium500(fontSize: 20),
              decoration: InputDecoration(
                hintText: 'XXXXXXXX',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final code = codeController.text.trim();
                if (code.length == 8) {
                  Get.back();
                  controller.linkWithCode(code);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Link Account'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _LinkedTeenCard extends StatelessWidget {
  final FamilyLink link;
  final ParentalControlController controller;

  const _LinkedTeenCard({required this.link, required this.controller});

  @override
  Widget build(BuildContext context) {
    final teen = link.teen;
    return Card(
      color: bgMediumGrey(context),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CustomImage(
                  image: teen?.profilePhoto,
                  size: const Size(44, 44),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teen?.fullname ?? teen?.username ?? '-',
                        style: TextStyleCustom.outFitMedium500(fontSize: 15),
                      ),
                      Text(
                        '@${teen?.username ?? ''}',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 13,
                          color: textLightGrey(context),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'controls') {
                      _showControlsSheet(context);
                    } else if (value == 'report') {
                      _showActivityReport(context);
                    } else if (value == 'unlink') {
                      controller.unlinkAccount(link.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'controls', child: Text(LKey.familyEditControls)),
                    PopupMenuItem(value: 'report', child: Text(LKey.familyViewReport)),
                    PopupMenuItem(
                      value: 'unlink',
                      child: Text(LKey.familyUnlink, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ControlChips(link: link),
          ],
        ),
      ),
    );
  }

  void _showControlsSheet(BuildContext context) {
    final controls = Map<String, dynamic>.from(link.controls ?? {});
    final screenTimeController = TextEditingController(
      text: '${controls['daily_screen_time_min'] ?? 60}',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: scaffoldBackgroundColor(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LKey.familyEditControls,
                style: TextStyleCustom.outFitMedium500(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(LKey.familyDailyScreenTime)),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: screenTimeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ControlToggle(
                label: LKey.familyRestrictDMs,
                value: controls['dm_restricted'] == true,
                onChanged: (v) => setState(() => controls['dm_restricted'] = v),
              ),
              _ControlToggle(
                label: LKey.familyRestrictLive,
                value: controls['live_restricted'] == true,
                onChanged: (v) => setState(() => controls['live_restricted'] = v),
              ),
              _ControlToggle(
                label: LKey.familyRestrictDiscover,
                value: controls['discover_restricted'] == true,
                onChanged: (v) => setState(() => controls['discover_restricted'] = v),
              ),
              _ControlToggle(
                label: LKey.familyRestrictPurchases,
                value: controls['purchase_restricted'] == true,
                onChanged: (v) => setState(() => controls['purchase_restricted'] = v),
              ),
              _ControlToggle(
                label: LKey.familyRestrictGoLive,
                value: controls['live_stream_restricted'] == true,
                onChanged: (v) => setState(() => controls['live_stream_restricted'] = v),
              ),
              _ControlToggle(
                label: LKey.familyActivityReports,
                value: controls['activity_reports'] != false,
                onChanged: (v) => setState(() => controls['activity_reports'] = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controls['daily_screen_time_min'] =
                      int.tryParse(screenTimeController.text) ?? 60;
                  Get.back();
                  controller.updateControls(link.id!, controls);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Controls'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivityReport(BuildContext context) async {
    final report = await controller.fetchActivityReport(link.id!);
    if (report == null) return;
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: scaffoldBackgroundColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LKey.familyActivityReport,
              style: TextStyleCustom.outFitMedium500(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CustomImage(
                  image: report.teen?.profilePhoto,
                  size: const Size(44, 44),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    report.teen?.fullname ?? report.teen?.username ?? '-',
                    style: TextStyleCustom.outFitMedium500(fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ReportStat(label: LKey.familyTotalPosts, value: '${report.totalPosts}'),
                _ReportStat(label: LKey.familyFollowers, value: '${report.followerCount}'),
                _ReportStat(label: LKey.familyFollowing, value: '${report.followingCount}'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _LinkedParentCard extends StatelessWidget {
  final FamilyLink link;
  final ParentalControlController controller;

  const _LinkedParentCard({required this.link, required this.controller});

  @override
  Widget build(BuildContext context) {
    final parent = link.parent;
    return Card(
      color: bgMediumGrey(context),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CustomImage(
              image: parent?.profilePhoto,
              size: const Size(44, 44),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parent?.fullname ?? parent?.username ?? '-',
                    style: TextStyleCustom.outFitMedium500(fontSize: 15),
                  ),
                  Text(
                    '@${parent?.username ?? ''}',
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 13,
                      color: textLightGrey(context),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => controller.unlinkAccount(link.id!),
              child: Text(
                LKey.familyUnlink,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlChips extends StatelessWidget {
  final FamilyLink link;
  const _ControlChips({required this.link});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _chip(context, '${link.dailyScreenTimeMin}m/day', Colors.blue),
        if (link.dmRestricted) _chip(context, 'DMs Off', Colors.orange),
        if (link.liveRestricted) _chip(context, 'Live Off', Colors.orange),
        if (link.discoverRestricted) _chip(context, 'Discover Off', Colors.orange),
        if (link.purchaseRestricted) _chip(context, 'No Purchase', Colors.red),
        if (link.liveStreamRestricted) _chip(context, 'No Go Live', Colors.red),
        if (link.activityReports) _chip(context, 'Reports On', Colors.green),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ControlToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ControlToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyleCustom.outFitRegular400(fontSize: 14))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: themeAccentSolid(context),
          ),
        ],
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;

  const _ReportStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyleCustom.outFitMedium500(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
            fontSize: 12,
            color: textLightGrey(context),
          ),
        ),
      ],
    );
  }
}
