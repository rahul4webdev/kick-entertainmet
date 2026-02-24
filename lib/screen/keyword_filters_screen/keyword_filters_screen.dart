import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/keyword_filters_screen/keyword_filters_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class KeywordFiltersScreen extends StatelessWidget {
  const KeywordFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KeywordFiltersScreenController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.keywordFilters.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              LKey.keywordFiltersDesc.tr,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 14, color: whitePure(context)),
                    decoration: InputDecoration(
                      hintText: LKey.enterKeyword.tr,
                      hintStyle: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: textLightGrey(context)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => controller.addKeyword(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.addKeyword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeAccentSolid(context),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    LKey.add.tr,
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.keywords.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_list_off,
                            size: 48, color: textLightGrey(context)),
                        const SizedBox(height: 12),
                        Text(
                          LKey.keywordFiltersEmpty.tr,
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 16, color: whitePure(context)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          LKey.keywordFiltersEmptyDesc.tr,
                          textAlign: TextAlign.center,
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 13, color: textLightGrey(context)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.keywords.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = controller.keywords[index];
                  return ListTile(
                    title: Text(
                      item['keyword'] ?? '',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 15, color: whitePure(context)),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close,
                          size: 20, color: textLightGrey(context)),
                      onPressed: () =>
                          controller.removeKeyword(item['id'] as int),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
