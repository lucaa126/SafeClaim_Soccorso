import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/api_config.dart';
import '../app/auth_service.dart';
import '../models/soccorso.dart';

class DettaglioInterventoApiService {
  DettaglioInterventoApiService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> _getToken() async {
    return AuthService.getAccessToken();
  }

  /// Ottiene i dettagli di un intervento
  Future<SoccorsoRequest> getIntervento(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dettaglioIntervento/$requestId');

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
        final interventoData = data['data'] as Map<String, dynamic>? ?? {};
        return SoccorsoRequest.fromJson(interventoData);
      } else if (response.statusCode == 404) {
        throw Exception('Intervento non trovato');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel recupero (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Prende in carico un intervento
  Future<SoccorsoRequest> takeInCharge(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dettaglioIntervento/$requestId/take-in-charge');

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
        final interventoData = data['data'] as Map<String, dynamic>? ?? {};
        return SoccorsoRequest.fromJson(interventoData);
      } else if (response.statusCode == 404) {
        throw Exception('Intervento non trovato');
      } else if (response.statusCode == 409) {
        throw Exception('Azione non disponibile per lo stato corrente');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel salvataggio (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Rifiuta un intervento
  Future<SoccorsoRequest> reject(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dettaglioIntervento/$requestId/reject');

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
        final interventoData = data['data'] as Map<String, dynamic>? ?? {};
        return SoccorsoRequest.fromJson(interventoData);
      } else if (response.statusCode == 404) {
        throw Exception('Intervento non trovato');
      } else if (response.statusCode == 409) {
        throw Exception('Azione non disponibile per lo stato corrente');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel salvataggio (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Completa un intervento
  Future<SoccorsoRequest> complete(String requestId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dettaglioIntervento/$requestId/complete');

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
        final interventoData = data['data'] as Map<String, dynamic>? ?? {};
        return SoccorsoRequest.fromJson(interventoData);
      } else if (response.statusCode == 404) {
        throw Exception('Intervento non trovato');
      } else if (response.statusCode == 409) {
        throw Exception('Azione non disponibile per lo stato corrente');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel completamento (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }
}
