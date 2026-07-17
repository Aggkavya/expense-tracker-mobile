import 'package:flutter/material.dart';
import '../core/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true; // default to dark like the web app

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  final _storage = StorageService();

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  String get userName => _user?['userName'] as String? ?? '';

  Future<bool> checkAuth() async {
    final hasToken = await _storage.hasToken();
    _isAuthenticated = hasToken;
    if (hasToken) {
      _user = await _storage.getUser();
    }
    notifyListeners();
    return hasToken;
  }

  Future<void> setSession(String token, Map<String, dynamic> user) async {
    await _storage.setToken(token);
    await _storage.setUser(user);
    _isAuthenticated = true;
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
