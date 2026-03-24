import '../Models/user.dart';

abstract class AuthService {
  Future<UserModel?> signIn({
    required String email,
    required String password,
  });

  Future<UserModel?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<UserModel?> getCurrentUser();

  Future<void> signOut();
}