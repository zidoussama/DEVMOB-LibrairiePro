import '../Models/cart.dart';
import '../services/cart_service.dart';

class CartController {
  final CartService _service = CartService();

  // 🔹 GET STREAM
  Stream<List<CartModel>> fetchCarts() {
    return _service.getCarts();
  }

  // 🔹 GET SINGLE CART ITEM
  Future<CartModel?> getCart(String id) async {
    return await _service.getCartById(id);
  }

  // 🔹 ADD
  Future<void> addToCart(CartModel cart) async {
    if (cart.id.isEmpty) {
      throw Exception("ID du panier est obligatoire");
    }
    if (cart.quantity <= 0) {
      throw Exception("La quantité doit être supérieure à 0");
    }
    await _service.addCart(cart);
  }

  // 🔹 UPDATE
  Future<void> updateCart(CartModel cart) async {
    if (cart.quantity <= 0) {
      await _service.deleteCart(cart.id);
    } else {
      await _service.updateCart(cart);
    }
  }

  // 🔹 DELETE
  Future<void> removeFromCart(String id) async {
    await _service.deleteCart(id);
  }

  // 🔹 CLEAR ALL
  Future<void> clearCart() async {
    await _service.clearCart();
  }
}
