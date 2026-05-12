# Guida Backend - Integrazione SafeClaim Flask

## 📋 Panoramica

Questa guida spiega come completare l'implementazione del backend Flask per supportare completamente il frontend Flutter.

---

## ✅ Cosa è Già Implementato

✔️ **Autenticazione Keycloak JS** (`token_service.py`)
- `require_auth`: Decorator per verificare JWT
- `require_role`: Decorator per verificare i ruoli
- `get_roles`: Estrae ruoli dal token

✔️ **Endpoint Auth** (`auth.py`)
- `GET /api/auth/status`: Verifica token e ritorna info utente
- `POST /api/auth/validate`: Valida token completo

✔️ **Documentazione** (`documentation.py`)
- HTML interattivo con tutti gli endpoint

---

## 🚀 Pattern da Seguire per i Nuovi Endpoint

Ecco il pattern standard per implementare endpoint protetti:

```python
from flask import Blueprint, jsonify, g, request
from app.services.token_service import require_auth, require_role

bp = Blueprint("example", __name__)

@bp.get("/example/protected")
@require_auth
def example_protected():
    """
    Endpoint protetto da autenticazione.
    Require: Bearer token nell'header Authorization
    """
    # g.user contiene il payload del token
    user_id = g.user.get("sub")
    email = g.user.get("email")
    
    return jsonify({
        "message": "Accesso consentito",
        "user_id": user_id,
        "email": email,
    }), 200


@bp.get("/example/admin-only")
@require_auth
@require_role("admin")
def example_admin_only():
    """
    Endpoint accessibile solo da admin.
    """
    return jsonify({
        "message": "Accesso admin consentito",
    }), 200
```

---

## 📊 Implementazione Blueprint Principali

### 1. Dashboard Soccorso (`dashboard_routes.py`)

```python
from flask import Blueprint, jsonify, g
from app.services.token_service import require_auth, require_role
from app.models import (
    Workshop, Request, Status  # ORM models
)

bp = Blueprint("dashboard", __name__)

@bp.get("/dashboard/summary")
@require_auth
@require_role("officina")
def get_dashboard_summary():
    """
    Recupera il sommario della dashboard dell'officina.
    
    Response: 200 OK
    {
        "data": {
            "workshop_name": "Officina Centrale",
            "operativo_online": true,
            "kpi": {
                "richieste_attive": 2,
                "completati_oggi": 1,
                "tempo_medio_minuti": 34
            },
            "selected_request_id": "SOS-2491"
        }
    }
    """
    workshop_id = g.user.get("sub")  # o come identifichi l'officina
    
    try:
        # Query il DB per l'officina
        workshop = Workshop.query.get(workshop_id)
        if not workshop:
            return jsonify({"error": "Officina non trovata"}), 404
        
        # Calcola KPI
        active_requests = Request.query.filter(
            Request.workshop_id == workshop_id,
            Request.status.in_(["pending", "accepted"])
        ).count()
        
        completed_today = Request.query.filter(
            Request.workshop_id == workshop_id,
            Request.status == "handled",
            Request.completed_at >= today_start
        ).count()
        
        # TODO: Calcola tempo_medio_minuti dal DB
        avg_time = 34
        
        return jsonify({
            "data": {
                "workshop_name": workshop.name,
                "operativo_online": workshop.is_online,
                "kpi": {
                    "richieste_attive": active_requests,
                    "completati_oggi": completed_today,
                    "tempo_medio_minuti": avg_time
                },
                "selected_request_id": workshop.selected_request_id
            }
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.get("/dashboard/requests")
@require_auth
@require_role("officina")
def get_dashboard_requests():
    """
    Recupera la lista delle richieste per la dashboard.
    """
    workshop_id = g.user.get("sub")
    
    try:
        requests = Request.query.filter(
            Request.workshop_id == workshop_id,
            Request.status.in_(["pending", "accepted"])
        ).all()
        
        return jsonify({
            "count": len(requests),
            "data": [
                {
                    "id": r.request_id,
                    "vehicle_type": r.vehicle_type,
                    "vehicle_label": r.vehicle_label,
                    "cliente": r.client_name,
                    "posizione": r.location,
                    "lat": r.latitude,
                    "lng": r.longitude,
                    "status": r.status,
                    "status_text": _format_status(r.status),
                    "available_actions": _get_available_actions(r.status)
                }
                for r in requests
            ]
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.patch("/dashboard/operational-status")
@require_auth
@require_role("officina")
def update_operational_status():
    """
    Aggiorna lo stato operativo (online/offline) dell'officina.
    
    Request body:
    {
        "operativo_online": boolean
    }
    """
    data = request.get_json() or {}
    new_status = data.get("operativo_online")
    
    if not isinstance(new_status, bool):
        return jsonify({"error": "Il campo 'operativo_online' deve essere booleano"}), 400
    
    workshop_id = g.user.get("sub")
    
    try:
        workshop = Workshop.query.get(workshop_id)
        if not workshop:
            return jsonify({"error": "Officina non trovata"}), 404
        
        workshop.is_online = new_status
        db.session.commit()
        
        # Ritorna i dati aggiornati
        return jsonify({
            "message": "Stato operativo aggiornato",
            "data": {
                "workshop_name": workshop.name,
                "operativo_online": workshop.is_online,
                "kpi": {...},  # Ricalcola
                "selected_request_id": workshop.selected_request_id
            }
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def _format_status(status: str) -> str:
    """Converte lo stato tecnico in descrizione leggibile."""
    status_map = {
        "pending": "In attesa di presa in carico",
        "accepted": "Intervento assegnato",
        "rejected": "Intervento rifiutato",
        "handled": "Intervento completato",
    }
    return status_map.get(status, status)


def _get_available_actions(status: str) -> list:
    """Determina le azioni disponibili in base allo stato."""
    actions_map = {
        "pending": ["take_in_charge", "reject"],
        "accepted": ["complete", "reject"],
        "rejected": [],
        "handled": [],
    }
    return actions_map.get(status, [])
```

