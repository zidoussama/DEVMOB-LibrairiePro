import 'package:flutter/foundation.dart';
import '../Models/cart.dart';
import '../controllers/cart_controller.dart';

class CartProvider extends ChangeNotifier {
  final CartController _controller;

  CartProvider({CartController? controller})
      : _controller = controller ?? CartController();

  List<CartModel> _carts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CartModel> get carts => _carts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalPrice => _carts.fold(0, (sum, cart) => sum + cart.totalPrice);
  int get totalItems => _carts.fold(0, (sum, cart) => sum + cart.quantity);

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  // 🔹 FETCH CARTS
  void fetchCarts() {
    _setLoading(true);
    _setError(null);

    _controller.fetchCarts().listen(
      (carts) {
        _carts = carts;
        _setLoading(false);
      },
      onError: (error) {
        _setError(error.toString().replaceFirst('Exception: ', ''));
        _setLoading(false);
      },
    );
  }

  // 🔹 ADD TO CART
  Future<bool> addToCart(CartModel cart) async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.addToCart(cart);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 🔹 UPDATE CART
  Future<bool> updateCart(CartModel cart) async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.updateCart(cart);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 🔹 REMOVE FROM CART
  Future<bool> removeFromCart(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.removeFromCart(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 🔹 CLEAR CART
  Future<bool> clearCart() async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.clearCart();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // 🔹 GET CART BY ID
  Future<CartModel?> getCartById(String id) async {
    try {
      return await _controller.getCart(id);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }
}
