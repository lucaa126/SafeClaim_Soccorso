import 'package:http/http.dart' as http;

import '../../app/api_client.dart';
import '../../app/auth_service.dart' show TokenInvalidException;

class AnalyticsSummary {
  final int total;
  final int pending;
  final int accepted;
  final int handled;
  final int rejected;
  final List<int> last7Days;
  final Map<String, int> fleetStatus;
  final int averageHandlingMins;

  const AnalyticsSummary({
    required this.total,
    required this.pending,
    required this.accepted,
    required this.handled,
    required this.rejected,
    required this.last7Days,
    required this.fleetStatus,
    required this.averageHandlingMins,
  });

  factory AnalyticsSummary.empty() => const AnalyticsSummary(
    total: 0,
    pending: 0,
    accepted: 0,
    handled: 0,
    rejected: 0,
    last7Days: [],
    fleetStatus: {},
    averageHandlingMins: 0,
  );
}

class AnalyticsApiService {
  AnalyticsApiService({http.Client? client})
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  /// Carica i KPI principali + serie temporale + stato flotta con un set
  /// minimo di chiamate. Una singola fallita non blocca le altre.
  Future<AnalyticsSummary> getAnalyticsSummary({int daysWindow = 7}) async {
    final summary = await _safeRequest('GET', '/v1/analytics/riepilogo');
    final series = await _safeRequest(
      'GET', '/v1/analytics/ultimi-giorni/$daysWindow',
    );
    final fleet = await _safeRequest('GET', '/v1/analytics/stato-flotta');

    return AnalyticsSummary(
      total: _asInt(summary['total']),
      pending: _asInt(summary['pending']),
      accepted: _asInt(summary['accepted']),
      handled: _asInt(summary['handled']),
      rejected: _asInt(summary['rejected']),
      averageHandlingMins: _asInt(summary['average_handling_minutes']),
      last7Days: _asIntList(series['data']),
      fleetStatus: _asStringIntMap(fleet),
    );
  }

  Future<Map<String, dynamic>> _safeRequest(String method, String path) async {
    try {
      return await _apiClient.requestJson(method, path);
    } on TokenInvalidException {
      rethrow;
    } catch (_) {
      // Un singolo endpoint giù non deve impedire alla pagina di renderizzarsi.
      return const <String, dynamic>{};
    }
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

List<int> _asIntList(dynamic value) {
  if (value is List) {
    return value.map((e) {
      if (e is int) return e;
      if (e is num) return e.toInt();
      if (e is String) return int.tryParse(e) ?? 0;
      return 0;
    }).toList();
  }
  return const [];
}

Map<String, int> _asStringIntMap(dynamic value) {
  if (value is Map) {
    final result = <String, int>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final v = entry.value;
      if (v is int) {
        result[key] = v;
      } else if (v is num) {
        result[key] = v.toInt();
      }
    }
    return result;
  }
  return const {};
}
