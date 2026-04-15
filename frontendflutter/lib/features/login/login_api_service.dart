import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/api_config.dart';
import '../../app/auth_service.dart';

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

      await AuthService.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        expiresIn: loginResponse.expiresIn,
      );
      return loginResponse;
    } else {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error_description'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await AuthService.clearSession();
  }

  Future<String?> getAccessToken() async {
    return AuthService.getAccessToken();
  }

  Future<String?> getRefreshToken() async {
    return AuthService.getRefreshToken();
  }

  Future<bool> isLoggedIn() async {
    return AuthService.hasValidAccessToken();
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

      await AuthService.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
        expiresIn: loginResponse.expiresIn,
      );
      return loginResponse;
    } else {
      await AuthService.clearSession();
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(data['error_description'] ?? 'Token refresh failed');
    }
  }
}
