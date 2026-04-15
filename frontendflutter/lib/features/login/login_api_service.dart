import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/api_config.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
    );
  }
}

class LoginApiService {
  LoginApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _tokenKey = 'admin_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<LoginResponse> login(String email, String password) async {
    final uri = Uri.parse(
      '${SafeClaimApiConfig.keycloakBaseUrl}/realms/${SafeClaimApiConfig.keycloakRealm}/protocol/openid-connect/token',
    );

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'password',
        'client_id': SafeClaimApiConfig.keycloakClientId,
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(data);

      // Save tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, loginResponse.accessToken);
      await prefs.setString(_refreshTokenKey, loginResponse.refreshToken);

      return loginResponse;
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error_description'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<LoginResponse> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final uri = Uri.parse(
      '${SafeClaimApiConfig.keycloakBaseUrl}/realms/${SafeClaimApiConfig.keycloakRealm}/protocol/openid-connect/token',
    );

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'client_id': SafeClaimApiConfig.keycloakClientId,
        'refresh_token': refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final loginResponse = LoginResponse.fromJson(data);

      // Update tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, loginResponse.accessToken);
      await prefs.setString(_refreshTokenKey, loginResponse.refreshToken);

      return loginResponse;
    } else {
      // If refresh fails, logout
      await logout();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error_description'] ?? 'Token refresh failed');
    }
  }
}