import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_back_button.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/screen/seller_kyc_screen/seller_kyc_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class SellerKycScreen extends StatelessWidget {
  const SellerKycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SellerKycController());
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(
          image: AssetRes.icBackArrow_1,
          height: 25,
          width: 25,
          padding: EdgeInsets.zero,
        ),
        title: Text(
          'Seller Verification',
          style: TextStyleCustom.unboundedMedium500(
              fontSize: 18, color: textDarkGrey(context)),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingApplication.value) {
          return const LoaderWidget();
        }

        final app = controller.application.value;

        // Already submitted — show status
        if (app != null) {
          return _ApplicationStatus(controller: controller);
        }

        // New application form
        return _ApplicationForm(controller: controller);
      }),
    );
  }
}

// ─── Application Status ─────────────────────────────────────

class _ApplicationStatus extends StatelessWidget {
  final SellerKycController controller;
  const _ApplicationStatus({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final app = controller.application.value!;
      final statusColor = app.isPending
          ? Colors.orange
          : app.isApproved
              ? Colors.green
              : Colors.red;
      final statusText = app.isPending
          ? 'Under Review'
          : app.isApproved
              ? 'Approved'
              : 'Rejected';
      final statusIcon = app.isPending
          ? Icons.hourglass_top_rounded
          : app.isApproved
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: statusColor.withValues(alpha: .08),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                      cornerRadius: 16, cornerSmoothing: 1),
                  side: BorderSide(
                      color: statusColor.withValues(alpha: .3), width: 1),
                ),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 48, color: statusColor),
                  const SizedBox(height: 12),
                  Text(
                    statusText,
                    style: TextStyleCustom.unboundedSemiBold600(
                        color: statusColor, fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.isPending
                        ? 'Your application is being reviewed. This usually takes 1-2 business days.'
                        : app.isApproved
                            ? 'You are verified! You can now list products and receive orders.'
                            : 'Your application was rejected. Please review and resubmit.',
                    textAlign: TextAlign.center,
                    style: TextStyleCustom.outFitRegular400(
                        color: statusColor.withValues(alpha: .8), fontSize: 13),
                  ),
                  if (app.isRejected && app.rejectionReason != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        color: Colors.red.withValues(alpha: .05),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1),
                        ),
                      ),
                      child: Text(
                        'Reason: ${app.rejectionReason}',
                        style: TextStyleCustom.outFitRegular400(
                            color: Colors.red.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Application details
            _DetailCard(
              title: 'Business Details',
              children: [
                _DetailRow('Business Name', app.businessName ?? '-'),
                _DetailRow('Business Type', app.businessType ?? '-'),
                _DetailRow('PAN', app.pan ?? '-'),
                if (app.gstin != null && app.gstin!.isNotEmpty)
                  _DetailRow('GSTIN', app.gstin!),
              ],
            ),
            const SizedBox(height: 12),

            if (app.businessAddress != null) ...[
              _DetailCard(
                title: 'Business Address',
                children: [
                  _DetailRow('Address', app.businessAddress ?? '-'),
                  _DetailRow('City', app.businessCity ?? '-'),
                  _DetailRow('State', app.businessState ?? '-'),
                  _DetailRow('Pincode', app.businessPincode ?? '-'),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Bank details section (editable even after submission)
            _DetailCard(
              title: 'Bank Details',
              children: [
                if (app.bankAccountNumber != null &&
                    app.bankAccountNumber!.isNotEmpty) ...[
                  _DetailRow('Account', app.bankAccountNumber!),
                  _DetailRow('IFSC', app.bankIfsc ?? '-'),
                  _DetailRow('Holder', app.bankAccountHolderName ?? '-'),
                ] else ...[
                  Text(
                    'Add bank details to receive payouts',
                    style: TextStyleCustom.outFitRegular400(
                        color: textLightGrey(context), fontSize: 13),
                  ),
                ],
                const SizedBox(height: 12),
                _KycTextField(
                  controller: controller.accountNumberController,
                  label: 'Account Number',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                _KycTextField(
                  controller: controller.ifscController,
                  label: 'IFSC Code',
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 10),
                _KycTextField(
                  controller: controller.accountHolderController,
                  label: 'Account Holder Name',
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: 'Update Bank Details',
                  onTap: controller.updateBankDetails,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Resubmit if rejected
            if (app.isRejected) ...[
              _PrimaryButton(
                label: 'Resubmit Application',
                onTap: () {
                  controller.application.value = null;
                },
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }
}

// ─── Application Form ───────────────────────────────────────

class _ApplicationForm extends StatelessWidget {
  final SellerKycController controller;
  const _ApplicationForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: ShapeDecoration(
              color: Colors.blue.withValues(alpha: .06),
              shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
                side: BorderSide(
                    color: Colors.blue.withValues(alpha: .2), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complete your KYC to start selling on the marketplace. PAN is mandatory.',
                    style: TextStyleCustom.outFitRegular400(
                        color: Colors.blue.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Business Details
          _SectionTitle('Business Details'),
          const SizedBox(height: 10),
          _KycTextField(
            controller: controller.businessNameController,
            label: 'Business / Store Name *',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          // Business type selector
          Text(
            'Business Type',
            style: TextStyleCustom.outFitMedium500(
                color: textDarkGrey(context), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.businessTypes.map((type) {
                  final isSelected =
                      controller.selectedBusinessType.value == type['value'];
                  return GestureDetector(
                    onTap: () => controller.selectedBusinessType.value =
                        type['value']!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? themeAccentSolid(context).withValues(alpha: .1)
                            : bgLightGrey(context),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1),
                          side: BorderSide(
                            color: isSelected
                                ? themeAccentSolid(context)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        type['label']!,
                        style: TextStyleCustom.outFitMedium500(
                          color: isSelected
                              ? themeAccentSolid(context)
                              : textLightGrey(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
          const SizedBox(height: 12),

          _KycTextField(
            controller: controller.panController,
            label: 'PAN Number *',
            textCapitalization: TextCapitalization.characters,
            maxLength: 10,
          ),
          const SizedBox(height: 12),
          _KycTextField(
            controller: controller.gstinController,
            label: 'GSTIN (optional)',
            textCapitalization: TextCapitalization.characters,
            maxLength: 15,
          ),

          const SizedBox(height: 24),

          // Business Address
          _SectionTitle('Business Address (Optional)'),
          const SizedBox(height: 10),
          _KycTextField(
            controller: controller.addressController,
            label: 'Address Line',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KycTextField(
                  controller: controller.cityController,
                  label: 'City',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KycTextField(
                  controller: controller.stateController,
                  label: 'State',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _KycTextField(
            controller: controller.pincodeController,
            label: 'Pincode',
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),

          const SizedBox(height: 24),

          // Documents
          _SectionTitle('Upload Documents'),
          const SizedBox(height: 6),
          Text(
            'PAN card, GSTIN certificate, address proof, etc.',
            style: TextStyleCustom.outFitLight300(
                color: textLightGrey(context), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Obx(() => Column(
                children: [
                  if (controller.documents.isNotEmpty)
                    ...controller.documents.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: ShapeDecoration(
                            color: bgLightGrey(context),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                  cornerRadius: 8, cornerSmoothing: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.insert_drive_file_outlined,
                                  size: 18, color: textLightGrey(context)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.value.name,
                                  style: TextStyleCustom.outFitRegular400(
                                      color: textDarkGrey(context),
                                      fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeDocument(entry.key),
                                child: Icon(Icons.close,
                                    size: 16, color: Colors.red.shade400),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  GestureDetector(
                    onTap: controller.pickDocuments,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1),
                          side: BorderSide(
                            color: textLightGrey(context).withValues(alpha: .4),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 20, color: textLightGrey(context)),
                          const SizedBox(width: 8),
                          Text(
                            'Add Documents',
                            style: TextStyleCustom.outFitMedium500(
                                color: textLightGrey(context), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),

          const SizedBox(height: 30),

          // Submit button
          _PrimaryButton(
            label: 'Submit Application',
            onTap: controller.submitApplication,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleCustom.unboundedMedium500(
          color: textDarkGrey(context), fontSize: 15),
    );
  }
}

class _KycTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final int maxLines;

  const _KycTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: bgLightGrey(context),
        shape: SmoothRectangleBorder(
          borderRadius:
              SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        maxLines: maxLines,
        style: TextStyleCustom.outFitRegular400(
            color: textDarkGrey(context), fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyleCustom.outFitLight300(
              color: textLightGrey(context), fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          counterText: '',
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Text(
            title,
            style: TextStyleCustom.unboundedMedium500(
                color: textDarkGrey(context), fontSize: 14),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyleCustom.outFitLight300(
                  color: textLightGrey(context), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyleCustom.outFitRegular400(
                  color: textDarkGrey(context), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: ShapeDecoration(
          color: themeAccentSolid(context),
          shape: SmoothRectangleBorder(
            borderRadius:
                SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 1),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyleCustom.outFitMedium500(
              color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
