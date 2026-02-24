import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/widget/custom_app_bar.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/utilities/text_style_custom.dart';
import 'package:shortzz/utilities/theme_res.dart';

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(title: LKey.wellbeing),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LKey.wellbeingDesc,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 14,
                      color: textLightGrey(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: LKey.wellbeingBreathing),
                  const SizedBox(height: 10),
                  _BreathingExerciseCard(
                    title: LKey.wellbeingBoxBreathing,
                    description: LKey.wellbeingBoxBreathingDesc,
                    inhale: 4,
                    hold: 4,
                    exhale: 4,
                    holdAfter: 4,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _BreathingExerciseCard(
                    title: LKey.wellbeing478,
                    description: LKey.wellbeing478Desc,
                    inhale: 4,
                    hold: 7,
                    exhale: 8,
                    holdAfter: 0,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 10),
                  _BreathingExerciseCard(
                    title: LKey.wellbeingCalm,
                    description: LKey.wellbeingCalmDesc,
                    inhale: 5,
                    hold: 2,
                    exhale: 7,
                    holdAfter: 0,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: LKey.wellbeingAffirmations),
                  const SizedBox(height: 10),
                  const _AffirmationCards(),
                  const SizedBox(height: 24),
                  _SectionTitle(title: LKey.wellbeingSounds),
                  const SizedBox(height: 10),
                  const _AmbientSoundsGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyleCustom.outFitMedium500(fontSize: 17),
    );
  }
}

class _BreathingExerciseCard extends StatelessWidget {
  final String title;
  final String description;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;
  final Color color;

  const _BreathingExerciseCard({
    required this.title,
    required this.description,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdAfter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => _BreathingSessionScreen(
              title: title,
              inhale: inhale,
              hold: hold,
              exhale: exhale,
              holdAfter: holdAfter,
              color: color,
            ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.air, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyleCustom.outFitMedium500(fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyleCustom.outFitRegular400(
                      fontSize: 12,
                      color: textLightGrey(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: textLightGrey(context)),
          ],
        ),
      ),
    );
  }
}

class _BreathingSessionScreen extends StatefulWidget {
  final String title;
  final int inhale;
  final int hold;
  final int exhale;
  final int holdAfter;
  final Color color;

  const _BreathingSessionScreen({
    required this.title,
    required this.inhale,
    required this.hold,
    required this.exhale,
    required this.holdAfter,
    required this.color,
  });

