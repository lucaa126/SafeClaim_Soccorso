import 'dart:async';
import '../../app/api_client.dart';
import 'richiesta_model.dart';

class RichiesteApiService {
  // Istanziamo il tuo client specifico
  final SafeClaimApiClient _apiClient = SafeClaimApiClient();

  Future<List<RichiestaIntervento>> fetchRichieste() async {
    try {
      // Usiamo requestJson del tuo SafeClaimApiClient
      // Sostituisci 'richieste_endpoint' con il path reale del tuo server
      final response = await _apiClient.requestJson(
        'GET', 
        'get_richieste.php', 
      );

      if (response['success'] == true) {
        final List data = response['data'] as List;
        return data.map((json) => RichiestaIntervento.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Errore nel recupero delle richieste');
      }
    } catch (e) {
      // L'errore verrà catturato dal blocco try-catch nella UI
      rethrow; 
    }
  }
}