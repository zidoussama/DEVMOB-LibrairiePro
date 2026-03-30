import '../Models/product.dart';
import '../services/produit_service.dart';

class ProduitController {
  final ProduitService _service = ProduitService();

  // 🔹 GET STREAM
  Stream<List<ProduitModel>> fetchProduits() {
    return _service.getProduits();
  }

  // 🔹 ADD
  Future<void> createProduit(ProduitModel produit) async {
    if (produit.titre.isEmpty) {
      throw Exception("Le titre est obligatoire");
    }
    await _service.addProduit(produit);
  }

  // 🔹 UPDATE
  Future<void> updateProduit(ProduitModel produit) async {
    await _service.updateProduit(produit);
  }

  // 🔹 DELETE
  Future<void> deleteProduit(String uid) async {
    await _service.deleteProduit(uid);
  }
}