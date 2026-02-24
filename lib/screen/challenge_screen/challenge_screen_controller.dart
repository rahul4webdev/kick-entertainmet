import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/challenge_service.dart';
import 'package:shortzz/model/challenge/challenge_model.dart';

class ChallengeScreenController extends GetxController {
  final challenges = <Challenge>[].obs;
  final isLoading = true.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChallenges();
  }

  Future<void> fetchChallenges() async {
    isLoading.value = true;
    final result = await ChallengeService.instance.fetchChallenges(
      status: selectedTab.value == 0 ? null : selectedTab.value,
    );
    if (result.status == true && result.data != null) {
      challenges.value = result.data!;
    }
    isLoading.value = false;
  }

  void onTabChanged(int index) {
    selectedTab.value = index;
    fetchChallenges();
  }

  Future<void> onRefresh() async {
    await fetchChallenges();
  }
}

class ChallengeDetailController extends GetxController {
  final int challengeId;
  ChallengeDetailController({required this.challengeId});

  final challenge = Rxn<Challenge>();
  final entries = <ChallengeEntry>[].obs;
  final isLoading = true.obs;
  final isEntriesLoading = true.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChallenge();
    fetchEntries();
  }

  Future<void> fetchChallenge() async {
    isLoading.value = true;
    final result = await ChallengeService.instance.fetchChallengeById(
      challengeId: challengeId,
    );
    if (result.status == true && result.data != null) {
      challenge.value = result.data;
    }
    isLoading.value = false;
  }

  Future<void> fetchEntries() async {
    isEntriesLoading.value = true;
    final result = selectedTab.value == 0
        ? await ChallengeService.instance.fetchEntries(challengeId: challengeId)
        : await ChallengeService.instance.fetchLeaderboard(challengeId: challengeId);
    if (result.status == true && result.data != null) {
      entries.value = result.data!;
    }
    isEntriesLoading.value = false;
  }

  void onEntryTabChanged(int index) {
    selectedTab.value = index;
    fetchEntries();
  }

  Future<void> endChallenge() async {
    final result = await ChallengeService.instance.endChallenge(
      challengeId: challengeId,
    );
    if (result.status == true) {
      fetchChallenge();
    }
  }

  Future<void> awardPrizes() async {
    final result = await ChallengeService.instance.awardPrizes(
      challengeId: challengeId,
    );
    if (result.status == true) {
      fetchChallenge();
      fetchEntries();
    }
  }
}

class CreateChallengeController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final hashtagController = TextEditingController();
  final rulesController = TextEditingController();
  final prizeAmountController = TextEditingController();
  final startsAt = Rxn<DateTime>();
  final endsAt = Rxn<DateTime>();
  final prizeType = 0.obs;
  final isCreating = false.obs;

  Future<bool> createChallenge() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        hashtagController.text.isEmpty ||
        startsAt.value == null ||
        endsAt.value == null) {
      return false;
    }

    isCreating.value = true;
    final result = await ChallengeService.instance.createChallenge(
      title: titleController.text,
      description: descriptionController.text,
      hashtag: hashtagController.text,
      startsAt: startsAt.value!.toIso8601String(),
      endsAt: endsAt.value!.toIso8601String(),
      rules: rulesController.text.isNotEmpty ? rulesController.text : null,
      prizeType: prizeType.value,
      prizeAmount: int.tryParse(prizeAmountController.text) ?? 0,
    );
    isCreating.value = false;
    return result.status == true;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    hashtagController.dispose();
    rulesController.dispose();
    prizeAmountController.dispose();
    super.onClose();
  }
}
