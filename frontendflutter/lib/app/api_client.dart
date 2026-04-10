import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class SafeClaimApiClient {
  SafeClaimApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
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

  Future<http.Response> _send(
    String method,
    Uri uri,
    Map<String, dynamic>? body,
  ) async {
    switch (method) {
      case 'GET':
        return _client.get(uri);
      case 'PATCH':
        return _client.patch(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body ?? const {}),
        );
      case 'POST':
        return _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body ?? const {}),
        );
      default:
        throw Exception('Metodo HTTP non supportato: $method');
    }
  }

  Map<String, dynamic> _decodeJson(http.Response response) {
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
