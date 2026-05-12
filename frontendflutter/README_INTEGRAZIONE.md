# 📱 SafeClaim Frontend Flutter - Integrazione Backend

## ✨ Cosa è Stato Aggiunto

### 📂 Nuovi Modelli (`lib/models/`)

| File | Descrizione |
|------|---|
| `auth_response.dart` | Modelli per risposte autenticazione backend (`AuthStatusResponse`, `UserInfo`, `ValidateTokenResponse`) |
| `soccorso.dart` | Modello `SoccorsoRequest` per le richieste di soccorso |
| `dashboard.dart` | Modelli per dashboard (`DashboardSummary`, `KpiData`, `DashboardRequest`) |

### 🔧 Nuovi Servizi (`lib/app/`)

| File | Descrizione | Utilizzo |
|------|---|---|
| `backend_auth_service.dart` | Comunica con `/api/auth/*` del backend | Validare Keycloak token tramite backend |
| `dashboard_api_service.dart` | Comunica con `/api/dashboard/*` | Recuperare sommario, richieste, stato operativo |
| `soccorso_api_service.dart` | Comunica con `/api/soccorsi/*` e `/api/richieste/*` | Recuperare richieste di soccorso |
| `dettaglio_intervento_api_service.dart` | Comunica con `/api/dettaglioIntervento/*` | Gestire azioni intervento (presa in carico, rifiuto, completamento) |

### 📚 Guide e Documentazione

| File | Ubicazione | Contenuto |
|------|---|---|
| `INTEGRAZIONE_GUIDA.md` | `frontendflutter/` | **Guida pratica Flutter** - Come usare i nuovi servizi con esempi |
| `INTEGRAZIONE_BACKEND.md` | Root | **Guida implementazione Backend** - Pattern e blueprint Flask da implementare |
| `FLUSSO_INTEGRAZIONE.md` | Root | **Flusso e architettura** - Diagrammi, ciclo di vita token, troubleshooting |

---

## 🚀 Quick Start - Usare i Nuovi Servizi

### 1️⃣ Validare Token Dopo Login

```dart
import 'package:frontendflutter/app/backend_auth_service.dart';

// Dopo il login Keycloak
final backendAuthService = BackendAuthService();
final authStatus = await backendAuthService.validateTokenWithBackend(token);

// Ora sai i ruoli dell'utente
print('Ruoli: ${authStatus.roles}');
```

### 2️⃣ Recuperare Dashboard

```dart
import 'package:frontendflutter/app/dashboard_api_service.dart';

final dashboardService = DashboardApiService();
final summary = await dashboardService.getDashboardSummary();
final requests = await dashboardService.getDashboardRequests();

// Aggiorna stato operativo
await dashboardService.updateOperationalStatus(true); // Online
```

### 3️⃣ Gestire Interventi

```dart
import 'package:frontendflutter/app/dettaglio_intervento_api_service.dart';

final interventoService = DettaglioInterventoApiService();

// Recupera dettagli
var intervento = await interventoService.getIntervento('SOS-2491');

// Prendi in carico
intervento = await interventoService.takeInCharge('SOS-2491');

// Oppure completa
intervento = await interventoService.complete('SOS-2491');
```

---

## 📍 Struttura File Creati

```
frontendflutter/
├── lib/
│   ├── app/
│   │   ├── api_config.dart          (✓ Già c'era)
│   │   ├── auth_service.dart        (✓ Già c'era)
│   │   ├── api_client.dart          (✓ Già c'era)
│   │   ├── backend_auth_service.dart        (✨ NUOVO)
│   │   ├── dashboard_api_service.dart       (✨ NUOVO)
│   │   ├── soccorso_api_service.dart        (✨ NUOVO)
│   │   └── dettaglio_intervento_api_service.dart  (✨ NUOVO)
│   │
│   └── models/
│       ├── auth_response.dart       (✨ NUOVO)
│       ├── soccorso.dart            (✨ NUOVO)
│       └── dashboard.dart           (✨ NUOVO)
│
└── INTEGRAZIONE_GUIDA.md           (✨ NUOVO)
```

---

## 🔐 Flusso di Autenticazione

