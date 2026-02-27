import 'dart:async';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shortzz/common/extensions/duration_extension.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/screen/dashboard_screen/dashboard_screen_controller.dart';
import 'package:shortzz/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class ReelSeekBar extends StatefulWidget {
  final Player? player;
  final ReelController controller;

  const ReelSeekBar({super.key, required this.player, required this.controller});

  @override
  State<ReelSeekBar> createState() => _ReelSeekBarState();
}

class _ReelSeekBarState extends State<ReelSeekBar> {
  late final GlobalKey sliderKey = GlobalKey();
  Player? _overlayPlayer;
  VideoController? _overlayVideoController;

  OverlayEntry? _overlayEntry;
  final ValueNotifier<Offset?> _overlayOffsetNotifier = ValueNotifier(null);
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isOverlayInitialized = false;
  bool _isOverlayVisible = false;
  StreamSubscription? _positionSub;
  StreamSubscription? _overlayPositionSub;

  final dashboardController = Get.find<DashboardScreenController>();

  @override
  void initState() {
    super.initState();
    _positionSub = widget.player?.stream.position.listen((pos) {
      if (mounted) setState(() => _currentPosition = pos);
    });
    // Also listen to duration changes
    final dur = widget.player?.state.duration;
    if (dur != null && dur.inMicroseconds > 0) {
      _totalDuration = dur;
    }
    widget.player?.stream.duration.listen((dur) {
      if (mounted && dur.inMicroseconds > 0) {
        setState(() => _totalDuration = dur);
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _isOverlayVisible = false;

    if (_isOverlayInitialized && _overlayPlayer != null) {
      _overlayPositionSub?.cancel();
      _overlayPositionSub = null;
      _overlayPlayer!.dispose();
      _overlayPlayer = null;
      _overlayVideoController = null;
      _isOverlayInitialized = false;
    }

    _overlayOffsetNotifier.value = null;
  }

  void _updateOverlayLocation(Offset globalOffset) {
    _overlayOffsetNotifier.value = globalOffset;
  }

  Future<void> _createOverlay() async {
    if (_isOverlayVisible) return;

    _isOverlayVisible = true;
    _removeOverlay();

    String url = widget.controller.reelData.value.video?.addBaseURL() ?? '';
    if (url.isEmpty) return;

    // Create a separate media_kit player for the seek preview overlay
    final newPlayer = Player();
    final newVideoController = VideoController(newPlayer);
    await newPlayer.open(Media(url), play: false);

    // Wait for it to be ready
    await newPlayer.stream.width.firstWhere((w) => w != null).timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );

    _overlayPositionSub = newPlayer.stream.position.listen((pos) {
      if (mounted) setState(() => _currentPosition = pos);
    });

    _overlayPlayer = newPlayer;
    _overlayVideoController = newVideoController;
    _isOverlayInitialized = true;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        if (!_isOverlayInitialized || _overlayVideoController == null) return const SizedBox();

        return ValueListenableBuilder<Offset?>(
          valueListenable: _overlayOffsetNotifier,
          builder: (context, offset, _) {
            if (offset == null) return const SizedBox();

            final screenWidth = MediaQuery.of(context).size.width;
            final double dx = (offset.dx - 30).clamp(0, screenWidth - 100);
            bool isPostUploading = dashboardController.postProgress.value.uploadType != UploadType.none;
            final top = MediaQuery.of(context).size.height * 0.75 - (!isPostUploading ? 60 : 80);

            return Positioned(
              left: dx,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 170,
                      child: ClipRRect(
                        borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                        child: Video(
                          controller: _overlayVideoController!,
                          controls: NoVideoControls,
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 170,
                      decoration: ShapeDecoration(
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1),
                          side: BorderSide(
                            color: whitePure(context).withAlpha(50),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _currentPosition.printDuration,
                        style: TextStyleCustom.outFitMedium500(
                          color: whitePure(context),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_overlayEntry != null) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.player == null) return const SizedBox(height: 15);

    final duration = _totalDuration.inMicroseconds.toDouble();
    final position = _currentPosition.inMicroseconds.toDouble();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        padding: EdgeInsets.zero,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
        thumbShape: _InvisibleThumbShape(),
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Listener(
        onPointerMove: (event) => _updateOverlayLocation(event.position),
        child: Slider(
          key: sliderKey,
          value: position.clamp(0, duration),
          min: 0,
          max: duration > 0 ? duration : 1,
          activeColor: textLightGrey(context),
          inactiveColor: textDarkGrey(context),
          onChangeStart: (value) {
            if (duration <= 0) return;
            _createOverlay();
            widget.player?.pause();
          },
          onChangeEnd: (value) {
            if (duration <= 0) return;
            _removeOverlay();
            widget.player?.play();
            widget.player?.seek(Duration(microseconds: value.toInt()));
          },
          onChanged: (value) {
            if (duration <= 0) return;
            _overlayPlayer?.seek(Duration(microseconds: value.toInt()));
          },
        ),
      ),
    );
  }
}

class _InvisibleThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(15, 15);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter? labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    // No thumb to paint
  }

  bool hitTest(
    Offset thumbCenter,
    Offset touchPosition, {
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
  }) {
    // Expand interactive area (e.g., 24x24)
    return (touchPosition - thumbCenter).distance <= 12;
  }
}
