class Categoriemodel {
  final String id;
  final String name;

  Categoriemodel({
    required this.id,
    required this.name,
  });

  factory Categoriemodel.fromMap(Map<String, dynamic> map) {
    return Categoriemodel(
      id: (map['id'] ?? map['uid'] ?? map['categorieId'] ?? map['categoryId'] ?? '')
          .toString(),
      name: (map['name'] ?? map['nom'] ?? map['titre'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}