/// Modello per il sommario dashboard soccorso
class DashboardSummary {
  final String workshopName;
  final bool operativoOnline;
  final KpiData kpi;
  final String? selectedRequestId;

  const DashboardSummary({
    required this.workshopName,
    required this.operativoOnline,
    required this.kpi,
    this.selectedRequestId,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      workshopName: json['workshop_name'] as String? ?? '',
      operativoOnline: json['operativo_online'] as bool? ?? false,
      kpi: KpiData.fromJson(json['kpi'] as Map<String, dynamic>? ?? {}),
      selectedRequestId: json['selected_request_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'workshop_name': workshopName,
        'operativo_online': operativoOnline,
        'kpi': kpi.toJson(),
        'selected_request_id': selectedRequestId,
      };
}

/// Modello per i KPI
class KpiData {
  final int richiesteAttive;
  final int completatiOggi;
  final int tempoMedioMinuti;

  const KpiData({
    required this.richiesteAttive,
    required this.completatiOggi,
    required this.tempoMedioMinuti,
  });

  factory KpiData.fromJson(Map<String, dynamic> json) {
    return KpiData(
      richiesteAttive: json['richieste_attive'] as int? ?? 0,
      completatiOggi: json['completati_oggi'] as int? ?? 0,
      tempoMedioMinuti: json['tempo_medio_minuti'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'richieste_attive': richiesteAttive,
        'completati_oggi': completatiOggi,
        'tempo_medio_minuti': tempoMedioMinuti,
      };
}

/// Risposta lista richieste dashboard
class DashboardRequestsResponse {
  final int count;
  final List<DashboardRequest> data;

  const DashboardRequestsResponse({
    required this.count,
    required this.data,
  });

  factory DashboardRequestsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardRequestsResponse(
      count: json['count'] as int? ?? 0,
      data: (json['data'] as List?)
              ?.map((e) => DashboardRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Modello per una richiesta nella dashboard
class DashboardRequest {
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

  const DashboardRequest({
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

  factory DashboardRequest.fromJson(Map<String, dynamic> json) {
    return DashboardRequest(
      id: json['id'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
      vehicleLabel: json['vehicle_label'] as String? ?? '',
      cliente: json['cliente'] as String? ?? '',
      posizione: json['posizione'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      statusText: json['status_text'] as String? ?? '',
      availableActions: List<String>.from(json['available_actions'] as List? ?? []),
    );
  }
}
