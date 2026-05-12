# Officina SafeClaim - Audit grafico operativo

## 1. Panorama grafico generale

Il frontend osservato in `frontend/src` usa un linguaggio visivo light, tecnico e funzionale, costruito su una base `shadcn/ui` + Tailwind CSS 4 con token centralizzati in `src/styles/theme.css` e componenti applicativi che riusano soprattutto una palette teal/blu-grigio. Il pattern dominante e riconoscibile e:

- fondo pagina chiaro `#F4F4F4`
- card bianche con bordo leggero e radius ampio
- header pieni `primary` con testo bianco
- badge di stato colorati ma coerenti con la stessa famiglia cromatica
- input e pulsanti basati sui componenti `ui/*`
- icone `lucide-react` come linguaggio iconografico principale

Il dark theme esiste nei token, ma nelle schermate principali osservate non emerge come standard grafico primario.

Questo documento e ora anche il riferimento operativo per `frontendflutter`: lo standard React resta basato su `frontend/src`, `theme.css`, componenti `shadcn/ui` e icone `lucide-react`; la traduzione Flutter vive invece in `frontendflutter/lib/app/theme.dart` tramite `SafeClaimColors`, `lightTheme()`, `darkTheme()` e helper UI in `frontendflutter/lib/widgets/safeclaim_ui.dart`. In Flutter il linguaggio iconografico equivalente e Material Icons.

## 2. Palette colori

### 2.1 Design tokens definiti in `theme.css`

| Token | Hex | Uso semantico osservabile |
| --- | --- | --- |
| `--color-primary-dark` | `#09637E` | hover, bordi header, enfasi secondaria |
| `--color-primary-medium` | `#088395` | colore principale del brand UI, CTA, header, icone |
| `--color-primary-light` | `#7AB2B2` | bordi soft, accenti, stati intermedi |
| `--color-primary-lightest` | `#EBF4F6` | superfici secondarie, badge chiari, pannelli informativi |
| `--color-secondary-darkest` | `#061E29` | testo forte, foreground base |
| `--color-secondary-dark` | `#10546D` | testo secondario importante, label, stati completati |
| `--color-secondary-medium` | `#5F9598` | statistica intermedia, supporto cromatico |
| `--color-secondary-light` | `#F3F4F4` | sfondi neutri freddi, badge "non assegnata" |
| `--color-alt-dark` | `#005461` | token alternativo/destructive, poco visibile nelle schermate principali |
| `--color-alt-medium` | `#018790` | variante alternativa, non dominante nelle pagine principali |
| `--color-alt-teal` | `#008785` | variante alternativa, non dominante nelle pagine principali |
| `--color-alt-light` | `#F4F4F4` | allineato al fondo principale |

### 2.2 Mapping dei token di tema Tailwind

I token Tailwind effettivamente impostati sopra la palette sono:

- `--background: #F4F4F4`
- `--foreground: #061E29`
- `--card: #FFFFFF`
- `--primary: #088395`
- `--secondary: #EBF4F6`
- `--accent: #7AB2B2`
- `--border: #7AB2B2`
- `--ring: #088395`
- `--sidebar-*` allineati alla stessa famiglia teal/bianco

Questo conferma che lo standard previsto dal tema e lo standard osservato nelle schermate sono sostanzialmente allineati.

### 2.3 Mapping dei token Flutter

In `frontendflutter`, la stessa palette e stata tradotta in token Material 3 centralizzati in `SafeClaimColors`:

| Token Flutter | Hex | Uso semantico |
| --- | --- | --- |
| `SafeClaimColors.primaryDark` | `#09637E` | hover, contrasto forte, stati operativi intermedi |
| `SafeClaimColors.primary` | `#088395` | CTA, header, stato attivo, icone principali |
| `SafeClaimColors.primaryLight` | `#7AB2B2` | bordi soft, accenti, sfondi stato intermedi |
| `SafeClaimColors.primaryLightest` | `#EBF4F6` | superfici informative, badge chiari, pannelli secondari |
| `SafeClaimColors.foreground` | `#061E29` | testo forte e foreground light theme |
| `SafeClaimColors.textStrong` | `#10546D` | label, stati completati, testo secondario forte |
| `SafeClaimColors.textMuted` | `#5F9598` | testo secondario, metriche intermedie, icone non attive |
| `SafeClaimColors.neutral` | `#F3F4F4` | superfici neutre e stati non assegnati/manutenzione |
| `SafeClaimColors.background` | `#F4F4F4` | fondo pagina light |
| `SafeClaimColors.card` | `#FFFFFF` | card e superfici principali |

Il tema Flutter usa `ThemeMode.light` come default. Il dark mode resta disponibile tramite `darkTheme()`, ma e secondario rispetto allo standard light.

### 2.4 Colori effettivamente riusati nelle schermate

Colori ricorrenti nelle viste principali `Login`, `Dashboard`, `DettaglioPratica`, `Notifiche`:

