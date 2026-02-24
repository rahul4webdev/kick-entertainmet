import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/my_refresh_indicator.dart';
import 'package:shortzz/model/challenge/challenge_model.dart';
import 'package:shortzz/screen/challenge_screen/challenge_detail_screen.dart';
import 'package:shortzz/screen/challenge_screen/challenge_screen_controller.dart';
import 'package:shortzz/screen/challenge_screen/create_challenge_screen.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChallengeScreenController());

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'Challenges',
            rowWidget: GestureDetector(
              onTap: () => Get.to(() => const CreateChallengeScreen()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeAccentSolid(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Create',
                  style: TextStyleCustom.outFitSemiBold600(
                      fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ),
          // Tab bar
          Obx(() => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _TabChip(
                      label: 'All',
                      isSelected: controller.selectedTab.value == 0,
                      onTap: () => controller.onTabChanged(0),
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Active',
                      isSelected: controller.selectedTab.value == 1,
                      onTap: () => controller.onTabChanged(1),
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Completed',
                      isSelected: controller.selectedTab.value == 4,
                      onTap: () => controller.onTabChanged(4),
                    ),
                  ],
                ),
              )),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (controller.challenges.isEmpty) {
                return Center(
                  child: Text(
                    'No challenges yet',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 14, color: textLightGrey(context)),
                  ),
                );
              }
              return MyRefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.challenges.length,
                  itemBuilder: (context, index) {
                    return _ChallengeCard(
                        challenge: controller.challenges[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(
        () => ChallengeDetailScreen(challengeId: challenge.id!),
        preventDuplicates: false,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: bgLightGrey(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeAccentSolid(context).withValues(alpha: .1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image or gradient header
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
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
                        image: NetworkImage(
                            challenge.coverImage!.addBaseURL()),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(challenge.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        challenge.statusLabel,
                        style: TextStyleCustom.outFitSemiBold600(
                            fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                  if (challenge.isFeatured)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  // Hashtag overlay
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Text(
                      '#${challenge.hashtag ?? ''}',
                      style: TextStyleCustom.outFitBold700(
                          fontSize: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title ?? '',
                    style: TextStyleCustom.outFitSemiBold600(
                        fontSize: 16, color: textDarkGrey(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description ?? '',
                    style: TextStyleCustom.outFitRegular400(
                        fontSize: 13, color: textLightGrey(context)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Creator
                      if (challenge.creator != null) ...[
                        CustomImage(
                          size: const Size(20, 20),
                          image: challenge.creator?.profilePhoto?.addBaseURL(),
                          fullName: challenge.creator?.fullname,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '@${challenge.creator?.username ?? ''}',
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 12, color: textLightGrey(context)),
                        ),
                        const Spacer(),
                      ],
                      // Entry count
                      Icon(Icons.people_outline,
                          size: 16, color: textLightGrey(context)),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.entryCount}',
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 12, color: textLightGrey(context)),
                      ),
                      if (challenge.hasPrize) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.emoji_events_outlined,
                            size: 16, color: Colors.amber.shade700),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.prizeAmount} coins',
                          style: TextStyleCustom.outFitMedium500(
                              fontSize: 12, color: Colors.amber.shade700),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
