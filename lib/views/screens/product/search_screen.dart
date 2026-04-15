import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Config/app_colors.dart';
import '../../../../Models/cart.dart';
import '../../../../Models/product.dart';
import '../../../../providers/Like_Provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/produit_provider.dart';
import '../../../../providers/search_provider.dart';
import '../../widgets/home/product_tag_utils.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search/search_filter_sheet.dart';
import '../../widgets/search/search_list_item_card.dart';
import 'Product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  late final SearchProvider _searchProvider;

  @override
  void initState() {
    super.initState();
    _searchProvider = SearchProvider();
    _searchProvider.initializeQuery(widget.initialQuery);
    _queryController.text = _searchProvider.query;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().listenProduits();
    });
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      _searchProvider.initializeQuery(widget.initialQuery);
      final next = _searchProvider.query;
      _queryController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _searchProvider.dispose();
    super.dispose();
  }

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
              : (cartProvider.errorMessage ??
                    'Erreur lors de l ajout au panier'),
        ),
        backgroundColor: success ? AppColors.secondary : Colors.redAccent,
      ),
    );
  }

  void _openProductDetails(
    BuildContext context,
    ProduitModel produit,
    bool isFavorite,
    String? currentUserId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: produit,
          isFavorite: isFavorite,
          onFavoriteTap: currentUserId == null
              ? null
              : () => context.read<LikeProvider>().toggleLikeForProduct(
                  userId: currentUserId,
                  productId: produit.uid,
                ),
          onAddToCartTap: (selectedQuantity) =>
              _addProductToCart(context, produit, quantity: selectedQuantity),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SearchProvider>.value(
      value: _searchProvider,
      child: Consumer3<ProduitProvider, LikeProvider, SearchProvider>(
        builder: (context, produitProvider, likeProvider, searchProvider, _) {
          final allProducts = produitProvider.produits;
          final categories = searchProvider.availableCategories(allProducts);
          final priceBounds = searchProvider.priceBounds(allProducts);
          final effectiveFilters = searchProvider.effectiveFilters(allProducts);
          final filtersActive = searchProvider.hasActiveFilters(allProducts);
          final filteredProducts = searchProvider.filteredProducts(allProducts);

          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          if (currentUserId != null && filteredProducts.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<LikeProvider>().syncForProducts(
                userId: currentUserId,
                productIds: filteredProducts.map((p) => p.uid).toList(),
              );
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recherche',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Trouvez un livre puis affinez les résultats avec les filtres.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _queryController,
                            autofocus: false,
                            onChanged: searchProvider.setQuery,
                            decoration: InputDecoration(
                              hintText: 'Rechercher un livre...',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black12,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.black26,
                                ),
                              ),
                              suffixIcon: _queryController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        _queryController.clear();
                                        searchProvider.clearQuery();
                                      },
                                      icon: const Icon(Icons.clear),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ActionButton(
                          icon: Icons.tune,
                          active: filtersActive,
                          onTap: () => showSearchFilterSheet(
                            context: context,
                            filters: searchProvider.filters,
                            categories: categories,
                            priceBounds: priceBounds,
                            onApply: searchProvider.applyFilters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: searchProvider.isGridView
                              ? Icons.grid_view
                              : Icons.view_list,
                          active: true,
                          onTap: searchProvider.toggleViewMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          '${filteredProducts.length} résultat${filteredProducts.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const Spacer(),
                        if (filtersActive ||
                            searchProvider.query.trim().isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _queryController.clear();
                              searchProvider.resetFiltersAndQuery();
                            },
                            child: const Text(
                              'Réinitialiser',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (filtersActive) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(label: effectiveFilters.priceLabel),
                          if (effectiveFilters.categories.isNotEmpty)
                            ...effectiveFilters.categories.map((category) {
                              return _FilterChip(label: category);
                            }),
                          if (effectiveFilters.inStockOnly)
                            const _FilterChip(label: 'En stock'),
                          if (effectiveFilters.expressOnly)
                            const _FilterChip(label: 'Livraison express'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (produitProvider.isLoading)
                      const SizedBox(
                        height: 260,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (produitProvider.error != null)
                      SizedBox(
                        height: 260,
                        child: Center(
                          child: Text(
                            'Erreur lors du chargement des produits:\n${produitProvider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      )
                    else if (filteredProducts.isEmpty)
                      _EmptyResults(
                        hasQuery: searchProvider.query.trim().isNotEmpty,
                        hasFilters: filtersActive,
                      )
                    else if (searchProvider.isGridView)
                      GridView.builder(
                        itemCount: filteredProducts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                        itemBuilder: (context, index) {
                          final produit = filteredProducts[index];
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
                            width: double.infinity,
                            price: price,
                            oldPrice: produit.prixPromo > 0
                                ? produit.prix
                                : null,
                            reviewCount: likeProvider.likesCountForProduct(
                              produit.uid,
                            ),
                            badgeText: badgeTextFromTag(produit),
                            isFavorite: isFavorite,
                            onTap: () => _openProductDetails(
                              context,
                              produit,
                              isFavorite,
                              currentUserId,
                            ),
                            onFavoriteTap: currentUserId == null
                                ? null
                                : () => context
                                      .read<LikeProvider>()
                                      .toggleLikeForProduct(
                                        userId: currentUserId,
                                        productId: produit.uid,
                                      ),
                            onAddToCartTap: () =>
                                _addProductToCart(context, produit),
                          );
                        },
                      )
                    else
                      ListView.separated(
                        itemCount: filteredProducts.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final produit = filteredProducts[index];
                          final isFavorite = currentUserId != null
                              ? likeProvider.isProductLiked(produit.uid)
                              : false;

                          return SearchListItemCard(
                            produit: produit,
                            isFavorite: isFavorite,
                            onTap: () => _openProductDetails(
                              context,
                              produit,
                              isFavorite,
                              currentUserId,
                            ),
                            onFavoriteTap: currentUserId == null
                                ? null
                                : () => context
                                      .read<LikeProvider>()
                                      .toggleLikeForProduct(
                                        userId: currentUserId,
                                        productId: produit.uid,
                                      ),
                            onAddToCartTap: () =>
                                _addProductToCart(context, produit),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: active ? Colors.white : AppColors.text),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final bool hasQuery;
  final bool hasFilters;

  const _EmptyResults({required this.hasQuery, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    final message = hasQuery
        ? 'Aucun produit ne correspond à votre recherche.'
        : hasFilters
        ? 'Aucun produit ne correspond à ces filtres.'
        : 'Aucun produit disponible pour le moment.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 56,
              color: Colors.black38,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
