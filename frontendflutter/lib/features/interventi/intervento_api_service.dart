import 'package:http/http.dart' as http;

import '../../app/api_client.dart';

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
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<InterventionDetail> getInterventoDetail(String requestId) async {
    final data = await _requestJson('GET', '/v1/sinistri/$requestId');
    return InterventionDetail.fromJson(
      (data['data'] as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<ActionResponse> takeInCharge(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/v1/sinistri/$requestId/prendi-in-carico',
    );
    return ActionResponse.fromJson(data);
  }

  Future<ActionResponse> reject(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/v1/sinistri/$requestId/rifiuta',
    );
    return ActionResponse.fromJson(data);
  }

  Future<ActionResponse> complete(String requestId) async {
    final data = await _requestJson(
      'POST',
      '/v1/sinistri/$requestId/completa',
    );
    return ActionResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _apiClient.requestJson(method, path, body: body);
  }
}
