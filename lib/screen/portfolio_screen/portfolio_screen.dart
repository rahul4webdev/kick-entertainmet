import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/model/portfolio/portfolio_model.dart';
import 'package:shortzz/screen/portfolio_screen/portfolio_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PortfolioController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'My Portfolio',
            rowWidget: Obx(() {
              if (controller.isSaving.value) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return GestureDetector(
                onTap: controller.savePortfolio,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'Save',
                    style: TextStyleCustom.outFitMedium500(
                      color: themeAccentSolid(context),
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.portfolio.value == null) {
                return const LoaderWidget();
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portfolio URL preview + copy
                    _PortfolioUrlCard(controller: controller),
                    const SizedBox(height: 16),

                    // Active toggle
                    _ToggleRow(
                      label: 'Portfolio Active',
                      value: controller.isActive,
                      onChanged: (v) => controller.isActive.value = v,
                    ),
                    const SizedBox(height: 16),

                    // Theme selector
                    _SectionHeader(title: 'Theme'),
                    const SizedBox(height: 8),
                    _ThemeSelector(controller: controller),
                    const SizedBox(height: 16),

                    // Headline
                    _SectionHeader(title: 'Headline'),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: controller.headlineController,
                      hint: 'Your headline...',
                    ),
                    const SizedBox(height: 16),

                    // Bio override
                    _SectionHeader(title: 'Bio'),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: controller.bioController,
                      hint: 'Custom bio for portfolio...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Slug
                    _SectionHeader(title: 'Custom URL Slug'),
                    const SizedBox(height: 8),
                    _StyledTextField(
                      controller: controller.slugController,
                      hint: 'your-slug',
                    ),
                    const SizedBox(height: 16),

                    // Display toggles
                    _ToggleRow(
                      label: 'Show Products',
                      value: controller.showProducts,
                      onChanged: (v) => controller.showProducts.value = v,
                    ),
                    _ToggleRow(
                      label: 'Show Links',
                      value: controller.showLinks,
                      onChanged: (v) => controller.showLinks.value = v,
                    ),
                    _ToggleRow(
                      label: 'Show Follow CTA',
                      value: controller.showSubscriptionCta,
                      onChanged: (v) => controller.showSubscriptionCta.value = v,
                    ),
                    const SizedBox(height: 24),

                    // Sections
                    _SectionsManager(controller: controller),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PortfolioUrlCard extends StatelessWidget {
  final PortfolioController controller;

  const _PortfolioUrlCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slug = controller.slugController.text.trim();
      if (slug.isEmpty && controller.portfolio.value == null) {
        return const SizedBox();
      }
      final url = controller.portfolio.value?.portfolioUrl ?? controller.portfolioUrl;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgMediumGrey(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Portfolio URL',
                    style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    url,
                    style: TextStyleCustom.outFitRegular400(
                      color: themeAccentSolid(context),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                Get.snackbar('Copied', 'URL copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM);
              },
              child: Icon(Icons.copy, size: 20, color: textLightGrey(context)),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
              child: Icon(Icons.open_in_new, size: 20, color: textLightGrey(context)),
            ),
          ],
        ),
      );
    });
  }
}

class _ThemeSelector extends StatelessWidget {
  final PortfolioController controller;

  const _ThemeSelector({required this.controller});

  static const _themeColors = {
    'default': Color(0xFF6366F1),
    'dark': Color(0xFF818CF8),
    'minimal': Color(0xFF333333),
    'vibrant': Color(0xFFF472B6),
    'gradient': Color(0xFF38BDF8),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: PortfolioController.themes.map((theme) {
              final isSelected = controller.selectedTheme.value == theme;
              final color = _themeColors[theme] ?? Colors.grey;
              return GestureDetector(
                onTap: () => controller.selectedTheme.value = theme,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : bgMediumGrey(context),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(color: color.withValues(alpha: .3)),
                  ),
                  child: Text(
                    theme[0].toUpperCase() + theme.substring(1),
                    style: TextStyleCustom.outFitMedium500(
                      color: isSelected ? Colors.white : textDarkGrey(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final RxBool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context),
                  fontSize: 15,
                ),
              ),
              Switch.adaptive(
                value: value.value,
                onChanged: onChanged,
                activeColor: themeAccentSolid(context),
              ),
            ],
          ),
        ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleCustom.outFitMedium500(
        color: textDarkGrey(context),
        fontSize: 15,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyleCustom.outFitRegular400(
        color: textDarkGrey(context),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleCustom.outFitRegular400(
          color: textLightGrey(context),
          fontSize: 14,
        ),
        filled: true,
        fillColor: bgMediumGrey(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _SectionsManager extends StatelessWidget {
  final PortfolioController controller;

  const _SectionsManager({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sections = controller.portfolio.value?.sections ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sections',
                style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context),
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: () => _showAddSectionSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: themeAccentSolid(context)),
                      const SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyleCustom.outFitMedium500(
                          color: themeAccentSolid(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sections.isEmpty)
            const NoDataView(
              title: 'No Sections',
              description: 'Add text, heading, or divider sections to customize your portfolio page.',
            )
          else
            ...sections.map((s) => _SectionCard(
                  section: s,
                  controller: controller,
                )),
        ],
      );
    });
  }

  void _showAddSectionSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String sectionType = 'text';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Section',
              style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context),
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 16),
            _StyledTextField(controller: titleCtrl, hint: 'Section title'),
            const SizedBox(height: 12),
            _StyledTextField(controller: contentCtrl, hint: 'Content...', maxLines: 4),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.addSection(
                    sectionType: sectionType,
                    title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : null,
                    content: contentCtrl.text.trim().isNotEmpty ? contentCtrl.text.trim() : null,
                  );
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Section'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final PortfolioSection section;
  final PortfolioController controller;

  const _SectionCard({required this.section, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgMediumGrey(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (section.title != null && section.title!.isNotEmpty)
                  Text(
                    section.title!,
                    style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context),
                      fontSize: 14,
                    ),
                  ),
                if (section.content != null && section.content!.isNotEmpty)
                  Text(
                    section.content!,
                    style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (section.id != null) {
                controller.removeSection(section.id!);
              }
            },
            child: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade300),
          ),
        ],
      ),
    );
  }
}
