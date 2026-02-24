import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/extensions/string_extension.dart';
import 'package:shortzz/languages/languages_keys.dart';
import 'package:shortzz/model/post_story/post_model.dart';
import 'package:shortzz/model/product/product_model.dart';
import 'package:shortzz/screen/shop_screen/product_detail_screen.dart';

/// Enhanced reel product overlay that shows product tags at specified
/// positions and times within a reel video. Tags without position data
/// fall back to a bottom-left stacked layout.
class ReelProductOverlay extends StatelessWidget {
  final Post post;
  final int currentPositionMs;

  const ReelProductOverlay({
    super.key,
    required this.post,
    this.currentPositionMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tags = post.productTags;
    if (tags == null || tags.isEmpty) return const SizedBox.shrink();

    // Separate positioned and non-positioned tags
    final positionedTags =
        tags.where((t) => t.hasPosition).toList();
    final stackedTags =
        tags.where((t) => !t.hasPosition).toList();

    return Stack(
      children: [
        // Positioned tags — placed at exact coordinates on screen
        ...positionedTags.map((tag) => _PositionedTag(
              tag: tag,
              currentPositionMs: currentPositionMs,
            )),
        // Non-positioned tags — stacked at bottom-left
        if (stackedTags.isNotEmpty)
          Positioned(
            bottom: 100,
            left: 12,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: stackedTags
                  .where((t) => t.isVisibleAtTime(currentPositionMs))
                  .map((tag) => _StackedTagChip(tag: tag))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

/// A product tag that appears at a specific position on the reel.
class _PositionedTag extends StatefulWidget {
  final PostProductTag tag;
  final int currentPositionMs;

  const _PositionedTag({
    required this.tag,
    required this.currentPositionMs,
  });

  @override
  State<_PositionedTag> createState() => _PositionedTagState();
}

class _PositionedTagState extends State<_PositionedTag>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  bool get _isVisible => widget.tag.isVisibleAtTime(widget.currentPositionMs);

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final product = widget.tag.product;
    if (product == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Position as percentage of screen
    final left = (widget.tag.displayPositionX ?? 0) / 100.0 * screenWidth;
    final top = (widget.tag.displayPositionY ?? 0) / 100.0 * screenHeight;

    return Positioned(
      left: left.clamp(0.0, screenWidth - 50),
      top: top.clamp(0.0, screenHeight - 50),
      child: GestureDetector(
        onTap: () {
          if (_expanded) {
            _navigateToProduct(product);
          } else {
            setState(() => _expanded = true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: _expanded ? 10 : 8,
            vertical: _expanded ? 8 : 6,
          ),
          decoration: ShapeDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                  cornerRadius: _expanded ? 12 : 20, cornerSmoothing: 1),
            ),
          ),
          child: _expanded
              ? _ExpandedContent(tag: widget.tag, product: product)
              : _CollapsedContent(tag: widget.tag),
        ),
      ),
    );
  }

  void _navigateToProduct(TaggedProductInfo product) {
    Get.to(() => ProductDetailScreen(
          product: Product(
            id: product.id,
            name: product.name,
            priceCoins: product.priceCoins,
            imageUrls: product.images?.map((e) => e.addBaseURL()).toList(),
          ),
        ));
  }
}

class _CollapsedContent extends StatelessWidget {
  final PostProductTag tag;
  const _CollapsedContent({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shopping_bag_outlined,
            size: 12, color: Colors.white),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            tag.label ?? tag.product?.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final PostProductTag tag;
  final TaggedProductInfo product;
  const _ExpandedContent({required this.tag, required this.product});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Product thumbnail
        if (product.images != null && product.images!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              product.images!.first.addBaseURL(),
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(Icons.shopping_bag_outlined,
                      size: 18, color: Colors.white54)),
            ),
          ),
        if (product.images != null && product.images!.isNotEmpty)
          const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                tag.label ?? product.name ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${product.priceCoins ?? 0} ${LKey.coinsText}',
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios,
                    size: 9, color: Colors.white70),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Stacked tag chip (used for tags without position data).
class _StackedTagChip extends StatelessWidget {
  final PostProductTag tag;
  const _StackedTagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    final product = tag.product;
    if (product == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () {
          Get.to(() => ProductDetailScreen(
                product: Product(
                  id: product.id,
                  name: product.name,
                  priceCoins: product.priceCoins,
                  imageUrls:
                      product.images?.map((e) => e.addBaseURL()).toList(),
                ),
              ));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: ShapeDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: SmoothRectangleBorder(
              borderRadius:
                  SmoothBorderRadius(cornerRadius: 8, cornerSmoothing: 1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tag.label ?? product.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${product.priceCoins ?? 0} ${LKey.coinsText}',
                style: TextStyle(
                  color: Colors.amber[300],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios,
                  size: 10, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}
