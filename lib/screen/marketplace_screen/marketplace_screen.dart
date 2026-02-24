import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/marketplace/marketplace_model.dart';
import 'package:shortzz/screen/marketplace_screen/marketplace_controller.dart';
import 'package:shortzz/screen/marketplace_screen/campaign_detail_screen.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MarketplaceController());
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: const CustomBackButton(
            image: AssetRes.icBackArrow_1,
            height: 25,
            width: 25,
            padding: EdgeInsets.zero,
          ),
          title: Text(
            LKey.creatorMarketplace,
            style: TextStyleCustom.unboundedMedium500(
                fontSize: 18, color: textDarkGrey(context)),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: TextStyleCustom.outFitMedium500(fontSize: 13),
            unselectedLabelStyle:
                TextStyleCustom.outFitRegular400(fontSize: 13),
            labelColor: themeAccentSolid(context),
            unselectedLabelColor: textLightGrey(context),
            indicatorColor: themeAccentSolid(context),
            tabs: [
              Tab(text: LKey.browseCampaigns),
              Tab(text: LKey.myCampaigns),
              Tab(text: LKey.myProposals),
            ],
            onTap: (index) {
              if (index == 1 && controller.myCampaigns.isEmpty) {
                controller.fetchMyCampaigns();
              } else if (index == 2 && controller.myProposals.isEmpty) {
                controller.fetchMyProposals();
              }
            },
          ),
        ),
        body: TabBarView(
          children: [
            _BrowseCampaignsTab(controller: controller),
            _MyCampaignsTab(controller: controller),
            _MyProposalsTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ─── Browse Campaigns Tab ──────────────────────────────────

class _BrowseCampaignsTab extends StatelessWidget {
  final MarketplaceController controller;
  const _BrowseCampaignsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCampaigns.value && controller.campaigns.isEmpty) {
        return const LoaderWidget();
      }
      return Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              decoration: ShapeDecoration(
                color: bgLightGrey(context),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                ),
              ),
              child: TextField(
                onChanged: (v) => controller.onSearchChanged(v),
                style: TextStyleCustom.outFitRegular400(
                    fontSize: 14, color: textDarkGrey(context)),
                decoration: InputDecoration(
                  hintText: LKey.searchCampaigns,
                  hintStyle: TextStyleCustom.outFitLight300(
                      fontSize: 14, color: textLightGrey(context)),
                  prefixIcon:
                      Icon(Icons.search, color: textLightGrey(context)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: NoDataView(
              showShow: !controller.isLoadingCampaigns.value &&
                  controller.campaigns.isEmpty,
              title: LKey.noCampaigns,
              description: LKey.noCampaignsDesc,
              child: RefreshIndicator(
                onRefresh: () async =>
                    controller.fetchCampaigns(reset: true),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.campaigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _CampaignCard(
                      campaign: controller.campaigns[index],
                      controller: controller,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _CampaignCard extends StatelessWidget {
  final MarketplaceCampaign campaign;
  final MarketplaceController controller;

  const _CampaignCard({required this.campaign, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CampaignDetailScreen(campaign: campaign));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand info row
            if (campaign.brand != null)
              Row(
                children: [
                  CustomImage(
                    size: const Size(28, 28),
                    image: campaign.brand?.profilePhoto?.addBaseURL(),
                    fullName: campaign.brand?.fullname,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      campaign.brand?.username ?? '',
                      style: TextStyleCustom.outFitMedium500(
                          color: textDarkGrey(context), fontSize: 13),
                    ),
                  ),
                  if (campaign.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: ShapeDecoration(
                        color: themeAccentSolid(context).withValues(alpha: .1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 8, cornerSmoothing: 1),
                        ),
                      ),
                      child: Text(
                        campaign.category!,
                        style: TextStyleCustom.outFitMedium500(
                            color: themeAccentSolid(context), fontSize: 10),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            // Title
            Text(
              campaign.title ?? '',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (campaign.description != null &&
                campaign.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                campaign.description!,
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Stats row
            Row(
              children: [
                Icon(Icons.monetization_on_outlined,
                    size: 14, color: themeAccentSolid(context)),
                const SizedBox(width: 3),
                Text(
                  '${campaign.budgetCoins ?? 0}',
                  style: TextStyleCustom.outFitMedium500(
                      color: themeAccentSolid(context), fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.people_outline,
                    size: 14, color: textLightGrey(context)),
                const SizedBox(width: 3),
                Text(
                  '${campaign.applicationCount ?? 0} ${LKey.applicationsCount}',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 11),
                ),
                const Spacer(),
                if (campaign.hasApplied == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: Colors.green.withValues(alpha: .1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1),
                      ),
                    ),
                    child: Text(
                      LKey.applied,
                      style: TextStyleCustom.outFitMedium500(
                          color: Colors.green, fontSize: 11),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showApplySheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: ShapeDecoration(
                        color: themeAccentSolid(context),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 8, cornerSmoothing: 1),
                        ),
                      ),
                      child: Text(
                        LKey.applyNow,
                        style: TextStyleCustom.outFitMedium500(
                            color: whitePure(context), fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showApplySheet(BuildContext context) {
    final msgController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${LKey.applyNow} - ${campaign.title}',
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgController,
              maxLines: 3,
              style: TextStyleCustom.outFitRegular400(
                  fontSize: 14, color: textDarkGrey(context)),
              decoration: InputDecoration(
                hintText: 'Why are you a good fit? (optional)',
                hintStyle: TextStyleCustom.outFitLight300(
                    fontSize: 14, color: textLightGrey(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: bgMediumGrey(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: bgMediumGrey(context)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.applyToCampaign(
                    campaign.id!,
                    message: msgController.text.isNotEmpty
                        ? msgController.text
                        : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  foregroundColor: whitePure(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(LKey.applyNow),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── My Campaigns Tab ──────────────────────────────────────

class _MyCampaignsTab extends StatelessWidget {
  final MarketplaceController controller;
  const _MyCampaignsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingMyCampaigns.value &&
          controller.myCampaigns.isEmpty) {
        return const LoaderWidget();
      }
      return Stack(
        children: [
          NoDataView(
            showShow: !controller.isLoadingMyCampaigns.value &&
                controller.myCampaigns.isEmpty,
            title: LKey.noMyCampaigns,
            description: LKey.noMyCampaignsDesc,
            child: RefreshIndicator(
              onRefresh: () async => controller.fetchMyCampaigns(),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                itemCount: controller.myCampaigns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _MyCampaignRow(
                    campaign: controller.myCampaigns[index],
                    controller: controller,
                  );
                },
              ),
            ),
          ),
          // FAB for creating campaign
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateCampaignSheet(context, controller),
              backgroundColor: themeAccentSolid(context),
              foregroundColor: whitePure(context),
              icon: const Icon(Icons.add),
              label: Text(LKey.createCampaign),
            ),
          ),
        ],
      );
    });
  }
}

void _showCreateCampaignSheet(
    BuildContext context, MarketplaceController controller) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final minFollowersCtrl = TextEditingController();
  final maxCreatorsCtrl = TextEditingController();
  final requirementsCtrl = TextEditingController();

  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(20),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LKey.createCampaign,
              style: TextStyleCustom.outFitMedium500(
                  color: textDarkGrey(context), fontSize: 18),
            ),
            const SizedBox(height: 16),
            _SheetField(
              controller: titleCtrl,
              hint: LKey.campaignTitle,
              context: context,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: descCtrl,
              hint: LKey.campaignDescription,
              maxLines: 3,
              context: context,
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: budgetCtrl,
              hint: LKey.budgetCoins,
              keyboardType: TextInputType.number,
              context: context,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SheetField(
                    controller: minFollowersCtrl,
                    hint: LKey.minFollowers,
                    keyboardType: TextInputType.number,
                    context: context,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SheetField(
                    controller: maxCreatorsCtrl,
                    hint: LKey.maxCreators,
                    keyboardType: TextInputType.number,
                    context: context,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SheetField(
              controller: requirementsCtrl,
              hint: LKey.campaignRequirements,
              maxLines: 2,
              context: context,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.isEmpty || budgetCtrl.text.isEmpty) return;
                  Get.back();
                  controller.createCampaign(
                    title: titleCtrl.text,
                    budgetCoins: int.tryParse(budgetCtrl.text) ?? 0,
                    description: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                    minFollowers:
                        int.tryParse(minFollowersCtrl.text),
                    maxCreators: int.tryParse(maxCreatorsCtrl.text),
                    requirements: requirementsCtrl.text.isNotEmpty
                        ? requirementsCtrl.text
                        : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeAccentSolid(context),
                  foregroundColor: whitePure(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(LKey.createCampaign),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final BuildContext context;

  const _SheetField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyleCustom.outFitRegular400(
          fontSize: 14, color: textDarkGrey(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyleCustom.outFitLight300(
            fontSize: 14, color: textLightGrey(context)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bgMediumGrey(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: bgMediumGrey(context)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _MyCampaignRow extends StatelessWidget {
  final MarketplaceCampaign campaign;
  final MarketplaceController controller;

  const _MyCampaignRow({required this.campaign, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (campaign.status) {
      1 => Colors.grey,
      2 => Colors.green,
      3 => Colors.orange,
      4 => Colors.blue,
      5 => Colors.red,
      _ => Colors.grey,
    };

    return GestureDetector(
      onTap: () => Get.to(() => CampaignDetailScreen(campaign: campaign)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: bgLightGrey(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campaign.title ?? '',
                    style: TextStyleCustom.outFitMedium500(
                        color: textDarkGrey(context), fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: ShapeDecoration(
                          color: statusColor.withValues(alpha: .1),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                                cornerRadius: 6, cornerSmoothing: 1),
                          ),
                        ),
                        child: Text(
                          campaign.statusLabel,
                          style: TextStyleCustom.outFitMedium500(
                              color: statusColor, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${campaign.applicationCount ?? 0} ${LKey.applicationsCount}',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${campaign.acceptedCount ?? 0} ${LKey.acceptedCount}',
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.withValues(alpha: .7), size: 20),
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Campaign?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteCampaign(campaign.id!);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── My Proposals Tab ──────────────────────────────────────

class _MyProposalsTab extends StatelessWidget {
  final MarketplaceController controller;
  const _MyProposalsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingProposals.value &&
          controller.myProposals.isEmpty) {
        return const LoaderWidget();
      }
      return NoDataView(
        showShow: !controller.isLoadingProposals.value &&
            controller.myProposals.isEmpty,
        title: LKey.noProposals,
        description: LKey.noProposalsDesc,
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchMyProposals(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.myProposals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _ProposalRow(
                proposal: controller.myProposals[index],
                controller: controller,
              );
            },
          ),
        ),
      );
    });
  }
}

class _ProposalRow extends StatelessWidget {
  final MarketplaceProposal proposal;
  final MarketplaceController controller;

  const _ProposalRow({required this.proposal, required this.controller});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (proposal.status) {
      0 => Colors.orange,
      1 => Colors.green,
      2 => Colors.red,
      3 => Colors.blue,
      4 => Colors.grey,
      _ => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.campaign?.title ?? 'Campaign',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: .1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 8, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  proposal.statusLabel,
                  style: TextStyleCustom.outFitMedium500(
                      color: statusColor, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (proposal.brand != null) ...[
                CustomImage(
                  size: const Size(18, 18),
                  image: proposal.brand?.profilePhoto?.addBaseURL(),
                  fullName: proposal.brand?.fullname,
                ),
                const SizedBox(width: 6),
                Text(
                  proposal.brand?.username ?? '',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
                const SizedBox(width: 12),
              ],
              Icon(Icons.monetization_on_outlined,
                  size: 13, color: themeAccentSolid(context)),
              const SizedBox(width: 3),
              Text(
                '${proposal.offeredCoins ?? 0}',
                style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context), fontSize: 12),
              ),
              const Spacer(),
              Text(
                proposal.isFromBrand ? 'Invitation' : 'Application',
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 11),
              ),
            ],
          ),
          // If it's a brand invitation that's pending, show accept/decline
          if (proposal.isPending && proposal.isFromBrand) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () =>
                      controller.respondToProposal(proposal.id!, 'accept'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: ShapeDecoration(
                      color: Colors.green.withValues(alpha: .1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyleCustom.outFitMedium500(
                          color: Colors.green, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () =>
                      controller.respondToProposal(proposal.id!, 'decline'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: ShapeDecoration(
                      color: Colors.red.withValues(alpha: .1),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                            cornerRadius: 8, cornerSmoothing: 1),
                      ),
                    ),
                    child: Text(
                      'Decline',
                      style: TextStyleCustom.outFitMedium500(
                          color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
