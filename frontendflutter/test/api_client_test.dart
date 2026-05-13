import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/app/api_client.dart';
import 'package:frontendflutter/app/auth_service.dart';
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

  test('uses API message in thrown errors', () async {
    final client = SafeClaimApiClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Errore database'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(
      () => client.requestJson('GET', '/broken'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Errore database'),
        ),
      ),
    );
  });

  test('falls back to API error field when message is missing', () async {
    final client = SafeClaimApiClient(
      client: MockClient((request) async {
        return http.Response(
          jsonEncode({'error': 'INTERNAL_SERVER_ERROR'}),
          500,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(
      () => client.requestJson('GET', '/broken'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'error',
          contains('INTERNAL_SERVER_ERROR'),
        ),
      ),
    );
  });
}
