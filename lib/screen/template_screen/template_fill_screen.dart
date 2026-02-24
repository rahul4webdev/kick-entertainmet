import 'dart:io';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/service/api/template_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/template/template_model.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TemplateFillController extends BaseController {
  final VideoTemplate template;
  late RxList<Rx<String?>> clipPaths;

  TemplateFillController(this.template) {
    clipPaths = List.generate(
      template.clipCount ?? 1,
      (_) => Rx<String?>(null),
    ).obs;
  }

  bool get allClipsFilled =>
      clipPaths.every((clip) => clip.value != null);

  int get filledCount =>
      clipPaths.where((clip) => clip.value != null).length;

  void setClipPath(int index, String path) {
    clipPaths[index].value = path;
  }

  void clearClip(int index) {
    clipPaths[index].value = null;
  }

  Future<void> pickFromGallery(int index) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setClipPath(index, video.path);
    }
  }

  Future<void> recordClip(int index) async {
    final result = await Get.to<String?>(
      () => const CameraScreen(cameraType: CameraScreenType.post),
    );
    if (result != null) {
      setClipPath(index, result);
    }
  }

  Future<void> onUseTemplate() async {
    if (!allClipsFilled) {
      showSnackBar(LKey.fillAllClips.tr);
      return;
    }

    // Increment use count
    if (template.id != null) {
      TemplateService.instance.incrementTemplateUse(templateId: template.id!);
    }

    // Navigate to the camera edit screen with the first clip
    // Users can edit/apply filters before uploading
    final firstClipPath = clipPaths.first.value!;
    final content = PostStoryContent(
      type: PostStoryContentType.reel,
      content: firstClipPath,
      filter: [],
      hasAudio: true,
    );
    Get.to(() => CameraEditScreen(content: content));
  }
}

class TemplateFillScreen extends StatelessWidget {
  final VideoTemplate template;

  const TemplateFillScreen({super.key, required this.template});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TemplateFillController(template));

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: template.name ?? LKey.useTemplate.tr),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Template info header
                  _buildTemplateInfo(context),
                  const SizedBox(height: 20),

                  // Clip slots header
                  Text(
                    '${LKey.templateClips.tr} (${template.clipCount ?? 0})',
                    style: TextStyleCustom.unboundedSemiBold600(
                      color: textDarkGrey(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Clip slots
                  ...List.generate(
                    template.clipCount ?? 0,
                    (index) => _ClipSlotCard(
                      index: index,
                      clip: template.clips != null &&
                              index < template.clips!.length
                          ? template.clips![index]
                          : null,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Use Template button
          _buildBottomButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 0.6,
          ),
        ),
        color: bgMediumGrey(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (template.description != null &&
                    template.description!.isNotEmpty)
                  Text(
                    template.description!,
                    style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.video_library_outlined,
                      label: '${template.clipCount ?? 0} clips',
                      context: context,
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.timer_outlined,
                      label: '${template.durationSec ?? 0}s',
                      context: context,
                    ),
                    if (template.category != null) ...[
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: Icons.category_outlined,
                        label: template.category!,
                        context: context,
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

  Widget _buildBottomButton(
      BuildContext context, TemplateFillController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final filled = controller.filledCount;
          final total = template.clipCount ?? 0;
          final allFilled = controller.allClipsFilled;

          return SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: allFilled ? () => controller.onUseTemplate() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                disabledBackgroundColor: bgMediumGrey(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 14,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              child: Text(
                allFilled
                    ? LKey.useTemplate.tr
                    : '${LKey.useTemplate.tr} ($filled/$total)',
                style: TextStyleCustom.outFitMedium500(
                  color: allFilled
                      ? whitePure(context)
                      : textLightGrey(context),
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textLightGrey(context)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
            color: textLightGrey(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ClipSlotCard extends StatelessWidget {
  final int index;
  final TemplateClip? clip;
  final TemplateFillController controller;

  const _ClipSlotCard({
    required this.index,
    required this.clip,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Obx(() {
        final path = controller.clipPaths[index].value;
        final isFilled = path != null;

        return Container(
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 14,
                cornerSmoothing: 0.6,
              ),
              side: BorderSide(
                color: isFilled
                    ? Colors.green.withValues(alpha: 0.5)
                    : bgMediumGrey(context),
              ),
            ),
            color: bgGrey(context),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: ShapeDecoration(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 10,
                    cornerSmoothing: 0.6,
                  ),
                ),
                color: isFilled ? Colors.green.withValues(alpha: 0.15) : bgMediumGrey(context),
              ),
              child: isFilled
                  ? const Icon(Icons.check, color: Colors.green, size: 22)
                  : Icon(Icons.videocam_outlined,
                      color: textLightGrey(context), size: 22),
            ),
            title: Text(
              clip?.label ?? '${LKey.clipSlot.tr} ${index + 1}',
              style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context),
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              isFilled
                  ? File(path).uri.pathSegments.last
                  : '${clip?.durationSec.toStringAsFixed(1) ?? "3.0"}s • ${LKey.tapToFillClip.tr}',
              style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isFilled
                ? IconButton(
                    onPressed: () {
                      HapticManager.shared.light();
                      controller.clearClip(index);
                    },
                    icon: Icon(Icons.close,
                        color: textLightGrey(context), size: 20),
                  )
                : null,
            onTap: () => _showClipOptions(context, index),
          ),
        );
      }),
    );
  }

  void _showClipOptions(BuildContext context, int index) {
    HapticManager.shared.light();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                clip?.label ?? '${LKey.clipSlot.tr} ${index + 1}',
                style: TextStyleCustom.unboundedSemiBold600(
                  color: textDarkGrey(context),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _OptionTile(
                icon: Icons.videocam,
                label: LKey.recordClip.tr,
                context: context,
                onTap: () {
                  Get.back();
                  controller.recordClip(index);
                },
              ),
              const SizedBox(height: 8),
              _OptionTile(
                icon: Icons.photo_library,
                label: LKey.selectFromGallery.tr,
                context: context,
                onTap: () {
                  Get.back();
                  controller.pickFromGallery(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.context,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6,
            ),
          ),
          color: bgMediumGrey(context),
        ),
        child: Row(
          children: [
            Icon(icon, color: themeAccentSolid(context), size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right,
                color: textLightGrey(context), size: 20),
          ],
        ),
      ),
    );
  }
}
