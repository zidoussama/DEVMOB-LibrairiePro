import '../Models/adress.dart';
import '../services/adress_service.dart';

class AdressController {
  final AdressService _service;

  AdressController({AdressService? service})
    : _service = service ?? AdressService();

  Stream<List<Adressmodel>> fetchAdresses(String userId) {
    return _service.getAdresses(userId);
  }

  void _validateRequiredAdressFields(Adressmodel adress) {
    if (adress.name.trim().isEmpty) {
      throw Exception('Le nom de l\'adresse est obligatoire');
    }
    if ((adress.street ?? '').trim().isEmpty ||
        (adress.postalCode ?? '').trim().isEmpty ||
        (adress.city ?? '').trim().isEmpty ||
        (adress.country ?? '').trim().isEmpty ||
        (adress.phoneNumber ?? '').trim().isEmpty) {
      throw Exception(
        'Tous les champs obligatoires de l\'adresse doivent etre remplis',
      );
    }
  }

  Future<void> createAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    _validateRequiredAdressFields(adress);
    await _service.addAdress(userId: userId, adress: adress);
  }

  Future<void> updateAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    if (adress.id.trim().isEmpty) {
      throw Exception('Identifiant adresse manquant');
    }
    _validateRequiredAdressFields(adress);
    await _service.updateAdress(userId: userId, adress: adress);
  }

  Future<void> removeAdress({
    required String userId,
    required String adressId,
  }) async {
    if (adressId.trim().isEmpty) {
      throw Exception('Identifiant adresse manquant');
    }
    await _service.deleteAdress(userId: userId, adressId: adressId);
  }

  Future<void> makeDefaultAdress({
    required String userId,
    required String adressId,
  }) {
    return _service.setDefaultAdress(userId: userId, adressId: adressId);
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
