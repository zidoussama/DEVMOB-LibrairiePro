import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/adress.dart';

class AdressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userAdressesCollection(
    String userId,
  ) {
    return _db.collection('users').doc(userId).collection('addresses');
  }

  Stream<List<Adressmodel>> getAdresses(String userId) {
    return _userAdressesCollection(userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => Adressmodel.fromMap({
                    ...doc.data(),
                    'id': doc.id,
                  }))
              .toList();

          items.sort((a, b) {
            if (a.isDefault == b.isDefault) return 0;
            return a.isDefault ? -1 : 1;
          });
          return items;
        });
  }

  Future<void> addAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    final ref = _userAdressesCollection(userId).doc(adress.id);
    await ref.set(adress.toMap(), SetOptions(merge: true));
  }

  Future<void> updateAdress({
    required String userId,
    required Adressmodel adress,
  }) async {
    final ref = _userAdressesCollection(userId).doc(adress.id);
    await ref.set(adress.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteAdress({
    required String userId,
    required String adressId,
  }) async {
    await _userAdressesCollection(userId).doc(adressId).delete();
  }

  Future<void> setDefaultAdress({
    required String userId,
    required String adressId,
  }) async {
    final collection = _userAdressesCollection(userId);
    final all = await collection.get();

    final batch = _db.batch();
    for (final doc in all.docs) {
      batch.set(doc.reference, {'isDefault': doc.id == adressId}, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
