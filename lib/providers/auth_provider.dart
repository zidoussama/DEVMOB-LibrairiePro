import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/user.dart';
import '../controllers/auth_controller.dart';

class AuthProvider extends ChangeNotifier {
  static const String _rememberMeKey = 'remember_me';
  static const String _keepLoggedInKey = 'keep_logged_in';

  final AuthController _controller;

  AuthProvider({AuthController? controller})
      : _controller = controller ?? AuthController();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _controller.signIn(email: email, password: password);
      if (user == null) {
        _setError("Connexion échouée");
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      await _saveRememberMeChoice(rememberMe);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await _controller.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (user == null) {
        _setError("Inscription échouée");
        _setLoading(false);
        return false;
      }

      _currentUser = user;
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.resetPassword(email: email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _setError(null);

    try {
      await _controller.signOut();
      await _saveRememberMeChoice(false);
      _currentUser = null;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _setError(null);

    try {
      _currentUser = await _controller.getCurrentUser();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> shouldKeepLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keepLoggedInKey) ?? false;
  }

  Future<bool> getRememberMeChoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> _saveRememberMeChoice(bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, rememberMe);
    await prefs.setBool(_keepLoggedInKey, rememberMe);
  }
}