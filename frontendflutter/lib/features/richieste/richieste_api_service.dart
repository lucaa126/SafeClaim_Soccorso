import 'dart:async';
import '../../app/api_client.dart';
import 'richiesta_model.dart';

class RichiesteApiService {
  // Istanziamo il tuo client specifico
  final SafeClaimApiClient _apiClient = SafeClaimApiClient();

  Future<List<RichiestaIntervento>> fetchRichieste({String? stato}) async {
    try {
      final query = (stato != null && stato != "Tutte")
          ? '?stato=${Uri.encodeQueryComponent(stato)}'
          : '';
      final response = await _apiClient.requestJson('GET', '/richieste/$query');

      if (response['success'] == true) {
        final List data = response['data'] as List;
        return data.map((json) => RichiestaIntervento.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Errore nel recupero delle richieste');
      }
    } catch (e) {
      rethrow;
    }
  }
}