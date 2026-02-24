import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:retrytech_plugin/retrytech_plugin.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:video_player/video_player.dart';

/// Records user's response after viewing the selected stitch clip.
/// Flow: plays source clip first (preview), then camera records the response.
class StitchRecordingScreen extends StatefulWidget {
  final Post sourcePost;
  final int clipStartMs;
  final int clipEndMs;

  const StitchRecordingScreen({
    super.key,
    required this.sourcePost,
    required this.clipStartMs,
    required this.clipEndMs,
  });

  @override
  State<StitchRecordingScreen> createState() => _StitchRecordingScreenState();
}

class _StitchRecordingScreenState extends State<StitchRecordingScreen> {
  VideoPlayerController? _sourceVideoController;
  bool _sourceInitialized = false;
  bool _isDisposed = false;

  // States: preview -> recording -> done
  bool _isPreviewingClip = true;
  bool _isRecording = false;
  bool _isStarted = false;
  double _progress = 0.0;
  Timer? _timer;

  int get _clipDurationMs => widget.clipEndMs - widget.clipStartMs;
  static const int _maxRecordingMs = 60000; // 60 seconds max

  @override
  void initState() {
    super.initState();
    _initSourceVideo();
    _initCamera();
  }

  Future<void> _initSourceVideo() async {
    try {
      final url = Uri.parse(widget.sourcePost.video?.addBaseURL() ?? '');
      _sourceVideoController = VideoPlayerController.networkUrl(url);
      await _sourceVideoController!.initialize();
      if (_isDisposed) return;
      _sourceVideoController!.setLooping(false);
      _sourceInitialized = true;

      // Seek to clip start and play the clip preview
      await _sourceVideoController!
          .seekTo(Duration(milliseconds: widget.clipStartMs));
      _sourceVideoController!.play();
      _startClipPreviewTimer();
      setState(() {});
    } catch (e) {
      Loggers.error('Stitch source video init error: $e');
    }
  }

  void _initCamera() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isDisposed) return;
      RetrytechPlugin.shared.initCamera();
    });
  }

  void _startClipPreviewTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      final pos = _sourceVideoController?.value.position ?? Duration.zero;
      final clipEnd = Duration(milliseconds: widget.clipEndMs);
      _progress = (pos.inMilliseconds - widget.clipStartMs) / _clipDurationMs;

      if (pos >= clipEnd) {
        timer.cancel();
        _sourceVideoController?.pause();
        _isPreviewingClip = false;
        _progress = 0.0;
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _sourceVideoController?.dispose();
    RetrytechPlugin.shared.disposeCamera;
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isRecording || _isPreviewingClip) return;

    try {
      RetrytechPlugin.shared.startRecording;
      _isRecording = true;
      _isStarted = true;
      _startRecordingTimer();
      setState(() {});
    } catch (e) {
      Loggers.error('Stitch recording start error: $e');
    }
  }

  void _startRecordingTimer() {
    _timer?.cancel();
    final startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      _progress = elapsed / _maxRecordingMs;

      if (elapsed >= _maxRecordingMs) {
        timer.cancel();
        _stopRecording();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _stopRecording() async {
    if (!_isStarted) return;

    try {
      _timer?.cancel();
      _isRecording = false;
      _isStarted = false;
      _progress = 0;
      setState(() {});

      final String? videoPath = await RetrytechPlugin.shared.stopRecording;
      if (videoPath == null) {
        Get.snackbar('Error', 'Recording file not found',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final XFile thumbnailPath =
          await MediaPickerHelper.shared.extractThumbnail(videoPath: videoPath);

      final content = PostStoryContent(
        type: PostStoryContentType.reel,
        content: videoPath,
        thumbNail: thumbnailPath.path,
        stitchSourcePostId: widget.sourcePost.id,
        stitchStartMs: widget.clipStartMs,
        stitchEndMs: widget.clipEndMs,
      );

      RetrytechPlugin.shared.disposeCamera;

      await Get.to(() => CameraEditScreen(content: content));
    } catch (e) {
      Loggers.error('Stitch recording stop error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Main view
            _isPreviewingClip ? _buildClipPreview() : _buildCameraView(),

            // Top bar
            _buildTopBar(),

            // Progress bar
            if (_isPreviewingClip || _isStarted) _buildProgressBar(),

            // Bottom controls
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClipPreview() {
    if (!_sourceInitialized || _sourceVideoController == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    final size = _sourceVideoController!.value.size;
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: VideoPlayer(_sourceVideoController!),
          ),
        ),
        // "Playing clip" overlay
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Playing clip from @${widget.sourcePost.user?.username ?? ''}...',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 13, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        RetrytechPlugin.shared.cameraView,
        if (!_isStarted)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Now record your response',
                  style: TextStyleCustom.outFitMedium500(
                      fontSize: 13, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
            const Spacer(),
            if (!_isPreviewingClip)
              InkWell(
                onTap: () => RetrytechPlugin.shared.toggleCamera,
                child: Image.asset(AssetRes.icCameraFlip,
                    width: 28, height: 28, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        value: _progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(
          _isPreviewingClip ? Colors.blue : Colors.red,
        ),
        minHeight: 3,
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isPreviewingClip)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Watch the clip, then record your response',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 13, color: Colors.white70),
                ),
              ),
            if (!_isPreviewingClip && !_isStarted)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Tap to start recording',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 13, color: Colors.white70),
                ),
              ),
            // Record button (hidden during clip preview)
            if (!_isPreviewingClip)
              GestureDetector(
                onTap: _isStarted ? _stopRecording : _startRecording,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : Colors.red.shade400,
                      shape:
                          _isRecording ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius:
                          _isRecording ? BorderRadius.circular(8) : null,
                    ),
                  ),
                ),
              ),
            if (_isStarted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Tap to stop',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 13, color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
