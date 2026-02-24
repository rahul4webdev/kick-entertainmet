import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';
import 'package:shortzz/utilities/app_res.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ContentSubTabs extends StatelessWidget {
  final HomeScreenController controller;

  const ContentSubTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ContentSubTab.values.map((subTab) {
          bool isSelected = controller.selectedContentSubTab.value == subTab;
          return GestureDetector(
            onTap: () => controller.onContentSubTabChanged(subTab),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                subTab.title,
                style: TextStyle(
                  color: isSelected ? blackPure(context) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}
