import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/service/api/post_service.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class CustomAppOpenAdScreen extends StatefulWidget {
  final int postId;
  final int skipSeconds;
  final String? clickUrl;
  final VoidCallback onDismiss;

  const CustomAppOpenAdScreen({
    super.key,
    required this.postId,
    required this.skipSeconds,
    this.clickUrl,
    required this.onDismiss,
  });

  @override
  State<CustomAppOpenAdScreen> createState() => _CustomAppOpenAdScreenState();
}

class _CustomAppOpenAdScreenState extends State<CustomAppOpenAdScreen> {
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _canSkip = false;
  int _countdown = 0;
  Timer? _timer;
  Post? _post;

  @override
  void initState() {
    super.initState();
    _countdown = widget.skipSeconds;
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final model = await PostService.instance.fetchPostById(postId: widget.postId);
      if (model.status == true && model.data?.post != null) {
        _post = model.data!.post;
        final videoUrl = _post?.video?.addBaseURL();
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
          await _videoController!.initialize();
          _videoController!.setLooping(true);
          _videoController!.play();
          _startCountdown();
          if (mounted) setState(() => _isLoading = false);
        } else {
          _dismiss();
        }
      } else {
        _dismiss();
      }
    } catch (e) {
      Loggers.error('Custom app open ad error: $e');
      _dismiss();
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _canSkip = true);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
  }

  void _dismiss() {
    _timer?.cancel();
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
    widget.onDismiss();
  }

  void _onAdTap() async {
    if (widget.clickUrl != null && widget.clickUrl!.isNotEmpty) {
      final uri = Uri.tryParse(widget.clickUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (!_isLoading && _videoController != null && _videoController!.value.isInitialized)
            GestureDetector(
              onTap: _onAdTap,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          // Ad label
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ad',
                style: TextStyleCustom.outFitMedium500(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: _canSkip ? _dismiss : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  _canSkip ? 'Skip' : 'Skip in $_countdown',
                  style: TextStyleCustom.outFitMedium500(
                    color: _canSkip ? Colors.white : Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          // Click URL indicator
          if (widget.clickUrl != null && widget.clickUrl!.isNotEmpty && !_isLoading)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _onAdTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Learn More',
                      style: TextStyleCustom.outFitMedium500(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
