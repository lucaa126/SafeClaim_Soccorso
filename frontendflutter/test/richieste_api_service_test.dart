import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/app/auth_service.dart';
import 'package:frontendflutter/features/richieste/richieste_api_service.dart';
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

  test('loads requests from soccorsi endpoint and filters locally', () async {
    final service = RichiesteApiService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/soccorsi/');

        return http.Response(
          jsonEncode({
            'count': 3,
            'data': [
              {
                'id': 1,
                'data_richiesta': '2026-05-11T11:17:08',
                'orario_arrivo': null,
                'stato': 'in_attesa',
              },
              {
                'id': 2,
                'data_richiesta': '2026-05-11T12:17:08',
                'orario_arrivo': null,
                'stato': 'in_corso',
              },
              {
                'id': 3,
                'data_richiesta': '2026-05-11T13:17:08',
                'orario_arrivo': '2026-05-11T14:17:08',
                'stato': 'completata',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final pending = await service.fetchRichieste(stato: 'Da Gestire');
    final all = await service.fetchRichieste(stato: 'Tutte');

    expect(pending, hasLength(1));
    expect(pending.single.stato, 'in_attesa');
    expect(all, hasLength(3));
  });
}
