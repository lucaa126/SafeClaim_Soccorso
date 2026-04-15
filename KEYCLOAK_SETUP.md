# Keycloak Setup for SafeClaim

## Avviare Keycloak con Docker

1. Assicurati di avere Docker installato.
2. Nella root del progetto (`/workspaces/SafeClaim_Soccorso/`), esegui:
   ```
   docker-compose up -d
   ```
3. Keycloak sarà disponibile su `http://localhost:8080`.

## Configurazione Keycloak

1. Accedi all'admin console: `http://localhost:8080` con user `admin` / password `admin`.
2. Crea un nuovo realm chiamato `safeclaim` (o usa `master` se preferisci).
3. Nel realm, vai a "Clients" e crea un client:
   - Client ID: `safeclaim-admin`
   - Client Type: `OpenID Connect`
   - Access Type: `confidential` (o `public` se necessario)
   - Abilita "Direct Access Grants" (per password grant).
   - Imposta "Valid Redirect URIs" a `*` per test (o specifica per produzione).
4. Crea un utente in "Users":
   - Username/Email: `admin@safeclaim.it`
   - Password: imposta una password (es. `admin123`), disabilita "Temporary" se vuoi che sia permanente.
5. Nel client, vai a "Credentials" e copia il "Client Secret" se necessario (per ora usiamo public).

## Aggiorna Configurazione Flutter

In `frontendflutter/lib/app/api_config.dart`, assicurati che:
- `keycloakBaseUrl`: `http://localhost:8080`
- `keycloakRealm`: `safeclaim` (o il nome del tuo realm)
- `keycloakClientId`: `safeclaim-admin`

## Test

1. Avvia l'app Flutter: `flutter run -d web-server`
2. Nella pagina login, usa le credenziali dell'utente creato.
3. Se funziona, vedrai la dashboard.

## Note

- Per produzione, usa HTTPS e configura correttamente i redirect URIs.
- Se Keycloak è su un server remoto, cambia `keycloakBaseUrl` di conseguenza.
- Il database è PostgreSQL persistente tramite volume Docker.