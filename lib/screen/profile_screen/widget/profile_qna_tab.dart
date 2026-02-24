import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/question_service.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/qna/question_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ProfileQnATab extends StatefulWidget {
  final int profileUserId;
  final bool isMe;

  const ProfileQnATab({
    super.key,
    required this.profileUserId,
    required this.isMe,
  });

  @override
  State<ProfileQnATab> createState() => _ProfileQnATabState();
}

class _ProfileQnATabState extends State<ProfileQnATab>
    with AutomaticKeepAliveClientMixin {
  final RxList<QuestionItem> questions = <QuestionItem>[].obs;
  final RxBool isLoading = false.obs;
  bool hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions({bool reset = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (reset) {
      questions.clear();
      hasMore = true;
    }
    final items = await QuestionService.instance.fetchQuestions(
      userId: widget.profileUserId,
      lastItemId: questions.isNotEmpty ? questions.last.id : null,
    );
    if (items.length < 20) hasMore = false;
    questions.addAll(items);
    isLoading.value = false;
  }

  void _showAskDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(LKey.askQuestion.tr),
        content: TextField(
          controller: textController,
          maxLength: 500,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: LKey.typeYourQuestion.tr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              Get.back();
              final q = await QuestionService.instance.askQuestion(
                userId: widget.profileUserId,
                question: text,
              );
              if (q != null) {
                questions.insert(0, q);
              }
            },
            child: Text(LKey.submit.tr),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(QuestionItem item) {
    final textController = TextEditingController(text: item.answer ?? '');
    Get.dialog(
      AlertDialog(
        title: Text(LKey.answerQuestion.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.question,
                style: TextStyleCustom.outFitMedium500(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLength: 2000,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: LKey.typeYourAnswer.tr,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(LKey.cancel.tr),
          ),
          TextButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              Get.back();
              final updated = await QuestionService.instance.answerQuestion(
                questionId: item.id,
                answer: text,
              );
              if (updated != null) {
                final idx = questions.indexWhere((q) => q.id == item.id);
                if (idx >= 0) {
                  questions[idx] = updated;
                }
              }
            },
            child: Text(LKey.submit.tr),
          ),
        ],
      ),
    );
  }

  void _showOptions(QuestionItem item) {
    final isOwner = widget.isMe;
    final isAsker =
        item.askedBy?.id == SessionManager.instance.getUserID();

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: scaffoldBackgroundColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: textLightGrey(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (isOwner && !item.isAnswered)
                ListTile(
                  leading: Icon(Icons.edit, color: blackPure(context)),
                  title: Text(LKey.answerQuestion.tr),
                  onTap: () {
                    Get.back();
                    _showAnswerDialog(item);
                  },
                ),
              if (isOwner)
                ListTile(
                  leading: Icon(
                      item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: blackPure(context)),
                  title: Text(item.isPinned ? LKey.unpin.tr : LKey.pin.tr),
                  onTap: () async {
                    Get.back();
                    await QuestionService.instance
                        .togglePinQuestion(questionId: item.id);
                    _fetchQuestions(reset: true);
                  },
                ),
              if (isOwner)
                ListTile(
                  leading: Icon(
                      item.isHidden
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: blackPure(context)),
                  title:
                      Text(item.isHidden ? LKey.unhide.tr : LKey.hide.tr),
                  onTap: () async {
                    Get.back();
                    await QuestionService.instance
                        .toggleHideQuestion(questionId: item.id);
                    _fetchQuestions(reset: true);
                  },
                ),
              if (isOwner || isAsker)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(LKey.delete.tr,
                      style: const TextStyle(color: Colors.red)),
                  onTap: () async {
                    Get.back();
                    final success = await QuestionService.instance
                        .deleteQuestion(questionId: item.id);
                    if (success) {
                      questions.removeWhere((q) => q.id == item.id);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        // Ask button (only visible if viewing someone else's profile)
        if (!widget.isMe)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAskDialog,
                icon: const Icon(Icons.help_outline, size: 18),
                label: Text(LKey.askQuestion.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: themeAccentSolid(context),
                  side: BorderSide(color: themeAccentSolid(context)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        Expanded(
          child: Obx(() {
            if (isLoading.value && questions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (questions.isEmpty) {
              return Center(
                child: Text(
                  LKey.noQuestionsYet.tr,
                  style: TextStyleCustom.outFitRegular400(
                      color: textLightGrey(context), fontSize: 15),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels >=
                        notification.metrics.maxScrollExtent - 200 &&
                    hasMore &&
                    !isLoading.value) {
                  _fetchQuestions();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return _QuestionCard(
                    item: questions[index],
                    isOwner: widget.isMe,
                    onLike: () {
                      questions[index].toggleLike();
                      questions.refresh();
                      QuestionService.instance
                          .likeQuestion(questionId: questions[index].id);
                    },
                    onAnswer: widget.isMe
                        ? () => _showAnswerDialog(questions[index])
                        : null,
                    onOptions: () => _showOptions(questions[index]),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionItem item;
  final bool isOwner;
  final VoidCallback onLike;
  final VoidCallback? onAnswer;
  final VoidCallback onOptions;

  const _QuestionCard({
    required this.item,
    required this.isOwner,
    required this.onLike,
    this.onAnswer,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: asker info + pin badge + options
          Row(
            children: [
              CustomImage(
                image: item.askedBy?.profilePhoto?.addBaseURL(),
                fullName: item.askedBy?.fullname,
                size: const Size(28, 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.askedBy?.username ?? '',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 13,
                    color: blackPure(context),
                  ),
                ),
              ),
              if (item.isPinned)
                Icon(Icons.push_pin,
                    size: 16, color: themeAccentSolid(context)),
              if (item.isHidden)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.visibility_off,
                      size: 16, color: textLightGrey(context)),
                ),
              InkWell(
                onTap: onOptions,
                child: Icon(Icons.more_horiz,
                    size: 20, color: textLightGrey(context)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Question text
          Text(
            item.question,
            style: TextStyleCustom.outFitMedium500(
              fontSize: 14,
              color: blackPure(context),
            ),
          ),
          // Answer
          if (item.isAnswered) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scaffoldBackgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomImage(
                    image: item.profileUser?.profilePhoto?.addBaseURL(),
                    fullName: item.profileUser?.fullname,
                    size: const Size(24, 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.profileUser?.username ?? '',
                          style: TextStyleCustom.outFitMedium500(
                            fontSize: 12,
                            color: themeAccentSolid(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.answer ?? '',
                          style: TextStyleCustom.outFitRegular400(
                            fontSize: 13,
                            color: blackPure(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Answer button (for profile owner, unanswered questions)
          if (!item.isAnswered && isOwner && onAnswer != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: onAnswer,
              child: Text(
                LKey.answerQuestion.tr,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 13,
                  color: themeAccentSolid(context),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          // Like row
          Row(
            children: [
              InkWell(
                onTap: onLike,
                child: Icon(
                  item.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: item.isLiked
                      ? Colors.red
                      : textLightGrey(context),
                ),
              ),
              const SizedBox(width: 4),
              if (item.likeCount > 0)
                Text(
                  '${item.likeCount}',
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 12,
                    color: textLightGrey(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
