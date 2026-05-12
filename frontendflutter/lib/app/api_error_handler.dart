/// Classe per gestire errori API comuni
class ApiErrorHandler {
  /// Interpreta il messaggio di errore e determina l'azione
  static ApiError parseError(Exception exception) {
    final message = exception.toString();

    // Errori token
    if (message.contains('Token scaduto') ||
        message.contains('Token non valido') ||
        message.contains('Sessione scaduta')) {
      return ApiError(
        code: 'TOKEN_EXPIRED',
        message: 'La tua sessione è scaduta. Effettua di nuovo il login.',
        isAuthError: true,
        shouldRedirectToLogin: true,
      );
    }

    // Errori permessi
    if (message.contains('Permesso negato') ||
        message.contains('non autorizzato')) {
      return ApiError(
        code: 'PERMISSION_DENIED',
        message: 'Non hai i permessi per questa azione.',
        isAuthError: true,
        shouldRedirectToLogin: false,
      );
    }

    // Errori non trovato
    if (message.contains('non trovato')) {
      return ApiError(
        code: 'NOT_FOUND',
        message: 'L\'elemento richiesto non esiste.',
        isRecoverable: false,
      );
    }

    // Errori Keycloak non configurato
    if (message.contains('Keycloak non configurato')) {
      return ApiError(
        code: 'KEYCLOAK_ERROR',
        message: 'Il servizio di autenticazione non è disponibile.',
        isServiceError: true,
      );
    }

    // Errori connessione
    if (message.contains('Errore di connessione') ||
        message.contains('timeout') ||
        message.contains('Failed to connect')) {
      return ApiError(
        code: 'CONNECTION_ERROR',
        message: 'Errore di connessione. Riprova più tardi.',
        isNetworkError: true,
        isRecoverable: true,
        shouldRetry: true,
      );
    }

    // Errori validazione (400)
    if (message.contains('400') || message.contains('Campi obbligatori')) {
      return ApiError(
        code: 'VALIDATION_ERROR',
        message: 'I dati inviati non sono validi.',
        isRecoverable: true,
      );
    }

    // Errori stato incompatibile (409)
    if (message.contains('409') ||
        message.contains('Azione non disponibile')) {
      return ApiError(
        code: 'CONFLICT',
        message: 'Azione non disponibile per lo stato corrente.',
        isRecoverable: true,
      );
    }

    // Errori server (500+)
    if (message.contains('500') || message.contains('Errore interno')) {
      return ApiError(
        code: 'SERVER_ERROR',
        message: 'Errore del server. Riprova più tardi.',
        isServiceError: true,
        shouldRetry: true,
      );
    }

    // Errore generico
    return ApiError(
      code: 'UNKNOWN',
      message: 'Si è verificato un errore: $message',
      isRecoverable: false,
    );
  }
}

/// Classe che rappresenta un errore API
class ApiError {
  final String code;
  final String message;

  /// Se true, l'errore riguarda l'autenticazione/autorizzazione
  final bool isAuthError;

  /// Se true, l'errore è dovuto a problemi di rete/connessione
  final bool isNetworkError;

  /// Se true, l'errore è dovuto a un problema del servizio backend
  final bool isServiceError;

  /// Se true, l'utente dovrebbe effettuare di nuovo il login
  final bool shouldRedirectToLogin;

  /// Se true, è consigliabile ritentare l'operazione
  final bool shouldRetry;

  /// Se true, l'errore potrebbe essere risolto dall'utente
  final bool isRecoverable;

  const ApiError({
    required this.code,
    required this.message,
    this.isAuthError = false,
    this.isNetworkError = false,
    this.isServiceError = false,
    this.shouldRedirectToLogin = false,
    this.shouldRetry = false,
    this.isRecoverable = true,
  });

  /// Restituisce il messaggio da mostrare all'utente
  String getUserMessage() {
    return message;
  }

  /// Restituisce il messaggio per i log
  String getLogMessage() {
    return '[$code] $message';
  }

  @override
  String toString() => getLogMessage();
}

/// Mixin per aggiungere funzionalità di error handling a qualsiasi servizio
mixin ApiErrorHandlingMixin {
  /// Gestisce un'eccezione e ritorna un errore strutturato
  ApiError handleError(Exception e) {
    return ApiErrorHandler.parseError(e);
  }

  /// Esegue un'operazione API con error handling
  Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    int maxRetries = 1,
  }) async {
    int retries = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        final error = handleError(e as Exception);

        // Riprova se consigliato e non abbiamo esaurito i tentativi
        if (error.shouldRetry && retries < maxRetries) {
          retries++;
          // Aspetta prima di ritentare (backoff)
          await Future.delayed(Duration(milliseconds: 500 * retries));
          continue;
        }

        // Se è un errore auth, fa un clear della sessione
        if (error.isAuthError) {
          // Questo dovrebbe essere implementato nel servizio che usa il mixin
          // onAuthError?.call();
        }

        rethrow;
      }
    }
  }
}

/// Classe per tracciare e loggare errori API
class ApiErrorTracker {
  static final List<ApiError> _errorHistory = [];
  static const int _maxHistorySize = 50;

  /// Registra un errore nella cronologia
  static void track(ApiError error) {
    _errorHistory.add(error);

    // Mantieni solo gli ultimi N errori
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }

    // Log
    print('🔴 ERROR TRACKED: ${error.getLogMessage()}');
  }

  /// Ottiene la cronologia degli errori
  static List<ApiError> getHistory() => List.unmodifiable(_errorHistory);

  /// Ottiene gli errori di un tipo specifico
  static List<ApiError> getErrorsByCode(String code) {
    return _errorHistory.where((e) => e.code == code).toList();
  }

  /// Pulisce la cronologia
  static void clear() {
    _errorHistory.clear();
  }

  /// Ottiene statistiche sugli errori
  static Map<String, int> getStatistics() {
    final stats = <String, int>{};
    for (final error in _errorHistory) {
      stats[error.code] = (stats[error.code] ?? 0) + 1;
    }
    return stats;
  }
}

/// Estensione per gestire ApiError in modo fluente
extension ApiErrorX on Future<void> {
  /// Cattura gli errori API e li gestisce
  void onApiError(void Function(ApiError error) handler) {
    catchError((e) {
      final error = ApiErrorHandler.parseError(e as Exception);
      ApiErrorTracker.track(error);
      handler(error);
    });
  }
}
