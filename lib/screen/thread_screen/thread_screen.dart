import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shortzz/common/service/api/thread_service.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/post_screen/post_card.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ThreadScreen extends StatefulWidget {
  final int threadId;
  final Post? initialPost;

  const ThreadScreen({super.key, required this.threadId, this.initialPost});

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  List<Post> threadPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchThread();
  }

  Future<void> _fetchThread() async {
    final result =
        await ThreadService.instance.fetchThread(threadId: widget.threadId);
    setState(() {
      isLoading = false;
      if (result.status == true && result.posts != null) {
        threadPosts = result.posts!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: 'Thread'),
          Expanded(
            child: isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : threadPosts.isEmpty
                    ? Center(
                        child: Text(
                          'Thread not found',
                          style: TextStyleCustom.outFitRegular400(
                              fontSize: 14, color: textLightGrey(context)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: threadPosts.length,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final post = threadPosts[index];
                          final isLast = index == threadPosts.length - 1;
                          return Column(
                            children: [
                              // Thread connector line
                              if (index > 0)
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: themeAccentSolid(context)
                                      .withValues(alpha: .3),
                                ),
                              // Thread position indicator
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: themeAccentSolid(context)
                                            .withValues(alpha: .1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${index + 1}/${threadPosts.length}',
                                        style:
                                            TextStyleCustom.outFitRegular400(
                                                fontSize: 11,
                                                color:
                                                    themeAccentSolid(context)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PostCard(
                                post: post,
                                shouldShowPinOption: false,
                                likeKey: GlobalKey(),
                              ),
                              // Connector line to next post
                              if (!isLast)
                                Container(
                                  width: 2,
                                  height: 20,
                                  color: themeAccentSolid(context)
                                      .withValues(alpha: .3),
                                ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
