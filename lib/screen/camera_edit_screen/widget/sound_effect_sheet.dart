import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SoundEffectCategory { funny, nature, action, ui, music }

extension SoundEffectCategoryInfo on SoundEffectCategory {
  String get label => switch (this) {
        SoundEffectCategory.funny => 'Funny',
        SoundEffectCategory.nature => 'Nature',
        SoundEffectCategory.action => 'Action',
        SoundEffectCategory.ui => 'UI',
        SoundEffectCategory.music => 'Music',
      };

  IconData get icon => switch (this) {
        SoundEffectCategory.funny => Icons.emoji_emotions,
        SoundEffectCategory.nature => Icons.park,
        SoundEffectCategory.action => Icons.flash_on,
        SoundEffectCategory.ui => Icons.touch_app,
        SoundEffectCategory.music => Icons.music_note,
      };
}

class SoundEffectItem {
  final String name;
  final String asset;
  final SoundEffectCategory category;
  final IconData icon;

  const SoundEffectItem({
    required this.name,
    required this.asset,
    required this.category,
    required this.icon,
  });
}

const List<SoundEffectItem> allSoundEffects = [
  // Funny
  SoundEffectItem(name: 'Whoosh', asset: 'assets/sounds/whoosh.mp3', category: SoundEffectCategory.funny, icon: Icons.air),
  SoundEffectItem(name: 'Pop', asset: 'assets/sounds/pop.mp3', category: SoundEffectCategory.funny, icon: Icons.bubble_chart),
  SoundEffectItem(name: 'Boing', asset: 'assets/sounds/boing.mp3', category: SoundEffectCategory.funny, icon: Icons.sports_basketball),
  SoundEffectItem(name: 'Laugh', asset: 'assets/sounds/laugh.mp3', category: SoundEffectCategory.funny, icon: Icons.sentiment_very_satisfied),
  SoundEffectItem(name: 'Gasp', asset: 'assets/sounds/gasp.mp3', category: SoundEffectCategory.funny, icon: Icons.sentiment_very_dissatisfied),
  SoundEffectItem(name: 'Horn', asset: 'assets/sounds/horn.mp3', category: SoundEffectCategory.funny, icon: Icons.volume_up),
  // Nature
  SoundEffectItem(name: 'Thunder', asset: 'assets/sounds/thunder.mp3', category: SoundEffectCategory.nature, icon: Icons.thunderstorm),
  SoundEffectItem(name: 'Rain', asset: 'assets/sounds/rain.mp3', category: SoundEffectCategory.nature, icon: Icons.water_drop),
  SoundEffectItem(name: 'Wind', asset: 'assets/sounds/wind.mp3', category: SoundEffectCategory.nature, icon: Icons.air),
  SoundEffectItem(name: 'Fire', asset: 'assets/sounds/fire.mp3', category: SoundEffectCategory.nature, icon: Icons.local_fire_department),
  SoundEffectItem(name: 'Water', asset: 'assets/sounds/water_drop.mp3', category: SoundEffectCategory.nature, icon: Icons.water),
  // Action
  SoundEffectItem(name: 'Boom', asset: 'assets/sounds/boom.mp3', category: SoundEffectCategory.action, icon: Icons.flash_on),
  SoundEffectItem(name: 'Swoosh', asset: 'assets/sounds/swoosh.mp3', category: SoundEffectCategory.action, icon: Icons.swipe),
  SoundEffectItem(name: 'Sword', asset: 'assets/sounds/sword.mp3', category: SoundEffectCategory.action, icon: Icons.sports_martial_arts),
  SoundEffectItem(name: 'Glass', asset: 'assets/sounds/glass_break.mp3', category: SoundEffectCategory.action, icon: Icons.broken_image),
  SoundEffectItem(name: 'Magic', asset: 'assets/sounds/magic.mp3', category: SoundEffectCategory.action, icon: Icons.auto_fix_high),
  // UI
  SoundEffectItem(name: 'Click', asset: 'assets/sounds/click.mp3', category: SoundEffectCategory.ui, icon: Icons.mouse),
  SoundEffectItem(name: 'Ding', asset: 'assets/sounds/ding.mp3', category: SoundEffectCategory.ui, icon: Icons.notifications),
  SoundEffectItem(name: 'Notify', asset: 'assets/sounds/notification.mp3', category: SoundEffectCategory.ui, icon: Icons.notification_important),
  SoundEffectItem(name: 'Camera', asset: 'assets/sounds/camera_shutter.mp3', category: SoundEffectCategory.ui, icon: Icons.camera_alt),
  SoundEffectItem(name: 'Typing', asset: 'assets/sounds/typing.mp3', category: SoundEffectCategory.ui, icon: Icons.keyboard),
  // Music
  SoundEffectItem(name: 'Tada', asset: 'assets/sounds/tada.mp3', category: SoundEffectCategory.music, icon: Icons.celebration),
  SoundEffectItem(name: 'Drum Roll', asset: 'assets/sounds/drum_roll.mp3', category: SoundEffectCategory.music, icon: Icons.music_note),
  SoundEffectItem(name: 'Bell', asset: 'assets/sounds/bell.mp3', category: SoundEffectCategory.music, icon: Icons.notifications_active),
  SoundEffectItem(name: 'Applause', asset: 'assets/sounds/applause.mp3', category: SoundEffectCategory.music, icon: Icons.emoji_people),
  SoundEffectItem(name: 'Whistle', asset: 'assets/sounds/whistle.mp3', category: SoundEffectCategory.music, icon: Icons.sports),
];

class SoundEffectEntry {
  final SoundEffectItem item;
  final int timestampMs;

  SoundEffectEntry({required this.item, required this.timestampMs});

  Map<String, dynamic> toJson() => {
        'asset': item.asset,
        'name': item.name,
        'timestampMs': timestampMs,
      };
}

class SoundEffectSheet extends StatefulWidget {
  final int currentPositionMs;

  const SoundEffectSheet({super.key, required this.currentPositionMs});

  @override
  State<SoundEffectSheet> createState() => _SoundEffectSheetState();
}

class _SoundEffectSheetState extends State<SoundEffectSheet> {
  SoundEffectCategory _selectedCategory = SoundEffectCategory.funny;

  List<SoundEffectItem> get _filteredEffects =>
      allSoundEffects.where((e) => e.category == _selectedCategory).toList();

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
            'Sound Effects',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Text(
              'Adding at ${_formatMs(widget.currentPositionMs)}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          // Category tabs
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: SoundEffectCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = SoundEffectCategory.values[index];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
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
                        Icon(cat.icon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
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
          const SizedBox(height: 8),
          // Effects grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: _filteredEffects.length,
              itemBuilder: (context, index) {
                final effect = _filteredEffects[index];
                return GestureDetector(
                  onTap: () {
                    final entry = SoundEffectEntry(
                      item: effect,
                      timestampMs: widget.currentPositionMs,
                    );
                    Get.back(result: entry);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(effect.icon, color: Colors.white70, size: 28),
                        const SizedBox(height: 6),
                        Text(
                          effect.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  String _formatMs(int ms) {
    final sec = ms ~/ 1000;
    final min = sec ~/ 60;
    final remSec = sec % 60;
    return '${min.toString().padLeft(2, '0')}:${remSec.toString().padLeft(2, '0')}';
  }
}
