import 'package:shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }
} 