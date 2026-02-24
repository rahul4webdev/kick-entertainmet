import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/product_service.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

/// Bottom sheet that lets user choose a sticker type (Poll or Question),
/// configure it, and return the sticker data map to attach to the story.
class StoryStickerSheet extends StatefulWidget {
  const StoryStickerSheet({super.key});

  @override
  State<StoryStickerSheet> createState() => _StoryStickerSheetState();
}

class _StoryStickerSheetState extends State<StoryStickerSheet> {
  _StickerMode _mode = _StickerMode.select;

  // Poll fields
  final _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  // Question fields
  final _questionTextController = TextEditingController();

  // Link fields
  final _linkUrlController = TextEditingController();
  final _linkLabelController = TextEditingController();

  // Quiz fields
  final _quizQuestionController = TextEditingController();
  final List<TextEditingController> _quizOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  int _quizCorrectIndex = 0;

  // Slider fields
  final _sliderQuestionController = TextEditingController();
  String _sliderEmoji = '😍';

  // Countdown fields
  final _countdownTitleController = TextEditingController();
  DateTime? _countdownDate;
  TimeOfDay? _countdownTime;

  // Add Yours fields
  final _addYoursPromptController = TextEditingController();

  // Product fields
  List<Product>? _products;
  bool _productsLoading = false;

  @override
  void dispose() {
    _pollQuestionController.dispose();
    for (final c in _pollOptionControllers) {
      c.dispose();
    }
    _questionTextController.dispose();
    _linkUrlController.dispose();
    _linkLabelController.dispose();
    _quizQuestionController.dispose();
    for (final c in _quizOptionControllers) {
      c.dispose();
    }
    _sliderQuestionController.dispose();
    _countdownTitleController.dispose();
    _addYoursPromptController.dispose();
    super.dispose();
  }

