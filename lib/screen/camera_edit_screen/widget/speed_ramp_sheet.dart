import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpeedSegment {
  double startFraction;
  double endFraction;
  double speed;

  SpeedSegment({
    required this.startFraction,
    required this.endFraction,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
        'startFrac': startFraction,
        'endFrac': endFraction,
        'speed': speed,
      };
}

enum SpeedPreset { custom, bulletTime, speedUp, slowDown, pulse }

extension SpeedPresetInfo on SpeedPreset {
  String get label => switch (this) {
        SpeedPreset.custom => 'Custom',
        SpeedPreset.bulletTime => 'Bullet Time',
        SpeedPreset.speedUp => 'Speed Up',
        SpeedPreset.slowDown => 'Slow Down',
        SpeedPreset.pulse => 'Pulse',
      };

  IconData get icon => switch (this) {
        SpeedPreset.custom => Icons.tune,
        SpeedPreset.bulletTime => Icons.slow_motion_video,
        SpeedPreset.speedUp => Icons.fast_forward,
        SpeedPreset.slowDown => Icons.fast_rewind,
        SpeedPreset.pulse => Icons.graphic_eq,
      };

  List<SpeedSegment> get segments => switch (this) {
        SpeedPreset.custom => [
            SpeedSegment(startFraction: 0, endFraction: 1, speed: 1.0)
          ],
        SpeedPreset.bulletTime => [
            SpeedSegment(startFraction: 0, endFraction: 0.3, speed: 2.0),
            SpeedSegment(startFraction: 0.3, endFraction: 0.7, speed: 0.5),
            SpeedSegment(startFraction: 0.7, endFraction: 1.0, speed: 2.0),
          ],
        SpeedPreset.speedUp => [
            SpeedSegment(startFraction: 0, endFraction: 0.33, speed: 0.75),
            SpeedSegment(startFraction: 0.33, endFraction: 0.66, speed: 1.5),
            SpeedSegment(startFraction: 0.66, endFraction: 1.0, speed: 3.0),
          ],
        SpeedPreset.slowDown => [
            SpeedSegment(startFraction: 0, endFraction: 0.33, speed: 3.0),
            SpeedSegment(startFraction: 0.33, endFraction: 0.66, speed: 1.5),
            SpeedSegment(startFraction: 0.66, endFraction: 1.0, speed: 0.5),
          ],
        SpeedPreset.pulse => [
            SpeedSegment(startFraction: 0, endFraction: 0.25, speed: 2.0),
            SpeedSegment(startFraction: 0.25, endFraction: 0.5, speed: 0.5),
            SpeedSegment(startFraction: 0.5, endFraction: 0.75, speed: 2.0),
            SpeedSegment(startFraction: 0.75, endFraction: 1.0, speed: 0.5),
          ],
      };
}

class SpeedRampSheet extends StatefulWidget {
  final List<SpeedSegment>? current;

  const SpeedRampSheet({super.key, this.current});

  @override
  State<SpeedRampSheet> createState() => _SpeedRampSheetState();
}

class _SpeedRampSheetState extends State<SpeedRampSheet> {
  SpeedPreset _selectedPreset = SpeedPreset.custom;
  late List<SpeedSegment> _segments;

  @override
  void initState() {
    super.initState();
    _segments = widget.current ??
        [SpeedSegment(startFraction: 0, endFraction: 1, speed: 1.0)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Speed Ramp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Preset selector
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: SpeedPreset.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final preset = SpeedPreset.values[index];
                final isSelected = preset == _selectedPreset;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPreset = preset;
                      _segments =
                          preset.segments.map((s) => SpeedSegment(
                                startFraction: s.startFraction,
                                endFraction: s.endFraction,
                                speed: s.speed,
                              )).toList();
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withAlpha(50)
                          : Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(preset.icon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          preset.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Speed visualization
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _SpeedCurvePainter(segments: _segments),
              size: const Size(double.infinity, 80),
            ),
          ),
          const SizedBox(height: 12),
          // Segment speed labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _segments.map((seg) {
                final width = seg.endFraction - seg.startFraction;
                return Expanded(
                  flex: (width * 100).toInt(),
                  child: Center(
                    child: Text(
                      '${seg.speed}x',
                      style: TextStyle(
                        color: seg.speed < 1
                            ? Colors.blue[300]
                            : seg.speed > 1
                                ? Colors.orange[300]
                                : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: _segments),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SpeedCurvePainter extends CustomPainter {
  final List<SpeedSegment> segments;

  _SpeedCurvePainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Draw baseline at 1.0x speed
    final baseY = size.height * 0.6;
    canvas.drawLine(
      Offset(0, baseY),
      Offset(size.width, baseY),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1,
    );

    final path = Path();
    path.moveTo(0, size.height);

    for (final seg in segments) {
      final x1 = seg.startFraction * size.width;
      final x2 = seg.endFraction * size.width;
      // Map speed 0.25-4.0 to height (inverted: higher speed = higher bar)
      final normalizedSpeed = ((seg.speed - 0.25) / 3.75).clamp(0.0, 1.0);
      final y = size.height * (1 - normalizedSpeed * 0.9);

      path.lineTo(x1, y);
      path.lineTo(x2, y);

      // Fill segment with color
      final segPath = Path()
        ..moveTo(x1, size.height)
        ..lineTo(x1, y)
        ..lineTo(x2, y)
        ..lineTo(x2, size.height)
        ..close();

      fillPaint.color = seg.speed < 1
          ? Colors.blue.withAlpha(40)
          : seg.speed > 1
              ? Colors.orange.withAlpha(40)
              : Colors.white.withAlpha(20);
      canvas.drawPath(segPath, fillPaint);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
