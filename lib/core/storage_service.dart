import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _tokenKey = 'finance-tracker-token';
const _userKey = 'finance-tracker-user';
const _balanceKey = 'finance-tracker-balances';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ─── Token ─────────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // ─── User ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // ─── Balances ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_balanceKey);
    if (raw == null) return {'cashInHand': null, 'bankBalance': null};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {'cashInHand': null, 'bankBalance': null};
    }
  }

  Future<void> setBalances(Map<String, dynamic> balances) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_balanceKey, jsonEncode(balances));
  }

  // ─── Session ───────────────────────────────────────────────────────────────

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_balanceKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
