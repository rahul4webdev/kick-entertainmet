import 'package:flutter/material.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/model/post_story/post_model.dart';

class ProductLinksOverlay extends StatelessWidget {
  final Post post;

  const ProductLinksOverlay({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final links = post.productLinks;
    final hasLinks = links != null && links.isNotEmpty;

    if (!hasLinks) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 12,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // External product links
          ...links.map((link) => _ProductButton(link: link)),
        ],
      ),
    );
  }
}

class _ProductButton extends StatelessWidget {
  final ProductLink link;

  const _ProductButton({required this.link});

  IconData _iconForType(ProductButtonType type) {
    switch (type) {
      case ProductButtonType.buyNow:
        return Icons.shopping_bag_outlined;
      case ProductButtonType.signup:
        return Icons.person_add_outlined;
      case ProductButtonType.contact:
        return Icons.mail_outline;
      case ProductButtonType.register:
        return Icons.app_registration_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          final url = link.url;
          if (url != null && url.isNotEmpty) {
            url.lunchUrl;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconForType(link.buttonType), size: 16, color: Colors.black87),
              const SizedBox(width: 6),
              Text(
                link.label ?? link.buttonType.label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
