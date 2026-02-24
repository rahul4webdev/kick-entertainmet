import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AudioEffect {
  none,
  echo,
  reverb,
  chipmunk,
  deep,
  robot,
  radio,
  chorus,
  underwater,
}

extension AudioEffectInfo on AudioEffect {
  String get label => switch (this) {
        AudioEffect.none => 'None',
        AudioEffect.echo => 'Echo',
        AudioEffect.reverb => 'Reverb',
        AudioEffect.chipmunk => 'Chipmunk',
        AudioEffect.deep => 'Deep',
        AudioEffect.robot => 'Robot',
        AudioEffect.radio => 'Radio',
        AudioEffect.chorus => 'Chorus',
        AudioEffect.underwater => 'Underwater',
      };

  IconData get icon => switch (this) {
        AudioEffect.none => Icons.block,
        AudioEffect.echo => Icons.surround_sound,
        AudioEffect.reverb => Icons.spatial_audio,
        AudioEffect.chipmunk => Icons.speed,
        AudioEffect.deep => Icons.graphic_eq,
        AudioEffect.robot => Icons.smart_toy,
        AudioEffect.radio => Icons.radio,
        AudioEffect.chorus => Icons.queue_music,
        AudioEffect.underwater => Icons.water,
      };

  /// FFmpeg audio filter string
  String get ffmpegFilter => switch (this) {
        AudioEffect.none => '',
        AudioEffect.echo => 'aecho=0.8:0.88:60:0.4',
        AudioEffect.reverb => 'aecho=0.8:0.9:1000:0.3',
        AudioEffect.chipmunk =>
          'asetrate=44100*1.5,aresample=44100,atempo=0.667',
        AudioEffect.deep =>
          'asetrate=44100*0.75,aresample=44100,atempo=1.333',
        AudioEffect.robot =>
          "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=512:overlap=0.75",
        AudioEffect.radio => 'highpass=f=300,lowpass=f=3000,volume=1.5',
        AudioEffect.chorus =>
          'chorus=0.5:0.9:50|60|70:0.4|0.32|0.3:0.25|0.4|0.3:2|2.3|1.3',
        AudioEffect.underwater => 'lowpass=f=500,volume=0.7',
      };
}

class AudioEffectSheet extends StatelessWidget {
  final AudioEffect? current;

  const AudioEffectSheet({super.key, this.current});

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
            'Audio Effects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...AudioEffect.values.map((effect) => _EffectTile(
                effect: effect,
                isSelected: effect == current,
                onTap: () => Get.back(result: effect),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _EffectTile extends StatelessWidget {
  final AudioEffect effect;
  final bool isSelected;
  final VoidCallback onTap;

  const _EffectTile({
    required this.effect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withAlpha(30)
              : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(effect.icon, color: Colors.white, size: 22),
      ),
      title: Text(
        effect.label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.white, size: 20)
          : null,
    );
  }
}
