import 'package:http/http.dart' as http;
import '../../app/api_client.dart';

// --- MODELLO DEI DATI ---
class WorkshopSettings {
  final String workshopName;
  final String email;
  final String phone;
  final bool notificheAttive;

  const WorkshopSettings({
    required this.workshopName,
    required this.email,
    required this.phone,
    required this.notificheAttive,
  });

  factory WorkshopSettings.fromJson(Map<String, dynamic> json) {
    // Adattiamo il parsing alla struttura standard { "data": { ... } }
    final payload = _asMap(json['data']) ?? json;

    return WorkshopSettings(
      workshopName: _asString(payload['workshop_name']) ?? '',
      email: _asString(payload['email']) ?? '',
      phone: _asString(payload['phone']) ?? '',
      notificheAttive: _asBool(payload['notifiche_attive']),
    );
  }
}

// --- SERVIZIO API ---
class SettingsApiService {
  SettingsApiService({http.Client? client})
      : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  // Recupera le impostazioni
  Future<WorkshopSettings> getSettings() async {
    final data = await _apiClient.requestJson('GET', '/settings');
    return WorkshopSettings.fromJson(data);
  }

  // Aggiorna le impostazioni
  Future<WorkshopSettings> updateSettings({
    required String workshopName,
    required String email,
    required String phone,
    required bool notificheAttive,
  }) async {
    final data = await _apiClient.requestJson(
      'PATCH', // Cambia in POST o PUT se il tuo backend lo richiede
      '/settings',
      body: {
        'workshop_name': workshopName,
        'email': email,
        'phone': phone,
        'notifiche_attive': notificheAttive,
      },
    );
    return WorkshopSettings.fromJson(data);
  }
}

// --- HELPER DI PARSING (Gli stessi della Dashboard per sicurezza) ---
Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}