import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/login_activity_screen/login_activity_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LoginActivityScreen extends StatelessWidget {
  const LoginActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginActivityScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.loginActivity.tr),
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AssetRes.icAlert, width: 48, height: 48,
                          color: textLightGrey(context)),
                      const SizedBox(height: 12),
                      Text(LKey.noLoginSessions.tr,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 15, color: textLightGrey(context))),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.sessions.length,
                separatorBuilder: (_, __) => Divider(
                    height: 1, color: bgLightGrey(context)),
                itemBuilder: (context, index) {
                  final session = controller.sessions[index];
                  final isCurrent = session['is_current'] == true ||
                      session['is_current'] == 1;
                  return _SessionTile(
                    controller: controller,
                    session: session,
                    isCurrent: isCurrent,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final LoginActivityScreenController controller;
  final Map<String, dynamic> session;
  final bool isCurrent;

  const _SessionTile({
    required this.controller,
    required this.session,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final deviceLabel = controller.getDeviceLabel(session);
    final osLabel = controller.getOsLabel(session);
    final timeLabel = controller.getTimeLabel(session);
    final ip = session['ip_address'] ?? '';
    final method = session['login_method'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: isCurrent
          ? themeAccentSolid(context).withValues(alpha: 0.05)
          : Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgLightGrey(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              session['device'] == '1' ? Icons.phone_iphone : Icons.phone_android,
              color: isCurrent
                  ? themeAccentSolid(context)
                  : textLightGrey(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        deviceLabel,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 15, color: whitePure(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeAccentSolid(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          LKey.currentSession.tr,
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [osLabel, if (method.isNotEmpty) method, if (ip.isNotEmpty) ip]
                      .where((s) => s.isNotEmpty)
                      .join(' \u2022 '),
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 13, color: textLightGrey(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (timeLabel.isNotEmpty)
                  Text(
                    timeLabel,
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 12, color: textLightGrey(context)),
                  ),
              ],
            ),
          ),
          if (!isCurrent)
            IconButton(
              onPressed: () => controller.removeSession(session['id']),
              icon: Icon(Icons.close, color: textLightGrey(context), size: 20),
              tooltip: LKey.removeSession.tr,
            ),
        ],
      ),
    );
  }
}
