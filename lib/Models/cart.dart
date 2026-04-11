import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:librairiepro/Models/product.dart';

class CartModel {
  final String id;
  final ProduitModel product;
  final double price;
  final int quantity;
  final double totalPrice;

  CartModel({
    required this.id,
    required this.product,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });

  // 🔹 FROM FIRESTORE
  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return CartModel(
      id: doc.id,
      product: data['product'] is Map<String, dynamic>
          ? ProduitModel.fromMap(data['product'] as Map<String, dynamic>)
          : ProduitModel(
              uid: '',
              titre: '',
              auteur: '',
              editeur: '',
              prix: 0,
              prixPromo: 0,
              tag: '',
              stock: 0,
              images: [],
              description: '',
            ),
      price: (data['price'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
    );
  }

  // 🔹 FROM MAP (API / LOCAL)
  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] ?? '',
      product: map['product'] is Map<String, dynamic>
          ? ProduitModel.fromMap(map['product'] as Map<String, dynamic>)
          : ProduitModel(
              uid: '',
              titre: '',
              auteur: '',
              editeur: '',
              prix: 0,
              prixPromo: 0,
              tag: '',
              stock: 0,
              images: [],
              description: '',
            ),
      price: (map['price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? 0).toInt(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }

  // 🔹 TO MAP (FIRESTORE)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }

  // 🔹 COPY WITH (IMMUTABILITY)
  CartModel copyWith({
    String? id,
    ProduitModel? product,
    double? price,
    int? quantity,
    double? totalPrice,
  }) {
    return CartModel(
      id: id ?? this.id,
      product: product ?? this.product,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // 🔹 DEBUG
  @override
  String toString() {
    return '''
CartModel(
  id: $id,
  product: ${product.titre},
  price: $price,
  quantity: $quantity,
  totalPrice: $totalPrice
)
''';
  }
}