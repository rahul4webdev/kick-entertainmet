import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/ai_sticker_service.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/ai/ai_sticker_model.dart';
import 'package:shortzz/utilities/color_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AiStickerController extends BaseController
    with GetTickerProviderStateMixin {
  RxList<AiSticker> myStickers = <AiSticker>[].obs;
  RxList<AiSticker> publicStickers = <AiSticker>[].obs;
  RxBool isGenerating = false.obs;
  RxBool isLoadingStickers = false.obs;
  Rx<AiSticker?> generatedSticker = Rx(null);
  final TextEditingController promptController = TextEditingController();
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    fetchMyStickers();
    fetchPublicStickers();
  }

  @override
  void onClose() {
    promptController.dispose();
    tabController.dispose();
    super.onClose();
  }

  Future<void> generateSticker() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty || isGenerating.value) return;

    isGenerating.value = true;
    generatedSticker.value = null;

    try {
      final response = await AiStickerService.instance.generateSticker(
        prompt: prompt,
        isPublic: true,
      );
      if (response.status == true && response.data != null) {
        generatedSticker.value = response.data;
        myStickers.insert(0, response.data!);
        promptController.clear();
        showSnackBar(LKey.stickerGenerated);
      }
    } catch (_) {}

    isGenerating.value = false;
  }

  Future<void> fetchMyStickers() async {
    isLoadingStickers.value = true;
    try {
      final response = await AiStickerService.instance.fetchMyStickers();
      if (response.status == true && response.data != null) {
        myStickers.assignAll(response.data!);
      }
    } catch (_) {}
    isLoadingStickers.value = false;
  }

  Future<void> fetchPublicStickers() async {
    try {
      final response = await AiStickerService.instance.fetchPublicStickers();
      if (response.status == true && response.data != null) {
        publicStickers.assignAll(response.data!);
      }
    } catch (_) {}
  }

  Future<void> deleteSticker(AiSticker sticker) async {
    if (sticker.id == null) return;
    try {
      final response =
          await AiStickerService.instance.deleteSticker(stickerId: sticker.id!);
      if (response.status == true) {
        myStickers.removeWhere((s) => s.id == sticker.id);
        showSnackBar(LKey.stickerDeleted);
      }
    } catch (_) {}
  }
}

class AiStickerScreen extends StatelessWidget {
  const AiStickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiStickerController());

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF1493)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                ),
              ),
              child: const Icon(Icons.auto_fix_high, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              LKey.aiSticker,
              style: TextStyleCustom.unboundedMedium500(
                  fontSize: 16, color: textDarkGrey(context)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Prompt input section
          _PromptSection(controller: controller),

          // Generated sticker preview
          Obx(() {
            final sticker = controller.generatedSticker.value;
            if (sticker == null && !controller.isGenerating.value) {
              return const SizedBox();
            }
            if (controller.isGenerating.value) {
              return _GeneratingIndicator();
            }
            return _StickerPreview(sticker: sticker!);
          }),

          // Tabs: My Stickers / Popular
          TabBar(
            controller: controller.tabController,
            labelColor: textDarkGrey(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: ColorRes.themeAccentSolid,
            labelStyle: TextStyleCustom.outFitMedium500(fontSize: 14),
            tabs: [
              Tab(text: LKey.myStickers),
              Tab(text: LKey.popularStickers),
            ],
          ),

          // Sticker grids
          Expanded(
            child: TabBarView(
              controller: controller.tabController,
              children: [
                _MyStickerGrid(controller: controller),
                _PublicStickerGrid(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptSection extends StatelessWidget {
  final AiStickerController controller;

  const _PromptSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: ShapeDecoration(
                color: bgLightGrey(context),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 14, cornerSmoothing: 1),
                ),
              ),
              child: TextField(
                controller: controller.promptController,
                style: TextStyleCustom.outFitRegular400(
                    color: textDarkGrey(context), fontSize: 14),
                decoration: InputDecoration(
                  hintText: LKey.stickerPromptHint,
                  hintStyle: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  prefixIcon: Icon(Icons.auto_fix_high,
                      size: 20, color: textLightGrey(context)),
                ),
                onSubmitted: (_) => controller.generateSticker(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
                onTap: controller.isGenerating.value
                    ? null
                    : controller.generateSticker,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: ShapeDecoration(
                    color: controller.isGenerating.value
                        ? Colors.grey
                        : ColorRes.themeAccentSolid,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                          cornerRadius: 14, cornerSmoothing: 1),
                    ),
                  ),
                  child: Text(
                    LKey.generateSticker,
                    style: TextStyleCustom.outFitMedium500(
                        color: Colors.white, fontSize: 13),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _GeneratingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: ColorRes.themeAccentSolid,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LKey.generating,
            style: TextStyleCustom.outFitMedium500(
                color: textLightGrey(context), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StickerPreview extends StatelessWidget {
  final AiSticker sticker;

  const _StickerPreview({required this.sticker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
          side: BorderSide(
              color: ColorRes.themeAccentSolid.withValues(alpha: .3)),
        ),
      ),
      child: Row(
        children: [
          ClipSmoothRect(
            radius:
                SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
            child: CachedNetworkImage(
              imageUrl: sticker.imageUrl?.addBaseURL() ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LKey.stickerGenerated,
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${sticker.prompt ?? ''}"',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyStickerGrid extends StatelessWidget {
  final AiStickerController controller;

  const _MyStickerGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingStickers.value && controller.myStickers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.myStickers.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_fix_high,
                  size: 48, color: textLightGrey(context)),
              const SizedBox(height: 12),
              Text(
                LKey.noStickersYet,
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                LKey.noStickersDesc,
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 13),
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.myStickers.length,
        itemBuilder: (context, index) {
          final sticker = controller.myStickers[index];
          return _StickerTile(
            sticker: sticker,
            onLongPress: () {
              Get.bottomSheet(ConfirmationSheet(
                title: LKey.delete,
                description: '${LKey.delete} "${sticker.prompt}"?',
                onTap: () => controller.deleteSticker(sticker),
              ));
            },
          );
        },
      );
    });
  }
}

class _PublicStickerGrid extends StatelessWidget {
  final AiStickerController controller;

  const _PublicStickerGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.publicStickers.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.explore_outlined,
                  size: 48, color: textLightGrey(context)),
              const SizedBox(height: 12),
              Text(
                LKey.noStickersYet,
                style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context), fontSize: 15),
              ),
            ],
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.publicStickers.length,
        itemBuilder: (context, index) {
          final sticker = controller.publicStickers[index];
          return _StickerTile(sticker: sticker);
        },
      );
    });
  }
}

class _StickerTile extends StatelessWidget {
  final AiSticker sticker;
  final VoidCallback? onLongPress;

  const _StickerTile({required this.sticker, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: sticker.imageUrl?.addBaseURL() ?? '',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: bgLightGrey(context),
                child: Icon(Icons.image,
                    color: textLightGrey(context), size: 32),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: .6),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  sticker.prompt ?? '',
                  style: TextStyleCustom.outFitLight300(
                      color: Colors.white, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
