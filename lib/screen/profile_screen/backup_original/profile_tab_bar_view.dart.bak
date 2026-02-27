import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileTabs extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isMe =
        controller.userData.value?.id == SessionManager.instance.getUserID();
    final hasExclusive = controller.hasExclusiveTab;

    // Build tab definitions dynamically
    final tabs = <_TabDef>[
      _TabDef.asset(AssetRes.icReel),
      _TabDef.asset(AssetRes.icPost),
      _TabDef.icon(Icons.playlist_play),
      _TabDef.icon(Icons.question_answer_outlined),
      if (hasExclusive) _TabDef.icon(Icons.workspace_premium),
      if (isMe) _TabDef.icon(Icons.drafts_outlined),
    ];

    final tabCount = tabs.length;

    return Column(
      children: [
        Obx(
          () => Stack(
            children: [
              Container(height: .5, color: textLightGrey(context)),
              AnimatedAlign(
                alignment: Alignment(
                    -1.0 +
                        controller.selectedTabIndex.value *
                            (2.0 / (tabCount - 1)),
                    0),
                duration: const Duration(milliseconds: 300),
                child: Container(
                  height: 1,
                  width: Get.width / tabCount - 40,
                  color: themeAccentSolid(context),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
        ),
        TabBar(
            onTap: (value) {
              controller.userData.value?.checkIsBlocked(() {
                controller.onTabChanged(value);
                controller.pageController.animateToPage(value,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear);
              });
            },
            indicatorColor: Colors.transparent,
            tabs: List.generate(tabCount, (index) {
              final tab = tabs[index];
              return Obx(() {
                final color = controller.selectedTabIndex.value == index
                    ? themeAccentSolid(context)
                    : disableGrey(context);
                if (tab.assetPath != null) {
                  return Image.asset(tab.assetPath!,
                      height: 50, width: 35, color: color);
                }
                return SizedBox(
                  height: 50,
                  width: 35,
                  child: Icon(tab.iconData, size: 24, color: color),
                );
              });
            })),
        Container(height: .5, color: textLightGrey(context)),
      ],
    );
  }
}

class _TabDef {
  final String? assetPath;
  final IconData? iconData;

  const _TabDef.asset(this.assetPath) : iconData = null;
  const _TabDef.icon(this.iconData) : assetPath = null;
}
