import 'dart:async';

import 'package:flutter/material.dart';
import '../Models/product.dart';
import '../controllers/produit_controller.dart';

class ProduitProvider extends ChangeNotifier {
  final ProduitController _controller = ProduitController();
  StreamSubscription<List<ProduitModel>>? _produitsSub;

  List<ProduitModel> _produits = [];
  bool _isLoading = false;
  String? _error;

  List<ProduitModel> get produits => _produits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔹 LOAD DATA (STREAM)
  void listenProduits() {
    if (_produitsSub != null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _produitsSub = _controller.fetchProduits().listen(
      (data) {
        _produits = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // 🔹 ADD
  Future<void> addProduit(ProduitModel produit) async {
    await _controller.createProduit(produit);
  }

  // 🔹 UPDATE
  Future<void> updateProduit(ProduitModel produit) async {
    await _controller.updateProduit(produit);
  }

  // 🔹 DELETE
  Future<void> deleteProduit(String uid) async {
    await _controller.deleteProduit(uid);
  }

  @override
  void dispose() {
    _produitsSub?.cancel();
    super.dispose();
  }
}