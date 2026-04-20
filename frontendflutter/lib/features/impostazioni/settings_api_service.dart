import 'package:http/http.dart' as http;
import '../../app/api_client.dart';

class WorkshopSettings {
  final int officinaId;
  final String workshopName;
  final String email;
  final String phone;
  final String? address;
  final String? avatarUrl;
  final bool? notificheAttive;

  const WorkshopSettings({
    required this.officinaId,
    required this.workshopName,
    required this.email,
    required this.phone,
    this.address,
    this.avatarUrl,
    this.notificheAttive,
  });

  factory WorkshopSettings.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;
    final profilo = _asMap(payload['profilo']) ?? const <String, dynamic>{};
    final officina = _asMap(payload['officina']) ?? const <String, dynamic>{};
    final notifiche = _asMap(payload['notifiche']) ?? const <String, dynamic>{};

    return WorkshopSettings(
      officinaId: _asInt(officina['id']) ?? 0,
      workshopName: _asString(profilo['nome']) ?? '',
      email: _asString(profilo['email_contatto']) ??
          _asString(officina['email']) ??
          '',
      phone: _asString(profilo['telefono_contatto']) ??
          _asString(officina['telefono']) ??
          '',
      address: _asString(officina['indirizzo']),
      avatarUrl: _asString(profilo['avatar_url']),
      notificheAttive: _asNullableBool(notifiche['push']),
    );
  }
}

class SettingsApiService {
  SettingsApiService({http.Client? client})
      : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<WorkshopSettings> getSettings({
    required int officinaId,
  }) async {
    final data = await _apiClient.requestJson(
      'GET',
      '/impostazioni/?officina_id=$officinaId',
    );

    return WorkshopSettings.fromJson(data);
  }

  Future<WorkshopSettings> updateProfile({
    required int officinaId,
    required String workshopName,
    required String email,
    required String phone,
  }) async {
    final data = await _apiClient.requestJson(
      'PATCH',
      '/impostazioni/profilo?officina_id=$officinaId',
      body: {
        'nome': workshopName,
        'email_contatto': email,
        'telefono_contatto': phone,
      },
    );

    final payload = _asMap(data['data']) ?? data;

    return WorkshopSettings(
      officinaId: _asInt(payload['id']) ?? officinaId,
      workshopName: _asString(payload['nome']) ?? '',
      email: _asString(payload['email_contatto']) ?? '',
      phone: _asString(payload['telefono_contatto']) ?? '',
      avatarUrl: _asString(payload['avatar_url']),
      address: null,
      notificheAttive: null,
    );
  }

  Future<void> updateNotifications({
    required int officinaId,
    required bool push,
  }) async {
    await _apiClient.requestJson(
      'PATCH',
      '/impostazioni/notifiche?officina_id=$officinaId',
      body: {
        'push': push,
      },
    );
  }
}

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

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes' ||
        normalized == 'si';
  }
  return false;
}

bool? _asNullableBool(dynamic value) {
  if (value == null) return null;
  return _asBool(value);
}
