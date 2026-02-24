import 'package:flutter/material.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/service/subscription/subscription_manager.dart';
import 'package:shortzz/common/widget/ima_preroll_overlay.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/content_screen/widget/content_reel_page.dart';

/// Overlay widget that shows "Previous Part" / "Next Part" buttons
/// on video posts that are linked to other parts.
class VideoLinkingOverlay extends StatefulWidget {
  final Post post;

  const VideoLinkingOverlay({super.key, required this.post});

  @override
  State<VideoLinkingOverlay> createState() => _VideoLinkingOverlayState();
}

class _VideoLinkingOverlayState extends State<VideoLinkingOverlay> {
  Post? _previousPost;
  Post? _nextPost;
  bool _loaded = false;
  bool _showTransitionAd = false;
  Post? _pendingNavTarget;

  @override
  void initState() {
    super.initState();
    _fetchLinkedPosts();
  }

  Future<void> _fetchLinkedPosts() async {
    if (widget.post.id == null) return;
    try {
      final result =
          await PostService.instance.fetchLinkedPost(postId: widget.post.id!);
      if (result.status == true && result.data != null && mounted) {
        setState(() {
          _previousPost = result.data!.previousPost;
          _nextPost = result.data!.nextPost;
          _loaded = true;
        });
      }
    } catch (_) {}
  }

  bool _shouldShowTransitionAd(Post targetPost) {
    if (isSubscribe.value) return false;
    final settings = SessionManager.instance.getSettings();
    if (settings?.partTransitionAdEnabled != true) return false;

    final startAt = settings?.partTransitionAdStartAt ?? 3;
    final interval = settings?.partTransitionAdInterval ?? 2;

    final partNumber = targetPost.episodeNumber ?? 2;
    if (partNumber < startAt) return false;
    return (partNumber - startAt) % interval == 0;
  }

  void _navigateTo(Post target) {
    if (_shouldShowTransitionAd(target)) {
      setState(() {
        _showTransitionAd = true;
        _pendingNavTarget = target;
      });
      return;
    }
    _performNavigation(target);
  }

  void _onTransitionAdComplete() {
    if (!mounted) return;
    setState(() => _showTransitionAd = false);
    if (_pendingNavTarget != null) {
      _performNavigation(_pendingNavTarget!);
      _pendingNavTarget = null;
    }
  }

  void _performNavigation(Post target) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LinkedPostPlayerScreen(post: target),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || (_previousPost == null && _nextPost == null)) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned(
          right: 12,
          bottom: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_previousPost != null)
                _PartButton(
                  icon: Icons.skip_previous_rounded,
                  label: 'Prev Part',
                  onTap: () => _navigateTo(_previousPost!),
                ),
              if (_previousPost != null && _nextPost != null)
                const SizedBox(height: 8),
              if (_nextPost != null)
                _PartButton(
                  icon: Icons.skip_next_rounded,
                  label: 'Next Part',
                  onTap: () => _navigateTo(_nextPost!),
                ),
            ],
          ),
        ),
        if (_showTransitionAd)
          ImaAdOverlay(
            adTagUrl:
                ImaAdManager.instance.getAdTagUrl(ImaAdPlacement.preRoll) ??
                    '',
            onAdComplete: _onTransitionAdComplete,
          ),
      ],
    );
  }
}

class _PartButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PartButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen player for a linked post. Reuses ContentReelPage.
class LinkedPostPlayerScreen extends StatelessWidget {
  final Post post;
  const LinkedPostPlayerScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          ContentReelPage(post: post, autoPlay: true),
          // The VideoLinkingOverlay is already inside ContentReelPage
          // so chained navigation works automatically
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
