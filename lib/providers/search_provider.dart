import 'package:flutter/material.dart';

import '../Models/product.dart';
import '../controllers/search_controller.dart' as search_logic;

class SearchProvider extends ChangeNotifier {
  final search_logic.SearchController _controller;

  SearchProvider({search_logic.SearchController? controller})
    : _controller = controller ?? search_logic.SearchController();

  String _query = '';
  bool _isGridView = true;
  search_logic.SearchFilters _filters = const search_logic.SearchFilters();

  String get query => _query;
  bool get isGridView => _isGridView;
  search_logic.SearchFilters get filters => _filters;

  void initializeQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void setQuery(String value) {
    final next = value;
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void resetFiltersAndQuery() {
    _query = '';
    _filters = const search_logic.SearchFilters();
    notifyListeners();
  }

  void applyFilters(search_logic.SearchFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  List<String> availableCategories(List<ProduitModel> products) {
    return _controller.availableCategories(products);
  }

  search_logic.SearchPriceBounds priceBounds(List<ProduitModel> products) {
    return _controller.priceBounds(products);
  }

  search_logic.SearchFilters effectiveFilters(List<ProduitModel> products) {
    return _filters.clamp(priceBounds(products));
  }

  bool hasActiveFilters(List<ProduitModel> products) {
    return _filters.isActive(priceBounds(products));
  }

  List<ProduitModel> filteredProducts(List<ProduitModel> products) {
    return _controller.filterProducts(
      products: products,
      query: _query,
      filters: effectiveFilters(products),
    );
  }
}
