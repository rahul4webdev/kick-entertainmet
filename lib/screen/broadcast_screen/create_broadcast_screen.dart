import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/service/api/broadcast_service.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CreateBroadcastScreen extends StatefulWidget {
  const CreateBroadcastScreen({super.key});

  @override
  State<CreateBroadcastScreen> createState() => _CreateBroadcastScreenState();
}

class _CreateBroadcastScreenState extends State<CreateBroadcastScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);

    final channel = await BroadcastService.instance.createChannel(
      name: name,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    setState(() => _isCreating = false);

    if (channel != null) {
      Get.back(result: true);
      Get.snackbar(
        LKey.channelCreated.tr,
        channel.name ?? '',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LKey.createChannel.tr,
          style: TextStyleCustom.unboundedMedium500(
            fontSize: 15,
            color: textDarkGrey(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: scaffoldBackgroundColor(context),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LKey.channelName.tr,
              style: TextStyleCustom.outFitMedium500(
                fontSize: 14,
                color: textDarkGrey(context),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: LKey.channelName.tr,
                hintStyle: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context),
                ),
                filled: true,
                fillColor: bgGrey(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              LKey.channelDescription.tr,
              style: TextStyleCustom.outFitMedium500(
                fontSize: 14,
                color: textDarkGrey(context),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLength: 1000,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: LKey.channelDescription.tr,
                hintStyle: TextStyleCustom.outFitRegular400(
                  color: textLightGrey(context),
                ),
                filled: true,
                fillColor: bgGrey(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
              style: TextStyleCustom.outFitRegular400(
                color: textDarkGrey(context),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isCreating ? null : _onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeAccentSolid(context),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: whitePure(context),
                      ),
                    )
                  : Text(
                      LKey.createChannel.tr,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 15,
                        color: whitePure(context),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
