# GuiaIntegrazione Frontend Flutter - Backend SafeClaim

## 📋 Panoramica

Questa guida spiega come collegare il frontend Flutter al backend Flask per gestire autenticazione, dashboard, richieste di soccorso e interventi.

---

## 🔐 1. Autenticazione

### A. Login con Keycloak (già implementato)

Il `LoginApiService` comunica direttamente con Keycloak per ottenere il token JWT:

```dart
final loginService = LoginApiService();
try {
  final response = await loginService.login('mario@example.com', 'password');
  // Token salvato automaticamente in SharedPreferences
  print('Token: ${response.accessToken}');
  print('Scade in: ${response.expiresIn} secondi');
} catch (e) {
  print('Login fallito: $e');
}
```

### B. Validazione token con Backend

Dopo il login, valida il token tramite il backend per ottenere i dati utente e i ruoli:

```dart
import 'package:frontendflutter/app/backend_auth_service.dart';

final authService = BackendAuthService();
try {
  final authStatus = await authService.validateTokenWithBackend(token);
  
  print('User: ${authStatus.user.email}');
  print('Ruoli: ${authStatus.roles}');
  print('Provider: ${authStatus.provider}');
  
  // Salva i ruoli localmente se necessario
  final isAdmin = authStatus.roles.contains('admin');
} catch (e) {
  print('Token validazione fallita: $e');
}
```

### C. Verificare i Ruoli

```dart
final backendAuthService = BackendAuthService();

// Verifica un ruolo specifico
bool isAdmin = await backendAuthService.isAdmin();
bool isOfficina = await backendAuthService.isOfficina();

// Oppure verifica un ruolo custom
bool hasCustomRole = await backendAuthService.hasRole('assicuratore');

// Ottieni tutti i ruoli
List<String> roles = await backendAuthService.getCurrentUserRoles();
```

---

## 📊 2. Dashboard Soccorso

### A. Recuperare il Sommario della Dashboard

```dart
import 'package:frontendflutter/app/dashboard_api_service.dart';

final dashboardService = DashboardApiService();

try {
  final summary = await dashboardService.getDashboardSummary();
  
  print('Officina: ${summary.workshopName}');
  print('Online: ${summary.operativoOnline}');
  print('KPI - Richieste attive: ${summary.kpi.richiesteAttive}');
  print('KPI - Tempo medio: ${summary.kpi.tempoMedioMinuti} min');
  print('Richiesta selezionata: ${summary.selectedRequestId}');
} catch (e) {
  print('Errore: $e');
}
```

### B. Recuperare le Richieste in Dashboard

```dart
try {
  final response = await dashboardService.getDashboardRequests();
  
  print('Totale richieste: ${response.count}');
  
  for (var request in response.data) {
    print('ID: ${request.id}');
    print('Cliente: ${request.cliente}');
    print('Veicolo: ${request.vehicleLabel}');
    print('Posizione: ${request.posizione}');
    print('Status: ${request.statusText}');
    print('Azioni disponibili: ${request.availableActions}');
  }
} catch (e) {
  print('Errore: $e');
}
```

### C. Aggiornare lo Stato Operativo

```dart
try {
  // Metti offline
  final newStatus = await dashboardService.updateOperationalStatus(false);
  
  print('Officina ${newStatus.workshopName} è '
      '${newStatus.operativoOnline ? "ONLINE" : "OFFLINE"}');
} catch (e) {
  print('Errore aggiornamento stato: $e');
}
```

---

## 🚨 3. Gestione Soccorsi (Richieste)

### A. Recuperare Tutte le Richieste

```dart
import 'package:frontendflutter/app/soccorso_api_service.dart';

final soccorsoService = SoccorsoApiService();

try {
  final requests = await soccorsoService.getAllRequests();
  
  for (var request in requests) {
    print('${request.id} - ${request.cliente}');
    print('  Status: ${request.statusText}');
    print('  Posizione: ${request.posizione}');
    print('  Data: ${request.dataRichiesta}');
  }
} catch (e) {
  print('Errore: $e');
}
```

### B. Recuperare una Singola Richiesta

```dart
try {
  final request = await soccorsoService.getRequest('SOS-2491');
  
  print('Cliente: ${request.cliente}');
  print('Veicolo: ${request.vehicleLabel}');
  print('Note: ${request.notes}');
} catch (e) {
  print('Richiesta non trovata: $e');
}
```

### C. Filtrare Richieste per Stato

```dart
try {
  // Recupera solo le richieste in attesa
  final pending = await soccorsoService.getRequestsByStatus('in_attesa');
  
  // Recupera solo le richieste in corso
  final inProgress = await soccorsoService.getRequestsByStatus('in_corso');
  
  // Stati supportati: "in_attesa", "assegnata", "in_corso", "completata", "annullata"
  print('Richieste in attesa: ${pending.length}');
} catch (e) {
  print('Errore filtro: $e');
}
```

---

## 📍 4. Dettaglio Intervento (Azioni Soccorso)

### A. Recuperare Dettagli Intervento

```dart
import 'package:frontendflutter/app/dettaglio_intervento_api_service.dart';

final interventoService = DettaglioInterventoApiService();

try {
  final intervento = await interventoService.getIntervento('SOS-2491');
  
  print('ID: ${intervento.id}');
  print('Cliente: ${intervento.cliente}');
  print('Status: ${intervento.status}');
  print('Azioni disponibili: ${intervento.availableActions}');
  print('  - take_in_charge: prendi in carico');
  print('  - reject: rifiuta');
  print('  - complete: completa');
} catch (e) {
  print('Errore: $e');
}
```

### B. Prendere in Carico un Intervento

