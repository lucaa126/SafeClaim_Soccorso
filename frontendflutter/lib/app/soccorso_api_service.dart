import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/api_config.dart';
import '../app/auth_service.dart';
import '../models/soccorso.dart';

class SoccorsoApiService {
  SoccorsoApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> _getToken() async {
    return AuthService.getAccessToken();
  }

  /// Ottiene tutte le richieste di soccorso
  Future<List<SoccorsoRequest>> getAllRequests() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/soccorsi/');

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
        final requestsData = data['data'] as List? ?? [];
        return requestsData
            .map((e) => SoccorsoRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel recupero richieste (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Ottiene una singola richiesta di soccorso
  Future<SoccorsoRequest> getRequest(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/soccorsi/$requestId');

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
        return SoccorsoRequest.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Richiesta non trovata');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel recupero richiesta (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Ottiene richieste raggruppate per stato
  Future<List<SoccorsoRequest>> getRequestsByStatus(String status) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/richieste/?status=$status');

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
        final requestsData = data['data'] as List? ?? [];
        return requestsData
            .map((e) => SoccorsoRequest.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 400) {
        throw Exception('Stato non valido');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel recupero richieste (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }
}
