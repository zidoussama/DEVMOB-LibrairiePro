import 'package:flutter/material.dart';

import '../../../../Config/app_colors.dart';
import '../../../../Models/product.dart';
import '../home/product_tag_utils.dart';

class SearchListItemCard extends StatelessWidget {
  final ProduitModel produit;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback onAddToCartTap;

  const SearchListItemCard({
    super.key,
    required this.produit,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAddToCartTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = produit.images.isNotEmpty ? produit.images.first : '';
    final effectivePrice = produit.prixPromo > 0
        ? produit.prixPromo
        : produit.prix;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 95,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SearchListImage(url: imageUrl),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          badgeTextFromTag(produit),
                          style: const TextStyle(
                            color: AppColors.surface,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produit.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (produit.auteur.trim().isNotEmpty)
                    Text(
                      produit.auteur,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (produit.prixPromo > 0)
                              Text(
                                '${produit.prix.toStringAsFixed(2)} €',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            Text(
                              '${effectivePrice.toStringAsFixed(2)} €',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: produit.prixPromo > 0
                                    ? Colors.redAccent
                                    : AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Material(
                            color: AppColors.surface,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: IconButton(
                              onPressed: onFavoriteTap,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? Colors.redAccent
                                    : Colors.black87,
                              ),
                              iconSize: 19,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkResponse(
                            onTap: onAddToCartTap,
                            radius: 20,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart_outlined,
                                size: 17,
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                        ],
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

class _SearchListImage extends StatefulWidget {
  final String url;

  const _SearchListImage({required this.url});

  @override
  State<_SearchListImage> createState() => _SearchListImageState();
}

class _SearchListImageState extends State<_SearchListImage> {
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
    final withoutQuery = encoded.toLowerCase().split('?').first;
    if (withoutQuery.endsWith('.jpgg')) {
      final fixed = encoded.replaceFirst(
        RegExp(r'\.jpgg(?=\?|$)', caseSensitive: false),
        '.jpg',
      );
      return [encoded, fixed];
    }

    return [encoded];
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.image_outlined, size: 34),
    );
  }

  Widget _brokenPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.broken_image_outlined, size: 34),
    );
  }
}
