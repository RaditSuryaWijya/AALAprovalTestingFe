import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _deviceIdKey = 'device_id';

  // Token Management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userData);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Clear all auth data
  static Future<void> clearAuth() async {
    await removeToken();
    await removeUserData();
  }

  // Device ID Management
  // Generate and persist a pseudo-UUID for this installation
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final newId = _generatePseudoUuid();
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  static String _generatePseudoUuid() {
    // Simple pseudo-UUID v4-ish using timestamps + random
    final millis = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch.remainder(1 << 32);
    return '${millis.toRadixString(16)}-${random.toRadixString(16)}';
  }
}

