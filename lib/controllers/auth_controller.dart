import '../Models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthController {
  final FirebaseAuthService _service;

  AuthController({FirebaseAuthService? service})
      : _service = service ?? FirebaseAuthService();

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) =>
      _service.signIn(email: email, password: password);

  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) =>
      _service.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

  Future<void> resetPassword({required String email}) =>
      _service.sendPasswordResetEmail(email: email);

  Future<UserModel?> getCurrentUser() => _service.getCurrentUser();

  Future<void> signOut() => _service.signOut();
}