class Adressmodel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? street;
  final bool isDefault;

  Adressmodel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.city,
    this.postalCode,
    this.country,
    this.street,
    this.isDefault = false,
  });

  factory Adressmodel.fromMap(Map<String, dynamic> map) {
    return Adressmodel(
      id: (map['id'] ?? map['uid'] ?? map['adressId'] ?? map['addressId'] ?? '')
          .toString(),
      name: (map['name'] ?? map['nom'] ?? map['titre'] ?? '').toString(),
      phoneNumber: (map['phoneNumber'] ?? map['telephone'] ?? '').toString(),
      city: (map['city'] ?? map['ville'] ?? '').toString(),
      postalCode: (map['postalCode'] ?? map['codePostal'] ?? '').toString(),
      country: (map['country'] ?? map['pays'] ?? '').toString(),
      street: (map['street'] ?? map['rue'] ?? '').toString(),
      isDefault: map['isDefault'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'street': street,
      'isDefault': isDefault,
    };
  }

  Adressmodel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? city,
    String? postalCode,
    String? country,
    String? street,
    bool? isDefault,
  }) {
    return Adressmodel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      street: street ?? this.street,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
