import 'package:flutter/material.dart';
import '../../Config/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl; // can be network url; if empty -> placeholder
  final double? width;
  final double price;
  final int reviewCount;

  final String? badgeText; // e.g. "Nouveau"
  final bool isFavorite;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCartTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.width,
    required this.price,
    this.reviewCount = 0,
    this.badgeText,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width ?? 170,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bordor),
          boxShadow: [
            BoxShadow(
              color: AppColors.bordor.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: _ProductImage(url: imageUrl),
                  ),
                ),

                // Badge
                if (badgeText != null && badgeText!.isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.black87,
                      ),
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    const Spacer(),

                    // Price + Cart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${price.toStringAsFixed(2)} €',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkResponse(
                          onTap: onAddToCartTap,
                          radius: 22,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                              color: AppColors.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _ProductImage extends StatefulWidget {
  final String url;

  const _ProductImage({required this.url});

  @override
  State<_ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<_ProductImage> {
  late final List<String> _candidates;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      _candidates[_currentIndex],
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholder();
      },
      errorBuilder: (_, __, ___) {
        if (_currentIndex < _candidates.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            setState(() {
              _currentIndex += 1;
            });
          });
          return _placeholder();
        }
        return _brokenPlaceholder();
      },
    );
  }

  List<String> _buildCandidates(String rawUrl) {
    final clean = rawUrl.trim();
    if (clean.isEmpty) return [];

    final encoded = Uri.encodeFull(clean);
    final lower = encoded.toLowerCase();

    final withoutQuery = lower.split('?').first;
    if (withoutQuery.endsWith('.jpgg')) {
      final fixed = encoded.replaceFirst(RegExp(r'\.jpgg(?=\?|$)', caseSensitive: false), '.jpg');
      return [encoded, fixed];
    }

    return [encoded];
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.image_outlined, size: 40),
    );
  }

  Widget _brokenPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.broken_image_outlined, size: 40),
    );
  }
}
