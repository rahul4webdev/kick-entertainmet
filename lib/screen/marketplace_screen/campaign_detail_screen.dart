import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/api/marketplace_service.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/marketplace/marketplace_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CampaignDetailScreen extends StatefulWidget {
  final MarketplaceCampaign campaign;

  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  MarketplaceCampaign? detail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final response = await MarketplaceService.instance.fetchCampaignById(
        campaignId: widget.campaign.id!,
      );
      if (response.status == true && response.data != null) {
        setState(() {
          detail = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          detail = widget.campaign;
          isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        detail = widget.campaign;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          detail?.title ?? widget.campaign.title ?? '',
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 16, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const LoaderWidget()
          : RefreshIndicator(
              onRefresh: () async => _loadDetail(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandSection(context),
                    const SizedBox(height: 16),
                    _buildDetailsSection(context),
                    const SizedBox(height: 16),
                    _buildStatsSection(context),
                    if (detail?.requirements != null &&
                        detail!.requirements!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildRequirementsSection(context),
                    ],
                    if (detail?.proposals != null &&
                        detail!.proposals!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildProposalsSection(context),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final brand = detail?.brand;
    if (brand == null) return const SizedBox();
    return Container(
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
          CustomImage(
            size: const Size(40, 40),
            image: brand.profilePhoto?.addBaseURL(),
            fullName: brand.fullname,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.fullname ?? brand.username ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 15),
                ),
                Text(
                  '@${brand.username ?? ''}',
                  style: TextStyleCustom.outFitLight300(
                      color: textLightGrey(context), fontSize: 12),
                ),
              ],
            ),
          ),
          if (detail?.category != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: ShapeDecoration(
                color: themeAccentSolid(context).withValues(alpha: .1),
                shape: SmoothRectangleBorder(
                  borderRadius:
                      SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
                ),
              ),
              child: Text(
                detail!.category!,
                style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context), fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          detail?.title ?? '',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 18),
        ),
        if (detail?.description != null &&
            detail!.description!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            detail!.description!,
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
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
        children: [
          _StatRow(
            icon: Icons.monetization_on_outlined,
            label: LKey.budgetCoins,
            value: '${detail?.budgetCoins ?? 0}',
            context: context,
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.people_outline,
            label: LKey.applicationsCount,
            value: '${detail?.applicationCount ?? 0}',
            context: context,
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.check_circle_outline,
            label: LKey.acceptedCount,
            value: '${detail?.acceptedCount ?? 0}',
            context: context,
          ),
          if (detail?.minFollowers != null && detail!.minFollowers! > 0) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.trending_up,
              label: LKey.minFollowers,
              value: '${detail!.minFollowers}',
              context: context,
            ),
          ],
          if (detail?.maxCreators != null && detail!.maxCreators! > 0) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.group_outlined,
              label: LKey.maxCreators,
              value: '${detail!.maxCreators}',
              context: context,
            ),
          ],
          if (detail?.deadline != null) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.calendar_today_outlined,
              label: LKey.campaignDeadline,
              value: detail!.deadline!,
              context: context,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LKey.campaignRequirements,
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: ShapeDecoration(
            color: bgLightGrey(context),
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 14, cornerSmoothing: 1),
            ),
          ),
          child: Text(
            detail!.requirements!,
            style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context), fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${LKey.myProposals} (${detail!.proposals!.length})',
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 15),
        ),
        const SizedBox(height: 10),
        ...detail!.proposals!.map((p) => _ProposalTile(proposal: p)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final BuildContext context;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textLightGrey(context)),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context), fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyleCustom.outFitMedium500(
              color: textDarkGrey(context), fontSize: 13),
        ),
      ],
    );
  }
}

class _ProposalTile extends StatelessWidget {
  final MarketplaceProposal proposal;
  const _ProposalTile({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (proposal.status) {
      0 => Colors.orange,
      1 => Colors.green,
      2 => Colors.red,
      3 => Colors.blue,
      _ => Colors.grey,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
        ),
      ),
      child: Row(
        children: [
          if (proposal.creator != null) ...[
            CustomImage(
              size: const Size(30, 30),
              image: proposal.creator?.profilePhoto?.addBaseURL(),
              fullName: proposal.creator?.fullname,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.creator?.username ?? 'Creator',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 13),
                ),
                if (proposal.message != null && proposal.message!.isNotEmpty)
                  Text(
                    proposal.message!,
                    style: TextStyleCustom.outFitLight300(
                        color: textLightGrey(context), fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: ShapeDecoration(
                  color: statusColor.withValues(alpha: .1),
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                        cornerRadius: 6, cornerSmoothing: 1),
                  ),
                ),
                child: Text(
                  proposal.statusLabel,
                  style: TextStyleCustom.outFitMedium500(
                      color: statusColor, fontSize: 10),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${proposal.offeredCoins ?? 0} coins',
                style: TextStyleCustom.outFitLight300(
                    color: textLightGrey(context), fontSize: 11),
              ),
            ],
          ),
          // Accept/Decline for pending creator applications
          if (proposal.isPending && proposal.isFromCreator) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                _MiniActionBtn(
                  label: 'Accept',
                  color: Colors.green,
                  onTap: () async {
                    BaseController.share.showLoader();
                    final res =
                        await MarketplaceService.instance.respondToProposal(
                      proposalId: proposal.id!,
                      action: 'accept',
                    );
                    BaseController.share.stopLoader();
                    BaseController.share
                        .showSnackBar(res.message ?? 'Done');
                  },
                ),
                const SizedBox(height: 4),
                _MiniActionBtn(
                  label: 'Decline',
                  color: Colors.red,
                  onTap: () async {
                    BaseController.share.showLoader();
                    final res =
                        await MarketplaceService.instance.respondToProposal(
                      proposalId: proposal.id!,
                      action: 'decline',
                    );
                    BaseController.share.stopLoader();
                    BaseController.share
                        .showSnackBar(res.message ?? 'Done');
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: .1),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 6, cornerSmoothing: 1),
          ),
        ),
        child: Text(
          label,
          style:
              TextStyleCustom.outFitMedium500(color: color, fontSize: 10),
        ),
      ),
    );
  }
}
