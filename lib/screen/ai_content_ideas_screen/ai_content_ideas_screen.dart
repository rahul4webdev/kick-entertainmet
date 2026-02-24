import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/ai_content_ideas_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/ai/ai_content_idea_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class AiContentIdeasController extends BaseController {
  RxList<ContentIdea> ideas = <ContentIdea>[].obs;
  RxBool isGenerating = false.obs;
  RxBool isLoadingTrending = false.obs;
  RxList<TrendingHashtag> trendingHashtags = <TrendingHashtag>[].obs;
  RxList<TrendingSound> trendingSounds = <TrendingSound>[].obs;
  final TextEditingController nicheController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchTrendingTopics();
  }

  @override
  void onClose() {
    nicheController.dispose();
    super.onClose();
  }

  Future<void> generateIdeas() async {
    if (isGenerating.value) return;
    isGenerating.value = true;
    ideas.clear();

    try {
      final niche = nicheController.text.trim().isEmpty
          ? null
          : nicheController.text.trim();
      final result =
          await AiContentIdeasService.instance.generateIdeas(niche: niche);
      if (result.status == true && result.data != null) {
        ideas.addAll(result.data!);
      } else {
        showSnackBar(result.message);
      }
    } catch (e) {
      showSnackBar(LKey.aiUnavailable.tr);
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> fetchTrendingTopics() async {
    isLoadingTrending.value = true;
    try {
      final result = await AiContentIdeasService.instance.fetchTrendingTopics();
      if (result.status == true && result.data != null) {
        trendingHashtags.value = result.data!.hashtags ?? [];
        trendingSounds.value = result.data!.sounds ?? [];
      }
    } catch (_) {}
    isLoadingTrending.value = false;
  }
}

class AiContentIdeasScreen extends StatelessWidget {
  const AiContentIdeasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiContentIdeasController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.lightbulb_outline, size: 16, color: whitePure(context)),
            ),
            const SizedBox(width: 8),
            Text(LKey.contentIdeas.tr,
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 16, color: textDarkGrey(context))),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _NicheInput(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isGenerating.value) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoaderWidget(),
                        const SizedBox(height: 12),
                        Text(LKey.generatingIdeas.tr,
                            style: TextStyleCustom.outFitRegular400(
                                fontSize: 13,
                                color: textLightGrey(context))),
                      ],
                    ),
                  );
                }
                if (controller.ideas.isEmpty) {
                  return _EmptyOrTrending(controller: controller);
                }
                return _IdeasList(controller: controller);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _NicheInput extends StatelessWidget {
  final AiContentIdeasController controller;

  const _NicheInput({required this.controller});

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
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
                ),
              ),
              child: TextField(
                controller: controller.nicheController,
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 14, color: textDarkGrey(context)),
                decoration: InputDecoration(
                  hintText: LKey.enterYourNiche.tr,
                  hintStyle: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                  prefixIcon: Icon(Icons.auto_fix_high,
                      size: 20, color: themeAccentSolid(context)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => controller.generateIdeas(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(() => GestureDetector(
                onTap:
                    controller.isGenerating.value ? null : controller.generateIdeas,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_awesome,
                      color: whitePure(context), size: 22),
                ),
              )),
        ],
      ),
    );
  }
}

class _EmptyOrTrending extends StatelessWidget {
  final AiContentIdeasController controller;

  const _EmptyOrTrending({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTrending.value) {
        return const Center(child: LoaderWidget());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Empty state
            if (controller.trendingHashtags.isEmpty &&
                controller.trendingSounds.isEmpty) ...[
              const SizedBox(height: 60),
              Icon(Icons.lightbulb_outline,
                  size: 64,
                  color: textLightGrey(context).withValues(alpha: .5)),
              const SizedBox(height: 16),
              Text(LKey.noIdeasYet.tr,
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 16, color: textDarkGrey(context))),
              const SizedBox(height: 8),
              Text(LKey.noIdeasDesc.tr,
                  textAlign: TextAlign.center,
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 13, color: textLightGrey(context))),
            ],

            // Trending hashtags
            if (controller.trendingHashtags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(LKey.trendingTopics.tr,
                    style: TextStyleCustom.unboundedMedium500(
                        fontSize: 14, color: textDarkGrey(context))),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.trendingHashtags.take(15).map((tag) {
                  return GestureDetector(
                    onTap: () {
                      controller.nicheController.text =
                          tag.hashtagName ?? '';
                      controller.generateIdeas();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: bgLightGrey(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#${tag.hashtagName ?? ''}',
                              style: TextStyleCustom.outFitMedium500(
                                  fontSize: 13,
                                  color: themeAccentSolid(context))),
                          const SizedBox(width: 4),
                          Text('${tag.hashtagCount ?? 0}',
                              style: TextStyleCustom.outFitRegular400(
                                  fontSize: 11,
                                  color: textLightGrey(context))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _IdeasList extends StatelessWidget {
  final AiContentIdeasController controller;

  const _IdeasList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.ideas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final idea = controller.ideas[index];
        return _IdeaCard(idea: idea);
      },
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final ContentIdea idea;

  const _IdeaCard({required this.idea});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(idea.title ?? '',
                    style: TextStyleCustom.unboundedMedium500(
                        fontSize: 15, color: textDarkGrey(context))),
              ),
              _DifficultyBadge(difficulty: idea.difficulty),
            ],
          ),
          const SizedBox(height: 8),
          Text(idea.description ?? '',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context))),

          // Hook
          if (idea.hook != null && idea.hook!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scaffoldBackgroundColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote,
                      size: 16, color: themeAccentSolid(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('"${idea.hook}"',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 12,
                            color: textDarkGrey(context))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),

          // Format + Hashtags row
          Row(
            children: [
              if (idea.format != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeAccentSolid(context).withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(idea.format!.toUpperCase(),
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 10, color: themeAccentSolid(context))),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  idea.hashtags?.map((h) => '#$h').join(' ') ?? '',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 11, color: themeAccentSolid(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String? difficulty;

  const _DifficultyBadge({this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => Colors.green,
      'medium' => Colors.orange,
      'hard' => Colors.red,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (difficulty ?? 'medium').toUpperCase(),
        style: TextStyleCustom.outFitMedium500(fontSize: 9, color: color),
      ),
    );
  }
}
