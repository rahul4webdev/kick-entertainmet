import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/manager/story_view/controller/story_controller.dart';
import 'package:shortzz/common/service/api/sticker_service.dart';
import 'package:shortzz/model/post_story/story/story_model.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/shop_screen/product_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Overlay widget that renders interactive poll or question stickers on stories.
class StoryStickerOverlay extends StatefulWidget {
  final Story story;
  final StoryController storyController;

  const StoryStickerOverlay({
    super.key,
    required this.story,
    required this.storyController,
  });

  @override
  State<StoryStickerOverlay> createState() => _StoryStickerOverlayState();
}

class _StoryStickerOverlayState extends State<StoryStickerOverlay> {
  Map<String, dynamic>? _stickerData;
  bool _isLoading = false;

  // Poll state
  int? _myVote;
  List<Map<String, dynamic>>? _pollResults;
  int _totalVotes = 0;

  // Slider state
  double? _mySliderValue;
  double _sliderAverage = 0;
  int _totalSliderResponses = 0;
  bool _sliderSubmitted = false;
  double _sliderDragValue = 0.5;

  // Quiz state
  int? _myQuizAnswer;
  int? _quizCorrectIndex;
  List<Map<String, dynamic>>? _quizResults;
  int _totalQuizAnswers = 0;

  // Question state
  bool _questionSubmitted = false;
  final _questionResponseController = TextEditingController();

  // Countdown state
  bool _countdownSubscribed = false;
  int _countdownSubscribers = 0;

  // Add Yours state
  int _chainParticipantCount = 0;

  @override
  void initState() {
    super.initState();
    _stickerData = widget.story.stickerData;
    if (_stickerData != null) {
      if (_stickerData!['type'] == 'poll') {
        _fetchPollResults();
      } else if (_stickerData!['type'] == 'quiz') {
        _fetchQuizResults();
      } else if (_stickerData!['type'] == 'slider') {
        _fetchSliderResults();
      } else if (_stickerData!['type'] == 'countdown') {
        _fetchCountdownInfo();
      } else if (_stickerData!['type'] == 'add_yours') {
        _fetchChainInfo();
      }
    }
  }

  @override
  void dispose() {
    _questionResponseController.dispose();
    super.dispose();
  }

