import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/api_config.dart';
import '../app/auth_service.dart';
import '../models/dashboard.dart';

class DashboardApiService {
  DashboardApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Ottiene il sommario della dashboard
  Future<DashboardSummary> getDashboardSummary() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dashboard/summary');

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
        final dashboardData = data['data'] as Map<String, dynamic>? ?? {};
        return DashboardSummary.fromJson(dashboardData);
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel recupero sommario (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }

  /// Ottiene la lista delle richieste in dashboard
  Future<DashboardRequestsResponse> getDashboardRequests() async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dashboard/requests');

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
        return DashboardRequestsResponse.fromJson(data);
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

  /// Aggiorna lo stato operativo dell'officina (online/offline)
  Future<DashboardSummary> updateOperationalStatus(bool isOnline) async {
    final token = await AuthService.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token non disponibile');
    }

    final baseUrl = SafeClaimApiConfig.baseUrls.first;
    final uri = Uri.parse('$baseUrl/dashboard/operational-status');

    try {
      final response = await _client.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'operativo_online': isOnline}),
      ).timeout(SafeClaimApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final dashboardData = data['data'] as Map<String, dynamic>? ?? {};
        return DashboardSummary.fromJson(dashboardData);
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(data['error'] ?? 'Errore nei parametri');
      } else if (response.statusCode == 401) {
        await AuthService.clearSession();
        throw Exception('Sessione scaduta');
      } else {
        throw Exception('Errore nel salvataggio stato (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Formato risposta non valido');
    }
  }
}