  void _addPollOption() {
    if (_pollOptionControllers.length < 4) {
      setState(() => _pollOptionControllers.add(TextEditingController()));
    }
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length > 2) {
      setState(() {
        _pollOptionControllers[index].dispose();
        _pollOptionControllers.removeAt(index);
      });
    }
  }

  void _submitPoll() {
    final question = _pollQuestionController.text.trim();
    final options = _pollOptionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      Get.snackbar('Error', 'Please enter a question',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (options.length < 2) {
      Get.snackbar('Error', 'Please add at least 2 options',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'poll',
      'question': question,
      'options': options,
    });
  }

  void _submitQuestion() {
    final question = _questionTextController.text.trim();
    if (question.isEmpty) {
      Get.snackbar('Error', 'Please enter a question',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'question',
      'question': question,
    });
  }

  void _submitLink() {
    String url = _linkUrlController.text.trim();
    if (url.isEmpty) {
      Get.snackbar('Error', 'Please enter a URL',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final label = _linkLabelController.text.trim();
    Get.back(result: {
      'type': 'link',
      'url': url,
      'label': label.isNotEmpty ? label : url,
    });
  }

  void _addQuizOption() {
    if (_quizOptionControllers.length < 4) {
      setState(() => _quizOptionControllers.add(TextEditingController()));
    }
  }

  void _removeQuizOption(int index) {
    if (_quizOptionControllers.length > 2) {
      setState(() {
        _quizOptionControllers[index].dispose();
        _quizOptionControllers.removeAt(index);
        if (_quizCorrectIndex >= _quizOptionControllers.length) {
          _quizCorrectIndex = 0;
        }
      });
    }
  }

  void _submitQuiz() {
    final question = _quizQuestionController.text.trim();
    final options = _quizOptionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (question.isEmpty) {
      Get.snackbar('Error', 'Please enter a question',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (options.length < 2) {
      Get.snackbar('Error', 'Please add at least 2 options',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'quiz',
      'question': question,
      'options': options,
      'correct_index': _quizCorrectIndex,
    });
  }

  void _submitSlider() {
    final question = _sliderQuestionController.text.trim();
    if (question.isEmpty) {
      Get.snackbar('Error', 'Please enter a question',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'slider',
      'question': question,
      'emoji': _sliderEmoji,
    });
  }

  void _submitCountdown() {
    final title = _countdownTitleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Error', 'Please enter a title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_countdownDate == null) {
      Get.snackbar('Error', 'Please select a date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final time = _countdownTime ?? const TimeOfDay(hour: 12, minute: 0);
    final endDateTime = DateTime(
      _countdownDate!.year,
      _countdownDate!.month,
      _countdownDate!.day,
      time.hour,
      time.minute,
    );

    if (endDateTime.isBefore(DateTime.now())) {
      Get.snackbar('Error', 'Countdown must be in the future',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'countdown',
      'title': title,
      'end_time': endDateTime.toUtc().toIso8601String(),
    });
  }

  void _submitAddYours() {
    final prompt = _addYoursPromptController.text.trim();
    if (prompt.isEmpty) {
      Get.snackbar('Error', 'Please enter a prompt',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Get.back(result: {
      'type': 'add_yours',
      'prompt': prompt,
    });
  }

  Future<void> _loadProducts() async {
    setState(() => _productsLoading = true);
    try {
      final result = await ProductService.instance.fetchMyProducts();
      if (result.status == true && mounted) {
        setState(() => _products = result.data);
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _productsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: SafeArea(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: switch (_mode) {
            _StickerMode.select => _buildStickerSelection(context),
            _StickerMode.poll => _buildPollEditor(context),
            _StickerMode.question => _buildQuestionEditor(context),
            _StickerMode.link => _buildLinkEditor(context),
            _StickerMode.quiz => _buildQuizEditor(context),
            _StickerMode.slider => _buildSliderEditor(context),
            _StickerMode.countdown => _buildCountdownEditor(context),
            _StickerMode.addYours => _buildAddYoursEditor(context),
            _StickerMode.product => _buildProductEditor(context),
            _StickerMode.music => const SizedBox(),
          },
        ),
      ),
    );
  }

  Widget _buildStickerSelection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dragHandle(context),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Add Sticker',
            style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 18, color: textDarkGrey(context)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stickerOption(
              context,
              icon: Icons.poll_outlined,
              label: 'Poll',
              onTap: () => setState(() => _mode = _StickerMode.poll),
            ),
            _stickerOption(
              context,
              icon: Icons.help_outline,
              label: 'Question',
              onTap: () => setState(() => _mode = _StickerMode.question),
            ),
            _stickerOption(
              context,
              icon: Icons.link,
              label: 'Link',
              onTap: () => setState(() => _mode = _StickerMode.link),
            ),
            _stickerOption(
              context,
              icon: Icons.quiz_outlined,
              label: 'Quiz',
              onTap: () => setState(() => _mode = _StickerMode.quiz),
            ),
            _stickerOption(
              context,
              icon: Icons.linear_scale,
              label: 'Slider',
              onTap: () => setState(() => _mode = _StickerMode.slider),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _stickerOption(
              context,
              icon: Icons.timer_outlined,
              label: 'Countdown',
              onTap: () => setState(() => _mode = _StickerMode.countdown),
            ),
            _stickerOption(
              context,
              icon: Icons.add_circle_outline,
              label: 'Add Yours',
              onTap: () => setState(() => _mode = _StickerMode.addYours),
            ),
            _stickerOption(
              context,
              icon: Icons.music_note,
              label: 'Music',
              onTap: () => Get.back(result: {'type': 'music_picker'}),
            ),
            _stickerOption(
              context,
              icon: Icons.auto_fix_high,
              label: 'AI Sticker',
              onTap: () => Get.back(result: {'type': 'ai_sticker'}),
            ),
            _stickerOption(
              context,
              icon: Icons.shopping_bag_outlined,
              label: 'Product',
              onTap: () {
                setState(() => _mode = _StickerMode.product);
                _loadProducts();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _stickerOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgMediumGrey(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: themeAccentSolid(context)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 14, color: textDarkGrey(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildPollEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Poll Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(context, _pollQuestionController, 'Ask a question...'),
          const SizedBox(height: 12),
          ...List.generate(_pollOptionControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _inputField(
                        context, _pollOptionControllers[i], 'Option ${i + 1}'),
                  ),
                  if (_pollOptionControllers.length > 2)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: textLightGrey(context)),
                      onPressed: () => _removePollOption(i),
                    ),
                ],
              ),
            );
          }),
          if (_pollOptionControllers.length < 4)
            TextButton.icon(
              onPressed: _addPollOption,
              icon: Icon(Icons.add, color: themeAccentSolid(context)),
              label: Text('Add option',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: themeAccentSolid(context))),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitPoll,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Poll',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuestionEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Question Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
              context, _questionTextController, 'Ask me anything...'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Question',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuizEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Quiz Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
              context, _quizQuestionController, 'Ask a question...'),
          const SizedBox(height: 12),
          Text('Tap the correct answer',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context))),
          const SizedBox(height: 8),
          ...List.generate(_quizOptionControllers.length, (i) {
            final isCorrect = _quizCorrectIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => _quizCorrectIndex = i),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? Colors.green
                            : bgMediumGrey(context),
                        border: isCorrect
                            ? null
                            : Border.all(
                                color: textLightGrey(context), width: 1),
                      ),
                      child: isCorrect
                          ? Icon(Icons.check,
                              size: 18, color: whitePure(context))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _inputField(context, _quizOptionControllers[i],
                        'Option ${i + 1}'),
                  ),
                  if (_quizOptionControllers.length > 2)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: textLightGrey(context)),
                      onPressed: () => _removeQuizOption(i),
                    ),
                ],
              ),
            );
          }),
          if (_quizOptionControllers.length < 4)
            TextButton.icon(
              onPressed: _addQuizOption,
              icon: Icon(Icons.add, color: themeAccentSolid(context)),
              label: Text('Add option',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: themeAccentSolid(context))),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Quiz',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSliderEditor(BuildContext context) {
    const emojis = ['😍', '🔥', '😂', '😢', '😡', '👍', '❤️', '🤔', '🎉', '💯'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Emoji Slider',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
              context, _sliderQuestionController, 'Ask a question...'),
          const SizedBox(height: 16),
          Text('Choose an emoji',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emojis.map((emoji) {
              final isSelected = _sliderEmoji == emoji;
              return InkWell(
                onTap: () => setState(() => _sliderEmoji = emoji),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? themeAccentSolid(context).withValues(alpha: 0.2)
                        : bgMediumGrey(context),
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: themeAccentSolid(context), width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitSlider,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Slider',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCountdownEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Countdown Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
              context, _countdownTitleController, 'Event name...'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _countdownDate ?? DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _countdownDate = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 18, color: textLightGrey(context)),
                  const SizedBox(width: 10),
                  Text(
                    _countdownDate != null
                        ? '${_countdownDate!.day}/${_countdownDate!.month}/${_countdownDate!.year}'
                        : 'Select date...',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: _countdownDate != null
                            ? textDarkGrey(context)
                            : textLightGrey(context)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime:
                    _countdownTime ?? const TimeOfDay(hour: 12, minute: 0),
              );
              if (picked != null) {
                setState(() => _countdownTime = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: bgMediumGrey(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      size: 18, color: textLightGrey(context)),
                  const SizedBox(width: 10),
                  Text(
                    _countdownTime != null
                        ? _countdownTime!.format(context)
                        : 'Select time...',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 15,
                        color: _countdownTime != null
                            ? textDarkGrey(context)
                            : textLightGrey(context)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitCountdown,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Countdown',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAddYoursEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Add Yours Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(
              context, _addYoursPromptController, 'Enter a prompt (e.g., "Show your pet")...'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitAddYours,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Yours',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProductEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Product Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          if (_productsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_products == null || _products!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'You don\'t have any products yet.\nCreate one in your shop first.',
                  textAlign: TextAlign.center,
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _products!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = _products![index];
                  return InkWell(
                    onTap: () {
                      Get.back(result: {
                        'type': 'product',
                        'product_id': product.id,
                        'product_name': product.name ?? '',
                        'price_coins': product.priceCoins ?? 0,
                        'image': product.firstImageUrl,
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgMediumGrey(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.firstImageUrl.isNotEmpty
                                ? Image.network(
                                    product.firstImageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: bgLightGrey(context),
                                      child: Icon(Icons.shopping_bag_outlined,
                                          size: 24,
                                          color: textLightGrey(context)),
                                    ),
                                  )
                                : Container(
                                    width: 50,
                                    height: 50,
                                    color: bgLightGrey(context),
                                    child: Icon(Icons.shopping_bag_outlined,
                                        size: 24,
                                        color: textLightGrey(context)),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name ?? '',
                                  style: TextStyleCustom.outFitMedium500(
                                      fontSize: 14,
                                      color: textDarkGrey(context)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${product.priceCoins ?? 0} coins',
                                  style: TextStyleCustom.outFitRegular400(
                                      fontSize: 12,
                                      color: themeAccentSolid(context)),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 14, color: textLightGrey(context)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLinkEditor(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dragHandle(context),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => _mode = _StickerMode.select),
                child: Icon(Icons.arrow_back_ios,
                    size: 20, color: textDarkGrey(context)),
              ),
              const SizedBox(width: 8),
              Text('Link Sticker',
                  style: TextStyleCustom.unboundedSemiBold600(
                      fontSize: 18, color: textDarkGrey(context))),
            ],
          ),
          const SizedBox(height: 16),
          _inputField(context, _linkUrlController, 'Enter URL...'),
          const SizedBox(height: 12),
          _inputField(
              context, _linkLabelController, 'Button label (optional)'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                foregroundColor: whitePure(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Add Link',
                  style: TextStyleCustom.outFitMedium500(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _inputField(
      BuildContext context, TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: TextStyleCustom.outFitRegular400(
          fontSize: 15, color: textDarkGrey(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleCustom.outFitRegular400(
            fontSize: 15, color: textLightGrey(context)),
        filled: true,
        fillColor: bgMediumGrey(context),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _dragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: textLightGrey(context),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

enum _StickerMode { select, poll, question, link, quiz, slider, countdown, addYours, product, music }
