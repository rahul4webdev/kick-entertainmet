import 'dart:io';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/ai_video_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/utilities/const_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AiVideoController extends BaseController {
  final TextEditingController promptController = TextEditingController();
  RxBool isGenerating = false.obs;
  RxInt selectedDuration = 5.obs;
  RxString selectedStyle = 'gradient'.obs;
  RxString selectedEffect = 'zoom_in'.obs;
  RxInt selectedTab = 0.obs; // 0=text, 1=image
  Rx<XFile?> selectedImage = Rx(null);

  final styles = ['gradient', 'dark', 'light', 'neon'];
  final effects = ['zoom_in', 'zoom_out', 'pan_left', 'pan_right'];
  final durations = [3, 5, 7, 10, 15];

  @override
  void onClose() {
    promptController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = image;
    }
  }

  Future<void> generate() async {
    if (isGenerating.value) return;

    if (selectedTab.value == 0) {
      await _generateFromText();
    } else {
      await _generateFromImage();
    }
  }

  Future<void> _generateFromText() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      showSnackBar('Please enter a text prompt');
      return;
    }

    isGenerating.value = true;
    try {
      final result = await AiVideoService.instance.generateFromText(
        prompt: prompt,
        duration: selectedDuration.value,
        style: selectedStyle.value,
      );

      if (result.status == true && result.data?.videoUrl != null) {
        await _downloadAndOpenEditor(result.data!.videoUrl!);
      } else {
        showSnackBar(result.message ?? 'Generation failed');
      }
    } catch (_) {
      showSnackBar('Video generation unavailable');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> _generateFromImage() async {
    if (selectedImage.value == null) {
      showSnackBar('Please select an image');
      return;
    }

    isGenerating.value = true;
    try {
      final result = await AiVideoService.instance.generateFromImage(
        imagePath: selectedImage.value!.path,
        duration: selectedDuration.value,
        effect: selectedEffect.value,
      );

      if (result.status == true && result.data?.videoUrl != null) {
        await _downloadAndOpenEditor(result.data!.videoUrl!);
      } else {
        showSnackBar(result.message ?? 'Generation failed');
      }
    } catch (_) {
      showSnackBar('Video generation unavailable');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> _downloadAndOpenEditor(String relUrl) async {
    final fullUrl =
        relUrl.startsWith('http') ? relUrl : '${baseURL}storage/$relUrl';
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(fullUrl));
    final response = await request.close();
    final tempDir = Directory.systemTemp;
    final filePath = '${tempDir.path}/ai_generated_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final file = File(filePath);
    final sink = file.openWrite();
    await response.pipe(sink);
    client.close();

    Get.off(() => CameraEditScreen(
          content: PostStoryContent(
            type: PostStoryContentType.reel,
            content: filePath,
          ),
        ));
  }
}

class AiVideoScreen extends StatelessWidget {
  const AiVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiVideoController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'AI Video Generator',
          style: TextStyleCustom.unboundedSemiBold600(
              color: textDarkGrey(context), fontSize: 18),
        ),
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab toggle: Text / Image
              _buildTabToggle(context, controller),
              const SizedBox(height: 20),

              // Input area
              if (controller.selectedTab.value == 0)
                _buildTextInput(context, controller)
              else
                _buildImageInput(context, controller),

              const SizedBox(height: 20),

              // Duration picker
              _buildDurationPicker(context, controller),

              const SizedBox(height: 16),

              // Style/Effect picker
              if (controller.selectedTab.value == 0)
                _buildStylePicker(context, controller)
              else
                _buildEffectPicker(context, controller),

              const SizedBox(height: 30),

              // Generate button
              Center(
                child: controller.isGenerating.value
                    ? Column(
                        children: [
                          CircularProgressIndicator(
                              color: themeAccentSolid(context)),
                          const SizedBox(height: 12),
                          Text(
                            'Generating video...',
                            style: TextStyleCustom.outFitRegular400(
                                color: textLightGrey(context), fontSize: 14),
                          ),
                        ],
                      )
                    : TextButtonCustom(
                        onTap: controller.generate,
                        title: 'Generate Video',
                        btnHeight: 48,
                        backgroundColor: themeAccentSolid(context),
                        titleColor: whitePure(context),
                        horizontalMargin: 40,
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabToggle(BuildContext context, AiVideoController controller) {
    return Container(
      decoration: BoxDecoration(
        color: bgLightGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedTab.value = 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius:
                        SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                  ),
                  color: controller.selectedTab.value == 0
                      ? themeAccentSolid(context)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Text to Video',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 14,
                    color: controller.selectedTab.value == 0
                        ? whitePure(context)
                        : textLightGrey(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedTab.value = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: ShapeDecoration(
                  shape: SmoothRectangleBorder(
                    borderRadius:
                        SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                  ),
                  color: controller.selectedTab.value == 1
                      ? themeAccentSolid(context)
                      : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Image to Video',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 14,
                    color: controller.selectedTab.value == 1
                        ? whitePure(context)
                        : textLightGrey(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, AiVideoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe your video',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.promptController,
          maxLines: 4,
          maxLength: 500,
          style: TextStyleCustom.outFitRegular400(
              color: textDarkGrey(context), fontSize: 14),
          decoration: InputDecoration(
            hintText: 'e.g., "Motivational quote about success"',
            hintStyle: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context), fontSize: 14),
            filled: true,
            fillColor: bgLightGrey(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildImageInput(BuildContext context, AiVideoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select an image',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgLightGrey(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bgGrey(context)),
            ),
            child: controller.selectedImage.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(controller.selectedImage.value!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 48, color: textLightGrey(context)),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to select image',
                        style: TextStyleCustom.outFitRegular400(
                            color: textLightGrey(context), fontSize: 13),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker(
      BuildContext context, AiVideoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: controller.durations.map((d) {
            final isSelected = controller.selectedDuration.value == d;
            return GestureDetector(
              onTap: () => controller.selectedDuration.value = d,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeAccentSolid(context)
                      : bgLightGrey(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${d}s',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: isSelected
                        ? whitePure(context)
                        : textDarkGrey(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStylePicker(
      BuildContext context, AiVideoController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Style',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: controller.styles.map((s) {
            final isSelected = controller.selectedStyle.value == s;
            return GestureDetector(
              onTap: () => controller.selectedStyle.value = s,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeAccentSolid(context)
                      : bgLightGrey(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s[0].toUpperCase() + s.substring(1),
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: isSelected
                        ? whitePure(context)
                        : textDarkGrey(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEffectPicker(
      BuildContext context, AiVideoController controller) {
    final effectLabels = {
      'zoom_in': 'Zoom In',
      'zoom_out': 'Zoom Out',
      'pan_left': 'Pan Left',
      'pan_right': 'Pan Right',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Effect',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: controller.effects.map((e) {
            final isSelected = controller.selectedEffect.value == e;
            return GestureDetector(
              onTap: () => controller.selectedEffect.value = e,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeAccentSolid(context)
                      : bgLightGrey(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  effectLabels[e] ?? e,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: isSelected
                        ? whitePure(context)
                        : textDarkGrey(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
