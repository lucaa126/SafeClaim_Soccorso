# 🔗 Flusso di Integrazione Completo SafeClaim

## 📊 Architettura Complessiva

```
┌─────────────────────────────────────────────────────────────────┐
│                    Frontend Flutter                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ UI Screens                                                 │ │
│  │  - Login Screen (email/password)                           │ │
│  │  - Dashboard Officina                                      │ │
│  │  - Dettaglio Intervento                                    │ │
│  │  - Lista Richieste                                         │ │
│  └────┬─────────────────────────────────────────┬─────────────┘ │
│       │                                          │                │
│  ┌────▼──────────────────────┐  ┌──────────────▼─────────────┐  │
│  │ LoginApiService           │  │ API Services               │  │
│  │ ├─ login()               │  │ ├─ DashboardApiService     │  │
│  │ ├─ refreshToken()        │  │ ├─ SoccorsoApiService      │  │
│  │ ├─ logout()              │  │ ├─ DettaglioInterventoApi  │  │
│  │ └─ getAccessToken()      │  │ └─ BackendAuthService      │  │
│  └────┬──────────────────────┘  └──────────────┬─────────────┘  │
│       │                                        │                  │
│  ┌────▼────────────────────────────────────────▼──────────────┐  │
│  │ AuthService (SharedPreferences)                           │  │
│  │ ├─ saveTokens()                                           │  │
│  │ ├─ getAccessToken()                                       │  │
│  │ ├─ hasValidAccessToken()                                  │  │
│  │ └─ clearSession()                                         │  │
│  └────┬─────────────────────────────────────────────────────┘   │
│       │ JWT Token in Authorization Header                       │
└───────┼──────────────────────────────────────────────────────────┘
        │
        │ HTTP/HTTPS
        │ Authorization: Bearer <JWT_TOKEN>
        │ Content-Type: application/json
        │
        ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Backend Flask (SafeClaim)                       │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Authentication Middleware                               │   │
│  │ ├─ Verifica JWT signature                               │   │
│  │ ├─ Verifica Keycloak JWKS                               │   │
│  │ ├─ Verifica audience (client_id)                        │   │
│  │ └─ Popola g.user con payload token                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          │                                       │
│         ┌────────────────┼────────────────┐                      │
│         │                │                │                      │
│    ┌────▼────┐      ┌────▼────┐     ┌────▼────┐                 │
│    │ Auth    │      │Dashboard│     │Soccorsi │     …           │
│    │Routes   │      │Routes   │     │Routes   │                 │
│    │         │      │         │     │         │                 │
│    │/status  │      │/summary │     │/        │                 │
│    │/validate│      │/requests│     │/<id>    │                 │
│    └────────┘      │/op-stat │     └────────┘                 │
│                    └────────┘                                   │
│                          │                                       │
│     ┌────────────────────┼────────────────────┐                 │
│     ▼                    ▼                    ▼                  │
│  ┌─────────┐      ┌──────────┐      ┌─────────────┐              │
│  │ Database│      │ Workshop │      │   Request   │              │
│  │ (SQLite)│      │   Model  │      │   Model     │              │
│  └─────────┘      └──────────┘      └─────────────┘              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Keycloak Integration                                     │   │
│  │ ├─ URL: https://keycloak.giobra.com/realms/safeClaim    │   │
│  │ ├─ Valida JWT via JWKS                                  │   │
│  │ └─ Estrae ruoli da realm_access + resource_access       │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
        ▲
        │ 1. Login: POST /token (grant_type=password)
        │
        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Keycloak Server                              │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Realm: safeClaim                                         │   │
│  │ Client: safeclaim-client                                │   │
│  │                                                          │   │
│  │ User: mario@example.com / admin123                      │   │
│  │ Ruoli: admin, automobilista, perito, officina, …        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flusso di Autenticazione Step-by-Step

### Fase 1: Login Iniziale

```
┌────────────────┐
│  Login Screen  │
│ mario@ex.com  │
│ password ****  │
└────────┬───────┘
         │ Utente clicca "Login"
         ▼
    ┌─────────────────────────────────┐
    │ LoginApiService.login()          │
    │ (email, password)               │
    └────────────┬────────────────────┘
                 │
                 ▼ HTTP POST
    ┌──────────────────────────────────────┐
    │ Keycloak: POST /token               │
    │ grant_type=password                 │
    │ username=mario@example.com          │
    │ password=****                       │
    │ client_id=safeclaim-client          │
    └────────────┬─────────────────────────┘
                 │
                 ▼ 200 OK
    ┌──────────────────────────────────────┐
    │ Response:                            │
    │ {                                    │
    │   "access_token": "eyJhbGc...",     │
    │   "refresh_token": "...",           │
    │   "expires_in": 3600,               │
    │   "token_type": "Bearer"            │
    │ }                                    │
    └────────────┬─────────────────────────┘
                 │
                 ▼ AuthService.saveTokens()
    ┌──────────────────────────────────────┐
    │ SharedPreferences:                   │
    │ - admin_token = "eyJhbGc..."       │
    │ - refresh_token = "..."             │
    │ - admin_token_expiry = ...           │
    └──────────────────────────────────────┘
