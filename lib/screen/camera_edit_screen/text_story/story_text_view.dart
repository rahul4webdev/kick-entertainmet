import 'dart:io';
import 'dart:math' as math;

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/screen/camera_edit_screen/camera_edit_screen_controller.dart';
import 'package:shortzz/screen/camera_edit_screen/gif_overlay/gif_overlay_view.dart';
import 'package:shortzz/screen/camera_edit_screen/text_story/story_text_view_controller.dart';
import 'package:shortzz/screen/camera_edit_screen/text_story/widget/text_animation_picker.dart';
import 'package:shortzz/screen/camera_edit_screen/text_story/widget/text_editor_sheet.dart';
import 'package:shortzz/screen/camera_screen/camera_screen_controller.dart';
import 'package:shortzz/screen/color_filter_screen/widget/color_filtered.dart';
import 'package:shortzz/utilities/text_style_custom.dart';

class CameraEditImageView extends StatelessWidget {
  final CameraEditScreenController cameraEditController;

  const CameraEditImageView({super.key, required this.cameraEditController});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryTextViewController(cameraEditController));
    return Obx(
      () {
        // Retrieve the selected background style once to avoid repetitive computation
        PostStoryContent content = cameraEditController.content.value;
        bool isTextStory = content.type == PostStoryContentType.storyText;
        var gradient = cameraEditController
            .storyGradientColor[cameraEditController.selectedBgIndex.value];
        List<double> filter = cameraEditController.selectedFilter.value;
        if (filter.length != 20) filter = defaultFilter.toList();

        return Container(
          decoration: ShapeDecoration(
            shape: SmoothRectangleBorder(
                borderRadius:
                    SmoothBorderRadius(cornerRadius: 10, cornerSmoothing: 1)),
          ),
          child: RepaintBoundary(
            key: controller.previewContainer,
            child: Stack(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(filter),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: ShapeDecoration(
                      shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                              cornerRadius: 10, cornerSmoothing: 1)),
                      // color: content.bgColor,
                      gradient: isTextStory ? gradient : content.bgGradient,
                    ),
                    child: ClipSmoothRect(
                      radius: SmoothBorderRadius(
                          cornerRadius: 10, cornerSmoothing: 1),
                      child: Stack(
                        children: [
                          if (content.type == PostStoryContentType.storyImage)
                            Align(
                                alignment: Alignment.center,
                                child: Image.file(File(content.content ?? ''),
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth)),
                        ],
                      ),
                    ),
                  ),
                ),
                ...controller.textWidgets.asMap().map(
                  (i, element) {
                    return MapEntry(
                        i,
                        DraggableTextWidget(
                          data: element,
                          onUpdate: (updatedData) =>
                              controller.updateTextWidget(i, updatedData),
                          onDelete: () => controller.deleteTextWidget(i),
                        ));
                  },
                ).values,
                // GIF overlays
                ...cameraEditController.gifOverlays.asMap().map(
                  (i, data) => MapEntry(
                    i,
                    DraggableGifWidget(
                      data: data,
                      onUpdate: (updated) =>
                          cameraEditController.updateGifOverlay(i, updated),
                      onDelete: () =>
                          cameraEditController.deleteGifOverlay(i),
                    ),
                  ),
                ).values,
              ],
            ),
          ),
        );
      },
    );
  }
}

class DraggableTextWidget extends StatefulWidget {
  final TextWidgetData data;
  final Function(TextWidgetData updatedData) onUpdate;
  final VoidCallback onDelete;

