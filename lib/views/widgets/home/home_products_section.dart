import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Models/cart.dart';
import '../../../Models/product.dart';
import '../../../Config/app_colors.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/Like_Provider.dart';
import '../../../providers/produit_provider.dart';
import '../../screens/product/Product_details_screen.dart';
import '../product_card.dart';
import 'product_tag_utils.dart';

class HomeProductsSection extends StatelessWidget {
  final VoidCallback onSeeAllTap;

  const HomeProductsSection({super.key, required this.onSeeAllTap});

  Future<void> _addProductToCart(
    BuildContext context,
    ProduitModel produit, {
    int quantity = 1,
  }) async {
    final cartProvider = context.read<CartProvider>();
    final unitPrice = produit.prixPromo > 0 ? produit.prixPromo : produit.prix;

    final cart = CartModel(
      id: '${produit.uid}_${DateTime.now().millisecondsSinceEpoch}',
      product: produit,
      price: unitPrice,
      quantity: quantity,
      totalPrice: unitPrice * quantity,
    );

    final success = await cartProvider.addToCart(cart);
    if (!context.mounted) return;

    final label = quantity > 1 ? 'articles' : 'article';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? '$quantity $label ajoute au panier'
              : (cartProvider.errorMessage ?? 'Erreur lors de l ajout au panier'),
        ),
        backgroundColor: success ? AppColors.secondary : Colors.redAccent,
      ),
    );
  }

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
            if (allProducts.isEmpty) {
              return const SizedBox(
                height: 120,
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

            final prioritized = allProducts.where(isNewTag).toList();

            final List<ProduitModel> productsToShow = <ProduitModel>[];
            final seen = <String>{};

            for (final product in prioritized) {
              if (seen.add(product.uid)) {
                productsToShow.add(product);
              }
              if (productsToShow.length == 4) break;
            }

            if (productsToShow.length < 4) {
              for (final product in allProducts) {
                if (seen.add(product.uid)) {
                  productsToShow.add(product);
                }
                if (productsToShow.length == 4) break;
              }
            }

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
                final produit = productsToShow[index];
                final imageUrl = produit.images.isNotEmpty
                    ? produit.images.first
                    : '';
                final price = produit.prixPromo > 0
                    ? produit.prixPromo
                    : produit.prix;
                final isFavorite = currentUserId != null
                    ? likeProvider.isProductLiked(produit.uid)
                    : false;

                return ProductCard(
                  title: produit.titre,
                  imageUrl: imageUrl,
                  price: price,
                  reviewCount: likeProvider.likesCountForProduct(produit.uid),
                  badgeText: badgeTextFromTag(produit),
                  isFavorite: isFavorite,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          product: produit,
                          isFavorite: isFavorite,
                          onFavoriteTap: currentUserId == null
                              ? null
                              : () => context
                                  .read<LikeProvider>()
                                  .toggleLikeForProduct(
                                    userId: currentUserId,
                                    productId: produit.uid,
                                  ),
                          onAddToCartTap: (selectedQuantity) => _addProductToCart(
                            context,
                            produit,
                            quantity: selectedQuantity,
                          ),
                        ),
                      ),
                    );
                  },
                  onFavoriteTap: currentUserId == null
                      ? null
                      : () => context.read<LikeProvider>().toggleLikeForProduct(
                          userId: currentUserId,
                          productId: produit.uid,
                        ),
                  onAddToCartTap: () => _addProductToCart(context, produit),
                  width: double.infinity,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