```

### Fase 2: Validazione con Backend

```
┌───────────────────────────────┐
│ Token salvato in prefs        │
└────────────┬──────────────────┘
             │
             ▼ BackendAuthService.validateTokenWithBackend()
    ┌────────────────────────────────────┐
    │ HTTP GET /api/auth/status          │
    │ Authorization: Bearer <token>      │
    │ Content-Type: application/json     │
    └───────────┬──────────────────────┘
                │ Backend verifica JWT
                ├─ Signature OK?
                ├─ Audience OK?
                ├─ Not expired?
                │
                ▼ 200 OK
    ┌────────────────────────────────────┐
    │ Response:                          │
    │ {                                  │
    │   "message": "Token valido",      │
    │   "provider": "keycloak",         │
    │   "user": {                       │
    │     "sub": "user123",             │
    │     "email": "mario@ex.com",      │
    │     "preferred_username": "mario" │
    │   },                              │
    │   "roles": ["admin", "officina"]  │
    │ }                                  │
    └───────────┬───────────────────────┘
                │
                ▼ App salva ruoli localmente
    ┌────────────────────────────────────┐
    │ Redirect a Dashboard               │
    │ (se officina) o AdminPanel         │
    │ (se admin)                        │
    └────────────────────────────────────┘
```

### Fase 3: Richieste Successive (Dashboard)

```
┌─────────────────────────────────┐
│ Dashboard Screen LOAD           │
└────────────┬────────────────────┘
             │
             ▼ DashboardApiService.getDashboardSummary()
    ┌───────────────────────────────────┐
    │ HTTP GET /api/dashboard/summary   │
    │ Authorization: Bearer <token>    │
    └───────────┬─────────────────────┘
                │ Backend middleware:
                ├─ Verifica JWT
                ├─ Popola g.user
                ├─ @require_auth OK
                ├─ @require_role("officina") OK
                │
                ▼ 200 OK
    ┌───────────────────────────────────┐
    │ Response:                         │
    │ {                                 │
    │   "data": {                       │
    │     "workshop_name": "Officina", │
    │     "operativo_online": true,    │
    │     "kpi": {...},                │
    │     "selected_request_id": "..." │
    │   }                              │
    │ }                                 │
    └───────────┬─────────────────────┘
                │
                ▼ UI Aggiornata con dati
    ┌───────────────────────────────────┐
    │ Dashboard Visualizzata            │
    │ - KPI in tempo reale              │
    │ - Stato operativo                 │
    │ - Richieste in lista              │
    └───────────────────────────────────┘
```

---

## 🔑 Gestione Token

### Ciclo di Vita

```
┌─────────────────┐
│ Token Obtained  │
│ (Keycloak)      │
└────────┬────────┘
         │ Valido per 3600 sec (1 ora)
         │
         ▼
    ┌─────────────┐
    │ In uso       │  ← Richieste API con token
    │ (1 ora)      │
    └──────┬──────┘
           │ ~59 min
           │
           ▼
    ┌──────────────┐
    │ Prossimo a   │  ← hasValidAccessToken() = quasi falso
    │ scadere      │
    └──────┬───────┘
           │ + 1 min
           │
           ▼
    ┌────────────────────┐
    │ SCADUTO            │  ← hasValidAccessToken() = false
    │ 401 Unauthorized   │  ← Tutte le richieste falliscono
    └──────┬─────────────┘
           │
           ├─→ OPZIONE A: Refresh automatico
           │   ├─ LoginApiService.refreshToken()
           │   ├─ grant_type=refresh_token
           │   └─ Nuovo token + nuovo expiry
           │
           └─→ OPZIONE B: Redirect a login
               └─ AuthService.clearSession()
               └─ Logout utente
