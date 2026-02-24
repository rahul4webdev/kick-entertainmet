import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/hidden_words_screen/hidden_words_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class HiddenWordsScreen extends StatelessWidget {
  const HiddenWordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HiddenWordsScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.hiddenWords.tr),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: LKey.addHiddenWordHint.tr,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 12),
                        borderSide: BorderSide(color: bgGrey(context)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 12),
                        borderSide: BorderSide(color: bgGrey(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: SmoothBorderRadius(cornerRadius: 12),
                        borderSide:
                            BorderSide(color: themeAccentSolid(context)),
                      ),
                    ),
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(context)),
                    onSubmitted: (_) => controller.addWord(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: controller.addWord,
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      borderRadius: SmoothBorderRadius(cornerRadius: 12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      LKey.add.tr,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              LKey.hiddenWordsDescription.tr,
              style: TextStyleCustom.outFitLight300(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(
              () => controller.isLoading.value && controller.hiddenWords.isEmpty
                  ? const LoaderWidget()
                  : NoDataView(
                      showShow: !controller.isLoading.value &&
                          controller.hiddenWords.isEmpty,
                      title: LKey.hiddenWordsEmptyTitle.tr,
                      description: LKey.hiddenWordsEmptyDescription.tr,
                      child: ListView.builder(
                        itemCount: controller.hiddenWords.length,
                        padding: const EdgeInsets.only(top: 5),
                        itemBuilder: (context, index) {
                          String word = controller.hiddenWords[index];
                          return _HiddenWordTile(
                            word: word,
                            onRemove: () => controller.removeWord(word),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HiddenWordTile extends StatelessWidget {
  final String word;
  final VoidCallback onRemove;

  const _HiddenWordTile({required this.word, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              word,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 15, color: textDarkGrey(context)),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bgGrey(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                LKey.delete.tr,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 13, color: textDarkGrey(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
