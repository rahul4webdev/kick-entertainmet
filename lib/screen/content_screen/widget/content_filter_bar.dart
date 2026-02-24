import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/screen/home_screen/home_screen_controller.dart';

class ContentFilterBar extends StatelessWidget {
  final HomeScreenController controller;

  const ContentFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final genres = controller.contentGenres;
      final languages = controller.contentLanguages;

      if (genres.isEmpty && languages.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            // Genre chips
            if (genres.isNotEmpty) ...[
              _FilterChip(
                label: controller.selectedGenre.value ?? 'Genre',
                isSelected: controller.selectedGenre.value != null,
                onTap: () => _showGenreSheet(context),
              ),
              const SizedBox(width: 8),
            ],
            // Language chips
            if (languages.isNotEmpty) ...[
              _FilterChip(
                label: controller.selectedLanguage.value ?? 'Language',
                isSelected: controller.selectedLanguage.value != null,
                onTap: () => _showLanguageSheet(context),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showGenreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterList(
        title: 'Select Genre',
        items: [null, ...controller.contentGenres.map((g) => g.name)],
        selected: controller.selectedGenre.value,
        onSelected: (value) {
          controller.onGenreChanged(value);
          Get.back();
        },
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterList(
        title: 'Select Language',
        items: [null, ...controller.contentLanguages.map((l) => l.name)],
        selected: controller.selectedLanguage.value,
        onSelected: (value) {
          controller.onLanguageChanged(value);
          Get.back();
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isSelected ? Colors.black : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterList extends StatelessWidget {
  final String title;
  final List<String?> items;
  final String? selected;
  final Function(String?) onSelected;

  const _FilterList({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selected;
              return ListTile(
                title: Text(item ?? 'All', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () => onSelected(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
