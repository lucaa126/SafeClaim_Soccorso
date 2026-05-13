import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontendflutter/app/auth_service.dart';
import 'package:frontendflutter/features/analytics/analytics_api_service.dart';
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

  test('keeps summary available when analytics endpoints fail', () async {
    final service = AnalyticsApiService(
      client: MockClient((request) async {
        switch (request.url.path) {
          case '/api/analytics/total-requests':
            return http.Response(
              jsonEncode({'total': 15}),
              200,
              headers: {'content-type': 'application/json'},
            );
          case '/api/analytics/pending':
            return http.Response(
              jsonEncode({'message': 'Unknown column status'}),
              500,
              headers: {'content-type': 'application/json'},
            );
          case '/api/analytics/accepted':
            return http.Response(
              jsonEncode({'error': 'NOT_IMPLEMENTED'}),
              501,
              headers: {'content-type': 'application/json'},
            );
          case '/api/analytics/handled':
            return http.Response(
              jsonEncode({'error': 'NOT_FOUND'}),
              404,
              headers: {'content-type': 'application/json'},
            );
        }

        return http.Response('{}', 404);
      }),
    );

    final summary = await service.getAnalyticsSummary();

    expect(summary.total, 15);
    expect(summary.pending, 0);
    expect(summary.accepted, 0);
    expect(summary.handled, 0);
    expect(summary.last7Days, isEmpty);
  });

  test(
    'returns empty optional analytics lists when endpoints are missing',
    () async {
      final service = AnalyticsApiService(
        client: MockClient((request) async {
          return http.Response(
            jsonEncode({'error': 'NOT_FOUND'}),
            404,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(await service.getRecentReviews(), isEmpty);
      expect(await service.getRealTimeTraffic('Milano'), isEmpty);
    },
  );
}
