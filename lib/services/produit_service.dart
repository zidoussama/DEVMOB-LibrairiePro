import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/product.dart';

class ProduitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = "produits";

  // 🔹 CREATE
  Future<void> addProduit(ProduitModel produit) async {
    await _db.collection(collection).doc(produit.uid).set(produit.toMap());
  }

  // 🔹 READ (LIST)
  Stream<List<ProduitModel>> getProduits() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProduitModel.fromFirestore(doc))
          .toList();
    });
  }

  // 🔹 UPDATE
  Future<void> updateProduit(ProduitModel produit) async {
    await _db.collection(collection).doc(produit.uid).update(produit.toMap());
  }

  // 🔹 DELETE
  Future<void> deleteProduit(String uid) async {
    await _db.collection(collection).doc(uid).delete();
  }
}