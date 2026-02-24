import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/comment/fetch_comment_model.dart';

class PendingCommentsScreenController extends BaseController {
  final int postId;
  RxList<Comment> pendingComments = RxList<Comment>();

  PendingCommentsScreenController(this.postId);

  @override
  void onInit() {
    super.onInit();
    fetchPendingComments();
  }

  Future<void> fetchPendingComments({bool isEmpty = false}) async {
    isLoading.value = true;
    List<Comment> comments = await PostService.instance.fetchPendingComments(
      postId: postId,
      lastItemId: isEmpty ? null : pendingComments.lastOrNull?.id?.toInt(),
    );
    if (isEmpty) pendingComments.clear();
    pendingComments.addAll(comments);
    isLoading.value = false;
  }

  Future<void> approveComment(Comment comment) async {
    final result = await PostService.instance
        .approveComment(commentId: comment.id?.toInt() ?? -1);
    if (result.status == true) {
      pendingComments.removeWhere((c) => c.id == comment.id);
    }
  }

  Future<void> rejectComment(Comment comment) async {
    final result = await PostService.instance
        .rejectComment(commentId: comment.id?.toInt() ?? -1);
    if (result.status == true) {
      pendingComments.removeWhere((c) => c.id == comment.id);
    }
  }
}
