import 'package:cloud_firestore/cloud_firestore.dart';

class ProduitModel {
  final String uid;
  final String titre;
  final String auteur;
  final String editeur;
  final double prix;
  final double prixPromo;
  final int stock;
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
    required this.stock,
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
      stock: (data['stock'] ?? 0).toInt(),
      images: List<String>.from(data['images'] ?? []),

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

      prix: (map['prix'] ?? 0).toDouble(),
      prixPromo: (map['prixPromo'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),

      images: List<String>.from(map['images'] ?? []),
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
      'stock': stock,
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
    int? stock,
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
      stock: stock ?? this.stock,
      images: images ?? this.images,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
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
  stock: $stock,
  images: $images,
  description: $description,
  createdAt: $createdAt
)
''';
  }
}