| Colore | Frequenza | Uso ricorrente |
| --- | --- | --- |
| `#088395` | alta | CTA, header, titoli evidenziati, icone, importi, badge attivi |
| `#09637E` | alta | hover del primary, bordi header, testo di stati in lavorazione |
| `#7AB2B2` | alta | bordi input, badge intermedi, accenti soft |
| `#EBF4F6` | alta | testo secondario su header, superfici di supporto, pannelli informativi |
| `#10546D` | alta | label, testo secondario forte, badge completati |
| `#061E29` | media | testo forte locale |
| `#F4F4F4` | alta | background pagina |
| `#FFFFFF` | alta | card, testo su primary, controlli overlay |
| `#F3F4F4` | media | badge neutri e stato "non assegnata" |
| `#5F9598` | bassa ma significativa | contatore statistico "In Attesa" |

### 2.5 Colori episodici o locali

Questi colori esistono nel codice ma non vanno trattati come standard condiviso:

- `#9A6463`: usato solo per il bottone `Rifiuta` in dashboard
- `#f0f8fa`: callout locale del preventivo in `DettaglioPratica`
- `bg-red-500`: badge numerico notifiche non letto
- grigi Tailwind (`text-gray-400/500/600/700/800`, `bg-gray-50/100/200`, `border-gray-200`): testo di supporto, skeleton visivi, fallback neutrali
- stili inline del PDF in `DettaglioPratica`: `#333`, `#666`, `#999`, `#ddd`, `#ffffff`

## 3. Tipografia e tono visivo

### Tipografia

Non emerge una font custom attiva: `src/styles/fonts.css` e vuoto, quindi il progetto si appoggia di fatto allo stack di default dell'ambiente/Tailwind. Lo standard tipografico osservabile deriva soprattutto da `theme.css`:

- `h1`: scala `text-2xl`, peso medio
- `h2`: scala `text-xl`, peso medio
- `h3`: scala `text-lg`, peso medio
- `label`, `button`: peso medio
- `input`: peso normale

### Tono visivo

Il tono e:

- professionale e gestionale, non editoriale
- rassicurante ma non "marketing"
- leggibile e orientato allo stato del flusso
- costruito su contrasto chiaro/scuro piu che su decorazione

Le uniche concessioni decorative visibili sono:

- gradiente teal trasparente nel login
- leggere ombre sulle card principali
- icone tonde o callout con superfici colorate soft

## 4. Componenti ricorrenti e standard UI

### Base di sistema

La base componentistica e quella dei componenti `frontend/src/app/components/ui/*`, con convenzioni tipiche `shadcn/ui`:

- `Button`: varianti `default`, `outline`, `ghost`, `secondary`, `destructive`
- `Card`: `rounded-xl`, bordo leggero, contenuto a padding generoso
- `Badge`: `rounded-md`, testo `text-xs`, bordo visibile
- `Input` e `Textarea`: `rounded-md`, bordo soft, focus ring `primary`
- `Toaster`/Sonner: allineato ai token `popover` e `border`

La base Flutter equivalente e Material 3 con tema centralizzato:

- `lightTheme()` e `darkTheme()` in `frontendflutter/lib/app/theme.dart`
- `SafeClaimColors` come unica fonte per palette e semantica colore
- `safeClaimStatusStyle()` per badge e stati operativi
- `safeClaimCardDecoration()` per card gestionali coerenti
- `buildSharedThemeToggle()` per il toggle tema condiviso
- Material Icons come icon set Flutter, invece di `lucide-react`

### Standard osservato nelle viste applicative

- Header pagina: sfondo `#088395`, bordo inferiore `#09637E`, testo bianco, sottotitolo `#EBF4F6`
- Card contenuto: bianco su fondo `#F4F4F4`, ombre leggere o medie in punti selezionati
- Pulsante primary: `#088395` con hover `#09637E`
- Pulsanti ghost su header: `bg-white/10`, hover `bg-white/20`, testo bianco
- Input: bordo `#7AB2B2`, focus ring `#088395`
- Badge stato: combinazione di background tenue + testo/bordo della stessa famiglia teal/blu-grigio
- Icone: sempre `lucide-react`, spesso a 16px, 20px o 24px
- Icone Flutter: usare Material Icons coerenti con il contesto operativo, evitando asset o set iconografici aggiuntivi non necessari

## 5. Pattern di layout e spacing

Pattern ricorrenti:

- `min-h-screen` come contenitore pagina
- wrapper centrale `max-w-7xl mx-auto`
- padding orizzontale responsive `px-4 sm:px-6 lg:px-8`
- padding verticale ampio `py-6`, `py-8`
- composizione a card con `gap-4`, `gap-6`, `space-y-4`, `space-y-6`
- griglie 1/2/3 colonne per dashboard e dettaglio

Standard di rotondita osservato:

- `rounded-md` per button, input, badge base
- `rounded-lg` per callout locali e pannelli di supporto
- `rounded-xl` per card
- `rounded-full` per avatar iconici, dot notifiche e cerchi illustrativi

Standard di elevazione:

