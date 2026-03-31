import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Config/app_colors.dart';
import '../../../Models/product.dart';
import '../../../providers/produit_provider.dart';
import '../product_card.dart';

class HomeProductsSection extends StatelessWidget {
  final VoidCallback onSeeAllTap;

  const HomeProductsSection({super.key, required this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Nouveautes',
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
        Consumer<ProduitProvider>(
          builder: (context, produitProvider, _) {
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

            final produits = produitProvider.produits;
            if (produits.isEmpty) {
              return const SizedBox(
                height: 290,
                child: Center(
                  child: Text(
                    'Aucun produit disponible pour le moment.',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            final int visibleCount = math.min(4, produits.length);

            return GridView.builder(
              itemCount: visibleCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (context, index) {
                final produit = produits[index];
                final imageUrl = produit.images.isNotEmpty
                    ? produit.images.first
                    : '';
                final price = produit.prixPromo > 0
                    ? produit.prixPromo
                    : produit.prix;

                return ProductCard(
                  title: produit.titre,
                  imageUrl: imageUrl,
                  price: price,
                  reviewCount: 0,
                  badgeText: _badgeTextFromTag(produit),
                  isFavorite: false,
                  onTap: () {},
                  onFavoriteTap: () {},
                  onAddToCartTap: () {},
                  width: double.infinity,
                );
              },
            );
          },
        ),
      ],
    );
  }

  String _badgeTextFromTag(ProduitModel produit) {
    final tag = produit.tag.trim().toLowerCase();

    if (tag.isEmpty) {
      return produit.stock > 0 ? 'Nouveau' : 'Rupture';
    }

    switch (tag) {
      case 'new':
      case 'nouveau':
        return 'Nouveau';
      case 'promo':
      case 'sale':
      case 'promotion':
      case 'discount':
      case 'soldes':
        return 'Promo';
      case 'rupture':
      case 'out_of_stock':
      case 'out-of-stock':
        return 'Rupture';
      default:
        return produit.tag.trim();
    }
  }
}
