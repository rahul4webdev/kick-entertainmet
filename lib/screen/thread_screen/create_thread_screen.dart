import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/thread_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/screen/feed_screen/feed_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreateThreadScreen extends StatefulWidget {
  const CreateThreadScreen({super.key});

  @override
  State<CreateThreadScreen> createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends State<CreateThreadScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isSubmitting = false;

  void _addSegment() {
    if (_controllers.length < 10) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _removeSegment(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  bool get _canSubmit {
    final filledCount =
        _controllers.where((c) => c.text.trim().isNotEmpty).length;
    return filledCount >= 2 && !_isSubmitting;
  }

  Future<void> _submitThread() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    final posts = _controllers
        .where((c) => c.text.trim().isNotEmpty)
        .map((c) => {'description': c.text.trim()})
        .toList();

    final result = await ThreadService.instance.createThread(posts: posts);

    setState(() => _isSubmitting = false);

    if (result.status == true && result.posts != null) {
      // Add first thread post to feed
      if (result.posts!.isNotEmpty &&
          Get.isRegistered<FeedScreenController>()) {
        Get.find<FeedScreenController>().posts.insert(0, result.posts!.first);
      }
      Get.back();
      Get.snackbar('Thread Created', '${result.posts!.length} posts published',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('Error', result.message ?? 'Failed to create thread',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: 'Create Thread'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _controllers.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                if (index == _controllers.length) {
                  // Add segment button
                  if (_controllers.length >= 10) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: InkWell(
                      onTap: _addSegment,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 20, color: themeAccentSolid(context)),
                          const SizedBox(width: 6),
                          Text(
                            'Add another post',
                            style: TextStyleCustom.outFitRegular400(
                                fontSize: 14,
                                color: themeAccentSolid(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thread connector
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: themeAccentSolid(context),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: TextStyleCustom.outFitMedium500(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ),
                          if (index < _controllers.length - 1)
                            Container(
                              width: 2,
                              height: 60,
                              color: themeAccentSolid(context)
                                  .withValues(alpha: .3),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Text input
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          maxLines: 4,
                          minLines: 2,
                          maxLength: 2000,
                          onChanged: (_) => setState(() {}),
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 15, color: textDarkGrey(context)),
                          decoration: InputDecoration(
                            hintText: index == 0
                                ? 'Start your thread...'
                                : 'Continue...',
                            hintStyle: TextStyleCustom.outFitRegular400(
                                fontSize: 15, color: textLightGrey(context)),
                            filled: true,
                            fillColor: bgMediumGrey(context),
                            counterStyle: TextStyleCustom.outFitRegular400(
                                fontSize: 11, color: textLightGrey(context)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            suffixIcon: _controllers.length > 2
                                ? IconButton(
                                    icon: Icon(Icons.remove_circle_outline,
                                        size: 20,
                                        color: textLightGrey(context)),
                                    onPressed: () => _removeSegment(index),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Submit button
          TextButtonCustom(
            onTap: _canSubmit ? () => _submitThread() : () {},
            title: _isSubmitting ? 'Posting...' : 'Post Thread',
            backgroundColor: textDarkGrey(context)
                .withValues(alpha: _canSubmit ? 1 : .5),
            titleColor:
                Colors.white.withValues(alpha: _canSubmit ? 1 : .5),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ],
      ),
    );
  }
}