- ombra quasi assente sui componenti base di sistema
- `shadow-xl` nel login
- `hover:shadow-lg` sulle card cliccabili
- `hover:shadow-md` sulle notifiche

## 6. Stati, badge e segnali cromatici

Lo standard di stato piu chiaro e centralizzato e `getStatoColor` in `mockData.ts`:

| Stato | Background | Testo | Bordo | Lettura UX |
| --- | --- | --- | --- | --- |
| `non_assegnata` | `#F3F4F4` | `#10546D` | `#7AB2B2` | neutro, in attesa di presa in carico |
| `in_attesa` | `#EBF4F6` | `#10546D` | `#7AB2B2` | attesa soft, coerente col secondario chiaro |
| `in_lavorazione` | `#7AB2B2/20` | `#09637E` | `#7AB2B2` | stato operativo intermedio |
| `in_attesa_riconsegna` | `#088395/10` | `#088395` | `#088395` | pronto/positivo ma ancora attivo |
| `completata` | `#10546D/10` | `#10546D` | `#10546D` | chiusura del flusso |

Altri segnali cromatici ricorrenti:

- contatore notifiche rosso per urgenza numerica
- callout informativi chiari su `#EBF4F6` o `#f0f8fa`
- timeline e step completati con `#088395`
- testo secondario quasi sempre affidato a grigi Tailwind

## 7. Eccezioni e incoerenze da distinguere dallo standard

Questi elementi non vanno promossi automaticamente a standard:

- hardcode diffuso di hex direttamente nei componenti applicativi, anche quando esiste gia il token equivalente
- bottone `Rifiuta` con palette brunita `#9A6463`, isolata rispetto alla famiglia teal
- `DettaglioPratica` usa callout `#f0f8fa` oltre a `#EBF4F6`, creando una doppia variante di superficie informativa
- generazione PDF in `DettaglioPratica` usa stili inline e una mini-palette autonoma non allineata ai token
- alcuni componenti secondari (`GestioneStato`, `ContattoCliente`, `PraticaDetail`) replicano pattern corretti ma con ulteriore hardcode locale
- il dark theme e presente a livello token e in utility `ui/*`, ma non risulta parte del linguaggio visivo primario delle schermate osservate
- in Flutter, la precedente palette viola/blu generica va considerata storica: nuove schermate devono usare `SafeClaimColors`
- eventuali nuovi colori locali in `frontendflutter` vanno prima formalizzati in `SafeClaimColors` o in uno style helper dedicato, invece di essere hardcoded nei widget

## 8. Regole pratiche riusabili

Se il team deve estendere il frontend senza rompere la coerenza attuale, le regole operative piu sicure sono:

- usare `primary` `#088395` per CTA, header, highlight e stato attivo
- usare `#09637E` come hover o contrasto piu deciso dello stesso asse cromatico
- usare `#EBF4F6` e `#F3F4F4` per superfici di supporto, pannelli e badge neutri
- mantenere `#F4F4F4` come fondo pagina principale e `#FFFFFF` per card
- preferire sempre componenti `ui/*` rispetto a nuovi blocchi custom stilizzati da zero
- mantenere radius su tre livelli: `rounded-md`, `rounded-lg`, `rounded-xl`
- usare `lucide-react` come icon set di default
- trattare i grigi come supporto tipografico e non come colori identitari
- evitare nuovi hex inline quando esiste gia un token equivalente in `theme.css`
- in Flutter, preferire `lightTheme()`, `darkTheme()`, `safeClaimStatusStyle()`, `safeClaimCardDecoration()` e `buildSharedThemeToggle()` rispetto a stili locali ripetuti
- in Flutter, mantenere `ThemeMode.light` come default e trattare il dark mode come supporto secondario
- in Flutter, usare Material Icons come set coerente di default

## 9. Verifica Flutter

Per considerare allineata l'app `frontendflutter` allo standard grafico:

- `flutter analyze` deve chiudere senza issue
- `flutter build web` deve completare con successo
- `Login`, `Dashboard`, `Richieste`, `Dettaglio`, `Flotta`, `Analytics`, `Impostazioni` e drawer devono risultare coerenti con tema light SafeClaim
- CTA, badge, card, input e stati devono leggere dai token o dagli helper condivisi, non da nuove palette locali

## 10. Conclusione pratica

Lo standard grafico reale di Officina SafeClaim e gia abbastanza leggibile: piattaforma light, palette teal/blu-grigio, card bianche, header pieni, badge di stato e componenti personalizzati via token. Il principale punto di miglioramento non e l'identita visiva di base, ma la disciplina di applicazione: i token centrali esistono e vanno usati in modo coerente sia nel frontend React sia in `frontendflutter`.

In sintesi, il riferimento corretto per nuove schermate e: tema light, `primary` teal, superfici neutre chiare, card bianche, badge di stato coerenti e componenti base del rispettivo stack (`ui/*` per React, helper Material 3 per Flutter); tutto cio che esce da questo asse va considerato eccezione locale finche non viene formalizzato nel tema.
