import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/screen/profile_screen/profile_screen_controller.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileTabs extends StatelessWidget {
  final ProfileScreenController controller;

  const ProfileTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isMe =
        controller.userData.value?.id == SessionManager.instance.getUserID();
    final hasExclusive = controller.hasExclusiveTab;

    // New modern icon set
    final tabs = <_TabDef>[
      const _TabDef(Icons.slow_motion_video_rounded, Icons.slow_motion_video_rounded),  // Reels
      const _TabDef(Icons.grid_on_rounded, Icons.grid_on_rounded),                       // Posts
      const _TabDef(Icons.playlist_play_rounded, Icons.playlist_play_rounded),            // Playlists
      const _TabDef(Icons.forum_outlined, Icons.forum_rounded),                           // Q&A
      if (hasExclusive) const _TabDef(Icons.star_outline_rounded, Icons.star_rounded),    // Exclusive
      if (isMe) const _TabDef(Icons.edit_note_rounded, Icons.edit_note_rounded),          // Drafts
    ];

    final tabCount = tabs.length;

    return Column(
      children: [
        Container(height: 0.5, color: textLightGrey(context).withValues(alpha: 0.15)),
        Obx(
          () => TabBar(
            onTap: (value) {
              controller.userData.value?.checkIsBlocked(() {
                controller.onTabChanged(value);
                controller.pageController.animateToPage(value,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.linear);
              });
            },
            indicatorColor: themeAccentSolid(context),
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 8),
            labelPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
            tabs: List.generate(tabCount, (index) {
              final tab = tabs[index];
              final isActive = controller.selectedTabIndex.value == index;
              final color = isActive
                  ? themeAccentSolid(context)
                  : textLightGrey(context).withValues(alpha: 0.45);
              return Tab(
                height: 44,
                child: Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: color,
                ),
              );
            }),
          ),
        ),
        Container(height: 0.5, color: textLightGrey(context).withValues(alpha: 0.15)),
      ],
    );
  }
}

class _TabDef {
  final IconData icon;
  final IconData activeIcon;

  const _TabDef(this.icon, this.activeIcon);
}
