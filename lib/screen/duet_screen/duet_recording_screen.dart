import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:retrytech_plugin/retrytech_plugin.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/common/functions/media_picker_helper.dart';
import 'package:shortzz/common/manager/logger.dart';
import 'package:shortzz/common/manager/session_manager.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

enum DuetLayout { sideBySide, topBottom }

class DuetRecordingScreen extends StatefulWidget {
  final Post sourcePost;

  const DuetRecordingScreen({super.key, required this.sourcePost});

  @override
  State<DuetRecordingScreen> createState() => _DuetRecordingScreenState();
}

class _DuetRecordingScreenState extends State<DuetRecordingScreen> {
  VideoPlayerController? _sourceVideoController;
  bool _sourceInitialized = false;
  bool _isRecording = false;
  bool _isStarted = false;
  bool _isDisposed = false;
  DuetLayout _layout = DuetLayout.sideBySide;
  double _progress = 0.0;
  Timer? _progressTimer;
  Duration? _sourceDuration;

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
      _sourceDuration = _sourceVideoController!.value.duration;
      _sourceInitialized = true;
      setState(() {});
    } catch (e) {
      Loggers.error('Duet source video init error: $e');
    }
  }

  void _initCamera() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isDisposed) return;
      RetrytechPlugin.shared.initCamera();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _progressTimer?.cancel();
    _sourceVideoController?.dispose();
    RetrytechPlugin.shared.disposeCamera;
    super.dispose();
  }

  void _toggleLayout() {
    setState(() {
      _layout = _layout == DuetLayout.sideBySide
          ? DuetLayout.topBottom
          : DuetLayout.sideBySide;
    });
  }

  Future<void> _startRecording() async {
    if (_isRecording || !_sourceInitialized) return;

    try {
      RetrytechPlugin.shared.startRecording;
      _sourceVideoController!.seekTo(Duration.zero);
      _sourceVideoController!.play();
      _isRecording = true;
      _isStarted = true;
      _startProgressTimer();
      setState(() {});
    } catch (e) {
      Loggers.error('Duet recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isStarted) return;

    try {
      _sourceVideoController?.pause();
      _progressTimer?.cancel();
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

      final layoutStr = _layout == DuetLayout.sideBySide
          ? 'side_by_side'
          : 'top_bottom';

      final content = PostStoryContent(
        type: PostStoryContentType.reel,
        content: videoPath,
        thumbNail: thumbnailPath.path,
        duetSourcePostId: widget.sourcePost.id,
        duetLayout: layoutStr,
      );

      // Dispose camera before navigating
      RetrytechPlugin.shared.disposeCamera;

      await Get.to(() => CameraEditScreen(content: content));
    } catch (e) {
      Loggers.error('Duet recording stop error: $e');
    }
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();
    final totalMs = _sourceDuration?.inMilliseconds ?? 60000;

    _progressTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }
        final currentMs =
            _sourceVideoController?.value.position.inMilliseconds ?? 0;
        _progress = currentMs / totalMs;

        if (_progress >= 1.0 || !(_sourceVideoController?.value.isPlaying ?? false)) {
          if (_isStarted) {
            timer.cancel();
            _stopRecording();
          }
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Split screen content
            _buildSplitView(),

            // Top bar
            _buildTopBar(),

            // Bottom controls
            _buildBottomControls(),

            // Progress bar
            if (_isStarted) _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitView() {
    if (_layout == DuetLayout.sideBySide) {
      return Row(
        children: [
          Expanded(child: _buildSourceVideo()),
          Container(width: 2, color: Colors.white24),
          Expanded(child: _buildCameraPreview()),
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: _buildSourceVideo()),
          Container(height: 2, color: Colors.white24),
          Expanded(child: _buildCameraPreview()),
        ],
      );
    }
  }

  Widget _buildSourceVideo() {
    if (!_sourceInitialized || _sourceVideoController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final size = _sourceVideoController!.value.size;
    return ClipRect(
      child: Stack(
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
          // Source user label
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '@${widget.sourcePost.user?.username ?? ''}',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RetrytechPlugin.shared.cameraView,
          // "You" label
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '@${SessionManager.instance.getUser()?.username ?? 'You'}',
                style: TextStyleCustom.outFitMedium500(
                    fontSize: 11, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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
            // Back button
            InkWell(
              onTap: () => Get.back(),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
            const Spacer(),
            // Layout toggle
            InkWell(
              onTap: _isStarted ? null : _toggleLayout,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isStarted ? Colors.white24 : Colors.white30,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _layout == DuetLayout.sideBySide
                          ? Icons.view_sidebar_rounded
                          : Icons.view_agenda_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _layout == DuetLayout.sideBySide
                          ? 'Side by Side'
                          : 'Top & Bottom',
                      style: TextStyleCustom.outFitMedium500(
                          fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Camera flip
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

  Widget _buildBottomControls() {
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
            if (!_isStarted)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Tap to start duet recording',
                  style: TextStyleCustom.outFitRegular400(
                      fontSize: 13, color: Colors.white70),
                ),
              ),
            // Record button
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
                    shape: _isRecording ? BoxShape.rectangle : BoxShape.circle,
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

  Widget _buildProgressBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: LinearProgressIndicator(
        value: _progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white24,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        minHeight: 3,
      ),
    );
  }
}
