import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;
      return await getUserById(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName("$firstName $lastName");

      final userModel = UserModel(
        uid: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      await _usersCollection.doc(userModel.uid).set(userModel.toMap());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUserById(user.uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "Utilisateur introuvable";
      case 'wrong-password':
        return "Mot de passe incorrect";
      case 'email-already-in-use':
        return "Email déjà utilisé";
      case 'weak-password':
        return "Mot de passe trop faible";
      case 'invalid-email':
        return "Email invalide";
      case 'missing-email':
        return "Email requis";
      default:
        return "Erreur d'authentification";
    }
  }
}