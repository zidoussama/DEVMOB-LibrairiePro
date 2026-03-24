import 'package:flutter/material.dart';
import '../../Config/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String imageUrl; // can be network url; if empty -> placeholder
  final double price;
  final double rating; // 0..5
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
    required this.price,
    this.rating = 0,
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
        width: 170,
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: imageUrl.isEmpty
                        ? Container(
                            color: AppColors.background,
                            child: const Icon(Icons.image_outlined, size: 40),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.background,
                              child:
                                  const Icon(Icons.broken_image_outlined, size: 40),
                            ),
                          ),
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
            Padding(
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
                  const SizedBox(height: 8),

                  // Rating
                  if (rating > 0)
                    Row(
                      children: [
                        _Stars(rating: rating, color: const Color(0xFFFFB300)),
                        const SizedBox(width: 6),
                        Text(
                          '($reviewCount)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.text.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 10),

                  // Price + Cart
                  Row(
                    children: [
                      Text(
                        '${price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
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
          ],
        ),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  final Color color;

  const _Stars({required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    // simple (not half-stars): 0..5
    final full = rating.clamp(0, 5).floor();
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < full ? Icons.star : Icons.star_border,
          size: 14,
          color: color,
        );
      }),
    );
  }
}