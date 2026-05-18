import 'package:http/http.dart' as http;

import '../../app/api_client.dart';

class WorkshopSettings {
  final String serviceName;
  final String email;
  final String phone;
  final String avatarUrl;
  final bool operativoOnline;
  final String orarioInizio;
  final String orarioFine;
  final int maxCoda;
  final bool accettazioneAutomatica;

  const WorkshopSettings({
    required this.serviceName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.operativoOnline,
    required this.orarioInizio,
    required this.orarioFine,
    required this.maxCoda,
    required this.accettazioneAutomatica,
  });

  factory WorkshopSettings.empty() {
    return const WorkshopSettings(
      serviceName: '',
      email: '',
      phone: '',
      avatarUrl: '',
      operativoOnline: false,
      orarioInizio: '',
      orarioFine: '',
      maxCoda: 0,
      accettazioneAutomatica: false,
    );
  }

  factory WorkshopSettings.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;
    final profilo = _asMap(payload['profilo']) ?? const <String, dynamic>{};
    final parametri =
        _asMap(payload['parametri_operativi']) ?? const <String, dynamic>{};

    return WorkshopSettings(
      serviceName: _asString(profilo['nome']) ?? '',
      email: _asString(profilo['email_contatto']) ?? '',
      phone: _asString(profilo['telefono_contatto']) ?? '',
      avatarUrl: _asString(profilo['avatar_url']) ?? '',
      operativoOnline: _asBool(parametri['operativo_online']),
      orarioInizio: _asString(parametri['orario_inizio']) ?? '',
      orarioFine: _asString(parametri['orario_fine']) ?? '',
      maxCoda: _asInt(parametri['max_coda']) ?? 0,
      accettazioneAutomatica: _asBool(parametri['accettazione_automatica']),
    );
  }
}

/// Dati dell'account loggato (sezione "Account" della pagina Impostazioni).
class AccountProfile {
  final int? id;
  final String nome;
  final String? cognome;
  final String email;
  final String telefono;
  final List<String> ruoli;

  const AccountProfile({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.telefono,
    required this.ruoli,
  });

  /// Il backend omette `cognome` se è blank — qui resta `null`.
  bool get hasCognome => cognome != null && cognome!.trim().isNotEmpty;

  factory AccountProfile.empty() => const AccountProfile(
    id: null, nome: '', cognome: null, email: '', telefono: '', ruoli: [],
  );

  factory AccountProfile.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']) ?? json;
    final ruoliRaw = payload['ruolo'];
    final ruoli = ruoliRaw is List
        ? ruoliRaw.map((e) => e.toString()).toList()
        : <String>[];

    return AccountProfile(
      id: _asInt(payload['id']),
      nome: _asString(payload['nome']) ?? '',
      cognome: _asString(payload['cognome']),
      email: _asString(payload['email']) ?? '',
      telefono: _asString(payload['telefono']) ?? '',
      ruoli: ruoli,
    );
  }
}

class SettingsApiService {
  SettingsApiService({http.Client? client})
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<WorkshopSettings> getSettings() async {
    final data = await _apiClient.requestJson('GET', '/v1/impostazioni/');
    return WorkshopSettings.fromJson(data);
  }

  Future<WorkshopSettings> updateProfile({
    required String serviceName,
    required String email,
    required String phone,
    required String avatarUrl,
  }) async {
    final data = await _apiClient.requestJson(
      'PATCH',
      '/v1/impostazioni/profilo',
      body: {
        'nome': serviceName,
        'email_contatto': email,
        'telefono_contatto': phone,
        'avatar_url': avatarUrl.isEmpty ? null : avatarUrl,
      },
    );

    return WorkshopSettings.fromJson(data);
  }

  Future<void> updateOperationalParameters({
    required bool operativoOnline,
    required String orarioInizio,
    required String orarioFine,
    required int maxCoda,
    required bool accettazioneAutomatica,
  }) async {
    await _apiClient.requestJson(
      'PATCH',
      '/v1/impostazioni/parametri-operativi',
      body: {
        'operativo_online': operativoOnline,
        'orario_inizio': orarioInizio.isEmpty ? null : orarioInizio,
        'orario_fine': orarioFine.isEmpty ? null : orarioFine,
        'max_coda': maxCoda,
        'accettazione_automatica': accettazioneAutomatica,
      },
    );
  }

  // ----- Account -------------------------------------------------------

  Future<AccountProfile> getAccount() async {
    final data = await _apiClient.requestJson('GET', '/v1/auth/me');
    return AccountProfile.fromJson(data);
  }

  Future<AccountProfile> updateAccount({
    String? nome,
    String? telefono,
  }) async {
    final body = <String, dynamic>{};
    if (nome != null) body['nome'] = nome;
    if (telefono != null) body['telefono'] = telefono;

    final data = await _apiClient.requestJson(
      'PATCH',
      '/v1/auth/me',
      body: body,
    );
    return AccountProfile.fromJson(data);
  }

  /// Cambia la password dell'utente loggato. Lancia eccezione con
  /// messaggio user-facing in caso di old_password errata.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.requestJson(
      'POST',
      '/v1/auth/me/password',
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
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
