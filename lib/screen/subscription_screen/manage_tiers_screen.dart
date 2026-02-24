import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/subscription_service.dart';
import 'package:shortzz/model/subscription/subscription_tier_model.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ManageTiersScreen extends StatefulWidget {
  const ManageTiersScreen({super.key});

  @override
  State<ManageTiersScreen> createState() => _ManageTiersScreenState();
}

class _ManageTiersScreenState extends State<ManageTiersScreen> {
  List<SubscriptionTier> tiers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTiers();
  }

  Future<void> _loadTiers() async {
    setState(() => isLoading = true);
    try {
      final response = await SubscriptionService.instance.fetchTiers(
        creatorId: 0, // Will use auth token on backend
      );
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final tiersList = data['tiers'] as List? ?? [];
      setState(() {
        tiers = tiersList.map((e) => SubscriptionTier.fromJson(e)).toList();
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteTier(SubscriptionTier tier) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Tier'),
        content: Text('Delete "${tier.name}"? Active subscribers will not be affected.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SubscriptionService.instance.deleteTier(tierId: tier.id ?? 0);
      _loadTiers();
    }
  }

  void _showCreateEditSheet({SubscriptionTier? existing}) {
    Get.bottomSheet(
      _TierEditorSheet(
        existing: existing,
        onSaved: () => _loadTiers(),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Subscription Tiers',
          style: TextStyleCustom.outFitMedium500(
            color: blackPure(context),
            fontSize: 18,
          ),
        ),
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: blackPure(context)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tiers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AssetRes.icCrown, width: 60, height: 60),
                      const SizedBox(height: 16),
                      Text(
                        'No subscription tiers yet',
                        style: TextStyleCustom.outFitMedium500(
                          color: blackPure(context),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create tiers to let fans subscribe to you',
                        style: TextStyleCustom.outFitRegular400(
                          color: textLightGrey(context),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tiers.length,
                  itemBuilder: (context, index) {
                    final tier = tiers[index];
                    return _buildTierItem(context, tier);
                  },
                ),
      floatingActionButton: tiers.length < 3
          ? FloatingActionButton(
              onPressed: () => _showCreateEditSheet(),
              backgroundColor: themeAccentSolid(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTierItem(BuildContext context, SubscriptionTier tier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgGrey(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(AssetRes.icCrown, width: 20, height: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tier.name ?? '',
                  style: TextStyleCustom.outFitMedium500(
                    color: blackPure(context),
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${tier.priceCoins} coins/mo',
                style: TextStyleCustom.outFitMedium500(
                  color: themeAccentSolid(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (tier.description != null && tier.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              tier.description!,
              style: TextStyleCustom.outFitRegular400(
                color: textLightGrey(context),
                fontSize: 13,
              ),
            ),
          ],
          if (tier.benefits != null && tier.benefits!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...tier.benefits!.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 14, color: themeAccentSolid(context)),
                    const SizedBox(width: 6),
                    Text(
                      b,
                      style: TextStyleCustom.outFitRegular400(
                        color: blackPure(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showCreateEditSheet(existing: tier),
                child: Text(
                  'Edit',
                  style: TextStyleCustom.outFitMedium500(
                    color: themeAccentSolid(context),
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _deleteTier(tier),
                child: Text(
                  'Delete',
                  style: TextStyleCustom.outFitMedium500(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for creating or editing a subscription tier
class _TierEditorSheet extends StatefulWidget {
  final SubscriptionTier? existing;
  final VoidCallback onSaved;

  const _TierEditorSheet({this.existing, required this.onSaved});

  @override
  State<_TierEditorSheet> createState() => _TierEditorSheetState();
}

class _TierEditorSheetState extends State<_TierEditorSheet> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  List<TextEditingController> benefitControllers = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existing?.name);
    priceController = TextEditingController(
        text: widget.existing?.priceCoins?.toString());
    descController = TextEditingController(text: widget.existing?.description);

    if (widget.existing?.benefits != null) {
      for (var b in widget.existing!.benefits!) {
        benefitControllers.add(TextEditingController(text: b));
      }
    }
    if (benefitControllers.isEmpty) {
      benefitControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descController.dispose();
    for (var c in benefitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    final price = int.tryParse(priceController.text.trim());
    if (name.isEmpty || price == null || price <= 0) {
      Get.snackbar('Error', 'Name and valid price are required');
      return;
    }

    final benefits = benefitControllers
        .map((c) => c.text.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    setState(() => isSaving = true);
    try {
      if (widget.existing != null) {
        await SubscriptionService.instance.updateTier(
          tierId: widget.existing!.id!,
          name: name,
          priceCoins: price,
          description: descController.text.trim(),
          benefits: benefits,
        );
      } else {
        await SubscriptionService.instance.createTier(
          name: name,
          priceCoins: price,
          description: descController.text.trim(),
          benefits: benefits,
        );
      }
      widget.onSaved();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save tier');
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: scaffoldBackgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: bgMediumGrey(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.existing != null ? 'Edit Tier' : 'Create Tier',
                style: TextStyleCustom.outFitMedium500(
                  color: blackPure(context),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),

              // Name
              _buildTextField(context, nameController, 'Tier Name',
                  hint: 'e.g. Basic, Premium, VIP'),
              const SizedBox(height: 12),

              // Price
              _buildTextField(context, priceController, 'Monthly Price (coins)',
                  hint: 'e.g. 50', keyboardType: TextInputType.number),
              const SizedBox(height: 12),

              // Description
              _buildTextField(context, descController, 'Description (optional)',
                  hint: 'What subscribers get', maxLines: 2),
              const SizedBox(height: 16),

              // Benefits
              Text(
                'Benefits',
                style: TextStyleCustom.outFitMedium500(
                  color: blackPure(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(benefitControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          context,
                          benefitControllers[index],
                          '',
                          hint: 'Benefit ${index + 1}',
                        ),
                      ),
                      if (benefitControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              benefitControllers[index].dispose();
                              benefitControllers.removeAt(index);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
              if (benefitControllers.length < 6)
                TextButton.icon(
                  onPressed: () {
                    setState(
                        () => benefitControllers.add(TextEditingController()));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add benefit'),
                ),

              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeAccentSolid(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.existing != null ? 'Update' : 'Create',
                          style: TextStyleCustom.outFitMedium500(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyleCustom.outFitMedium500(
              color: blackPure(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyleCustom.outFitRegular400(
            color: blackPure(context),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyleCustom.outFitRegular400(
              color: textLightGrey(context),
              fontSize: 14,
            ),
            filled: true,
            fillColor: bgGrey(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