### 2. Soccorsi/Richieste (`soccorsi_routes.py`)

```python
from flask import Blueprint, jsonify, g, request
from app.services.token_service import require_auth
from app.models import Request

bp = Blueprint("soccorsi", __name__)

@bp.get("/soccorsi/")
@require_auth
def get_all_requests():
    """Recupera tutte le richieste di soccorso."""
    try:
        requests = Request.query.order_by(Request.created_at.desc()).all()
        
        return jsonify({
            "count": len(requests),
            "data": [
                {
                    "id": r.request_id,
                    "data_richiesta": r.created_at.isoformat(),
                    "orario_arrivo": r.arrival_time.isoformat() if r.arrival_time else None,
                    # ...altri campi
                }
                for r in requests
            ]
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.get("/soccorsi/<request_id>")
@require_auth
def get_request_detail(request_id: str):
    """Recupera i dettagli di una singola richiesta."""
    try:
        soccorso = Request.query.get(request_id)
        if not soccorso:
            return jsonify({"error": "Richiesta non trovata"}), 404
        
        return jsonify({
            "id": soccorso.request_id,
            # ...
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.get("/richieste/")
@require_auth
def get_requests_by_status():
    """
    Recupera richieste filtrate per stato.
    
    Query params:
    - status: in_attesa, assegnata, in_corso, completata, annullata
    """
    status = request.args.get("status", "")
    
    if status and status not in ["in_attesa", "assegnata", "in_corso", "completata", "annullata"]:
        return jsonify({"error": "Stato non valido"}), 400
    
    try:
        query = Request.query
        if status:
            status_map = {
                "in_attesa": "pending",
                "assegnata": "assigned",
                "in_corso": "in_progress",
                "completata": "handled",
                "annullata": "rejected",
            }
            query = query.filter(Request.status == status_map.get(status))
        
        requests = query.all()
        
        return jsonify({
            "success": True,
            "count": len(requests),
            "data": [...]
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
```