  Future<void> _fetchPollResults() async {
    if (widget.story.id == null) return;
    try {
      final response = await StickerService.instance
          .fetchPollResults(storyId: widget.story.id!);
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _myVote = data['my_vote'];
          _totalVotes = data['total_votes'] ?? 0;
          _pollResults =
              List<Map<String, dynamic>>.from(data['results'] ?? []);
        });
      }
    } catch (e) {
      Loggers.error('Fetch poll results error: $e');
    }
  }

  Future<void> _voteOnPoll(int optionIndex) async {
    if (_isLoading || widget.story.id == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await StickerService.instance.voteOnPoll(
        storyId: widget.story.id!,
        optionIndex: optionIndex,
      );
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _myVote = data['my_vote'];
          _totalVotes = data['total_votes'] ?? 0;
          _pollResults =
              List<Map<String, dynamic>>.from(data['results'] ?? []);
        });
      }
    } catch (e) {
      Loggers.error('Vote on poll error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitQuestionResponse() async {
    final text = _questionResponseController.text.trim();
    if (text.isEmpty || _isLoading || widget.story.id == null) return;

    setState(() => _isLoading = true);
    widget.storyController.pause();

    try {
      final response = await StickerService.instance.submitQuestionResponse(
        storyId: widget.story.id!,
        responseText: text,
      );
      if (response.status == true && mounted) {
        setState(() => _questionSubmitted = true);
        _questionResponseController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      Loggers.error('Submit question response error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      widget.storyController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stickerData == null) return const SizedBox();

    final type = _stickerData!['type'];
    if (type == 'poll') return _buildPollSticker(context);
    if (type == 'question') return _buildQuestionSticker(context);
    if (type == 'link') return _buildLinkSticker(context);
    if (type == 'quiz') return _buildQuizSticker(context);
    if (type == 'slider') return _buildSliderSticker(context);
    if (type == 'countdown') return _buildCountdownSticker(context);
    if (type == 'add_yours') return _buildAddYoursSticker(context);
    if (type == 'product') return _buildProductSticker(context);
    if (type == 'music') return _buildMusicSticker(context);
    return const SizedBox();
  }

  Widget _buildPollSticker(BuildContext context) {
    final question = _stickerData!['question'] ?? '';
    final options = List<String>.from(_stickerData!['options'] ?? []);
    final bool hasVoted = _myVote != null;
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (i) {
            final isSelected = _myVote == i;
            final resultData = _pollResults != null && i < _pollResults!.length
                ? _pollResults![i]
                : null;
            final votes = resultData?['votes'] ?? 0;
            final percentage = (resultData?['percentage'] ?? 0).toDouble();

            if (hasVoted || isMyStory) {
              return _pollResultRow(
                  context, options[i], votes, percentage, isSelected);
            }
            return _pollOptionButton(context, options[i], i);
          }),
          if (hasVoted || isMyStory)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$_totalVotes vote${_totalVotes == 1 ? '' : 's'}',
                style: TextStyleCustom.outFitLight300(
                    fontSize: 12, color: whitePure(context).withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _pollOptionButton(BuildContext context, String option, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _isLoading ? null : () => _voteOnPoll(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: whitePure(context).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            option,
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _pollResultRow(BuildContext context, String option, int votes,
      double percentage, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: whitePure(context).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_circle,
                        size: 16, color: themeAccentSolid(context)),
                  ),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: whitePure(context)),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: whitePure(context)),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: (isSelected
                          ? themeAccentSolid(context)
                          : whitePure(context))
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionSticker(BuildContext context) {
    final question = _stickerData!['question'] ?? '';
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (isMyStory)
            InkWell(
              onTap: () => _showResponses(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: whitePure(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'View Responses',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: whitePure(context)),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_questionSubmitted)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: whitePure(context).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      size: 18, color: themeAccentSolid(context)),
                  const SizedBox(width: 6),
                  Text(
                    'Response sent!',
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: whitePure(context)),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionResponseController,
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 14, color: whitePure(context)),
                    decoration: InputDecoration(
                      hintText: 'Send a response...',
                      hintStyle: TextStyleCustom.outFitRegular400(
                          fontSize: 14,
                          color: whitePure(context).withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: whitePure(context).withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onTap: () => widget.storyController.pause(),
                    onSubmitted: (_) => _submitQuestionResponse(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isLoading ? null : _submitQuestionResponse,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeAccentSolid(context),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: whitePure(context)))
                        : Icon(Icons.send,
                            size: 18, color: whitePure(context)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _fetchSliderResults() async {
    if (widget.story.id == null) return;
    try {
      final response = await StickerService.instance
          .fetchSliderResults(storyId: widget.story.id!);
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _mySliderValue = data['my_value'] != null
              ? (data['my_value'] as num).toDouble()
              : null;
          _sliderAverage = (data['average'] as num?)?.toDouble() ?? 0;
          _totalSliderResponses = data['total_responses'] ?? 0;
          if (_mySliderValue != null) {
            _sliderSubmitted = true;
            _sliderDragValue = _mySliderValue!;
          }
        });
      }
    } catch (e) {
      Loggers.error('Fetch slider results error: $e');
    }
  }

  Future<void> _submitSliderValue() async {
    if (_isLoading || widget.story.id == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await StickerService.instance.submitSlider(
        storyId: widget.story.id!,
        value: _sliderDragValue,
      );
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _sliderSubmitted = true;
          _mySliderValue = _sliderDragValue;
          _sliderAverage = (data['average'] as num?)?.toDouble() ?? 0;
          _totalSliderResponses = data['total_responses'] ?? 0;
        });
      }
    } catch (e) {
      Loggers.error('Submit slider error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSliderSticker(BuildContext context) {
    final question = _stickerData!['question'] ?? '';
    final emoji = _stickerData!['emoji'] ?? '😍';
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();
    final bool showResults = _sliderSubmitted || isMyStory;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        whitePure(context).withValues(alpha: 0.2),
                        themeAccentSolid(context),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (showResults)
                  Positioned(
                    left: (_sliderAverage *
                            (MediaQuery.of(context).size.width - 96 - 20))
                        .clamp(0.0, double.infinity),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 28)),
                        Text(
                          '$_totalSliderResponses',
                          style: TextStyleCustom.outFitLight300(
                              fontSize: 10,
                              color: whitePure(context)
                                  .withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  )
                else
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 0),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned(
                            left: (_sliderDragValue *
                                    (MediaQuery.of(context).size.width -
                                        96 -
                                        20))
                                .clamp(0.0, double.infinity),
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 28)),
                          ),
                          Opacity(
                            opacity: 0,
                            child: Slider(
                              value: _sliderDragValue,
                              onChanged: (v) {
                                widget.storyController.pause();
                                setState(() => _sliderDragValue = v);
                              },
                              onChangeEnd: (_) => _submitSliderValue(),
                            ),
                          ),
                        ],
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

  Future<void> _fetchQuizResults() async {
    if (widget.story.id == null) return;
    try {
      final response = await StickerService.instance
          .fetchQuizResults(storyId: widget.story.id!);
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _myQuizAnswer = data['my_answer'];
          _quizCorrectIndex = data['correct_index'];
          _totalQuizAnswers = data['total_answers'] ?? 0;
          _quizResults =
              List<Map<String, dynamic>>.from(data['results'] ?? []);
        });
      }
    } catch (e) {
      Loggers.error('Fetch quiz results error: $e');
    }
  }

  Future<void> _answerQuiz(int optionIndex) async {
    if (_isLoading || widget.story.id == null) return;
    setState(() => _isLoading = true);

    try {
      final response = await StickerService.instance.answerQuiz(
        storyId: widget.story.id!,
        optionIndex: optionIndex,
      );
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _myQuizAnswer = data['my_answer'];
          _quizCorrectIndex = data['correct_index'];
          _totalQuizAnswers = data['total_answers'] ?? 0;
          _quizResults =
              List<Map<String, dynamic>>.from(data['results'] ?? []);
        });
      }
    } catch (e) {
      Loggers.error('Answer quiz error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildQuizSticker(BuildContext context) {
    final question = _stickerData!['question'] ?? '';
    final options = List<String>.from(_stickerData!['options'] ?? []);
    final bool hasAnswered = _myQuizAnswer != null;
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();
    final correctIdx = _quizCorrectIndex ?? (_stickerData!['correct_index'] ?? 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined,
                  size: 18, color: whitePure(context).withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text('Quiz',
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 12,
                      color: whitePure(context).withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...List.generate(options.length, (i) {
            if (hasAnswered || isMyStory) {
              return _quizResultRow(context, options[i], i, correctIdx);
            }
            return _quizOptionButton(context, options[i], i);
          }),
          if (hasAnswered || isMyStory)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$_totalQuizAnswers answer${_totalQuizAnswers == 1 ? '' : 's'}',
                style: TextStyleCustom.outFitLight300(
                    fontSize: 12,
                    color: whitePure(context).withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quizOptionButton(BuildContext context, String option, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _isLoading ? null : () => _answerQuiz(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border:
                Border.all(color: whitePure(context).withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            option,
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _quizResultRow(
      BuildContext context, String option, int index, int correctIdx) {
    final isCorrect = index == correctIdx;
    final isMyPick = _myQuizAnswer == index;
    final resultData =
        _quizResults != null && index < _quizResults!.length
            ? _quizResults![index]
            : null;
    final percentage = (resultData?['percentage'] ?? 0).toDouble();

    Color borderColor;
    Color? bgColor;
    if (isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withValues(alpha: 0.2);
    } else if (isMyPick) {
      borderColor = Colors.red.shade400;
      bgColor = Colors.red.withValues(alpha: 0.15);
    } else {
      borderColor = whitePure(context).withValues(alpha: 0.3);
      bgColor = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
              color: bgColor,
            ),
            child: Row(
              children: [
                if (isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child:
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                  )
                else if (isMyPick)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.cancel,
                        size: 16, color: Colors.red.shade400),
                  ),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyleCustom.outFitMedium500(
                        fontSize: 14, color: whitePure(context)),
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: whitePure(context)),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: (isCorrect ? Colors.green : whitePure(context))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkSticker(BuildContext context) {
    final url = _stickerData!['url'] ?? '';
    final label = _stickerData!['label'] ?? url;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () async {
          widget.storyController.pause();
          final uri = Uri.tryParse(url);
          if (uri != null) {
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {
              Loggers.error('Failed to launch URL: $e');
            }
          }
          widget.storyController.play();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: blackPure(context).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.link, size: 20, color: whitePure(context)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 15, color: whitePure(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.open_in_new,
                  size: 16,
                  color: whitePure(context).withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicSticker(BuildContext context) {
    final title = _stickerData!['title'] ?? 'Unknown';
    final artist = _stickerData!['artist'] ?? '';
    final image = _stickerData!['image'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image != null && image.isNotEmpty
                ? Image.network(
                    image.addBaseURL(),
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      color: whitePure(context).withValues(alpha: 0.15),
                      child: Icon(Icons.music_note,
                          size: 24, color: whitePure(context)),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: whitePure(context).withValues(alpha: 0.15),
                    child: Icon(Icons.music_note,
                        size: 24, color: whitePure(context)),
                  ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: whitePure(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (artist.isNotEmpty)
                  Text(
                    artist,
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 12,
                        color: whitePure(context).withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.music_note,
              size: 18, color: whitePure(context).withValues(alpha: 0.7)),
        ],
      ),
    );
  }

  Widget _buildProductSticker(BuildContext context) {
    final productName = _stickerData!['product_name'] ?? '';
    final priceCoins = _stickerData!['price_coins'] ?? 0;
    final image = _stickerData!['image'] as String?;
    final productId = _stickerData!['product_id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () {
          if (productId != null) {
            widget.storyController.pause();
            Get.to(() => ProductDetailScreen(
              product: Product(
                id: productId is int
                    ? productId
                    : int.tryParse(productId.toString()),
                name: productName,
                priceCoins: priceCoins is int
                    ? priceCoins
                    : int.tryParse(priceCoins.toString()),
                imageUrls:
                    image != null && image.isNotEmpty ? [image] : null,
              ),
            ))?.then((_) => widget.storyController.play());
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: blackPure(context).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 48,
                          height: 48,
                          color: whitePure(context).withValues(alpha: 0.15),
                          child: Icon(Icons.shopping_bag_outlined,
                              size: 24, color: whitePure(context)),
                        ),
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: whitePure(context).withValues(alpha: 0.15),
                        child: Icon(Icons.shopping_bag_outlined,
                            size: 24, color: whitePure(context)),
                      ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 14, color: whitePure(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$priceCoins coins',
                      style: TextStyleCustom.outFitLight300(
                          fontSize: 12,
                          color:
                              whitePure(context).withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.shopping_bag_outlined,
                  size: 18,
                  color: whitePure(context).withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchCountdownInfo() async {
    if (widget.story.id == null) return;
    try {
      final response = await StickerService.instance
          .fetchCountdownInfo(storyId: widget.story.id!);
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _countdownSubscribed = data['is_subscribed'] == true;
          _countdownSubscribers = data['subscriber_count'] ?? 0;
        });
      }
    } catch (e) {
      Loggers.error('Fetch countdown info error: $e');
    }
  }

  Future<void> _toggleCountdownSubscription() async {
    if (_isLoading || widget.story.id == null) return;
    setState(() => _isLoading = true);

    try {
      final response = _countdownSubscribed
          ? await StickerService.instance
              .unsubscribeCountdown(storyId: widget.story.id!)
          : await StickerService.instance
              .subscribeCountdown(storyId: widget.story.id!);
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _countdownSubscribed = data['is_subscribed'] == true;
          _countdownSubscribers = data['subscriber_count'] ?? 0;
        });
      }
    } catch (e) {
      Loggers.error('Toggle countdown subscription error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildCountdownSticker(BuildContext context) {
    final title = _stickerData!['title'] ?? 'Countdown';
    final endTimeStr = _stickerData!['end_time'] ?? '';
    final endTime = DateTime.tryParse(endTimeStr)?.toLocal();
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 18, color: whitePure(context).withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text('Countdown',
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 12,
                      color: whitePure(context).withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (endTime != null) _CountdownTimer(endTime: endTime),
          const SizedBox(height: 12),
          if (!isMyStory)
            InkWell(
              onTap: _isLoading ? null : _toggleCountdownSubscription,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _countdownSubscribed
                      ? whitePure(context).withValues(alpha: 0.15)
                      : themeAccentSolid(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _countdownSubscribed
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      size: 18,
                      color: whitePure(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _countdownSubscribed ? 'Reminded' : 'Remind Me',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 13, color: whitePure(context)),
                    ),
                  ],
                ),
              ),
            ),
          if (_countdownSubscribers > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$_countdownSubscribers subscriber${_countdownSubscribers == 1 ? '' : 's'}',
                style: TextStyleCustom.outFitLight300(
                    fontSize: 12,
                    color: whitePure(context).withValues(alpha: 0.7)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _fetchChainInfo() async {
    final chainId = _stickerData?['chain_id'];
    if (chainId == null) return;
    try {
      final response = await StickerService.instance
          .fetchChainInfo(chainId: chainId is int ? chainId : int.parse(chainId.toString()));
      if (response['status'] == true && mounted) {
        final data = response['data'];
        setState(() {
          _chainParticipantCount = data['participant_count'] ?? 0;
        });
      }
    } catch (e) {
      Loggers.error('Fetch chain info error: $e');
    }
  }

  Widget _buildAddYoursSticker(BuildContext context) {
    final prompt = _stickerData!['prompt'] ?? '';
    final chainId = _stickerData!['chain_id'];
    final bool isMyStory =
        widget.story.userId == SessionManager.instance.getUserID();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blackPure(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  size: 18, color: whitePure(context).withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text('Add Yours',
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 12,
                      color: whitePure(context).withValues(alpha: 0.7))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prompt,
            style: TextStyleCustom.outFitMedium500(
                fontSize: 16, color: whitePure(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (!isMyStory && chainId != null)
            InkWell(
              onTap: () {
                // Navigate to story creation with this chain's prompt
                widget.storyController.pause();
                Get.snackbar(
                  'Add Yours',
                  'Create a story with: "$prompt"',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
                widget.storyController.play();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: whitePure(context)),
                    const SizedBox(width: 6),
                    Text(
                      'Add Yours',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 13, color: whitePure(context)),
                    ),
                  ],
                ),
              ),
            ),
          if (_chainParticipantCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: chainId != null
                    ? () => _showChainParticipants(context, chainId)
                    : null,
                child: Text(
                  '$_chainParticipantCount participant${_chainParticipantCount == 1 ? '' : 's'}',
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 12,
                      color: themeAccentSolid(context)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showChainParticipants(BuildContext context, dynamic chainId) async {
    widget.storyController.pause();
    try {
      final id = chainId is int ? chainId : int.parse(chainId.toString());
      final response =
          await StickerService.instance.fetchChainInfo(chainId: id);
      if (response['status'] == true) {
        final data = response['data'];
        final participants =
            List<Map<String, dynamic>>.from(data['participants'] ?? []);
        if (context.mounted) {
          Get.bottomSheet(
            _ChainParticipantsSheet(
                prompt: data['prompt'] ?? '', participants: participants),
            isScrollControlled: true,
          ).then((_) => widget.storyController.play());
        }
      }
    } catch (e) {
      Loggers.error('Fetch chain participants error: $e');
      widget.storyController.play();
    }
  }

  void _showResponses(BuildContext context) async {
    widget.storyController.pause();
    if (widget.story.id == null) return;

    try {
      final response = await StickerService.instance
          .fetchQuestionResponses(storyId: widget.story.id!);
      if (response['status'] == true) {
        final data = List<Map<String, dynamic>>.from(response['data'] ?? []);
        if (context.mounted) {
          Get.bottomSheet(
            _QuestionResponsesSheet(responses: data),
            isScrollControlled: true,
          ).then((_) => widget.storyController.play());
        }
      }
    } catch (e) {
      Loggers.error('Fetch responses error: $e');
      widget.storyController.play();
    }
  }
}

class _QuestionResponsesSheet extends StatelessWidget {
  final List<Map<String, dynamic>> responses;

  const _QuestionResponsesSheet({required this.responses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      padding: const EdgeInsets.only(top: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Responses (${responses.length})',
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 18, color: textDarkGrey(context)),
              ),
            ),
            const SizedBox(height: 12),
            if (responses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No responses yet.',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: responses.length,
                  itemBuilder: (context, index) {
                    final item = responses[index];
                    final user = item['user'] as Map<String, dynamic>?;
                    final responseText = item['response'] ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bgMediumGrey(context),
                        child: Text(
                          (user?['fullname'] ?? '?')[0].toUpperCase(),
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 16, color: textDarkGrey(context)),
                        ),
                      ),
                      title: Text(
                        user?['fullname'] ?? 'User',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 14, color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        responseText,
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 13, color: textLightGrey(context)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Live countdown timer that updates every second.
class _CountdownTimer extends StatefulWidget {
  final DateTime endTime;
  const _CountdownTimer({required this.endTime});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Duration _remaining;
  late final Stream<int> _ticker;
  late final dynamic _subscription;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endTime.difference(DateTime.now());
    if (_remaining.isNegative) _remaining = Duration.zero;
    _ticker = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _subscription = _ticker.listen((_) {
      if (!mounted) return;
      final diff = widget.endTime.difference(DateTime.now());
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    });
  }

  @override
  void dispose() {
    (_subscription as dynamic).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Ended!',
        style: TextStyleCustom.unboundedSemiBold600(
            fontSize: 20, color: whitePure(context)),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (days > 0) _timeUnit(context, days, 'D'),
        if (days > 0) _separator(context),
        _timeUnit(context, hours, 'H'),
        _separator(context),
        _timeUnit(context, minutes, 'M'),
        _separator(context),
        _timeUnit(context, seconds, 'S'),
      ],
    );
  }

  Widget _timeUnit(BuildContext context, int value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: whitePure(context).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyleCustom.unboundedSemiBold600(
                fontSize: 22, color: whitePure(context)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyleCustom.outFitLight300(
              fontSize: 10,
              color: whitePure(context).withValues(alpha: 0.7)),
        ),
      ],
    );
  }

  Widget _separator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      child: Text(
        ':',
        style: TextStyleCustom.unboundedSemiBold600(
            fontSize: 20, color: whitePure(context).withValues(alpha: 0.5)),
      ),
    );
  }
}

class _ChainParticipantsSheet extends StatelessWidget {
  final String prompt;
  final List<Map<String, dynamic>> participants;

  const _ChainParticipantsSheet(
      {required this.prompt, required this.participants});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      padding: const EdgeInsets.only(top: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textLightGrey(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                prompt,
                style: TextStyleCustom.unboundedSemiBold600(
                    fontSize: 16, color: textDarkGrey(context)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${participants.length} participant${participants.length == 1 ? '' : 's'}',
                style: TextStyleCustom.outFitLight300(
                    fontSize: 13, color: textLightGrey(context)),
              ),
            ),
            const SizedBox(height: 12),
            if (participants.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No participants yet.',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 14, color: textLightGrey(context)),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final item = participants[index];
                    final user = item['user'] as Map<String, dynamic>?;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: bgMediumGrey(context),
                        child: Text(
                          (user?['fullname'] ?? '?')[0].toUpperCase(),
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 16, color: textDarkGrey(context)),
                        ),
                      ),
                      title: Text(
                        user?['fullname'] ?? 'User',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 14, color: textDarkGrey(context)),
                      ),
                      subtitle: Text(
                        '@${user?['username'] ?? ''}',
                        style: TextStyleCustom.outFitRegular400(
                            fontSize: 13, color: textLightGrey(context)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
