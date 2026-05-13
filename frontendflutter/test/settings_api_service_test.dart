import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/app/auth_service.dart';
import 'package:frontendflutter/features/impostazioni/settings_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthService.saveTokens(
      accessToken: 'test-token',
      refreshToken: 'refresh-token',
      expiresIn: 3600,
    );
  });

  test(
    'loads settings from impostazioni endpoint without officina_id',
    () async {
      final service = SettingsApiService(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/impostazioni/');
          expect(request.url.query, isEmpty);

          return http.Response(
            jsonEncode({
              'status': 'success',
              'data': {
                'profilo': {
                  'nome': 'Soccorso SafeClaim',
                  'email_contatto': 'soccorso@safeclaim.it',
                  'telefono_contatto': '+39 02 1234567',
                  'avatar_url': 'https://example.com/avatar.png',
                },
                'parametri_operativi': {
                  'operativo_online': true,
                  'orario_inizio': '08:00',
                  'orario_fine': '18:30',
                  'max_coda': 12,
                  'accettazione_automatica': false,
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final settings = await service.getSettings();

      expect(settings.serviceName, 'Soccorso SafeClaim');
      expect(settings.operativoOnline, isTrue);
      expect(settings.maxCoda, 12);
    },
  );

  test('sends profile and operational patches without query', () async {
    final paths = <String>[];
    final service = SettingsApiService(
      client: MockClient((request) async {
        paths.add(request.url.path);
        expect(request.method, 'PATCH');
        expect(request.url.query, isEmpty);

        if (request.url.path == '/api/impostazioni/profilo') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['nome'], 'Centrale Soccorso');
          expect(body['avatar_url'], 'https://example.com/avatar.png');
        }

        if (request.url.path == '/api/impostazioni/parametri-operativi') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['operativo_online'], isTrue);
          expect(body['orario_inizio'], '08:00');
          expect(body['orario_fine'], '18:30');
          expect(body['max_coda'], 12);
          expect(body['accettazione_automatica'], isFalse);
        }

        return http.Response(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await service.updateProfile(
      serviceName: 'Centrale Soccorso',
      email: 'soccorso@safeclaim.it',
      phone: '+39 02 1234567',
      avatarUrl: 'https://example.com/avatar.png',
    );
    await service.updateOperationalParameters(
      operativoOnline: true,
      orarioInizio: '08:00',
      orarioFine: '18:30',
      maxCoda: 12,
      accettazioneAutomatica: false,
    );

    expect(paths, [
      '/api/impostazioni/profilo',
      '/api/impostazioni/parametri-operativi',
    ]);
  });
}
