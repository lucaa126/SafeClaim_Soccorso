/// Modello per una richiesta di soccorso
class SoccorsoRequest {
  final String id;
  final DateTime dataRichiesta;
  final DateTime? orarioArrivo;
  final String? cliente;
  final String? vehicleType;
  final String? vehicleLabel;
  final String? posizione;
  final double? lat;
  final double? lng;
  final String status;
  final String? statusText;
  final String? assignedDriver;
  final String? notes;
  final List<String> availableActions;

  const SoccorsoRequest({
    required this.id,
    required this.dataRichiesta,
    this.orarioArrivo,
    this.cliente,
    this.vehicleType,
    this.vehicleLabel,
    this.posizione,
    this.lat,
    this.lng,
    this.status = 'pending',
    this.statusText,
    this.assignedDriver,
    this.notes,
    this.availableActions = const [],
  });

  factory SoccorsoRequest.fromJson(Map<String, dynamic> json) {
    return SoccorsoRequest(
      id: json['id'] as String? ?? '',
      dataRichiesta: DateTime.tryParse(json['data_richiesta'] as String? ?? '') ??
          DateTime.now(),
      orarioArrivo: DateTime.tryParse(json['orario_arrivo'] as String? ?? ''),
      cliente: json['cliente'] as String?,
      vehicleType: json['vehicle_type'] as String?,
      vehicleLabel: json['vehicle_label'] as String?,
      posizione: json['posizione'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      statusText: json['status_text'] as String?,
      assignedDriver: json['assigned_driver'] as String?,
      notes: json['notes'] as String?,
      availableActions: List<String>.from(json['available_actions'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'data_richiesta': dataRichiesta.toIso8601String(),
        'orario_arrivo': orarioArrivo?.toIso8601String(),
        'cliente': cliente,
        'vehicle_type': vehicleType,
        'vehicle_label': vehicleLabel,
        'posizione': posizione,
        'lat': lat,
        'lng': lng,
        'status': status,
        'status_text': statusText,
        'assigned_driver': assignedDriver,
        'notes': notes,
        'available_actions': availableActions,
      };
}
