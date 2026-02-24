import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';
import 'package:shortzz/model/user_model/follow_request_model.dart';

class FollowRequestScreenController extends BaseController {
  RxList<FollowRequest> requests = <FollowRequest>[].obs;
  RxBool isLoadingRequests = true.obs;
  RxBool hasMore = true.obs;
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchRequests({bool reset = false}) async {
    if (reset) {
      requests.clear();
      hasMore.value = true;
    }
    if (!hasMore.value) return;

    isLoadingRequests.value = true;
    int? lastId = requests.isEmpty ? null : requests.last.id;
    List<FollowRequest> list =
        await UserService.instance.fetchFollowRequests(lastItemId: lastId);
    if (list.isEmpty) {
      hasMore.value = false;
    } else {
      requests.addAll(list);
    }
    isLoadingRequests.value = false;
  }

  Future<void> acceptRequest(FollowRequest request) async {
    await UserService.instance.acceptFollowRequest(requestId: request.id!);
    requests.remove(request);
  }

  Future<void> rejectRequest(FollowRequest request) async {
    await UserService.instance.rejectFollowRequest(requestId: request.id!);
    requests.remove(request);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingRequests.value && hasMore.value) {
        fetchRequests();
      }
    }
  }
}
