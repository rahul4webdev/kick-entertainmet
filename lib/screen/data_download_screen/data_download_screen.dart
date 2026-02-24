import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/data_download_screen/data_download_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class DataDownloadScreen extends StatelessWidget {
  const DataDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DataDownloadScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.downloadMyData.tr),
          Expanded(
            child: Obx(() {
              if (controller.isDataLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LKey.downloadMyDataDesc.tr,
                      style: TextStyleCustom.outFitRegular400(
                          fontSize: 14, color: textLightGrey(context)),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButtonCustom(
                        onTap: controller.requestDownload,
                        title: LKey.requestDataExport.tr,
                        backgroundColor: textDarkGrey(context),
                        titleColor: whitePure(context),
                      ),
                    ),
                    if (controller.requests.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        LKey.previousRequests.tr,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 16, color: whitePure(context)),
                      ),
                      const SizedBox(height: 12),
                      ...controller.requests.map((req) => _RequestTile(
                            controller: controller,
                            request: req,
                          )),
                    ],
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

class _RequestTile extends StatelessWidget {
  final DataDownloadScreenController controller;
  final Map<String, dynamic> request;

  const _RequestTile({required this.controller, required this.request});

  @override
  Widget build(BuildContext context) {
    final status = request['status'] as int? ?? 0;
    final statusLabel = controller.getStatusLabel(status);
    final timeLabel = controller.getTimeLabel(request['created_at']?.toString());
    final fileSize = controller.formatFileSize(request['file_size'] as int?);
    final isReady = status == 2;
    final expiresAt = request['expires_at']?.toString();

    Color statusColor;
    switch (status) {
      case 0:
      case 1:
        statusColor = Colors.orange;
        break;
      case 2:
        statusColor = Colors.green;
        break;
      case 3:
      case 4:
        statusColor = Colors.red;
        break;
      default:
        statusColor = textLightGrey(context);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgLightGrey(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isReady ? Icons.download_rounded : Icons.description_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyleCustom.outFitMedium500(
                            fontSize: 11, color: statusColor),
                      ),
                    ),
                    if (fileSize.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(fileSize,
                          style: TextStyleCustom.outFitLight300(
                              fontSize: 12, color: textLightGrey(context))),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested $timeLabel',
                  style: TextStyleCustom.outFitLight300(
                      fontSize: 12, color: textLightGrey(context)),
                ),
                if (isReady && expiresAt != null)
                  Text(
                    'Expires ${controller.getTimeLabel(expiresAt)}',
                    style: TextStyleCustom.outFitLight300(
                        fontSize: 11, color: textLightGrey(context)),
                  ),
              ],
            ),
          ),
          if (isReady)
            Icon(Icons.download_rounded,
                color: themeAccentSolid(context), size: 24),
        ],
      ),
    );
  }
}
