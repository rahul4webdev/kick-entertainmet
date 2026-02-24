import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/gift_wallet/monetization_status_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class KycUploadSection extends StatelessWidget {
  final List<VerificationDoc> documents;
  final bool isUploading;
  final Function(String documentType) onUpload;

  const KycUploadSection({
    super.key,
    required this.documents,
    required this.isUploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (documents.isNotEmpty) ...[
          ...documents.map((doc) => _DocumentTile(doc: doc)),
          const SizedBox(height: 12),
        ],
        if (isUploading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(LKey.uploading.tr,
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context))),
                ],
              ),
            ),
          )
        else
          _UploadButtons(onUpload: onUpload),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final VerificationDoc doc;

  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (doc.status) {
      case 1:
        statusColor = Colors.green;
        break;
      case 2:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          side: BorderSide(color: bgGrey(context)),
          borderRadius:
              SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
        ),
        color: bgLightGrey(context),
      ),
      child: Row(
        children: [
          Icon(Icons.description, color: textLightGrey(context), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.documentType ?? '',
                  style: TextStyleCustom.outFitMedium500(
                      color: textDarkGrey(context), fontSize: 14),
                ),
                if (doc.rejectionReason != null &&
                    doc.rejectionReason!.isNotEmpty)
                  Text(
                    doc.rejectionReason!,
                    style: TextStyleCustom.outFitLight300(
                        color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              doc.statusLabel,
              style: TextStyleCustom.outFitMedium500(
                  color: statusColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadButtons extends StatelessWidget {
  final Function(String documentType) onUpload;

  const _UploadButtons({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final docTypes = [
      LKey.idCard.tr,
      LKey.passport.tr,
      LKey.driverLicense.tr,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: docTypes.map((type) {
        return InkWell(
          onTap: () => onUpload(type),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              shape: SmoothRectangleBorder(
                side: BorderSide(color: bgGrey(context)),
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
              ),
              color: bgLightGrey(context),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_file,
                    size: 20, color: textLightGrey(context)),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyleCustom.outFitRegular400(
                      color: textDarkGrey(context), fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
