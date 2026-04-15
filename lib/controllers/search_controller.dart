import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../Models/product.dart';

class SearchPriceBounds {
  final double min;
  final double max;

  const SearchPriceBounds({required this.min, required this.max});

  int get divisions {
    final span = (max - min).round();
    return span <= 0 ? 1 : span;
  }
}

class SearchFilters {
  final RangeValues priceRange;
  final Set<String> categories;
  final bool inStockOnly;
  final bool expressOnly;

  const SearchFilters({
    this.priceRange = const RangeValues(0, 100),
    this.categories = const <String>{},
    this.inStockOnly = false,
    this.expressOnly = false,
  });

  bool isActive(SearchPriceBounds bounds) {
    return priceRange.start > bounds.min ||
        priceRange.end < bounds.max ||
        categories.isNotEmpty ||
        inStockOnly ||
        expressOnly;
  }

  String get priceLabel =>
      'Prix ${priceRange.start.round()}€ - ${priceRange.end.round()}€';

  SearchFilters clamp(SearchPriceBounds bounds) {
    final start = priceRange.start.clamp(bounds.min, bounds.max).toDouble();
    final end = priceRange.end.clamp(bounds.min, bounds.max).toDouble();

    return SearchFilters(
      priceRange: RangeValues(math.min(start, end), math.max(start, end)),
      categories: categories,
      inStockOnly: inStockOnly,
      expressOnly: expressOnly,
    );
  }
}

class SearchController {
  List<String> availableCategories(List<ProduitModel> products) {
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

  SearchPriceBounds priceBounds(List<ProduitModel> products) {
    if (products.isEmpty) {
      return const SearchPriceBounds(min: 0, max: 100);
    }

    final prices = products
        .map(
          (produit) => produit.prixPromo > 0 ? produit.prixPromo : produit.prix,
        )
        .toList();

    final min = prices.reduce(math.min).floorToDouble();
    final max = prices.reduce(math.max).ceilToDouble();

    if (min == max) {
      return SearchPriceBounds(min: math.max(0, min - 5), max: max + 5);
    }

    return SearchPriceBounds(min: math.max(0, min), max: max);
  }

  List<ProduitModel> filterProducts({
    required List<ProduitModel> products,
    required String query,
    required SearchFilters filters,
  }) {
    return products.where((produit) {
      return _matchesQuery(produit, query) && _matchesFilters(produit, filters);
    }).toList();
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

  bool _matchesFilters(ProduitModel produit, SearchFilters filters) {
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
