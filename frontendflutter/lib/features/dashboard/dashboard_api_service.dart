import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
    : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    const configured = String.fromEnvironment('SAFECLAIM_API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

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
    final uri = Uri.parse('$_baseUrl$path');
    late final http.Response response;

    try {
      switch (method) {
        case 'GET':
          response = await _client.get(uri);
          break;
        case 'PATCH':
          response = await _client.patch(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body ?? const {}),
          );
          break;
        default:
          throw Exception('Metodo HTTP non supportato: $method');
      }
    } on http.ClientException catch (error) {
      throw Exception('Errore di connessione API: ${error.message}');
    }

    if (response.body.isEmpty) {
      throw Exception('Risposta API vuota');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Formato risposta API non valido');
    }

    if (response.statusCode >= 400) {
      throw Exception(_asString(decoded['message']) ?? 'Errore API');
    }

    return decoded;
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
