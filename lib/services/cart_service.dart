import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/cart.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = "cart";

  // 🔹 CREATE
  Future<void> addCart(CartModel cart) async {
    await _db.collection(collection).doc(cart.id).set(cart.toMap());
  }

  // 🔹 READ (LIST)
  Stream<List<CartModel>> getCarts() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CartModel.fromFirestore(doc))
          .toList();
    });
  }

  // 🔹 READ (SINGLE)
  Future<CartModel?> getCartById(String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return CartModel.fromFirestore(doc);
  }

  // 🔹 UPDATE
  Future<void> updateCart(CartModel cart) async {
    await _db.collection(collection).doc(cart.id).update(cart.toMap());
  }

  // 🔹 DELETE
  Future<void> deleteCart(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  // 🔹 DELETE ALL CART ITEMS
  Future<void> clearCart() async {
    final carts = await _db.collection(collection).get();
    for (final doc in carts.docs) {
      await doc.reference.delete();
    }
  }
}