### 3. Dettaglio Intervento (`dettaglio_intervento_routes.py`)

```python
from flask import Blueprint, jsonify, g
from app.services.token_service import require_auth, require_role
from app.models import Request

bp = Blueprint("dettaglioIntervento", __name__)

@bp.get("/dettaglioIntervento/<request_id>")
@require_auth
def get_intervento(request_id: str):
    """Recupera i dettagli di un intervento."""
    try:
        intervento = Request.query.get(request_id)
        if not intervento:
            return jsonify({"error": "Intervento non trovato"}), 404
        
        return jsonify({
            "data": {
                "id": intervento.request_id,
                "cliente": intervento.client_name,
                "vehicle_type": intervento.vehicle_type,
                "vehicle_label": intervento.vehicle_label,
                "status": intervento.status,
                "status_text": _format_status(intervento.status),
                "lat": intervento.latitude,
                "lng": intervento.longitude,
                "posizione": intervento.location,
                "requested_at": intervento.created_at.isoformat(),
                "assigned_driver": intervento.assigned_driver,
                "notes": intervento.notes,
                "available_actions": _get_available_actions(intervento.status)
            }
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.post("/dettaglioIntervento/<request_id>/take-in-charge")
@require_auth
@require_role("officina")
def take_in_charge(request_id: str):
    """Prende in carico un intervento."""
    workshop_id = g.user.get("sub")
    
    try:
        intervento = Request.query.get(request_id)
        if not intervento:
            return jsonify({"error": "Intervento non trovato"}), 404
        
        if intervento.status != "pending":
            return jsonify({"error": "Azione non disponibile per lo stato corrente"}), 409
        
        # Aggiorna lo stato
        intervento.status = "accepted"
        intervento.assigned_driver = workshop_id  # o il nome dell'officina
        intervento.assigned_at = datetime.now()
        db.session.commit()
        
        return jsonify({
            "message": "Intervento preso in carico con successo",
            "request_id": request_id,
            "new_status": "accepted",
            "data": _format_intervento(intervento)
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.post("/dettaglioIntervento/<request_id>/reject")
@require_auth
@require_role("officina")
def reject_intervento(request_id: str):
    """Rifiuta un intervento."""
    try:
        intervento = Request.query.get(request_id)
        if not intervento:
            return jsonify({"error": "Intervento non trovato"}), 404
        
        if intervento.status not in ["pending", "accepted"]:
            return jsonify({"error": "Azione non disponibile per lo stato corrente"}), 409
        
        intervento.status = "rejected"
        intervento.assigned_driver = None
        db.session.commit()
        
        return jsonify({
            "message": "Intervento rifiutato con successo",
            "request_id": request_id,
            "new_status": "rejected",
            "data": _format_intervento(intervento)
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@bp.post("/dettaglioIntervento/<request_id>/complete")
@require_auth
@require_role("officina")
def complete_intervento(request_id: str):
    """Completa un intervento."""
    try:
        intervento = Request.query.get(request_id)
        if not intervento:
            return jsonify({"error": "Intervento non trovato"}), 404
        
        if intervento.status != "accepted":
            return jsonify({"error": "Azione non disponibile per lo stato corrente"}), 409
        
        intervento.status = "handled"
        intervento.completed_at = datetime.now()
        db.session.commit()
        
        return jsonify({
            "message": "Intervento completato con successo",
            "request_id": request_id,
            "new_status": "handled",
            "data": _format_intervento(intervento)
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


def _format_intervento(intervento):
    return {
        "id": intervento.request_id,
        "cliente": intervento.client_name,
        "vehicle_type": intervento.vehicle_type,
        "status": intervento.status,
        "status_text": _format_status(intervento.status),
        "lat": intervento.latitude,
        "lng": intervento.longitude,
        "posizione": intervento.location,
        "requested_at": intervento.created_at.isoformat(),
        "assigned_driver": intervento.assigned_driver,
        "notes": intervento.notes,
        "available_actions": _get_available_actions(intervento.status)
    }
```

