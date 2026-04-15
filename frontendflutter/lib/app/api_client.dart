import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'auth_service.dart';
import '../features/login/login_api_service.dart';

class SafeClaimApiClient {
  SafeClaimApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> _getToken() async {
    return AuthService.getAccessToken();
  }

  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    await _ensureValidToken();

    String? lastConnectionMessage;

    for (final baseUrl in SafeClaimApiConfig.baseUrls) {
      final uri = Uri.parse('$baseUrl$path');

      try {
        final response = await _send(
          method,
          uri,
          body,
        ).timeout(SafeClaimApiConfig.requestTimeout);
        return _decodeJson(response);
      } on TokenInvalidException {
        rethrow;
      } on http.ClientException catch (error) {
        lastConnectionMessage = error.message;
      } on _ApiConnectionException catch (error) {
        lastConnectionMessage = error.message;
      } on FormatException {
        lastConnectionMessage = 'Formato risposta API non valido';
      } on TimeoutException {
        lastConnectionMessage = 'timeout verso $baseUrl';
      }
    }

    throw Exception(
      'Errore di connessione API su tutti i base URL configurati'
      '${lastConnectionMessage == null ? '' : ': $lastConnectionMessage'}',
    );
  }

  Future<void> _ensureValidToken() async {
    if (await AuthService.hasValidAccessToken()) {
      return;
    }

    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await AuthService.clearSession();
      throw const TokenInvalidException();
    }

    try {
      await LoginApiService(client: _client).refreshToken();
    } catch (_) {
      await AuthService.clearSession();
      throw const TokenInvalidException();
    }
  }

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, dynamic>? body,
  ) async {
    final token = await _getToken();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'PATCH':
        return _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const {}),
        );
      case 'POST':
        return _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? const {}),
        );
      default:
        throw Exception('Metodo HTTP non supportato: $method');
    }
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      AuthService.clearSession();
      throw const TokenInvalidException();
    }

    if (response.body.isEmpty) {
      throw _ApiConnectionException('Risposta API vuota');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw _ApiConnectionException('Formato risposta API non valido');
    }

    if (response.statusCode >= 400) {
      throw Exception(decoded['message'] ?? 'Errore API');
    }

    return decoded;
  }
}

class _ApiConnectionException implements Exception {
  const _ApiConnectionException(this.message);

  final String message;
}
