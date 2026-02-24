import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/manager/haptic_manager.dart';
import 'package:shortzz/common/widget/confirmation_dialog.dart';
import 'package:shortzz/languages/languages_keys.dart';

class GifOverlayData {
  String url;
  double left;
  double top;
  double scale;
  double rotation;

  GifOverlayData({
    required this.url,
    this.left = 100,
    this.top = 300,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'left': left,
        'top': top,
        'scale': scale,
        'rotation': rotation,
      };
}

class DraggableGifWidget extends StatefulWidget {
  final GifOverlayData data;
  final Function(GifOverlayData updatedData) onUpdate;
  final VoidCallback onDelete;

  const DraggableGifWidget({
    super.key,
    required this.data,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DraggableGifWidget> createState() => _DraggableGifWidgetState();
}

class _DraggableGifWidgetState extends State<DraggableGifWidget> {
  double _baseScale = 1.0;
  double _initialRotation = 0.0;
  Offset _initialFocalPoint = Offset.zero;
  Offset _initialPosition = Offset.zero;

  void _onScaleStart(ScaleStartDetails details) {
    setState(() {
      _baseScale = widget.data.scale;
      _initialFocalPoint = details.focalPoint;
      _initialPosition = Offset(widget.data.left, widget.data.top);
      _initialRotation = widget.data.rotation;
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      final delta = details.focalPoint - _initialFocalPoint;
      widget.onUpdate(GifOverlayData(
        url: widget.data.url,
        left: _initialPosition.dx + (delta.dx / 2),
        top: _initialPosition.dy + (delta.dy / 2),
        scale: (_baseScale * details.scale).clamp(0.3, 5.0),
        rotation: _initialRotation + details.rotation,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onLongPress: () {
        HapticManager.shared.light();
        Get.bottomSheet(ConfirmationSheet(
          title: LKey.delete.tr,
          description: 'Remove this GIF?',
          onTap: widget.onDelete,
        ));
      },
      child: ClipRRect(
        child: Stack(
          children: [
            Positioned(
              left: widget.data.left,
              top: widget.data.top,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateZ(widget.data.rotation)
                  ..scaleByDouble(
                      widget.data.scale, widget.data.scale, 1.0, 1.0),
                child: Container(
                  width: 120,
                  height: 120,
                  color: Colors.transparent,
                  child: CachedNetworkImage(
                    imageUrl: widget.data.url,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      color: Colors.white38,
                      size: 40,
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
}
