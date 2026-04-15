import 'package:http/http.dart' as http;
import '../../app/api_client.dart';

// --- MODELLO DATI ---

class Vehicle {
  final int id; // Cambiato da String a int
  final String name;
  final String targa; // Rinominato da plate a targa per matchare l'API
  final String status;
  
  // Questi campi non sono presenti nel tuo esempio di risposta API. 
  // Li rendo opzionali per evitare errori di logica.
  final String? driver;
  final double? lat;
  final double? lng;

  const Vehicle({
    required this.id,
    required this.name,
    required this.targa,
    required this.status,
    this.driver,
    this.lat,
    this.lng,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // L'API restituisce i dati "flat", non serve cercare 'data' a meno che 
    // il tuo SafeClaimApiClient non faccia un wrapping automatico.
    final payload = json; 

    return Vehicle(
      id: _asInt(payload['id']),
      name: _asString(payload['name']) ?? 'Veicolo Sconosciuto',
      targa: _asString(payload['targa']) ?? 'N/A', // Usiamo 'targa'
      status: _asString(payload['status']) ?? 'available',
      driver: _asString(payload['driver']),
      lat: _asDouble(payload['lat']),
      lng: _asDouble(payload['lng']),
    );
  }
}

// --- SERVICE API ---

class FlottaApiService {
  final SafeClaimApiClient _apiClient;

  FlottaApiService({http.Client? client})
      : _apiClient = SafeClaimApiClient(client: client);

  /// Recupera la lista completa dei veicoli
  Future<List<Vehicle>> getFleet() async {
    // Nota: Ho aggiunto 'api' al percorso come da tua specifica /api/flotta/
    final dynamic data = await _requestJson('GET', '/api/flotta/');
    
    if (data is List) {
      return data
          .map((item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  /// Recupera i dettagli di un singolo veicolo
  Future<Vehicle> getVehicle(int vehicleId) async {
    final data = await _requestJson('GET', '/api/flotta/$vehicleId');
    return Vehicle.fromJson(Map<String, dynamic>.from(data));
  }

  /// Invia la richiesta di contatto per un autista
  Future<Map<String, dynamic>> contactDriver(String driverName) async {
    return await _requestJson(
      'POST',
      '/api/flotta/contact',
      body: {'driver': driverName},
    );
  }

  Future<dynamic> _requestJson(String method, String path, {Map<String, dynamic>? body}) async {
    return _apiClient.requestJson(method, path, body: body);
  }
}