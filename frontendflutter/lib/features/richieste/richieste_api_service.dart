import 'dart:async';
import 'package:http/http.dart' as http;

import '../../app/api_client.dart';
import 'richiesta_model.dart';

class RichiesteApiService {
  RichiesteApiService({http.Client? client})
    : _apiClient = SafeClaimApiClient(client: client);

  final SafeClaimApiClient _apiClient;

  Future<List<RichiestaIntervento>> fetchRichieste({String? stato}) async {
    try {
      final response = await _apiClient.requestJson('GET', '/soccorsi/');

      final rawItems = response['data'] is List
          ? response['data'] as List
          : const [];
      final richieste = rawItems
          .whereType<Map>()
          .map(
            (item) =>
                RichiestaIntervento.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();

      final normalizedFilter = _statusForFilter(stato);
      if (normalizedFilter == null) {
        return richieste;
      }

      return richieste
          .where((richiesta) => richiesta.stato == normalizedFilter)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  String? _statusForFilter(String? filter) {
    switch (filter) {
      case 'Da Gestire':
        return 'in_attesa';
      case 'In Corso':
        return 'in_corso';
      case 'Completate':
        return 'completata';
      default:
        return null;
    }
  }
}
