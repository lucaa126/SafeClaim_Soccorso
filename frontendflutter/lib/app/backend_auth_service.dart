import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/api_config.dart';
import '../../app/auth_service.dart';
import '../../models/auth_response.dart';

class BackendAuthService {
  BackendAuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Valida il token Keycloak tramite il backend
  /// Restituisce le informazioni utente e i ruoli
  Future<AuthStatusResponse> validateTokenWithBackend(String token) async {
    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/auth/status');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(SafeClaimApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthStatusResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Token non valido o scaduto');
      } else if (response.statusCode == 503) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['error'] ?? 'Keycloak non configurato');
      } else {
        throw Exception('Errore durante la validazione: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Formato risposta API non valido');
    }
  }

  /// Valida il token e restituisce i dati completi
  Future<ValidateTokenResponse> validateToken(String token) async {
    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/auth/validate');

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(SafeClaimApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ValidateTokenResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Token non valido o scaduto');
      } else {
        throw Exception('Errore durante la validazione: ${response.statusCode}');
      }
    } on FormatException {
      throw Exception('Formato risposta API non valido');
    }
  }

  /// Verifica se il token attuale è ancora valido
  Future<bool> isTokenValid() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      await validateTokenWithBackend(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Ottiene i ruoli dell'utente corrente
  Future<List<String>> getCurrentUserRoles() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return [];

      final response = await validateTokenWithBackend(token);
      return response.roles;
    } catch (_) {
      return [];
    }
  }

  /// Verifica se l'utente ha un ruolo specifico
  Future<bool> hasRole(String role) async {
    try {
      final roles = await getCurrentUserRoles();
      return roles.contains(role);
    } catch (_) {
      return false;
    }
  }

  /// Verifica se l'utente è admin
  Future<bool> isAdmin() => hasRole('admin');

  /// Verifica se l'utente è perito
  Future<bool> isPerito() => hasRole('perito');

  /// Verifica se l'utente è officina
  Future<bool> isOfficina() => hasRole('officina');

  /// Verifica se l'utente è automobilista
  Future<bool> isAutomobilista() => hasRole('automobilista');
}
