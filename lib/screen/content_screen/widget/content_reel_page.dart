import 'package:flutter/material.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/ads/ima_preroll_manager.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/common/widget/black_gradient_shadow.dart';
import 'package:shortzz/common/widget/ima_preroll_overlay.dart';
import 'package:shortzz/common/widget/video_linking_overlay.dart';
import 'package:shortzz/common/widget/product_links_overlay.dart';
import 'package:shortzz/common/widget/reel_product_overlay.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// A simplified reel page for content types (Music Videos, Trailers, News)
/// Shows the video with content-specific metadata overlay.
/// Supports IMA pre-roll/mid-roll/post-roll ads.
class ContentReelPage extends StatefulWidget {
  final Post post;
  final bool autoPlay;

  const ContentReelPage({
    super.key,
    required this.post,
    this.autoPlay = false,
  });

  @override
  State<ContentReelPage> createState() => _ContentReelPageState();
}

class _ContentReelPageState extends State<ContentReelPage> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isInitialized = false;

  // IMA Ad state
  bool _showImaAd = false;
  ImaAdPlacement? _currentAdPlacement;
  int _loopCount = 0;
  bool _videoEndHandled = false;

  @override
  void initState() {
    super.initState();
    if (ImaAdManager.instance.shouldShowPreRoll()) {
      _showImaAd = true;
      _currentAdPlacement = ImaAdPlacement.preRoll;
    }
    _initVideo();
  }

  void _initVideo() {
    final videoUrl = widget.post.video?.addBaseURL();
    if (videoUrl == null || videoUrl.isEmpty) return;

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
          _videoController?.setLooping(false);
          _videoController?.addListener(_onVideoPositionChanged);
          if (widget.autoPlay) {
            if (_showImaAd) {
              setState(() {});
              return;
            }
            _videoController?.play();
            _isPlaying = true;
          }
        }
      });

    PostService.instance.increaseViewsCount(postId: widget.post.id ?? 0);
  }

  void _onVideoPositionChanged() {
    if (_videoController == null || !_isInitialized || _videoEndHandled) return;
    final value = _videoController!.value;
    if (!value.isInitialized || value.duration.inMilliseconds == 0) return;

    if (!value.isPlaying &&
        value.position.inMilliseconds >= value.duration.inMilliseconds - 300) {
      _videoEndHandled = true;
      _onVideoLoopComplete();
    }
  }

  void _onVideoLoopComplete() {
    _loopCount++;
    if (_loopCount == 1) {
      if (ImaAdManager.instance.shouldShowMidRoll()) {
        _currentAdPlacement = ImaAdPlacement.midRoll;
        _showImaAd = true;
        setState(() {});
        return;
      }
    } else {
      if (ImaAdManager.instance.shouldShowPostRoll()) {
        _currentAdPlacement = ImaAdPlacement.postRoll;
        _showImaAd = true;
        setState(() {});
        return;
      }
    }
    _restartVideo();
  }

  void _restartVideo() {
    if (!mounted || _videoController == null) return;
    _videoEndHandled = false;
    _videoController!.seekTo(Duration.zero);
    _videoController!.play();
    _isPlaying = true;
    setState(() {});
  }

  void _onImaAdComplete() {
    if (!mounted || _videoController == null) return;
    _showImaAd = false;
    _currentAdPlacement = null;
    if (_loopCount == 0) {
      _videoController!.play();
      _isPlaying = true;
      setState(() {});
    } else {
      _restartVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoPositionChanged);
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || _showImaAd) return;
    setState(() {
      if (_isPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('content-reel-${widget.post.id}'),
      onVisibilityChanged: (info) {
        if (_showImaAd) return;
        if (info.visibleFraction > 0.5) {
          _videoController?.play();
          _isPlaying = true;
        } else {
          _videoController?.pause();
          _isPlaying = false;
        }
      },
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isInitialized && _videoController != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              )
            else if (widget.post.thumbnail != null)
              Image.network(
                widget.post.thumbnail!.addBaseURL(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),

            const Positioned(
              bottom: 0, left: 0, right: 0,
              child: BlackGradientShadow(),
            ),

            Positioned(
              bottom: 80, left: 16, right: 60,
              child: _ContentMetadataOverlay(post: widget.post),
            ),

            if (!_isPlaying && _isInitialized && !_showImaAd)
              Center(
                child: Icon(Icons.play_arrow_rounded, size: 80, color: Colors.white.withValues(alpha: 0.7)),
              ),

            // Video Linking: Previous/Next Part buttons
            if (_isInitialized && !_showImaAd)
              VideoLinkingOverlay(post: widget.post),

            // Product Links overlay (external)
            if (_isInitialized && !_showImaAd)
              ProductLinksOverlay(post: widget.post),

            // Product tags overlay (in-app)
            if (_isInitialized && !_showImaAd && widget.post.productTags != null && widget.post.productTags!.isNotEmpty)
              ReelProductOverlay(post: widget.post),

            if (_showImaAd && _currentAdPlacement != null)
              ImaAdOverlay(
                adTagUrl: ImaAdManager.instance.getAdTagUrl(_currentAdPlacement!) ?? '',
                onAdComplete: _onImaAdComplete,
              ),
          ],
        ),
      ),
    );
  }
}

class _ContentMetadataOverlay extends StatelessWidget {
  final Post post;
  const _ContentMetadataOverlay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildContentBadge(),
        const SizedBox(height: 8),
        if (post.user != null)
          Row(children: [
            if (post.user?.profilePhoto != null)
              CircleAvatar(radius: 16, backgroundImage: NetworkImage(post.user!.profilePhoto!.addBaseURL())),
            const SizedBox(width: 8),
            Expanded(
              child: Text(post.user?.username ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        const SizedBox(height: 6),
        if (post.description != null && post.description!.isNotEmpty)
          Text(post.descriptionWithUserName,
              style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        _buildMetadataTags(),
      ],
    );
  }

  Widget _buildContentBadge() {
    Color badgeColor;
    String label;
    switch (post.contentType) {
      case ContentType.musicVideo:
        badgeColor = Colors.purpleAccent; label = 'MUSIC VIDEO'; break;
      case ContentType.trailer:
        badgeColor = Colors.orangeAccent; label = 'TRAILER'; break;
      case ContentType.news:
        badgeColor = Colors.redAccent; label = post.isBreaking ? 'BREAKING NEWS' : 'NEWS'; break;
      case ContentType.shortStory:
        badgeColor = Colors.tealAccent; label = 'SHORT STORY'; break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildMetadataTags() {
    List<String> tags = [];
    if (post.genre != null) tags.add(post.genre!);
    if (post.contentLanguage != null) tags.add(post.contentLanguage!);
    if (post.artistName != null) tags.add(post.artistName!);
    if (post.releaseDate != null) tags.add(post.releaseDate!);
    if (post.production != null) tags.add(post.production!);
    if (post.source != null) tags.add(post.source!);
    if (post.category != null && post.genre == null) tags.add(post.category!);
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6, runSpacing: 4,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 11)),
      )).toList(),
    );
  }
}
