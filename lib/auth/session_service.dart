import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyLogged = "logged_in";

  static bool _isLogged = false;
  static SharedPreferences? _prefs;

  /// Inicializar SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isLogged = _prefs?.getBool(_keyLogged) ?? false;
  }

  /// Guardar login
  static Future<void> login() async {
    _isLogged = true;
    await _prefs?.setBool(_keyLogged, true);
  }

  /// Logout
  static Future<void> logout() async {
    _isLogged = false;
    await _prefs?.setBool(_keyLogged, false);
  }

  /// Getter asíncrono para usar en FutureBuilder
  static Future<bool> isLoggedIn() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs?.getBool(_keyLogged) ?? false;
  }

  /// Getter sin Future (opcional)
  static bool get loggedSync => _isLogged;
}