```dart
try {
  final updatedIntervento = await interventoService.takeInCharge('SOS-2491');
  
  print('Intervento preso in carico');
  print('Nuovo status: ${updatedIntervento.statusText}');
  print('Assegnato a: ${updatedIntervento.assignedDriver}');
} catch (e) {
  // Possibili errori:
  // "Intervento non trovato"
  // "Azione non disponibile per lo stato corrente"
  print('Errore: $e');
}
```

### C. Rifiutare un Intervento

```dart
try {
  final rejectedIntervento = await interventoService.reject('SOS-2491');
  
  print('Intervento rifiutato');
  print('Nuovo status: ${rejectedIntervento.statusText}');
} catch (e) {
  print('Errore: $e');
}
```

### D. Completare un Intervento

```dart
try {
  final completedIntervento = await interventoService.complete('SOS-2492');
  
  print('Intervento completato');
  print('Nuovo status: ${completedIntervento.statusText}');
  print('Tempo totale: ...'); // Calcola dal backend se necessario
} catch (e) {
  print('Errore: $e');
}
```

---

## 🔄 5. Gestione Errori e Token Scaduto

### A. Intercettare Token Scaduto

```dart
try {
  final summary = await dashboardService.getDashboardSummary();
} on Exception catch (e) {
  if (e.toString().contains('Sessione scaduta')) {
    // Token scaduto, effettua refresh
    try {
      final oldToken = await AuthService.getAccessToken();
      print('Token scaduto: $oldToken');
      
      // Il LoginApiService.refreshToken() sa come farlo
      // Oppure reindirizza il user a login
    } catch (_) {
      // Reindirizza al login
    }
  }
}
```

### B. Verificare Token Valido

```dart
import 'package:frontendflutter/app/backend_auth_service.dart';

final authService = BackendAuthService();
bool isValid = await authService.isTokenValid();

if (!isValid) {
  // Reindirizza al login
}
```

---

## 🛠️ 6. Integrazione in Provider/Riverpod

### Esempio con Provider (flutter_riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Servizi come provider
final backendAuthServiceProvider = Provider((ref) => BackendAuthService());
final dashboardServiceProvider = Provider((ref) => DashboardApiService());
final interventoServiceProvider = Provider((ref) => DettaglioInterventoApiService());

// Dati della dashboard
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDashboardSummary();
});

final dashboardRequestsProvider = FutureProvider<DashboardRequestsResponse>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDashboardRequests();
});

// Dati intervento
final interventoDetailsProvider = FutureProvider.family<SoccorsoRequest, String>((ref, requestId) async {
  final service = ref.watch(interventoServiceProvider);
  return service.getIntervento(requestId);
});

// Utilizzo in UI
@override
Widget build(BuildContext context, WidgetRef ref) {
  final summaryAsync = ref.watch(dashboardSummaryProvider);
  
  return summaryAsync.when(
    data: (summary) => Text('Officina: ${summary.workshopName}'),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('Errore: $error'),
  );
}
```

---

## 📱 7. Flusso Completo di Autenticazione

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Login con Keycloak
    Future<void> handleLogin(String email, String password) async {
      try {
        final loginService = LoginApiService();
        final response = await loginService.login(email, password);
        
        // 2. Token salvato automaticamente
        
        // 3. Valida con backend
        final backendAuthService = BackendAuthService();
        final authStatus = await backendAuthService.validateTokenWithBackend(
          response.accessToken,
        );
        
        // 4. Controlla ruoli
        if (authStatus.roles.contains('officina')) {
          // Reindirizza a dashboard officina
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (authStatus.roles.contains('admin')) {
          // Reindirizza a admin
          Navigator.pushReplacementNamed(context, '/admin');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login fallito: $e')),
        );
      }
    }
    
    return Container(); // Tuo widget
  }
}
```

---

## 📌 Riepilogo URL di Base

Il frontend usa questi base URL (in ordine di priorità):

1. `https://glowing-funicular-v6ww5xrg44wcxvjg-5000.app.github.dev/api` (dev)
2. `https://safeclaim.giobra.com/api` (fallback)

Tutti gli endpoint sono relativi a questi URL:
- `GET /dashboard/summary`
- `GET /dashboard/requests`
- `PATCH /dashboard/operational-status`
- `GET /soccorsi/`
- `GET /soccorsi/<id>`
- `GET /richieste/?status=<stato>`
- `GET /dettaglioIntervento/<id>`
- `POST /dettaglioIntervento/<id>/take-in-charge`
- `POST /dettaglioIntervento/<id>/reject`
- `POST /dettaglioIntervento/<id>/complete`

---

## ⚠️ Note Importanti

1. **Token JWT**: Ottenuto da Keycloak, salvato in SharedPreferences
2. **Header Authorization**: `Authorization: Bearer <token>`
3. **Timeout**: 5 secondi per default (configurabile in `SafeClaimApiConfig`)
4. **Errori 401**: Token scaduto → effettua logout o refresh
5. **Errori 503**: Keycloak non configurato nel backend
6. **Content-Type**: Sempre `application/json`

---

## 🔧 Troubleshooting

### "Token non valido o scaduto"
- Verifica che il token non sia scaduto: `await AuthService.hasValidAccessToken()`
- Effettua un refresh: `await loginService.refreshToken()`

### "Errore di connessione API su tutti i base URL"
- Verifica che il backend sia raggiungibile
- Controlla i base URL in `SafeClaimApiConfig`
- Verifica la connessione di rete

### "Sessione scaduta" su tutte le richieste
- Il token è scaduto: effettua refresh o login
- Keycloak potrebbe aver invalidato il token

### "Formato risposta API non valido (FormatException)"
- Il backend sta restituendo JSON malformato
- Controlla i log del backend
- Verifica che l'endpoint sia corretto