  const DraggableTextWidget({
    super.key,
    required this.data,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableTextWidget> createState() => _DraggableTextWidgetState();
}

class _DraggableTextWidgetState extends State<DraggableTextWidget>
    with TickerProviderStateMixin {
  double _baseFontScale = 1.0;
  double _initialRotationAngle = 0.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialPosition = Offset.zero;
  final _controller = Get.find<StoryTextViewController>();
  bool _isViewVisible = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void onScaleStart(ScaleStartDetails details) {
    setState(() {
      _baseFontScale = widget.data.fontScale;
      _initialFocalPoint = details.focalPoint;
      _initialPosition = Offset(widget.data.left, widget.data.top);
      _initialRotationAngle = widget.data.fontAngle;
    });
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Update position (panning)
      final Offset delta = details.focalPoint - _initialFocalPoint;
      double leftX = _initialPosition.dx + (delta.dx / 2);
      double topY = _initialPosition.dy + (delta.dy / 2);

      // Update font scale (scaling)
      double fontScale = (_baseFontScale * details.scale).clamp(0.2, 100);

      // Update rotation angle
      double rotationAngle = _initialRotationAngle + details.rotation;

      // Notify parent of changes
      widget.onUpdate(TextWidgetData(
          text: widget.data.text,
          top: topY,
          left: leftX,
          fontSize: widget.data.fontSize,
          fontScale: fontScale,
          fontAngle: rotationAngle,
          fontColor: widget.data.fontColor,
          fontAlign: widget.data.fontAlign,
          googleFontFamily: widget.data.googleFontFamily,
          opacity: widget.data.opacity,
          textAnimation: widget.data.textAnimation));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openTextEditor,
      onLongPress: () {
        HapticManager.shared.light();
        Get.bottomSheet(ConfirmationSheet(
          title: LKey.delete.tr,
          description: LKey.deleteTextConfirmation.tr,
          onTap: widget.onDelete,
        ));
      },
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: ClipRRect(
        child: Stack(
          children: [
            // Draggable text widget
            Positioned(
              left: widget.data.left,
              top: widget.data.top,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(widget.data.fontAngle)
                  ..scaleByDouble(
                    widget.data.fontScale,
                    widget.data.fontScale,
                    1.0,
                    1.0,
                  ),
                child: Container(
                  width: Get.width - 50,
                  color: Colors.transparent,
                  constraints:
                      const BoxConstraints(minWidth: 100, minHeight: 50),
                  child: _wrapWithAnimation(
                    Text(
                      _isViewVisible ? widget.data.text : '',
                      style: _getTextStyle(
                          widget.data.googleFontFamily,
                          widget.data.fontSize,
                          widget.data.fontColor,
                          widget.data.opacity),
                      textAlign: widget.data.fontAlign.align,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _getTextStyle(
      GoogleFontFamily? font, double fontSize, Color color, double opacity) {
    return font?.style.copyWith(
          fontSize: fontSize,
          color: color.withValues(alpha: opacity),
        ) ??
        TextStyleCustom.outFitMedium500(
            fontSize: fontSize, color: color, opacity: opacity);
  }

  Widget _wrapWithAnimation(Widget child) {
    final anim = widget.data.textAnimation;
    if (anim == TextAnimation.none) return child;

    switch (anim) {
      case TextAnimation.none:
        return child;
      case TextAnimation.fadeIn:
        return FadeTransition(
          opacity: CurvedAnimation(
              parent: _animController, curve: Curves.easeIn),
          child: child,
        );
      case TextAnimation.slideUp:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _animController, curve: Curves.easeOut)),
          child: child,
        );
      case TextAnimation.slideDown:
        return SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: _animController, curve: Curves.easeOut)),
          child: child,
        );
      case TextAnimation.bounceIn:
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: _animController, curve: Curves.bounceOut),
          child: child,
        );
      case TextAnimation.scaleUp:
        return ScaleTransition(
          scale: CurvedAnimation(
              parent: _animController, curve: Curves.elasticOut),
          child: child,
        );
      case TextAnimation.typewriter:
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _animController.value.clamp(0.01, 1.0),
                child: child,
              ),
            );
          },
          child: child,
        );
      case TextAnimation.wave:
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final offset =
                math.sin(_animController.value * math.pi * 2) * 6;
            return Transform.translate(
              offset: Offset(0, offset),
              child: child,
            );
          },
          child: child,
        );
    }
  }

  void openTextEditor() {
    _isViewVisible = false;
    setState(() {});
    Get.bottomSheet<TextWidgetData>(TextEditorSheet(data: widget.data),
            isScrollControlled: true,
            ignoreSafeArea: false,
            // backgroundColor: textVeryLightGrey(context).withValues(alpha: 1),
            enableDrag: false,
            isDismissible: false,
            // barrierColor: textVeryLightGrey(context).withValues(alpha: 1),
            persistent: false)
        .then((value) {
      _isViewVisible = true;
      setState(() {});
      if (value != null) {
        widget.onUpdate(value);
        widget.onDelete();
        _controller.textWidgets.add(value);
      }
    });
  }
}
