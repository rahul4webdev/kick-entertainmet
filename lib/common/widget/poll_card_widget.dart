import 'package:flutter/material.dart';
import 'package:shortzz/common/service/api/poll_service.dart';
import 'package:shortzz/model/post_story/poll_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class PollCardWidget extends StatefulWidget {
  final Poll poll;
  final int? postId;

  const PollCardWidget({super.key, required this.poll, this.postId});

  @override
  State<PollCardWidget> createState() => _PollCardWidgetState();
}

class _PollCardWidgetState extends State<PollCardWidget> {
  late Poll _poll;
  bool _isVoting = false;

  @override
  void initState() {
    super.initState();
    _poll = widget.poll;
  }

  @override
  void didUpdateWidget(PollCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.poll != oldWidget.poll) {
      _poll = widget.poll;
    }
  }

  Future<void> _vote(PollOption option) async {
    if (_isVoting || !_poll.isActive) return;
    if (_poll.hasVoted && !_poll.allowMultiple) return;

    setState(() => _isVoting = true);

    final result = await PollService.instance.voteOnPoll(
      pollId: _poll.id!,
      optionId: option.id!,
    );

    if (result.status == true && result.data != null) {
      setState(() {
        _poll = result.data!;
        _isVoting = false;
      });
    } else {
      setState(() => _isVoting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showResults = _poll.hasVoted || !_poll.isActive;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: textLightGrey(context).withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll question
          Text(
            _poll.question ?? '',
            style: TextStyleCustom.outFitMedium500(
              fontSize: 15,
              color: textDarkGrey(context),
            ),
          ),
          const SizedBox(height: 10),
          // Options
          ...(_poll.options).map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: showResults
                    ? _PollResultBar(
                        option: option,
                        totalVotes: _poll.totalVotes,
                        isSelected: option.id == _poll.userVoteOptionId,
                        context: context,
                      )
                    : _PollOptionButton(
                        option: option,
                        onTap: () => _vote(option),
                        isVoting: _isVoting,
                        context: context,
                      ),
              )),
          // Footer: total votes + status
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${_poll.totalVotes} ${_poll.totalVotes == 1 ? 'vote' : 'votes'}',
                style: TextStyleCustom.outFitRegular400(
                  fontSize: 12,
                  color: textLightGrey(context),
                ),
              ),
              if (_poll.isClosed || (_poll.endsAt != null && !_poll.isActive)) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: textLightGrey(context).withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Closed',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 10, color: textLightGrey(context)),
                  ),
                ),
              ] else if (_poll.endsAt != null) ...[
                const SizedBox(width: 8),
                _PollCountdown(endsAt: _poll.endsAt!, context: context),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PollOptionButton extends StatelessWidget {
  final PollOption option;
  final VoidCallback onTap;
  final bool isVoting;
  final BuildContext context;

  const _PollOptionButton({
    required this.option,
    required this.onTap,
    required this.isVoting,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return InkWell(
      onTap: isVoting ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: themeAccentSolid(context), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          option.optionText ?? '',
          style: TextStyleCustom.outFitMedium500(
            fontSize: 14,
            color: themeAccentSolid(context),
          ),
        ),
      ),
    );
  }
}

class _PollResultBar extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool isSelected;
  final BuildContext context;

  const _PollResultBar({
    required this.option,
    required this.totalVotes,
    required this.isSelected,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final percentage = option.votePercentage(totalVotes);
    final percentText = '${(percentage * 100).round()}%';

    return Stack(
      children: [
        // Background bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: textLightGrey(context).withValues(alpha: .08),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: themeAccentSolid(context), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              if (isSelected) ...[
                Icon(Icons.check_circle,
                    size: 16, color: themeAccentSolid(context)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  option.optionText ?? '',
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 14,
                    color: isSelected
                        ? themeAccentSolid(context)
                        : textDarkGrey(context),
                  ),
                ),
              ),
              Text(
                percentText,
                style: TextStyleCustom.outFitMedium500(
                  fontSize: 13,
                  color: isSelected
                      ? themeAccentSolid(context)
                      : textLightGrey(context),
                ),
              ),
            ],
          ),
        ),
        // Fill bar
        Positioned.fill(
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? themeAccentSolid(context).withValues(alpha: .15)
                    : textLightGrey(context).withValues(alpha: .08),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PollCountdown extends StatelessWidget {
  final String endsAt;
  final BuildContext context;

  const _PollCountdown({required this.endsAt, required this.context});

  @override
  Widget build(BuildContext _) {
    final endTime = DateTime.tryParse(endsAt);
    if (endTime == null) return const SizedBox();

    final remaining = endTime.difference(DateTime.now());
    String text;
    if (remaining.isNegative) {
      text = 'Ended';
    } else if (remaining.inDays > 0) {
      text = '${remaining.inDays}d left';
    } else if (remaining.inHours > 0) {
      text = '${remaining.inHours}h left';
    } else {
      text = '${remaining.inMinutes}m left';
    }

    return Text(
      text,
      style: TextStyleCustom.outFitRegular400(
        fontSize: 12,
        color: textLightGrey(context),
      ),
    );
  }
}
