import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../../Config/app_colors.dart';
import '../../../Models/product.dart';
import '../../../providers/Like_Provider.dart';
import '../../../providers/produit_provider.dart';
import '../../widgets/home/product_tag_utils.dart';
import '../product/Product_details_screen.dart';
import '../../widgets/product_card.dart';

class FavoScreen extends StatefulWidget {
  const FavoScreen({super.key});

  @override
  State<FavoScreen> createState() => _FavoScreenState();
}

class _FavoScreenState extends State<FavoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProduitProvider>().listenProduits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mes Favoris',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 4),
              Consumer2<ProduitProvider, LikeProvider>(
                builder: (context, produitProvider, likeProvider, _) {
                  final produits = produitProvider.produits;

                  if (currentUserId != null && produits.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      context.read<LikeProvider>().syncForProducts(
                        userId: currentUserId,
                        productIds: produits.map((p) => p.uid).toList(),
                      );
                    });
                  }

                  final favorites = currentUserId == null
                      ? <ProduitModel>[]
                      : produits
                            .where((p) => likeProvider.isProductLiked(p.uid))
                            .toList();

                  return Text(
                    '${favorites.length} articles',
                    style: const TextStyle(fontSize: 18, color: AppColors.text),
                  );
                },
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Expanded(
                child: Consumer2<ProduitProvider, LikeProvider>(
                  builder: (context, produitProvider, likeProvider, _) {
                    if (currentUserId == null) {
                      return const _EmptyState(
                        message:
                            'Connectez-vous pour voir et gerer vos favoris.',
                      );
                    }

                    if (produitProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (produitProvider.error != null) {
                      return Center(
                        child: Text(
                          'Erreur: ${produitProvider.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      );
                    }

                    final products = produitProvider.produits;

                    if (products.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        context.read<LikeProvider>().syncForProducts(
                          userId: currentUserId,
                          productIds: products.map((p) => p.uid).toList(),
                        );
                      });
                    }

                    final favorites = products
                        .where((p) => likeProvider.isProductLiked(p.uid))
                        .toList();

                    if (favorites.isEmpty) {
                      if (likeProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const _EmptyState(
                        message: 'Aucun produit favori pour le moment.',
                      );
                    }

                    return GridView.builder(
                      itemCount: favorites.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.62,
                          ),
                      itemBuilder: (context, index) {
                        final produit = favorites[index];
                        final imageUrl = produit.images.isNotEmpty
                            ? produit.images.first
                            : '';

                        return ProductCard(
                          title: produit.titre,
                          imageUrl: imageUrl,
                          price: produit.prixPromo > 0
                              ? produit.prixPromo
                              : produit.prix,
                          oldPrice: hasPromotionPrice(produit)
                              ? produit.prix
                              : null,
                          badgeText: badgeTextFromTag(produit),
                          isFavorite: true,
                          reviewCount: likeProvider.likesCountForProduct(
                            produit.uid,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailsScreen(
                                  product: produit,
                                  isFavorite: true,
                                  onFavoriteTap: () {
                                    context
                                        .read<LikeProvider>()
                                        .toggleLikeForProduct(
                                          userId: currentUserId,
                                          productId: produit.uid,
                                        );
                                  },
                                  onAddToCartTap: () {},
                                ),
                              ),
                            );
                          },
                          onAddToCartTap: () {},
                          onFavoriteTap: () {
                            context.read<LikeProvider>().toggleLikeForProduct(
                              userId: currentUserId,
                              productId: produit.uid,
                            );
                          },
                          width: double.infinity,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
