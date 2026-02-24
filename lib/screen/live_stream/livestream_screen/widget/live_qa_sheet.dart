import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/livestream/live_qa_question.dart';
import 'package:shortzz/screen/live_stream/livestream_screen/livestream_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class LiveQASheet extends StatelessWidget {
  final LivestreamScreenController controller;

  const LiveQASheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final questionController = TextEditingController();
    final isHostUser = controller.isHost;

    return Container(
      height: Get.height * 0.65,
      decoration: ShapeDecoration(
        color: scaffoldBackgroundColor(context),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  LKey.qaSession,
                  style: TextStyleCustom.unboundedMedium500(
                      fontSize: 18, color: textDarkGrey(context)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close,
                      color: textLightGrey(context), size: 22),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final questions = controller.qaQuestions;
              if (questions.isEmpty) {
                return Center(
                  child: Text(
                    LKey.noQuestions,
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 15),
                  ),
                );
              }

              // Sort: pinned first, then by upvotes
              final sorted = List<LiveQAQuestion>.from(questions);
              sorted.sort((a, b) {
                if (a.isPinned == true && b.isPinned != true) return -1;
                if (b.isPinned == true && a.isPinned != true) return 1;
                return (b.upvoteCount ?? 0).compareTo(a.upvoteCount ?? 0);
              });

              return ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final q = sorted[index];
                  return _QuestionCard(
                    question: q,
                    controller: controller,
                    isHost: isHostUser,
                  );
                },
              );
            }),
          ),
          // Submit question area (for audience)
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: bgLightGrey(context),
              border: Border(
                  top: BorderSide(
                      color: bgMediumGrey(context), width: 0.5)),
            ),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: TextField(
                    controller: questionController,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: LKey.typeYourQuestion,
                      hintStyle: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    style: TextStyleCustom.outFitRegular400(
                        color: textDarkGrey(context), fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final text = questionController.text.trim();
                    if (text.isEmpty) return;
                    controller.submitQuestion(text);
                    questionController.clear();
                    controller.showSnackBar(LKey.questionSubmitted);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: ShapeDecoration(
                      color: themeAccentSolid(context),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1),
                      ),
                    ),
                    child: Text(
                      LKey.submitQuestion,
                      style: TextStyleCustom.outFitMedium500(
                          color: whitePure(context), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final LiveQAQuestion question;
  final LivestreamScreenController controller;
  final bool isHost;

  const _QuestionCard({
    required this.question,
    required this.controller,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    final isPinned = question.isPinned ?? false;
    final isAnswered = question.isAnswered ?? false;
    final hasUpvoted = question.hasUpvoted(controller.myUserId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: isPinned
            ? Colors.amber.withValues(alpha: .08)
            : bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          side: isPinned
              ? BorderSide(color: Colors.amber.withValues(alpha: .3))
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isPinned) ...[
                Icon(Icons.push_pin, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
              ],
              Text(
                '@${question.username ?? ''}',
                style: TextStyleCustom.outFitMedium500(
                    color: textLightGrey(context), fontSize: 12),
              ),
              const Spacer(),
              if (isAnswered)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Answered',
                      style: TextStyleCustom.outFitLight300(
                          color: Colors.green, fontSize: 10)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.question ?? '',
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Upvote button
              GestureDetector(
                onTap: hasUpvoted
                    ? null
                    : () => controller.upvoteQuestion(question),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Icon(
                      hasUpvoted
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      size: 16,
                      color: hasUpvoted
                          ? themeAccentSolid(context)
                          : textLightGrey(context),
                    ),
                    Text(
                      '${question.upvoteCount ?? 0}',
                      style: TextStyleCustom.outFitMedium500(
                        color: hasUpvoted
                            ? themeAccentSolid(context)
                            : textLightGrey(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Host actions
              if (isHost && !isAnswered) ...[
                GestureDetector(
                  onTap: () => controller.pinQuestion(question),
                  child: Text(
                    isPinned ? LKey.unpinQuestion : LKey.pinQuestion,
                    style: TextStyleCustom.outFitMedium500(
                        color: Colors.amber, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => controller.markQuestionAnswered(question),
                  child: Text(
                    LKey.markAnswered,
                    style: TextStyleCustom.outFitMedium500(
                        color: Colors.green, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
