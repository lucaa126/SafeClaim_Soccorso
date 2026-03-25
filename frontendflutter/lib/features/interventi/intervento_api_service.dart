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
    final kpi = (json['kpi'] as Map<String, dynamic>? ?? const {});
    return DashboardSummary(
      workshopName: (json['workshop_name'] ?? 'Officina Centrale') as String,
      operativoOnline: (json['operativo_online'] ?? false) as bool,
      richiesteAttive: (kpi['richieste_attive'] ?? 0) as int,
      completatiOggi: (kpi['completati_oggi'] ?? 0) as int,
      tempoMedioMinuti: (kpi['tempo_medio_minuti'] ?? 0) as int,
      selectedRequestId: json['selected_request_id'] as String?,
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
    return QueueRequest(
      id: (json['id'] ?? '') as String,
      vehicleType: (json['vehicle_type'] ?? '') as String,
      vehicleLabel: (json['vehicle_label'] ?? '') as String,
      cliente: (json['cliente'] ?? '') as String,
      posizione: (json['posizione'] ?? '') as String,
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lng: (json['lng'] as num? ?? 0).toDouble(),
      status: (json['status'] ?? 'pending') as String,
      statusText: (json['status_text'] ?? '') as String,
      availableActions: List<String>.from(
        json['available_actions'] ?? const [],
      ),
    );
  }
}

class InterventionDetail {
  final String id;
  final String cliente;
  final String vehicleType;
  final String status;
  final String statusText;
  final double lat;
  final double lng;
  final String posizione;
  final String requestedAt;
  final String? assignedDriver;
  final String? notes;
  final List<String> availableActions;

  const InterventionDetail({
    required this.id,
    required this.cliente,
    required this.vehicleType,
    required this.status,
    required this.statusText,
    required this.lat,
    required this.lng,
    required this.posizione,
    required this.requestedAt,
    required this.assignedDriver,
    required this.notes,
    required this.availableActions,
  });

  factory InterventionDetail.fromJson(Map<String, dynamic> json) {
    return InterventionDetail(
      id: (json['id'] ?? '') as String,
      cliente: (json['cliente'] ?? '') as String,
      vehicleType: (json['vehicle_type'] ?? '') as String,
      status: (json['status'] ?? 'pending') as String,
      statusText: (json['status_text'] ?? '') as String,
      lat: (json['lat'] as num? ?? 0).toDouble(),
      lng: (json['lng'] as num? ?? 0).toDouble(),
      posizione: (json['posizione'] ?? '') as String,
      requestedAt: (json['requested_at'] ?? '') as String,
      assignedDriver: json['assigned_driver'] as String?,
      notes: json['notes'] as String?,
      availableActions: List<String>.from(
        json['available_actions'] ?? const [],
      ),
    );
  }
}

class ActionResponse {
  final String message;
  final String requestId;
  final String newStatus;
  final InterventionDetail detail;

  const ActionResponse({
    required this.message,
    required this.requestId,
    required this.newStatus,
    required this.detail,
  });

  factory ActionResponse.fromJson(Map<String, dynamic> json) {
    return ActionResponse(
      message: (json['message'] ?? '') as String,
      requestId: (json['request_id'] ?? '') as String,
      newStatus: (json['new_status'] ?? '') as String,
      detail: InterventionDetail.fromJson(
        (json['data'] as Map<String, dynamic>? ?? const {}),
      ),
    );
  }
}

class InterventoApiService {
  InterventoApiService({http.Client? client})
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
    final items = List<Map<String, dynamic>>.from(data['data'] ?? const []);
    return items.map(QueueRequest.fromJson).toList();
  }

  Future<DashboardSummary> setOperationalStatus(bool operativoOnline) async {
    final data = await _requestJson(
      'PATCH',
      '/dashboard/operational-status',
      body: {'operativo_online': operativoOnline},
    );
    return DashboardSummary.fromJson(data);
  }

  Future<InterventionDetail> getInterventoDetail(String requestId) async {
    final data = await _requestJson('GET', '/dettaglioIntervento/$requestId');
    return InterventionDetail.fromJson(
      (data['data'] as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<ActionResponse> takeInCharge(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/dettaglioIntervento/$requestId/take-in-charge',
    );
    return ActionResponse.fromJson(data);
  }

  Future<ActionResponse> reject(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/dettaglioIntervento/$requestId/reject',
    );
    return ActionResponse.fromJson(data);
  }

  Future<ActionResponse> complete(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/dettaglioIntervento/$requestId/complete',
    );
    return ActionResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    late final http.Response response;

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
      case 'POST':
        response = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body ?? const {}),
        );
        break;
      default:
        throw Exception('Metodo HTTP non supportato: $method');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(decoded['message'] ?? 'Errore API');
    }
    return decoded;
  }
}
