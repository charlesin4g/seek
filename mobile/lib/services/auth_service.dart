// imports
import 'storage_service.dart';
import 'user_api.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return false;

    try {
      // Call backend login API
      final result = await UserApi().login(username, password);

      // Persist returned data
      await StorageService().cacheUser(result);

      _isLoggedIn = true;
      _currentUser = username;
      return true;
    } catch (_) {
      _isLoggedIn = false;
      _currentUser = null;
      return false;
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoggedIn = false;
    _currentUser = null;
  }

  bool validateCredentials(String username, String password) {
    return username.trim().isNotEmpty && password.trim().isNotEmpty;
  }
}


