import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/green_screen_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/green_screen/green_screen_bg_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class GreenScreenSheetController extends BaseController {
  RxList<GreenScreenBg> backgrounds = <GreenScreenBg>[].obs;
  RxList<String> categories = <String>[].obs;
  Rx<String?> selectedCategory = Rx(null);

  @override
  void onInit() {
    super.onInit();
    fetchBackgrounds();
  }

  Future<void> fetchBackgrounds() async {
    try {
      showLoader();
      final response = await GreenScreenService.instance.fetchBackgrounds(
        category: selectedCategory.value,
      );
      stopLoader();
      if (response.status == true) {
        backgrounds.value = response.data ?? [];
        if (categories.isEmpty) {
          categories.value = response.categories ?? [];
        }
      }
    } catch (e) {
      stopLoader();
    }
  }

  void onCategorySelected(String? category) {
    selectedCategory.value = category;
    fetchBackgrounds();
  }
}

class GreenScreenSheet extends StatelessWidget {
  final Function(String? imagePath) onBackgroundSelected;
  final VoidCallback onRemoveBackground;

  const GreenScreenSheet({
    super.key,
    required this.onBackgroundSelected,
    required this.onRemoveBackground,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GreenScreenSheetController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          ),
        ),
        color: scaffoldBackgroundColor(context),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LKey.selectBackground.tr,
                  style: TextStyleCustom.outFitMedium500(
                    color: textDarkGrey(context),
                    fontSize: 17,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onRemoveBackground();
                    Get.back();
                  },
                  child: Text(
                    LKey.removeBackground.tr,
                    style: TextStyleCustom.outFitRegular400(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Category filter
          _buildCategoryFilter(context, controller),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.backgrounds.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: controller.backgrounds.length + 1, // +1 for gallery picker
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildGalleryPickerTile(context);
                  }
                  final bg = controller.backgrounds[index - 1];
                  return _buildBackgroundTile(context, bg);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(
      BuildContext context, GreenScreenSheetController controller) {
    return Obx(() {
      final cats = controller.categories;
      if (cats.isEmpty) return const SizedBox();

      return SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: cats.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : cats[index - 1];
            final isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.onCategorySelected(category),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 18,
                        cornerSmoothing: 0.6,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? themeAccentSolid(context)
                            : bgMediumGrey(context),
                      ),
                    ),
                    color: isSelected
                        ? themeAccentSolid(context)
                        : bgMediumGrey(context),
                  ),
                  child: Text(
                    isAll ? LKey.allCategories.tr : category ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      color: isSelected
                          ? whitePure(context)
                          : textLightGrey(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildGalleryPickerTile(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final file = await picker.pickImage(source: ImageSource.gallery);
        if (file != null) {
          onBackgroundSelected(file.path);
          Get.back();
        }
      },
      child: Container(
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6,
            ),
          ),
          color: bgMediumGrey(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined,
                color: textLightGrey(context), size: 28),
            const SizedBox(height: 6),
            Text(
              LKey.fromGallery.tr,
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundTile(BuildContext context, GreenScreenBg bg) {
    return GestureDetector(
      onTap: () {
        onBackgroundSelected(bg.image?.addBaseURL());
        Get.back();
      },
      child: Container(
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 12,
              cornerSmoothing: 0.6,
            ),
          ),
          color: bgMediumGrey(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImage(
              size: const Size(double.infinity, double.infinity),
              image: bg.image?.addBaseURL(),
              fullName: bg.title,
              radius: 0,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Text(
                  bg.title ?? '',
                  style: TextStyleCustom.outFitRegular400(
                    color: Colors.white,
                    fontSize: 10,
                  ),
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