---

## 🔧 Pattern Comuni

### Validazione Ruolo Multip
lo

```python
# Verifica se l'utente è admin o perito
from functools import wraps

def require_any_role(*roles):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            from app.services.token_service import get_roles
            user_roles = get_roles(g.user)
            if not any(role in user_roles for role in roles):
                return jsonify({"error": "Permesso negato"}), 403
            return f(*args, **kwargs)
        return decorated
    return decorator

# Utilizzo
@bp.get("/admin/stats")
@require_auth
@require_any_role("admin", "perito")
def get_admin_stats():
    return jsonify({...}), 200
```

### Gestione Errori Globale

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.errorhandler(TokenInvalidException)
def handle_token_error(e):
    return jsonify({"error": "Token non valido", "message": str(e)}), 401

@app.errorhandler(404)
def handle_not_found(e):
    return jsonify({"error": "Endpoint non trovato"}), 404

@app.errorhandler(500)
def handle_internal_error(e):
    return jsonify({"error": "Errore interno del server"}), 500
```

---

## 📝 Registrazione dei Blueprint

Nel `app.py` o file di startup principale:

```python
from flask import Flask
from app.services.token_service import require_auth
from app.blueprints.auth import bp as auth_bp
from app.blueprints.dashboard import bp as dashboard_bp
from app.blueprints.soccorsi import bp as soccorsi_bp
from app.blueprints.dettaglio_intervento import bp as intervento_bp
from app.blueprints.documentation import bp as docs_bp

app = Flask(__name__)

# Registra i blueprint
app.register_blueprint(auth_bp, url_prefix="/api")
app.register_blueprint(dashboard_bp, url_prefix="/api")
app.register_blueprint(soccorsi_bp, url_prefix="/api")
app.register_blueprint(intervento_bp, url_prefix="/api")
app.register_blueprint(docs_bp)

@app.get("/")
def health_check():
    return jsonify({
        "name": "SafeClaim API",
        "status": "ok"
    }), 200

if __name__ == "__main__":
    app.run(debug=True, port=5000)
```

---

## 💾 Modelli di Database (SQLAlchemy)

Suggerimento di struttura modelli:

```python
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

db = SQLAlchemy()

class Workshop(db.Model):
    __tablename__ = 'workshops'
    
    id = db.Column(db.String(255), primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255))
    phone = db.Column(db.String(20))
    address = db.Column(db.Text)
    is_online = db.Column(db.Boolean, default=False)
    selected_request_id = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, default=datetime.now)
    
    requests = db.relationship('Request', backref='workshop', lazy=True)


class Request(db.Model):
    __tablename__ = 'requests'
    
    id = db.Column(db.String(255), primary_key=True)
    request_id = db.Column(db.String(255), unique=True, nullable=False)
    client_name = db.Column(db.String(255))
    vehicle_type = db.Column(db.String(100))
    vehicle_label = db.Column(db.String(255))
    location = db.Column(db.String(255))
    latitude = db.Column(db.Float)
    longitude = db.Column(db.Float)
    status = db.Column(db.String(50), default='pending')  # pending, accepted, handled, rejected
    assigned_driver = db.Column(db.String(255))
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now)
    arrival_time = db.Column(db.DateTime)
    assigned_at = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)
    workshop_id = db.Column(db.String(255), db.ForeignKey('workshops.id'))
```

---

## ✅ Checklist Implementazione

- [ ] Creato file `dashboard_routes.py` con i 3 endpoint
- [ ] Creato file `soccorsi_routes.py` con gli endpoint
- [ ] Creato file `dettaglio_intervento_routes.py` con azioni
- [ ] Registrati tutti i blueprint in `app.py`
- [ ] Modelli ORM creati e migrati
- [ ] Test degli endpoint con Postman/curl
- [ ] Collegamento al frontend Flutter completato
- [ ] Autenticazione Keycloak testata end-to-end
