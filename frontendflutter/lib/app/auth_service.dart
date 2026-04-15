import 'package:shared_preferences/shared_preferences.dart';

class TokenInvalidException implements Exception {
  final String message;

  const TokenInvalidException([
    this.message = 'Sessione scaduta. Effettua il login.',
  ]);

  @override
  String toString() => message;
}

class AuthService {
  static const String _accessTokenKey = 'admin_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'admin_token_expiry';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<String?> getAccessToken() async {
    final prefs = await _prefs();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await _prefs();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<int?> getAccessTokenExpiry() async {
    final prefs = await _prefs();
    return prefs.getInt(_tokenExpiryKey);
  }

  static Future<bool> hasValidAccessToken() async {
    final token = await getAccessToken();
    final expiry = await getAccessTokenExpiry();

    if (token == null || token.isEmpty || expiry == null) {
      return false;
    }

    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final prefs = await _prefs();
    final expiryTimestamp =
        DateTime.now().millisecondsSinceEpoch + expiresIn * 1000;

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_tokenExpiryKey, expiryTimestamp);
  }

  static Future<void> clearSession() async {
    final prefs = await _prefs();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }
}
