import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/slideshow_screen/slideshow_screen_controller.dart';
import 'package:shortzz/screen/camera_edit_screen/widget/transition_picker_sheet.dart';

class SlideshowScreen extends StatelessWidget {
  final List<String> imagePaths;

  const SlideshowScreen({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SlideshowScreenController(imagePaths));
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Slideshow',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.isProcessing.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: controller.createSlideshow,
                  child: const Text('Create',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                )),
        ],
      ),
      body: Obx(() => Column(
            children: [
              // Image list (reorderable)
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.images.length,
                  onReorder: controller.reorderImages,
                  itemBuilder: (context, index) {
                    final img = controller.images[index];
                    return _SlideshowImageTile(
                      key: ValueKey(img),
                      imagePath: img,
                      index: index,
                      duration: controller.durations[index],
                      onDurationChanged: (d) =>
                          controller.setDuration(index, d),
                      onRemove: controller.images.length > 1
                          ? () => controller.removeImage(index)
                          : null,
                    );
                  },
                ),
              ),
              // Bottom controls
              Container(
                color: const Color(0xFF1C1C1E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Transition
                      _ControlRow(
                        icon: Icons.animation,
                        label: 'Transition',
                        value: controller.transition.value.label,
                        onTap: () async {
                          final result =
                              await Get.bottomSheet<VideoTransition>(
                            TransitionPickerSheet(
                                current: controller.transition.value),
                            isScrollControlled: true,
                          );
                          if (result != null) {
                            controller.transition.value = result;
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Ken Burns toggle
                      Row(
                        children: [
                          const Icon(Icons.zoom_in,
                              color: Colors.white70, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Ken Burns Effect',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                          ),
                          Switch(
                            value: controller.kenBurnsEnabled.value,
                            onChanged: (v) =>
                                controller.kenBurnsEnabled.value = v,
                            activeTrackColor: Colors.white54,
                            activeThumbColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Music button
                      _ControlRow(
                        icon: Icons.music_note,
                        label: 'Music',
                        value: controller.musicPath.value != null
                            ? 'Added'
                            : 'None',
                        onTap: controller.selectMusic,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class _SlideshowImageTile extends StatelessWidget {
  final String imagePath;
  final int index;
  final int duration;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback? onRemove;

  const _SlideshowImageTile({
    super.key,
    required this.imagePath,
    required this.index,
    required this.duration,
    required this.onDurationChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.drag_handle, color: Colors.white30, size: 20),
          ),
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Index label
          Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Duration selector
          GestureDetector(
            onTap: () {
              final next = duration >= 7 ? 2 : duration + 1;
              onDurationChanged(next);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${duration}s',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white30, size: 18),
              onPressed: onRemove,
            )
          else
            const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ControlRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Text(value,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white30, size: 18),
        ],
      ),
    );
  }
}
