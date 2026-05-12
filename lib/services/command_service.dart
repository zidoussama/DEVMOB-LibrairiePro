import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/command.dart';

class CommandService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCommandsCollection(
    String userId,
  ) {
    return _db.collection('users').doc(userId).collection('commands');
  }

  Stream<List<CommandModel>> getCommands(String userId) {
    return _userCommandsCollection(userId).snapshots().map((snapshot) {
      final commands = snapshot.docs
          .map((doc) => CommandModel.fromFirestore(doc))
          .toList();

      commands.sort((a, b) {
        final left = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final right = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return right.compareTo(left);
      });

      return commands;
    });
  }

  Future<CommandModel?> getCommandById({
    required String userId,
    required String commandId,
  }) async {
    final doc = await _userCommandsCollection(userId).doc(commandId).get();
    if (!doc.exists) return null;
    return CommandModel.fromFirestore(doc);
  }

  Future<String> addCommand({
    required String userId,
    required CommandModel command,
  }) async {
    final ref = command.id.isEmpty
        ? _userCommandsCollection(userId).doc()
        : _userCommandsCollection(userId).doc(command.id);

    await ref.set(command.copyWith(id: ref.id, userId: userId).toMap());
    return ref.id;
  }

  Future<void> updateCommand({
    required String userId,
    required CommandModel command,
  }) async {
    await _userCommandsCollection(userId)
        .doc(command.id)
        .set(command.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteCommand({
    required String userId,
    required String commandId,
  }) async {
    await _userCommandsCollection(userId).doc(commandId).delete();
  }

  Future<void> clearCommands(String userId) async {
    final commands = await _userCommandsCollection(userId).get();
    for (final doc in commands.docs) {
      await doc.reference.delete();
    }
  }
}