import 'package:http/http.dart' as http;

import '../../app/api_client.dart';

class DashboardSummary {
  final String workshopName;
  final bool operativoOnline;
  final int richiesteAttive;
  final int completatiOggi;
  final int tempoMedioMinuti;
  final String? selectedRequestId;

  const DashboardSummary({
    required this.workshopName,
    required this.operativoOnline,
    required this.richiesteAttive,
    required this.completatiOggi,
    required this.tempoMedioMinuti,
    required this.selectedRequestId,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;
    final kpi = _asMap(payload['kpi']) ?? const <String, dynamic>{};

    return DashboardSummary(
      workshopName: _asString(payload['workshop_name']) ?? 'Officina Centrale',
      operativoOnline: _asBool(payload['operativo_online']),
      richiesteAttive: _asInt(kpi['richieste_attive']),
      completatiOggi: _asInt(kpi['completati_oggi']),
      tempoMedioMinuti: _asInt(kpi['tempo_medio_minuti']),
      selectedRequestId: _asString(payload['selected_request_id']),
    );
  }
}

class QueueRequest {
  final String id;
  final String vehicleType;
  final String vehicleLabel;
  final String cliente;
  final String posizione;
  final double lat;
  final double lng;
  final String status;
  final String statusText;
  final List<String> availableActions;

  const QueueRequest({
    required this.id,
    required this.vehicleType,
    required this.vehicleLabel,
    required this.cliente,
    required this.posizione,
    required this.lat,
    required this.lng,
    required this.status,
    required this.statusText,
    required this.availableActions,
  });

  String get tipoLabel => '($vehicleType)';

  factory QueueRequest.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;

    return QueueRequest(
      id: _asString(payload['id']) ?? '',
      vehicleType: _asString(payload['vehicle_type']) ?? '',
      vehicleLabel: _asString(payload['vehicle_label']) ?? '',
      cliente: _asString(payload['cliente']) ?? '',
      posizione: _asString(payload['posizione']) ?? '',
      lat: _asDouble(payload['lat']),
      lng: _asDouble(payload['lng']),
      status: _asString(payload['status']) ?? 'pending',
      statusText: _asString(payload['status_text']) ?? '',
      availableActions: _asStringList(payload['available_actions']),
    );
  }
}

class DashboardApiService {
  DashboardApiService({http.Client? client})
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<DashboardSummary> getDashboardSummary() async {
    final data = await _requestJson('GET', '/dashboard/summary');
    return DashboardSummary.fromJson(data);
  }

  Future<List<QueueRequest>> getDashboardRequests() async {
    final data = await _requestJson('GET', '/dashboard/requests');
    final rawItems = data['data'] is List ? data['data'] as List : const [];

    return rawItems
        .whereType<Map>()
        .map((item) => QueueRequest.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<DashboardSummary> setOperationalStatus(bool operativoOnline) async {
    final data = await _requestJson(
      'PATCH',
      '/dashboard/operational-status',
      body: {'operativo_online': operativoOnline},
    );
    return DashboardSummary.fromJson(data);
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _apiClient.requestJson(method, path, body: body);
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

String? _asString(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double _asDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0;
  }
  return 0;
}

bool _asBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value.map((item) => item.toString()).toList();
}
