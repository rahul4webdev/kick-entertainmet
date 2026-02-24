import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum VideoBlendMode {
  multiply,
  screen,
  overlay,
  softlight,
  hardlight,
  colorDodge,
  colorBurn,
  difference,
  addition,
}

extension VideoBlendModeInfo on VideoBlendMode {
  String get label => switch (this) {
        VideoBlendMode.multiply => 'Multiply',
        VideoBlendMode.screen => 'Screen',
        VideoBlendMode.overlay => 'Overlay',
        VideoBlendMode.softlight => 'Soft Light',
        VideoBlendMode.hardlight => 'Hard Light',
        VideoBlendMode.colorDodge => 'Dodge',
        VideoBlendMode.colorBurn => 'Burn',
        VideoBlendMode.difference => 'Difference',
        VideoBlendMode.addition => 'Addition',
      };

  IconData get icon => switch (this) {
        VideoBlendMode.multiply => Icons.layers,
        VideoBlendMode.screen => Icons.wb_sunny,
        VideoBlendMode.overlay => Icons.filter,
        VideoBlendMode.softlight => Icons.blur_on,
        VideoBlendMode.hardlight => Icons.brightness_high,
        VideoBlendMode.colorDodge => Icons.exposure,
        VideoBlendMode.colorBurn => Icons.local_fire_department,
        VideoBlendMode.difference => Icons.compare,
        VideoBlendMode.addition => Icons.add_circle,
      };

  String get ffmpegMode => switch (this) {
        VideoBlendMode.multiply => 'multiply',
        VideoBlendMode.screen => 'screen',
        VideoBlendMode.overlay => 'overlay',
        VideoBlendMode.softlight => 'softlight',
        VideoBlendMode.hardlight => 'hardlight',
        VideoBlendMode.colorDodge => 'dodge',
        VideoBlendMode.colorBurn => 'burn',
        VideoBlendMode.difference => 'difference',
        VideoBlendMode.addition => 'addition',
      };
}

class BlendModeResult {
  final VideoBlendMode mode;
  final double opacity;

  BlendModeResult({required this.mode, required this.opacity});
}

class BlendModeSheet extends StatefulWidget {
  final VideoBlendMode? currentMode;
  final double currentOpacity;

  const BlendModeSheet({
    super.key,
    this.currentMode,
    this.currentOpacity = 0.5,
  });

  @override
  State<BlendModeSheet> createState() => _BlendModeSheetState();
}

class _BlendModeSheetState extends State<BlendModeSheet> {
  late VideoBlendMode _selected;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentMode ?? VideoBlendMode.overlay;
    _opacity = widget.currentOpacity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Blend Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Blend mode grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: VideoBlendMode.values.length,
              itemBuilder: (context, index) {
                final mode = VideoBlendMode.values[index];
                final isSelected = mode == _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = mode),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withAlpha(40)
                          : Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mode.icon,
                            color: isSelected ? Colors.white : Colors.white60,
                            size: 26),
                        const SizedBox(height: 6),
                        Text(
                          mode.label,
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : Colors.white60,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Opacity slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Opacity',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Expanded(
                  child: Slider(
                    value: _opacity,
                    min: 0.1,
                    max: 1.0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() => _opacity = v),
                  ),
                ),
                Text(
                  '${(_opacity * 100).toInt()}%',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(
                  result: BlendModeResult(mode: _selected, opacity: _opacity),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
