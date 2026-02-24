import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/template/template_model.dart';
import 'package:shortzz/screen/template_screen/template_fill_screen.dart';
import 'package:shortzz/screen/template_screen/template_gallery_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TemplateGalleryController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.templates.tr),
          _buildSourceTabs(context, controller),
          _buildCategoryFilter(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.templates.isEmpty) {
                return const LoaderWidget();
              }
              if (controller.templates.isEmpty) {
                return NoDataView(
                  title: LKey.noTemplates.tr,
                  description: LKey.noTemplatesDesc.tr,
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchTemplates(reset: true),
                child: GridView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: controller.templates.length,
                  itemBuilder: (context, index) => _TemplateCard(
                    template: controller.templates[index],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTabs(
      BuildContext context, TemplateGalleryController controller) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              _buildSourceChip(context, controller, 'All', 0),
              const SizedBox(width: 8),
              _buildSourceChip(context, controller, 'Trending', 1),
              const SizedBox(width: 8),
              _buildSourceChip(context, controller, 'Creator', 2),
            ],
          ),
        ));
  }

  Widget _buildSourceChip(BuildContext context,
      TemplateGalleryController controller, String label, int index) {
    final isSelected = controller.sourceTab.value == index;
    return GestureDetector(
      onTap: () => controller.onSourceTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? themeAccentSolid(context)
              : themeAccentSolid(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 13,
            color: isSelected ? Colors.white : themeAccentSolid(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
      BuildContext context, TemplateGalleryController controller) {
    return Obx(() {
      final categories = controller.categories;
      if (categories.isEmpty) return const SizedBox();

      return SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          itemCount: categories.length + 1,
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final category = isAll ? null : categories[index - 1];
            final isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.onCategorySelected(category),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: ShapeDecoration(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
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
                      fontSize: 13,
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
}

class _TemplateCard extends StatelessWidget {
  final VideoTemplate template;

  const _TemplateCard({required this.template});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => TemplateFillScreen(template: template)),
      child: Container(
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          color: bgMediumGrey(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImage(
                    size: const Size(double.infinity, double.infinity),
                    image: template.thumbnail?.addBaseURL(),
                    fullName: template.name,
                    radius: 0,
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${template.clipCount ?? 0} clips • ${template.durationSec ?? 0}s',
                        style: TextStyleCustom.outFitRegular400(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name ?? '',
                    style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (template.category != null) ...[
                        Flexible(
                          child: Text(
                            template.category!,
                            style: TextStyleCustom.outFitLight300(
                              color: textLightGrey(context),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${template.useCount ?? 0} uses',
                        style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (template.isUserCreated &&
                      template.creatorUsername != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 12, color: textLightGrey(context)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '@${template.creatorUsername}',
                            style: TextStyleCustom.outFitLight300(
                              color: themeAccentSolid(context),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (Get.isRegistered<
                                TemplateGalleryController>()) {
                              Get.find<TemplateGalleryController>()
                                  .onLikeTemplate(template);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                template.isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 14,
                                color: template.isLiked
                                    ? Colors.red
                                    : textLightGrey(context),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${template.likeCount}',
                                style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
