import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/call_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/call/call_model.dart';
import 'package:shortzz/screen/call_screen/call_helper.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class CallHistoryController extends BaseController {
  RxList<CallRecord> calls = <CallRecord>[].obs;
  RxBool isLoadingCalls = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCalls();
  }

  Future<void> fetchCalls({bool reset = false}) async {
    isLoadingCalls.value = true;
    final lastId = reset || calls.isEmpty ? null : calls.last.id;
    final response = await CallService.instance.fetchCallHistory(lastItemId: lastId);
    if (response.status == true && response.data != null) {
      if (reset) calls.clear();
      calls.addAll(response.data!);
    }
    isLoadingCalls.value = false;
  }
}

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallHistoryController());
    final myUserId = SessionManager.instance.getUserID();

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor(context),
      body: Column(
        children: [
          CustomAppBar(title: LKey.callHistory.tr),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCalls.value && controller.calls.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.calls.isEmpty) {
                return NoDataView(
                  title: LKey.noCallHistory.tr,
                  description: LKey.noCallHistoryDesc.tr,
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchCalls(reset: true),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.calls.length,
                  itemBuilder: (context, index) {
                    final call = controller.calls[index];
                    return _CallHistoryItem(
                      call: call,
                      myUserId: myUserId,
                    );
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

class _CallHistoryItem extends StatelessWidget {
  final CallRecord call;
  final int myUserId;

  const _CallHistoryItem({required this.call, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    final isOutgoing = call.callerId == myUserId;
    // Find the other person
    CallUser? otherUser;
    if (isOutgoing) {
      final participant = call.participants?.firstWhereOrNull((p) => p.userId != myUserId);
      otherUser = participant?.user;
    } else {
      otherUser = call.caller;
    }

    final name = otherUser?.fullname ?? otherUser?.username ?? 'Unknown';
    final profile = otherUser?.profilePhoto;
    final isMissed = call.isMissed;
    final isRejected = call.isRejected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CustomImage(
            size: const Size(48, 48),
            image: profile?.addBaseURL(),
            fullName: name,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyleCustom.outFitMedium500(
                    color: isMissed ? Colors.red : textDarkGrey(context),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isOutgoing ? Icons.call_made : Icons.call_received,
                      size: 14,
                      color: isMissed || isRejected
                          ? Colors.red
                          : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(call, isOutgoing),
                      style: TextStyleCustom.outFitLight300(
                          color: textLightGrey(context), fontSize: 13),
                    ),
                    if (call.durationFormatted.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        call.durationFormatted,
                        style: TextStyleCustom.outFitLight300(
                            color: textLightGrey(context), fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Call back button
          GestureDetector(
            onTap: () {
              if (otherUser == null) return;
              CallHelper.startCall(
                userId: otherUser.id ?? 0,
                fullname: otherUser.fullname ?? '',
                username: otherUser.username,
                profilePhoto: otherUser.profilePhoto,
                callType: call.callType ?? 1,
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgGrey(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                call.isVideoCall ? Icons.videocam : Icons.call,
                color: themeAccentSolid(context),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(CallRecord call, bool isOutgoing) {
    if (call.isMissed) return LKey.missedCall.tr;
    if (call.isRejected) return LKey.callRejected.tr;
    final type = call.isVideoCall ? LKey.videoCall.tr : LKey.voiceCall.tr;
    return type;
  }
}
