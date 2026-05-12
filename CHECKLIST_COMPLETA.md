# ✅ Checklist Completa - SafeClaim Frontend/Backend Integration

## 📌 Stato Attuale

### ✅ Completato - Frontend Flutter

- [x] **Modelli creati** (`lib/models/`)
  - [x] `auth_response.dart` - Risposte autenticazione
  - [x] `soccorso.dart` - Modello richieste soccorso
  - [x] `dashboard.dart` - Modelli dashboard

- [x] **Servizi API creati** (`lib/app/`)
  - [x] `backend_auth_service.dart` - Validazione token con backend
  - [x] `dashboard_api_service.dart` - Gestione dashboard
  - [x] `soccorso_api_service.dart` - Gestione richieste soccorso
  - [x] `dettaglio_intervento_api_service.dart` - Azioni interventi
  - [x] `api_error_handler.dart` - Gestione centralizzata errori

- [x] **Documentazione creata**
  - [x] `INTEGRAZIONE_GUIDA.md` - Come usare i servizi (Frontend)
  - [x] `README_INTEGRAZIONE.md` - Riepilogo frontend
  - [x] `example_dashboard_screen.dart` - Esempio implementazione UI

- [x] **Autenticazione**
  - [x] `LoginApiService` - Login con Keycloak (già c'era ✓)
  - [x] `AuthService` - Gestione token in SharedPreferences (già c'era ✓)
  - [x] Integrazione con `BackendAuthService` per validazione backend

---

### 🔄 Da Fare - Backend Flask

#### 🔴 PRIORITARIO

- [ ] **Implementare Blueprint Dashboard**
  ```
  POST /api/dashboard/summary
  POST /api/dashboard/requests
  PATCH /api/dashboard/operational-status
  ```
  
- [ ] **Implementare Blueprint Soccorsi**
  ```
  GET /api/soccorsi/
  GET /api/soccorsi/<id>
  GET /api/richieste/?status=...
  ```

- [ ] **Implementare Blueprint Dettaglio Intervento**
  ```
  GET /api/dettaglioIntervento/<id>
  POST /api/dettaglioIntervento/<id>/take-in-charge
  POST /api/dettaglioIntervento/<id>/reject
  POST /api/dettaglioIntervento/<id>/complete
  ```

#### 🟡 SECONDARIO

- [ ] Modelli ORM (SQLAlchemy)
- [ ] Database migration
- [ ] Logica business per calcolo KPI
- [ ] Test endpoint con Postman/curl
- [ ] Error handling globalizzato
- [ ] Logging strutturato

**Vedi: `INTEGRAZIONE_BACKEND.md`** per i dettagli implementativi

---

### 🟡 Da Fare - Frontend (UI Screens)

- [ ] **Login Screen**
  - [x] `LoginApiService` già implementato
  - [x] `AuthService` già implementato
  - [ ] UI view con email/password input
  - [ ] Validazione form
  - [ ] Error handling
  - [ ] Redirect a dashboard post-login

- [ ] **Dashboard Screen**
  - [x] Modello `DashboardSummary` creato
  - [x] Servizio `DashboardApiService` creato
  - [x] Esempio implementazione in `example_dashboard_screen.dart`
  - [ ] Integrazione UI reale nel progetto
  - [ ] RefreshIndicator per aggiornamento dati
  - [ ] Toggle stato operativo funzionante

- [ ] **Lista Richieste Screen**
  - [x] Modello `SoccorsoRequest` creato
  - [x] Servizio `SoccorsoApiService` creato
  - [ ] UI per visualizzare lista richieste
  - [ ] Filtri per stato

- [ ] **Dettaglio Intervento Screen**
  - [x] Modello `SoccorsoRequest` creato
  - [x] Servizio `DettaglioInterventoApiService` creato
  - [ ] UI con dettagli intervento
  - [ ] Pulsanti azioni (prendi in carico, rifiuta, completa)
  - [ ] Mappa con posizione (Map plugin)

#### State Management
- [ ] Setup Riverpod/Provider
- [ ] Provider per autenticazione
- [ ] Provider per dashboard
- [ ] Provider per richieste
- [ ] Invalidamento cache post-azioni

---

## 📋 Setup Inale - Passaggi

### Step 1: Backend - Database & Models (1-2 ore)

```python
# 1. Crea models/request.py
class Request(db.Model):
    id = db.Column(...)
    request_id = db.Column(..., unique=True)
    # ... altri campi

# 2. Crea models/workshop.py
class Workshop(db.Model):
    id = db.Column(...)
    name = db.Column(...)
    # ... altri campi

# 3. Migrazione database
flask db migrate
flask db upgrade
```

### Step 2: Backend - Blueprint Endpoint (2-3 ore)

```python
# 1. Crea file blueprint/dashboard_routes.py
@bp.get("/dashboard/summary")
@require_auth
@require_role("officina")
def get_dashboard_summary():
    # Query DB, calcola KPI, ritorna JSON

# 2. Crea file blueprint/soccorsi_routes.py
@bp.get("/soccorsi/")
@require_auth
def get_all_requests():
    # Query DB, ritorna liste

# 3. Crea file blueprint/dettaglio_intervento_routes.py
@bp.get("/dettaglioIntervento/<id>")
@bp.post("/dettaglioIntervento/<id>/take-in-charge")
# ... altri endpoint

# 4. Registra in app.py
app.register_blueprint(dashboard_bp, url_prefix="/api")
app.register_blueprint(soccorsi_bp, url_prefix="/api")
app.register_blueprint(intervento_bp, url_prefix="/api")
```

### Step 3: Backend - Test (1 hora)

```bash
# Test GET /api/dashboard/summary
curl -H "Authorization: Bearer <token>" \
  https://api.example.com/api/dashboard/summary

# Test POST /api/dettaglioIntervento/SOS-2491/take-in-charge
curl -X POST \
  -H "Authorization: Bearer <token>" \
  https://api.example.com/api/dettaglioIntervento/SOS-2491/take-in-charge
```

### Step 4: Frontend - State Management (1-2 ore)

```dart
// Configura Riverpod
final dashboardServiceProvider = Provider(...);
final dashboardSummaryProvider = FutureProvider(...);
// ...

// In main.dart
ProviderContainer app = ProviderContainer();
```

### Step 5: Frontend - UI Screens (2-3 ore)

```dart
// 1. Login Screen
// 2. Dashboard Screen (vedi example_dashboard_screen.dart)
// 3. Richieste List Screen
// 4. Dettaglio Intervento Screen
```

### Step 6: Test End-to-End (1-2 ore)

```
Login ✓
↓
Ottieni token JWT ✓
↓
Valida con backend ✓
↓
Carica dashboard ✓
↓
Visualizza KPI ✓
↓
Visualizza richieste ✓
↓
Prendi in carico intervento ✓
↓
Dashboard aggiorna KPI ✓
```

---

## 🚀 Deploy Timeline

| Fase | Stima | Stato |
|------|-------|-------|
| **Backend Models & DB** | 1-2h | ⏳ Da fare |
| **Backend Endpoints** | 2-3h | ⏳ Da fare |
| **Backend Testing** | 1h | ⏳ Da fare |
| **Frontend State** | 1-2h | ⏳ Da fare |
| **Frontend UI** | 2-3h | ⏳ Da fare |
| **E2E Testing** | 1-2h | ⏳ Da fare |
| **Staging Deploy** | 1h | ⏳ Da fare |
| **Production** | 1h | ⏳ Da fare |
| **TOTALE** | **11-17h** | ⏳ |

---

## 📁 File Structure Overview

```
SafeClaim_Soccorso/
├── INTEGRAZIONE_BACKEND.md          ✓ Guida backend
├── FLUSSO_INTEGRAZIONE.md           ✓ Architettura
│
│
├── frontend/                         (Esisting Angular)
│
│
└── frontendflutter/
    ├── lib/
    │   ├── app/
    │   │   ├── api_config.dart       ✓
    │   │   ├── auth_service.dart     ✓
    │   │   ├── api_client.dart       ✓
    │   │   ├── backend_auth_service.dart        ✓ NUOVO
    │   │   ├── dashboard_api_service.dart       ✓ NUOVO
    │   │   ├── soccorso_api_service.dart        ✓ NUOVO
    │   │   ├── dettaglio_intervento_api_service.dart  ✓ NUOVO
    │   │   └── api_error_handler.dart           ✓ NUOVO
    │   │
    │   ├── models/
    │   │   ├── auth_response.dart               ✓ NUOVO
    │   │   ├── soccorso.dart                    ✓ NUOVO
    │   │   └── dashboard.dart                   ✓ NUOVO
    │   │
    │   ├── features/
    │   │   ├── login/
    │   │   │   └── login_api_service.dart       ✓ (Già c'era, da testare)
    │   │   ├── dashboard/                       ⏳ (Creare screens)
    │   │   ├── richieste/                       ⏳ (Creare screens)
    │   │   └── intervento/                      ⏳ (Creare screens)
    │   │
    │   ├── main.dart                            ⏳ (Aggiornare con Riverpod)
    │   └── example_dashboard_screen.dart        ✓ NUOVO (Esempio)
    │
    ├── README_INTEGRAZIONE.md                   ✓ NUOVO
    └── INTEGRAZIONE_GUIDA.md                    ✓ NUOVO
```

---

## 🔗 Dipendenze da Aggiungere

### Frontend (`pubspec.yaml`)

Verifica che siano presenti:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP
  http: ^1.1.0
  
  # Stato
  flutter_riverpod: ^2.0.0
  riverpod: ^2.0.0
  
  # Storage
  shared_preferences: ^2.0.0
  
  # JSON
  json_serializable: ^6.0.0
  
  # Date/Time
  intl: ^0.19.0
  
  # Networking
  dio: ^5.0.0  # (Opzionale, alternativa a http)
```

### Backend (`requirements.txt`)

Verifica che siano presenti:

```
Flask==2.3.0
Flask-CORS==4.0.0
Flask-SQLAlchemy==3.0.0
PyJWT==2.8.0
python-jose[cryptography]==3.3.0
```

---

## 📞 Supporto & Documentazione

**Leggi questi file per:**

1. **Come implementare il backend**: `INTEGRAZIONE_BACKEND.md`
2. **Come usare i servizi frontend**: `INTEGRAZIONE_GUIDA.md`
3. **Come funziona l'architettura**: `FLUSSO_INTEGRAZIONE.md`
4. **Esempio implementazione UI**: `example_dashboard_screen.dart`
5. **Riepilogo frontend**: `README_INTEGRAZIONE.md`

---

## ✨ Next Steps

→ **[Leggi INTEGRAZIONE_BACKEND.md]** per iniziare l'implementazione backend

→ Implementa i 3 blueprint principali in Flask

→ Testa gli endpoint con curl/Postman

→ Integra i servizi nelle UI screen Flutter

→ Effettua test E2E completi

→ Deploy

---

## 🎯 Versione Finale

Quando tutto sarà completo:

✅ Utente effettua login con email/password
✅ Keycloak genera JWT token
✅ Token validato con backend
✅ Dashboard carica dati real-time
✅ Officina visualizza richieste in attesa
✅ Officina prende in carico intervento
✅ Intervento passa da "pending" a "accepted"
✅ Dashboard aggiorna KPI automaticamente
✅ Intervento completato
✅ Sistema pronto per la production ✨

---

**Data di creazione**: May 11, 2026
**Ultimo aggiornamento**: May 11, 2026
