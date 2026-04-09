import 'dart:async';

import 'package:flutter/foundation.dart';

import '../Models/adress.dart';
import '../controllers/adress_controller.dart';

class AdressProvider extends ChangeNotifier {
  final AdressController _controller;

  AdressProvider({AdressController? controller})
      : _controller = controller ?? AdressController();

  StreamSubscription<List<Adressmodel>>? _adressesSub;
  List<Adressmodel> _adresses = <Adressmodel>[];
  bool _isLoading = false;
  String? _error;
  String? _activeUserId;

  List<Adressmodel> get adresses => _adresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenAdresses(String userId) {
    if (_activeUserId == userId && _adressesSub != null) return;

    _adressesSub?.cancel();
    _activeUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    _adressesSub = _controller.fetchAdresses(userId).listen(
      (items) {
        _adresses = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    await _controller.createAdress(userId: userId, adress: adress);
  }

  Future<void> updateAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    await _controller.updateAdress(userId: userId, adress: adress);
  }

  Future<void> deleteAdress({
    required String userId,
    required String adressId,
  }) async {
    await _controller.removeAdress(userId: userId, adressId: adressId);
  }

  Future<void> setDefaultAdress({
    required String userId,
    required String adressId,
  }) async {
    await _controller.makeDefaultAdress(userId: userId, adressId: adressId);
  }

  String generateAdressId() => _controller.generateId();

  @override
  void dispose() {
    _adressesSub?.cancel();
    super.dispose();
  }
}
