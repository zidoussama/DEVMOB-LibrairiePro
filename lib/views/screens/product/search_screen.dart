import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Config/app_colors.dart';
import '../../../../Models/cart.dart';
import '../../../../Models/product.dart';
import '../../../../providers/Like_Provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/produit_provider.dart';
import '../../widgets/home/product_tag_utils.dart';
import '../../widgets/product_card.dart';
import 'Product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;

  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();

  bool _isGridView = true;
  _SearchFilters _filters = const _SearchFilters();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery.trim();
    if (initial.isNotEmpty) {
      _queryController.value = TextEditingValue(
        text: initial,
        selection: TextSelection.collapsed(offset: initial.length),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().listenProduits();
    });
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQuery != widget.initialQuery) {
      final next = widget.initialQuery.trim();
      _queryController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer2<ProduitProvider, LikeProvider>(
          builder: (context, produitProvider, likeProvider, _) {
            final allProducts = produitProvider.produits;
            final categories = _availableCategories(allProducts);
            final priceBounds = _priceBounds(allProducts);
            final effectiveFilters = _filters.clamp(priceBounds);
            final filtersActive = _filters.isActive(priceBounds);

            final filteredProducts = allProducts.where((produit) {
              return _matchesQuery(produit, _queryController.text) &&
                  _matchesFilters(produit, effectiveFilters);
            }).toList();

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

            return SingleChildScrollView(
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
                          onChanged: (_) => setState(() {}),
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
                                      setState(() {});
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
                        onTap: () => _openFiltersSheet(
                          context: context,
                          categories: categories,
                          priceBounds: priceBounds,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: _isGridView ? Icons.grid_view : Icons.view_list,
                        active: true,
                        onTap: () {
                          setState(() {
                            _isGridView = !_isGridView;
                          });
                        },
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
                          _queryController.text.trim().isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _queryController.clear();
                              _filters = const _SearchFilters();
                            });
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
                        _FilterChip(label: _filters.priceLabel),
                        if (_filters.categories.isNotEmpty)
                          ..._filters.categories.map((category) {
                            return _FilterChip(label: category);
                          }),
                        if (_filters.inStockOnly)
                          const _FilterChip(label: 'En stock'),
                        if (_filters.expressOnly)
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
                      hasQuery: _queryController.text.trim().isNotEmpty,
                      hasFilters: filtersActive,
                    )
                  else if (_isGridView)
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
                        return _buildProductCard(
                          context,
                          produit,
                          likeProvider,
                          currentUserId,
                          width: double.infinity,
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
                        return _buildProductListItem(
                          context,
                          produit,
                          likeProvider,
                          currentUserId,
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProduitModel produit,
    LikeProvider likeProvider,
    String? currentUserId, {
    double? width,
  }) {
    final imageUrl = produit.images.isNotEmpty ? produit.images.first : '';
    final price = produit.prixPromo > 0 ? produit.prixPromo : produit.prix;
    final isFavorite = currentUserId != null
        ? likeProvider.isProductLiked(produit.uid)
        : false;

    return ProductCard(
      title: produit.titre,
      imageUrl: imageUrl,
      width: width,
      price: price,
      oldPrice: produit.prixPromo > 0 ? produit.prix : null,
      reviewCount: likeProvider.likesCountForProduct(produit.uid),
      badgeText: badgeTextFromTag(produit),
      isFavorite: isFavorite,
      onTap: () =>
          _openProductDetails(context, produit, isFavorite, currentUserId),
      onFavoriteTap: currentUserId == null
          ? null
          : () => context.read<LikeProvider>().toggleLikeForProduct(
              userId: currentUserId,
              productId: produit.uid,
            ),
      onAddToCartTap: () => _addProductToCart(context, produit),
    );
  }

  Widget _buildProductListItem(
    BuildContext context,
    ProduitModel produit,
    LikeProvider likeProvider,
    String? currentUserId,
  ) {
    final imageUrl = produit.images.isNotEmpty ? produit.images.first : '';
    final isFavorite = currentUserId != null
        ? likeProvider.isProductLiked(produit.uid)
        : false;
    final effectivePrice = produit.prixPromo > 0
        ? produit.prixPromo
        : produit.prix;

    return InkWell(
      onTap: () =>
          _openProductDetails(context, produit, isFavorite, currentUserId),
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
                              onPressed: currentUserId == null
                                  ? null
                                  : () => context
                                        .read<LikeProvider>()
                                        .toggleLikeForProduct(
                                          userId: currentUserId,
                                          productId: produit.uid,
                                        ),
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
                            onTap: () => _addProductToCart(context, produit),
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

  Future<void> _openFiltersSheet({
    required BuildContext context,
    required List<String> categories,
    required _PriceBounds priceBounds,
  }) async {
    final effectiveFilters = _filters.clamp(priceBounds);
    final tempSelectedCategories = <String>{...effectiveFilters.categories};
    var tempPriceRange = effectiveFilters.priceRange;
    var tempInStockOnly = effectiveFilters.inStockOnly;
    var tempExpressOnly = effectiveFilters.expressOnly;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFDF8F1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 14,
                    bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Filtres',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Text(
                          'Prix: ${tempPriceRange.start.round()}€ - ${tempPriceRange.end.round()}€',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        RangeSlider(
                          values: tempPriceRange,
                          min: priceBounds.min,
                          max: priceBounds.max,
                          divisions: priceBounds.divisions,
                          activeColor: AppColors.primary,
                          inactiveColor: AppColors.primary.withOpacity(0.25),
                          labels: RangeLabels(
                            '${tempPriceRange.start.round()}€',
                            '${tempPriceRange.end.round()}€',
                          ),
                          onChanged: (values) {
                            setModalState(() {
                              tempPriceRange = values;
                            });
                          },
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Catégorie',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (categories.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Aucune catégorie disponible.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: categories.map((category) {
                              final selected = tempSelectedCategories.contains(
                                category,
                              );
                              return _SelectableFilterChip(
                                label: category,
                                selected: selected,
                                onTap: () {
                                  setModalState(() {
                                    if (selected) {
                                      tempSelectedCategories.remove(category);
                                    } else {
                                      tempSelectedCategories.add(category);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),
                        const Text(
                          'Disponibilité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SelectableFilterChip(
                          label: 'En stock',
                          selected: tempInStockOnly,
                          fullWidth: true,
                          onTap: () {
                            setModalState(() {
                              tempInStockOnly = !tempInStockOnly;
                              if (!tempInStockOnly) {
                                tempExpressOnly = false;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _SelectableFilterChip(
                          label: 'Livraison express',
                          selected: tempExpressOnly,
                          fullWidth: true,
                          onTap: () {
                            setModalState(() {
                              tempExpressOnly = !tempExpressOnly;
                              if (tempExpressOnly) {
                                tempInStockOnly = true;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setModalState(() {
                                    tempSelectedCategories.clear();
                                    tempPriceRange = RangeValues(
                                      priceBounds.min,
                                      priceBounds.max,
                                    );
                                    tempInStockOnly = false;
                                    tempExpressOnly = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                  ),
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Réinitialiser'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _filters = _SearchFilters(
                                      priceRange: tempPriceRange,
                                      categories: tempSelectedCategories
                                          .toSet(),
                                      inStockOnly: tempInStockOnly,
                                      expressOnly: tempExpressOnly,
                                    );
                                  });
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Appliquer'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<String> _availableCategories(List<ProduitModel> products) {
    final categories = <String>{};
    for (final produit in products) {
      final category = produit.categorie?.name.trim() ?? '';
      if (category.isNotEmpty) {
        categories.add(category);
      }
    }
    final sorted = categories.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  _PriceBounds _priceBounds(List<ProduitModel> products) {
    if (products.isEmpty) {
      return const _PriceBounds(min: 0, max: 100);
    }

    final prices = products
        .map(
          (produit) => produit.prixPromo > 0 ? produit.prixPromo : produit.prix,
        )
        .toList();

    final min = prices.reduce(math.min).floorToDouble();
    final max = prices.reduce(math.max).ceilToDouble();

    if (min == max) {
      return _PriceBounds(min: math.max(0, min - 5), max: max + 5);
    }

    return _PriceBounds(min: math.max(0, min), max: max);
  }

  bool _matchesQuery(ProduitModel produit, String query) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final haystack = [
      produit.titre,
      produit.auteur,
      produit.editeur,
      produit.description,
      produit.tag,
      produit.categorie?.name ?? '',
    ].map(_normalize).join(' ');

    return haystack.contains(normalizedQuery);
  }

  bool _matchesFilters(ProduitModel produit, _SearchFilters filters) {
    final price = produit.prixPromo > 0 ? produit.prixPromo : produit.prix;
    if (price < filters.priceRange.start || price > filters.priceRange.end) {
      return false;
    }

    if (filters.categories.isNotEmpty) {
      final categoryName = produit.categorie?.name.trim() ?? '';
      if (categoryName.isEmpty || !filters.categories.contains(categoryName)) {
        return false;
      }
    }

    if (filters.inStockOnly && produit.stock <= 0) {
      return false;
    }

    if (filters.expressOnly && produit.stock <= 0) {
      return false;
    }

    return true;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll(RegExp(r'[ýÿ]'), 'y');
  }
}

class _SearchFilters {
  final RangeValues priceRange;
  final Set<String> categories;
  final bool inStockOnly;
  final bool expressOnly;

  const _SearchFilters({
    this.priceRange = const RangeValues(0, 100),
    this.categories = const <String>{},
    this.inStockOnly = false,
    this.expressOnly = false,
  });

  bool isActive(_PriceBounds bounds) =>
      priceRange.start > bounds.min ||
      priceRange.end < bounds.max ||
      categories.isNotEmpty ||
      inStockOnly ||
      expressOnly;

  String get priceLabel =>
      'Prix ${priceRange.start.round()}€ - ${priceRange.end.round()}€';

  _SearchFilters clamp(_PriceBounds bounds) {
    final start = priceRange.start.clamp(bounds.min, bounds.max).toDouble();
    final end = priceRange.end.clamp(bounds.min, bounds.max).toDouble();
    final normalizedStart = math.min(start, end);
    final normalizedEnd = math.max(start, end);
    return _SearchFilters(
      priceRange: RangeValues(normalizedStart, normalizedEnd),
      categories: categories,
      inStockOnly: inStockOnly,
      expressOnly: expressOnly,
    );
  }
}

class _PriceBounds {
  final double min;
  final double max;

  const _PriceBounds({required this.min, required this.max});

  int get divisions {
    final span = (max - min).round();
    return span <= 0 ? 1 : span;
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

class _SelectableFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _SelectableFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary : Colors.black12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.text,
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: child,
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
