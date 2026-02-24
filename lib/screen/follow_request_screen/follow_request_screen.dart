import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/service/navigation/navigate_with_controller.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/common/widget/custom_divider.dart';
import 'package:shortzz/common/widget/custom_image.dart';
import 'package:shortzz/common/widget/full_name_with_blue_tick.dart';
import 'package:shortzz/common/widget/loader_widget.dart';
import 'package:shortzz/common/widget/no_data_widget.dart';
import 'package:shortzz/common/widget/text_button_custom.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/user_model/follow_request_model.dart';
import 'package:shortzz/screen/follow_request_screen/follow_request_screen_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class FollowRequestScreen extends StatelessWidget {
  const FollowRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FollowRequestScreenController());
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.followRequests.tr),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingRequests.value &&
                  controller.requests.isEmpty) {
                return const LoaderWidget();
              }
              return NoDataView(
                showShow: controller.requests.isEmpty,
                title: LKey.noFollowRequests.tr,
                child: ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.requests.length,
                  padding: const EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    FollowRequest request = controller.requests[index];
                    return _FollowRequestTile(
                      request: request,
                      onAccept: () => controller.acceptRequest(request),
                      onReject: () => controller.rejectRequest(request),
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

class _FollowRequestTile extends StatefulWidget {
  final FollowRequest request;
  final Future<void> Function() onAccept;
  final Future<void> Function() onReject;

  const _FollowRequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_FollowRequestTile> createState() => _FollowRequestTileState();
}

class _FollowRequestTileState extends State<_FollowRequestTile> {
  RxBool isAcceptLoading = false.obs;
  RxBool isRejectLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final user = widget.request.fromUser;
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    NavigationService.shared.openProfileScreen(user);
                  },
                  child: Row(
                    children: [
                      CustomImage(
                        size: const Size(40, 40),
                        fullName: user?.fullname,
                        image: user?.profilePhoto?.addBaseURL(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FullNameWithBlueTick(
                              username: user?.username ?? '',
                              isVerify: user?.isVerify,
                              fontSize: 13,
                              iconSize: 14,
                            ),
                            Text(
                              user?.fullname ?? '',
                              style: TextStyleCustom.outFitLight300(
                                  color: textLightGrey(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(() => TextButtonCustom(
                    onTap: () async {
                      if (isAcceptLoading.value || isRejectLoading.value) {
                        return;
                      }
                      isAcceptLoading.value = true;
                      await widget.onAccept();
                      isAcceptLoading.value = false;
                    },
                    title: LKey.accept.tr,
                    btnWidth: 80,
                    fontSize: 14,
                    horizontalMargin: 0,
                    btnHeight: 30,
                    titleColor: whitePure(context),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    radius: 8,
                    backgroundColor: blueFollow(context),
                    child: isAcceptLoading.value
                        ? CupertinoActivityIndicator(
                            radius: 8, color: whitePure(context))
                        : null,
                  )),
              const SizedBox(width: 5),
              Obx(() => TextButtonCustom(
                    onTap: () async {
                      if (isAcceptLoading.value || isRejectLoading.value) {
                        return;
                      }
                      isRejectLoading.value = true;
                      await widget.onReject();
                      isRejectLoading.value = false;
                    },
                    title: LKey.refuse.tr,
                    btnWidth: 80,
                    fontSize: 14,
                    horizontalMargin: 0,
                    btnHeight: 30,
                    titleColor: textLightGrey(context),
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    radius: 8,
                    backgroundColor: whitePure(context),
                    borderSide: BorderSide(color: bgGrey(context)),
                    child: isRejectLoading.value
                        ? CupertinoActivityIndicator(
                            radius: 8, color: textLightGrey(context))
                        : null,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          const CustomDivider(),
        ],
      ),
    );
  }
}
