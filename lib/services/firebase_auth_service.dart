import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 Login
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // 🆕 Register
  Future<User?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        
      );
        await credential.user!.updateProfile(
          displayName: "$firstName $lastName",
        );

      // Update user profile with first and last name
      
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  // 🚪 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ❌ Error handling
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
      default:
        return "Erreur d'authentification";
    }
  }
}