  @override
  State<_BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<_BreathingSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  Timer? _phaseTimer;
  String _phase = 'Ready';
  int _countdown = 3;
  int _cycleCount = 0;
  bool _isActive = false;
  bool _isReady = true;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _startReadyCountdown();
  }

  void _startReadyCountdown() {
    _isReady = true;
    _countdown = 3;
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _isReady = false;
          _startBreathing();
        }
      });
    });
  }

  void _startBreathing() {
    _isActive = true;
    _cycleCount = 0;
    _runPhase('Inhale', widget.inhale);
  }

  void _runPhase(String phase, int duration) {
    if (!mounted || !_isActive) return;
    setState(() => _phase = phase);

    if (phase == 'Inhale') {
      _breathController.duration = Duration(seconds: duration);
      _breathController.forward(from: 0);
    } else if (phase == 'Exhale') {
      _breathController.duration = Duration(seconds: duration);
      _breathController.reverse(from: 1);
    }

    _phaseTimer?.cancel();
    _phaseTimer = Timer(Duration(seconds: duration), () {
      if (!mounted || !_isActive) return;
      if (phase == 'Inhale' && widget.hold > 0) {
        _runPhase('Hold', widget.hold);
      } else if (phase == 'Hold' || (phase == 'Inhale' && widget.hold == 0)) {
        _runPhase('Exhale', widget.exhale);
      } else if (phase == 'Exhale' && widget.holdAfter > 0) {
        _runPhase('Hold', widget.holdAfter);
      } else if (phase == 'Exhale' || (phase == 'Hold' && _phase == 'Exhale')) {
        setState(() => _cycleCount++);
        if (_cycleCount < 5) {
          _runPhase('Inhale', widget.inhale);
        } else {
          setState(() {
            _phase = 'Done';
            _isActive = false;
          });
        }
      } else {
        // After hold-after-exhale, go to next inhale
        setState(() => _cycleCount++);
        if (_cycleCount < 5) {
          _runPhase('Inhale', widget.inhale);
        } else {
          setState(() {
            _phase = 'Done';
            _isActive = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _breathController,
                      builder: (context, child) {
                        final size = 120.0 + (_breathController.value * 80.0);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color.withValues(alpha: 0.3 + _breathController.value * 0.3),
                            border: Border.all(
                              color: widget.color.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.2),
                                blurRadius: 30 + _breathController.value * 20,
                                spreadRadius: _breathController.value * 10,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _isReady ? '$_countdown' : _phase,
                      style: TextStyleCustom.outFitMedium500(
                        fontSize: _isReady ? 48 : 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_isReady && _isActive)
                      Text(
                        'Cycle ${_cycleCount + 1} of 5',
                        style: TextStyleCustom.outFitRegular400(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    if (_phase == 'Done') ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Finish'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AffirmationCards extends StatefulWidget {
  const _AffirmationCards();

  @override
  State<_AffirmationCards> createState() => _AffirmationCardsState();
}

class _AffirmationCardsState extends State<_AffirmationCards> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  static const List<String> _affirmations = [
    "You are capable of achieving great things.",
    "Take a deep breath. You are exactly where you need to be.",
    "Your creativity and ideas have value.",
    "It's okay to take a break and recharge.",
    "You are making progress, even when it doesn't feel like it.",
    "Be kind to yourself today.",
    "Your worth is not measured by likes or followers.",
    "Every small step counts toward your goals.",
    "You bring something unique to this world.",
    "It's okay to put your phone down and be present.",
  ];

  static const List<Color> _colors = [
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
    Colors.green,
    Colors.deepOrange,
    Colors.cyan,
    Colors.amber,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {},
        itemCount: _affirmations.length,
        itemBuilder: (context, index) {
          final color = _colors[index % _colors.length];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.format_quote, color: Colors.white54, size: 28),
                const SizedBox(height: 10),
                Text(
                  _affirmations[index],
                  textAlign: TextAlign.center,
                  style: TextStyleCustom.outFitMedium500(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AmbientSoundsGrid extends StatefulWidget {
  const _AmbientSoundsGrid();

  @override
  State<_AmbientSoundsGrid> createState() => _AmbientSoundsGridState();
}

class _AmbientSoundsGridState extends State<_AmbientSoundsGrid> {
  String? _activeSound;

  static const List<Map<String, dynamic>> _sounds = [
    {'name': 'Rain', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'Ocean', 'icon': Icons.waves, 'color': Colors.cyan},
    {'name': 'Forest', 'icon': Icons.forest, 'color': Colors.green},
    {'name': 'Fire', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    {'name': 'Wind', 'icon': Icons.air, 'color': Colors.blueGrey},
    {'name': 'Birds', 'icon': Icons.flutter_dash, 'color': Colors.amber},
    {'name': 'Night', 'icon': Icons.nightlight_round, 'color': Colors.indigo},
    {'name': 'Thunder', 'icon': Icons.bolt, 'color': Colors.deepPurple},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: _sounds.length,
      itemBuilder: (context, index) {
        final sound = _sounds[index];
        final isActive = _activeSound == sound['name'];
        final Color color = sound['color'] as Color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _activeSound = isActive ? null : sound['name'] as String;
            });
            // Sound playback would be integrated here with audioplayers package
            if (!isActive) {
              Get.snackbar(
                sound['name'] as String,
                'Ambient sound selected. Audio playback requires audioplayers integration.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.3)
                  : bgMediumGrey(context),
              borderRadius: BorderRadius.circular(12),
              border: isActive ? Border.all(color: color, width: 2) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sound['icon'] as IconData,
                  color: isActive ? color : textLightGrey(context),
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  sound['name'] as String,
                  style: TextStyleCustom.outFitRegular400(
                    fontSize: 11,
                    color: isActive ? color : textLightGrey(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
