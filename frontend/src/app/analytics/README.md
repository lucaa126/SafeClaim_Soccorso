# Analytics Page

Questi file forniscono una pagina `Analytics` standalone con grafici semplici (SVG/CSS) e dati aggregati ricavati dal servizio `SoccorsoData`.

File creati:
- `analytics.ts` - componente standalone (selector: `app-analytics`)
- `analytics.html` - template
- `analytics.css` - stili
- `analytics.service.ts` - logica di aggregazione
- `analytics.spec.ts` - test base

Come integrare la pagina nella app:
1. Apri `frontend/src/app/app.routes.ts` e aggiungi import e route:

```typescript
import { Analytics } from './analytics/analytics';

// poi nelle routes:
{ path: 'analytics', component: Analytics }
```

2. Aggiorna la UI (menu/sidebar) se vuoi aggiungere un link.
3. Nessuna dipendenza esterna è stata aggiunta: i grafici sono implementati con CSS/SVG nativo.

Suggerimenti futuri:
- Sostituire i mock delle "recensioni" con un endpoint reale
- Aggiungere una libreria di chart (es. Chart.js) se si desiderano grafici più completi (in questo caso aggiornare `package.json`)

