import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/portfolio_service.dart';
import 'package:shortzz/model/portfolio/portfolio_model.dart';
import 'package:shortzz/utilities/const_res.dart';

class PortfolioController extends BaseController {
  Rx<Portfolio?> portfolio = Rx<Portfolio?>(null);
  RxBool isSaving = false.obs;

  final TextEditingController headlineController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController slugController = TextEditingController();

  RxString selectedTheme = 'default'.obs;
  RxBool isActive = true.obs;
  RxBool showProducts = true.obs;
  RxBool showLinks = true.obs;
  RxBool showSubscriptionCta = true.obs;

  static const themes = ['default', 'dark', 'minimal', 'vibrant', 'gradient'];

  @override
  void onInit() {
    super.onInit();
    fetchPortfolio();
  }

  @override
  void onClose() {
    headlineController.dispose();
    bioController.dispose();
    slugController.dispose();
    super.onClose();
  }

  Future<void> fetchPortfolio() async {
    isLoading.value = true;
    final result = await PortfolioService.instance.fetchMine();
    if (result.data?.portfolio != null) {
      _applyPortfolio(result.data!.portfolio!);
    }
    isLoading.value = false;
  }

  void _applyPortfolio(Portfolio p) {
    portfolio.value = p;
    headlineController.text = p.headline ?? '';
    bioController.text = p.bioOverride ?? '';
    slugController.text = p.slug ?? '';
    selectedTheme.value = p.theme ?? 'default';
    isActive.value = p.isActive ?? true;
    showProducts.value = p.showProducts ?? true;
    showLinks.value = p.showLinks ?? true;
    showSubscriptionCta.value = p.showSubscriptionCta ?? true;
  }

  Future<void> savePortfolio() async {
    isSaving.value = true;
    final result = await PortfolioService.instance.createOrUpdate(
      slug: slugController.text.trim().isNotEmpty ? slugController.text.trim() : null,
      headline: headlineController.text.trim(),
      bioOverride: bioController.text.trim(),
      theme: selectedTheme.value,
      isActive: isActive.value,
      showProducts: showProducts.value,
      showLinks: showLinks.value,
      showSubscriptionCta: showSubscriptionCta.value,
    );
    isSaving.value = false;

    if (result.status == true && result.data?.portfolio != null) {
      _applyPortfolio(result.data!.portfolio!);
      Get.snackbar('Success', 'Portfolio saved', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', result.message ?? 'Failed to save', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> addSection({
    required String sectionType,
    String? title,
    String? content,
  }) async {
    final result = await PortfolioService.instance.addSection(
      sectionType: sectionType,
      title: title,
      content: content,
    );
    if (result.status == true && result.data?.portfolio != null) {
      _applyPortfolio(result.data!.portfolio!);
    }
  }

  Future<void> updateSection({
    required int sectionId,
    String? title,
    String? content,
    bool? isVisible,
  }) async {
    final result = await PortfolioService.instance.updateSection(
      sectionId: sectionId,
      title: title,
      content: content,
      isVisible: isVisible,
    );
    if (result.status == true && result.data?.portfolio != null) {
      _applyPortfolio(result.data!.portfolio!);
    }
  }

  Future<void> removeSection(int sectionId) async {
    final result = await PortfolioService.instance.removeSection(sectionId: sectionId);
    if (result.status == true && result.data?.portfolio != null) {
      _applyPortfolio(result.data!.portfolio!);
    }
  }

  String get portfolioUrl => '${baseURL}u/${slugController.text.trim()}';
}