```
┌─────────────────────────────────────────────────────────────┐
│ 1. LOGIN                                                     │
│    LoginApiService.login(email, password)                   │
│    → Keycloak restituisce JWT token                         │
│    → Salvato in SharedPreferences                           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. VALIDAZIONE BACKEND                                      │
│    BackendAuthService.validateTokenWithBackend(token)       │
│    → GET /api/auth/status con Bearer token                  │
│    → Backend verifica JWT con Keycloak                      │
│    → Ritorna info utente + ruoli                           │
└─────────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. USA I SERVIZI API                                        │
│    - DashboardApiService                                    │
│    - SoccorsoApiService                                     │
│    - DettaglioInterventoApiService                          │
│                                                              │
│    Tutti hanno token in Authorization header                │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚙️ Configurazione

Niente da configurare! I servizi usano automaticamente:

- **Base URL**: Da `SafeClaimApiConfig.baseUrls` 
- **Token**: Da `AuthService.getAccessToken()`
- **Timeout**: 5 secondi (configurabile in `SafeClaimApiConfig.requestTimeout`)
- **Header**: `Authorization: Bearer <token>` + `Content-Type: application/json`

---

## 🧪 Testing

### Test Login + Validazione

```dart
void testLoginAndValidate() async {
  // 1. Login
  final loginService = LoginApiService();
  final response = await loginService.login(
    'mario@example.com',
    'admin123'
  );
  
  // 2. Valida con backend
  final backendAuth = BackendAuthService();
  final authStatus = await backendAuth.validateTokenWithBackend(
    response.accessToken
  );
  
  assert(authStatus.roles.contains('officina')); // ✓
  print('✓ Login e validazione riuscito');
}
```

### Test Dashboard

```dart
void testDashboard() async {
  final dashboardService = DashboardApiService();
  
  // Recupera sommario
  final summary = await dashboardService.getDashboardSummary();
  assert(summary.workshopName.isNotEmpty); // ✓
  
  // Recupera richieste
  final requests = await dashboardService.getDashboardRequests();
  assert(requests.count >= 0); // ✓
  
  print('✓ Dashboard test riuscito');
}
```

---

## 📋 Prossimi Passi

### Per Frontend:

1. **Integra servizi nei provider/state** (Riverpod, Provider, etc.)
2. **Aggiungi UI per:**
   - Login screen (usa `LoginApiService` - già c'era)
   - Dashboard con KPI (usa `DashboardApiService`)
   - Lista richieste (usa `SoccorsoApiService`)
   - Dettaglio intervento con azioni (usa `DettaglioInterventoApiService`)
3. **Error handling per:**
   - Token scaduto (401)
   - Permessi insufficienti (403)
   - Connessione fallita

### Per Backend:

Vedi **`INTEGRAZIONE_BACKEND.md`** per:
- ✅ Implementare gli endpoint `/api/dashboard/*`
- ✅ Implementare gli endpoint `/api/soccorsi/*`
- ✅ Implementare gli endpoint `/api/dettaglioIntervento/*`
- ✅ Creare i modelli ORM (SQLAlchemy)
- ✅ Registrare i blueprint

---

## 📖 Leggi la Documentazione

| Documento | Per |
|-----------|---|
| `INTEGRAZIONE_GUIDA.md` | Sviluppatori Flutter - come usare i servizi |
| `INTEGRAZIONE_BACKEND.md` | Sviluppatori Backend - come implementare endpoint |
| `FLUSSO_INTEGRAZIONE.md` | Tutti - capire l'architettura e il flusso |

---

## ✅ Checklist Implementazione

- [x] Modelli Flutter creati
- [x] Servizi API creati
- [x] Autenticazione backend service creato
- [x] Documentazione guida Flutter
- [x] Documentazione guida Backend
- [x] Documentazione flusso architettura
- [ ] Backend: Implementare endpoint (vedi INTEGRAZIONE_BACKEND.md)
- [ ] Frontend: Integrare servizi in schermate UI
- [ ] Test end-to-end con backend reale
- [ ] Deploy staging

---

## 🔗 Link Importanti

- **Backend Docs (HTML)**: `GET /documentation`
- **Keycloak**: `https://keycloak.giobra.com`
- **Base URL Dev**: `https://glowing-funicular-v6ww5xrg44wcxvjg-5000.app.github.dev/api`
- **Base URL Prod**: `https://safeclaim.giobra.com/api`

---

## 💡 Supporto

Per domande su come usare i servizi, leggi:
- `INTEGRAZIONE_GUIDA.md` sezione "Troubleshooting Rapido"
- `FLUSSO_INTEGRAZIONE.md` sezione "Gestione Token"

Per implementare backend endpoints, leggi:
- `INTEGRAZIONE_BACKEND.md`
