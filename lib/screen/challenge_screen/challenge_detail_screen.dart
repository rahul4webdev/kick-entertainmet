import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/model/challenge/challenge_model.dart';
import 'package:shortzz/screen/challenge_screen/challenge_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChallengeDetailScreen extends StatelessWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ChallengeDetailController(challengeId: challengeId),
      tag: 'challenge_$challengeId',
    );

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(title: 'Challenge'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CupertinoActivityIndicator());
              }
              final challenge = controller.challenge.value;
              if (challenge == null) {
                return Center(
                  child: Text(
                    'Challenge not found',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 14, color: textLightGrey(context)),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChallengeHeader(challenge: challenge),
                    _ChallengeInfo(challenge: challenge),
                    // Creator actions
                    if (challenge.creatorId ==
                        SessionManager.instance.getUserID())
                      _CreatorActions(controller: controller),
                    const SizedBox(height: 8),
                    // Entry tabs
                    _EntryTabs(controller: controller),
                    // Entries list
                    _EntriesList(controller: controller),
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

class _ChallengeHeader extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeHeader({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: challenge.coverImage == null
            ? LinearGradient(
                colors: [
                  themeAccentSolid(context),
                  themeAccentSolid(context).withValues(alpha: .6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: challenge.coverImage != null
            ? DecorationImage(
                image: NetworkImage(challenge.coverImage!.addBaseURL()),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: .6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${challenge.hashtag ?? ''}',
                  style: TextStyleCustom.outFitBold700(
                      fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(challenge.status),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        challenge.statusLabel,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.people_outline,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.entryCount} entries',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.visibility_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.viewCount} views',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

class _ChallengeInfo extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeInfo({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title ?? '',
            style: TextStyleCustom.outFitSemiBold600(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description ?? '',
            style: TextStyleCustom.outFitRegular400(
                fontSize: 14, color: textLightGrey(context)),
          ),
          if (challenge.rules != null && challenge.rules!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Rules',
              style: TextStyleCustom.outFitSemiBold600(
                  fontSize: 15, color: textDarkGrey(context)),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.rules!,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 13, color: textLightGrey(context)),
            ),
          ],
          if (challenge.hasPrize) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: .3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Prize: ${challenge.prizeAmount} coins',
                    style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 14, color: Colors.amber.shade700),
                  ),
                  const Spacer(),
                  Text(
                    'Top 3 winners',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 12, color: Colors.amber.shade700),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Creator info
          if (challenge.creator != null)
            Row(
              children: [
                CustomImage(
                  size: const Size(28, 28),
                  image: challenge.creator?.profilePhoto?.addBaseURL(),
                  fullName: challenge.creator?.fullname,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Created by',
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 11, color: textLightGrey(context)),
                    ),
                    Text(
                      '@${challenge.creator?.username ?? ''}',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 13, color: textDarkGrey(context)),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CreatorActions extends StatelessWidget {
  final ChallengeDetailController controller;

  const _CreatorActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    final challenge = controller.challenge.value;
    if (challenge == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (challenge.isStatusActive)
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmEndChallenge(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('End Challenge'),
              ),
            ),
          if (challenge.isStatusJudging) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmAwardPrizes(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Award Prizes'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmEndChallenge(BuildContext context) {
    Get.defaultDialog(
      title: 'End Challenge',
      middleText: 'Move this challenge to judging? Entries will be locked.',
      textConfirm: 'End',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () {
        Get.back();
        controller.endChallenge();
      },
    );
  }

  void _confirmAwardPrizes(BuildContext context) {
    Get.defaultDialog(
      title: 'Award Prizes',
      middleText:
          'Award prizes to top 3 entries and complete the challenge?',
      textConfirm: 'Award',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      onConfirm: () {
        Get.back();
        controller.awardPrizes();
      },
    );
  }
}

class _EntryTabs extends StatelessWidget {
  final ChallengeDetailController controller;

  const _EntryTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildTab(context, 'Entries', 0),
              const SizedBox(width: 8),
              _buildTab(context, 'Leaderboard', 1),
            ],
          ),
        ));
  }

  Widget _buildTab(BuildContext context, String label, int index) {
    final isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.onEntryTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? themeAccentSolid(context)
              : themeAccentSolid(context).withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyleCustom.outFitMedium500(
            fontSize: 13,
            color: isSelected ? Colors.white : themeAccentSolid(context),
          ),
        ),
      ),
    );
  }
}

class _EntriesList extends StatelessWidget {
  final ChallengeDetailController controller;

  const _EntriesList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isEntriesLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CupertinoActivityIndicator()),
        );
      }
      if (controller.entries.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No entries yet',
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 14, color: textLightGrey(context)),
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: controller.entries.length,
        itemBuilder: (context, index) {
          final entry = controller.entries[index];
          return _EntryTile(entry: entry, index: index);
        },
      );
    });
  }
}

class _EntryTile extends StatelessWidget {
  final ChallengeEntry entry;
  final int index;

  const _EntryTile({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isWinner
            ? Colors.amber.withValues(alpha: .08)
            : bgLightGrey(context),
        borderRadius: BorderRadius.circular(12),
        border: entry.isWinner
            ? Border.all(color: Colors.amber.withValues(alpha: .3))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 32,
            child: Text(
              entry.rank != null ? '#${entry.rank}' : '#${index + 1}',
              style: TextStyleCustom.outFitBold700(
                fontSize: 16,
                color: _rankColor(entry.rank ?? (index + 1)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // User avatar
          CustomImage(
            size: const Size(36, 36),
            image: entry.user?.profilePhoto?.addBaseURL(),
            fullName: entry.user?.fullname,
          ),
          const SizedBox(width: 10),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user?.fullname ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 14, color: textDarkGrey(context)),
                ),
                Text(
                  '@${entry.user?.username ?? ''}',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 12, color: textLightGrey(context)),
                ),
              ],
            ),
          ),
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score}',
                style: TextStyleCustom.outFitSemiBold600(
                    fontSize: 16, color: themeAccentSolid(context)),
              ),
              Text(
                'score',
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 11, color: textLightGrey(context)),
              ),
            ],
          ),
          if (entry.isWinner) ...[
            const SizedBox(width: 8),
            Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 20),
          ],
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey;
    }
  }
}
