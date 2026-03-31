import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/product.dart';
import '../../../Config/app_colors.dart';
import '../../../providers/Like_Provider.dart';
import '../../../providers/produit_provider.dart';
import '../product_card.dart';
import 'product_tag_utils.dart';

class HomeSoldSection extends StatelessWidget {
  final VoidCallback onSeeAllTap;

  const HomeSoldSection({super.key, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Soldes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Text(
                'Voir tout',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer2<ProduitProvider, LikeProvider>(
          builder: (context, produitProvider, likeProvider, _) {
            if (produitProvider.isLoading) {
              return const SizedBox(
                height: 290,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (produitProvider.error != null) {
              return SizedBox(
                height: 290,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Erreur lors du chargement des produits:\n${produitProvider.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              );
            }

            final allProducts = produitProvider.produits;
            final soldProducts = allProducts.where(hasPromotionPrice).toList();

            if (soldProducts.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'Aucun produit en soldes pour le moment.',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            final List<ProduitModel> productsToShow = soldProducts
                .take(4)
                .toList();

            final int visibleCount = math.min(4, productsToShow.length);

            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
            if (currentUserId != null && productsToShow.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                context.read<LikeProvider>().syncForProducts(
                  userId: currentUserId,
                  productIds: productsToShow.map((p) => p.uid).toList(),
                );
              });
            }

            return SizedBox(
              height: 250,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: visibleCount,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final produit = productsToShow[index];
                  final imageUrl = produit.images.isNotEmpty
                      ? produit.images.first
                      : '';
                  final isFavorite = currentUserId != null
                      ? likeProvider.isProductLiked(produit.uid)
                      : false;

                  return ProductCard(
                    title: produit.titre,
                    imageUrl: imageUrl,
                    price: produit.prixPromo,
                    oldPrice: produit.prix,
                    reviewCount: likeProvider.likesCountForProduct(produit.uid),
                    badgeText: 'Soldes',
                    isFavorite: isFavorite,
                    onTap: () {},
                    onFavoriteTap: currentUserId == null
                        ? null
                        : () =>
                              context.read<LikeProvider>().toggleLikeForProduct(
                                userId: currentUserId,
                                productId: produit.uid,
                              ),
                    onAddToCartTap: () {},
                    width: 160,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
