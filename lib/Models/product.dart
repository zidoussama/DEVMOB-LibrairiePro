import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:librairiepro/Models/CategorieModel.dart';

class ProduitModel {
  final String uid;
  final String titre;
  final String auteur;
  final String editeur;
  final double prix;
  final double prixPromo;
  final String tag;
  final int stock;
  final Categoriemodel? categorie;
  final List<String> images;
  final String description;
  final DateTime createdAt;

  ProduitModel({
    required this.uid,
    required this.titre,
    required this.auteur,
    required this.editeur,
    required this.prix,
    required this.prixPromo,
    required this.tag,
    required this.stock,
    this.categorie,
    required this.images,
    required this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 🔹 FROM FIRESTORE
  factory ProduitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProduitModel(
      uid: doc.id,
      titre: data['titre'] ?? '',
      auteur: data['auteur'] ?? '',
      editeur: data['editeur'] ?? '',
      prix: (data['prix'] ?? 0).toDouble(),
      prixPromo: (data['prixPromo'] ?? 0).toDouble(),
      tag: (data['tag'] ?? ''),
      stock: (data['stock'] ?? 0).toInt(),
      categorie: _extractCategorie(data),
      images: _extractImages(data),

      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔹 FROM MAP (API / LOCAL)
  factory ProduitModel.fromMap(Map<String, dynamic> map) {
    return ProduitModel(
      uid: map['uid'] ?? '',
      titre: map['titre'] ?? '',
      auteur: map['auteur'] ?? '',
      editeur: map['editeur'] ?? '',
      tag: map['tag'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      prixPromo: (map['prixPromo'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      categorie: _extractCategorie(map),

      images: _extractImages(map),
      description: map['description'] ?? '',

      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  // 🔹 TO MAP (FIRESTORE)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'titre': titre,
      'auteur': auteur,
      'editeur': editeur,
      'prix': prix,
      'prixPromo': prixPromo,
      'tag': tag,
      'stock': stock,
      'categorie': categorie?.toMap(),
      'images': images,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 🔹 COPY WITH (IMMUTABILITY)
  ProduitModel copyWith({
    String? uid,
    String? titre,
    String? auteur,
    String? editeur,
    double? prix,
    double? prixPromo,
    String? tag,
    int? stock,
    Categoriemodel? categorie,
    List<String>? images,
    String? description,
    DateTime? createdAt,
  }) {
    return ProduitModel(
      uid: uid ?? this.uid,
      titre: titre ?? this.titre,
      auteur: auteur ?? this.auteur,
      editeur: editeur ?? this.editeur,
      prix: prix ?? this.prix,
      prixPromo: prixPromo ?? this.prixPromo,
      tag: tag ?? this.tag,
      stock: stock ?? this.stock,
      categorie: categorie ?? this.categorie,
      images: images ?? this.images,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static List<String> _extractImages(Map<String, dynamic> data) {
    final dynamic rawImages = data['images'];

    if (rawImages is List) {
      return rawImages
          .map((item) => item.toString().trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    final String singleUrl = (data['imageUrl'] ?? data['image'] ?? '')
        .toString()
        .trim();

    if (singleUrl.isNotEmpty) {
      return [singleUrl];
    }

    return [];
  }

  static Categoriemodel? _extractCategorie(Map<String, dynamic> data) {
    final dynamic raw = data['categorie'] ?? data['category'];

    if (raw is Map<String, dynamic>) {
      final cat = Categoriemodel.fromMap(raw);
      if (cat.id.isNotEmpty || cat.name.isNotEmpty) return cat;
    }

    if (raw is Map) {
      final cat = Categoriemodel.fromMap(
        raw.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (cat.id.isNotEmpty || cat.name.isNotEmpty) return cat;
    }

    final id = (data['categorieId'] ?? data['categoryId'] ?? '').toString();
    final name = (data['categorieName'] ?? data['categoryName'] ?? '').toString();

    if (id.isEmpty && name.isEmpty) return null;

    return Categoriemodel(id: id, name: name);
  }

  // 🔹 DEBUG
  @override
  String toString() {
    return '''
ProduitModel(
  uid: $uid,
  titre: $titre,
  auteur: $auteur,
  editeur: $editeur,
  prix: $prix,
  prixPromo: $prixPromo,
  tag: $tag,
  stock: $stock,
  categorie: ${categorie?.name.isNotEmpty == true ? categorie!.name : categorie?.id},
  images: $images,
  description: $description,
  createdAt: $createdAt
)
''';
  }
}