```

### Verifica Automatica

```dart
// Nel ApiClient prima di ogni richiesta
await _ensureValidToken(); // Controlla validità

Future<void> _ensureValidToken() async {
  if (await AuthService.hasValidAccessToken()) {
    return; // Token ancora valido ✓
  }

  final refreshToken = await AuthService.getRefreshToken();
  if (refreshToken == null) {
    await AuthService.clearSession();
    throw TokenInvalidException(); // Riporta al login
  }

  // Refresh automatico
  await LoginApiService.refreshToken(); // Nuovo token
}
```

---

## 📋 Codici di Stato HTTP

| Codice | Significato | Azione Flutter |
|--------|-------------|---|
| **200** | OK | Procedi, mostra dati |
| **201** | Created | Procedi, entità creata |
| **400** | Bad Request | Mostra errore validazione |
| **401** | Unauthorized | Token scaduto → Refresh o Logout |
| **403** | Forbidden | Utente non ha permessi per questa azione |
| **404** | Not Found | Entità non trovata |
| **409** | Conflict | Stato incompatibile per l'azione |
| **500** | Server Error | Riprova o mostra errore |
| **503** | Service Unavailable | Keycloak non configurato |

---

## 🛡️ Sicurezza

### Header Obbligatori

```
Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cC...<token>...
Content-Type: application/json
```

### Validazione Backend (Server-Side)

1. **JWT Signature**: Verifica con JWKS di Keycloak
2. **Audience (`aud`)**: Deve essere `safeclaim-client`
3. **Expiration (`exp`)**: Non scaduto
4. **Issuer (`iss`)**: Da Keycloak authorized server
5. **Ruoli**: Estratti da `realm_access.roles` + `resource_access.safeclaim-client.roles`

### Best Practices

✅ **Sempre usa HTTPS** in produzione
✅ **Non esporre token in log**
✅ **Usa refresh token per automatico rinnovo**
✅ **Timeout breve** (5 sec per connessione)
✅ **Valida su backend**, non solo client
✅ **Logout clearing**: Elimina token da SharedPreferences
✅ **CORS**: Configurato per soli domini autorizzati

---

## 🚀 Migrazione da Qualsiasi Servizio Esterno

Se attualmente usi un servizio mock per le API:

### Passo 1: Sostituisci Base URL

```dart
// Prima (mock)
const String baseUrl = 'https://mock-api.example.com/api';

// Dopo (backend reale)
const String baseUrl = 'https://glowing-funicular-v6ww5xrg44wcxvjg-5000.app.github.dev/api';
```

### Passo 2: Aggiungi Header Authorization

```dart
// Prima
final response = await http.get(uri);

// Dopo
final token = await AuthService.getAccessToken();
final response = await http.get(
  uri,
  headers: {'Authorization': 'Bearer $token'}
);
```

### Passo 3: Gestisci Errori 401

```dart
if (response.statusCode == 401) {
  await AuthService.clearSession();
  // Redirect a login
}
```

---

## 📞 Troubleshooting Rapido

| Problema | Causa Possibile | Soluzione |
|----------|---|---|
| "Token non valido" | JWT malformato | Verifica format token in Keycloak |
| 503 Service Unavailable | Keycloak non config | Controlla env vars backend |
| CORS error | Dominio non autorizzato | Aggiungi CORS header backend |
| Timeout | Network lento | Aumenta timeout in config |
| 403 Forbidden | Ruolo insufficiente | Verifica ruoli utente Keycloak |
| 404 Not Found | Endpoint sbagliato | Controlla path URL |
| 409 Conflict | Stato incompatibile | Leggi messaggio errore backend |

---

## 📚 Documentazione Rapida

- **Flutter Models**: `/frontendflutter/lib/models/`
- **Flutter Services**: `/frontendflutter/lib/app/*_api_service.dart`
- **Backend Docs HTML**: GET `/documentation`
- **Guida Frontend**: `/frontendflutter/INTEGRAZIONE_GUIDA.md`
- **Guida Backend**: `/INTEGRAZIONE_BACKEND.md`

---

## ✨ Prossimi Passi

1. ✅ Frontend Flutter: Modelli + Servizi API creati
2. ✅ Autenticazione Keycloak: Integrata
3. 🔄 **Backend Flask**: Implementare blueprint mancanti (vedi INTEGRAZIONE_BACKEND.md)
4. 🔄 **Test E2E**: Login → Dashboard → Interventi
5. 🔄 **Deployment**: Staging → Production
