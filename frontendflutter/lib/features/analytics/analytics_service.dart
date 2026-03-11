class TrafficIncident {
  final String title;
  final String source;
  final DateTime pubDate;
  final String link;

  TrafficIncident({
    required this.title,
    required this.source,
    required this.pubDate,
    required this.link,
  });
}

class Review {
  final String author;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.author,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

class AnalyticsService {
  // Simula una chiamata API con un delay casuale
  Future<T> _simulateApiCall<T>(T data, {int minDelay = 300, int maxDelay = 800, String endpoint = 'API'}) async {
    final delay = minDelay + (DateTime.now().microsecond % (maxDelay - minDelay));
    print('🔵 [$endpoint] Inizio chiamata API...');
    print('   ⏱️  Delay: ${delay}ms');
    await Future.delayed(Duration(milliseconds: delay));
    print('✅ [$endpoint] Risposta ricevuta con successo');
    return data;
  }

  // ===== STATISTICHE RICHIESTE =====
  Future<int> getTotalRequests() async {
    return await _simulateApiCall(1250, endpoint: 'getTotalRequests');
  }

  Future<int> getPending() async {
    return await _simulateApiCall(325, endpoint: 'getPending');
  }

  Future<int> getAccepted() async {
    return await _simulateApiCall(350, endpoint: 'getAccepted');
  }

  Future<int> getHandled() async {
    return await _simulateApiCall(1085, endpoint: 'getHandled');
  }

  // ===== DATI STATISTICI =====
  Future<List<int>> getRequestsOverLastDays(int days) async {
    return await _simulateApiCall([120, 145, 132, 150, 110, 160, 140], endpoint: 'getRequestsOverLastDays');
  }

  int getMaxRequestsValue() {
    final values = [120, 145, 132, 150, 110, 160, 140];
    return values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
  }

  Future<int> getAverageHandlingTimeMinutes() async {
    return await _simulateApiCall(34, endpoint: 'getAverageHandlingTimeMinutes');
  }

  // ===== STATO FLOTTA =====
  Future<Map<String, int>> getFleetStatusCounts() async {
    return await _simulateApiCall({
      'available': 12,
      'busy': 8,
      'maintenance': 3,
    }, endpoint: 'getFleetStatusCounts');
  }

  // ===== RECENSIONI =====
  Future<List<Review>> getRecentReviews() async {
    return await _simulateApiCall([
      Review(
        author: 'Mario R.',
        rating: 5,
        comment: 'Servizio rapidissimo.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        author: 'Anna B.',
        rating: 4,
        comment: 'Attesa lunga ma risolto.',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Review(
        author: 'Giovanni M.',
        rating: 5,
        comment: 'Professionali e gentili.',
        date: DateTime.now(),
      ),
      Review(
        author: 'Elena S.',
        rating: 3,
        comment: 'Potrebbe essere più veloce.',
        date: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ], endpoint: 'getRecentReviews');
  }

  Future<double> getAverageRating() async {
    return await _simulateApiCall(4.25, endpoint: 'getAverageRating');
  }

  // ===== TRAFFICO LIVE =====
  Future<List<TrafficIncident>> getRealTimeTraffic(String city) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final now = DateTime.now();
    return [
      TrafficIncident(
        title: 'Incidente in tangenziale Est a Milano, code di 4 km',
        source: 'Ansa',
        pubDate: now.subtract(const Duration(minutes: 15)),
        link: 'https://example.com/1',
      ),
      TrafficIncident(
        title: 'Code sulla A4 in direzione Como, uscita al Castellano',
        source: 'Corriere',
        pubDate: now.subtract(const Duration(minutes: 8)),
        link: 'https://example.com/2',
      ),
      TrafficIncident(
        title: 'Strada chiusa – Via di Niguarda direzione centro città blocca il traffico',
        source: 'TMB',
        pubDate: now.subtract(const Duration(minutes: 3)),
        link: 'https://example.com/3',
      ),
      TrafficIncident(
        title: 'Incidente in A1 a Milano e Corsico, 3 è di 6 traffico bloccato',
        source: 'Ansa',
        pubDate: now.subtract(const Duration(minutes: 25)),
        link: 'https://example.com/4',
      ),
      TrafficIncident(
        title: 'Coda sulla circonvallazione esterna, senso unico alternato',
        source: 'Radio Lombardia',
        pubDate: now.subtract(const Duration(minutes: 30)),
        link: 'https://example.com/5',
      ),
    ];
  }

  // ===== CALCOLI PERCENTUALI =====
  double getPercentage(int value, int total) {
    if (total == 0) return 0.0;
    return (value / total) * 100;
  }
}
