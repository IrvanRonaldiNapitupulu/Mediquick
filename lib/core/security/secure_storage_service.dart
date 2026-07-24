import 'package:mediquick/core/security/input_sanitizer.dart';
import 'package:mediquick/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyAuthToken = 'auth_token';

  static Future<void> saveUserSession({
    required String id,
    required String name,
    required String email,
    required String role,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, InputSanitizer.sanitize(id));
    await prefs.setString(_keyUserName, InputSanitizer.sanitize(name));
    await prefs.setString(_keyUserEmail, InputSanitizer.sanitize(email));
    await prefs.setString(_keyUserRole, InputSanitizer.sanitize(role));
    if (token != null) {
      await prefs.setString(_keyAuthToken, token);
    }
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId) ?? prefs.getString('id');
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole) ?? prefs.getString('role');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    AppLogger.debug('Session cleared.');
  }

  static Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }
}
