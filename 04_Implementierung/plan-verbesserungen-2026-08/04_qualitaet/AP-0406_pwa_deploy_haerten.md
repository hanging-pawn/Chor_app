# AP-0406: PWA & Deploy härten (Service Worker, CSP, Deploy-Scope)

## Ziel

Die App funktioniert offline (Einsingen), hat eine CSP als zweite XSS-Verteidigungslinie, und der Deploy liefert nur App-Dateien aus. Schliesst Review-Befunde 11, 13, 14, 15 und die Niedrig-Befunde (Seed-Race, Beitrags-Re-Render).

## Kontext

Kein Service Worker → als Homescreen-PWA ohne Netz weisse Seite, obwohl Einsingen rein clientseitig wäre (Befund 11, deckt sich mit offenem Dashboard-Punkt «Offline-Fähigkeit 5sp»). Keine CSP (13). Migration 008 nicht idempotent (14). `deploy.yml` deployt das ganze Repo inkl. Doku/Migrationen (15). Niedrig: `initChoere`-Seed-Race (Z. 4539–4546), voller Re-Render pro Beitrags-Klick (Z. 6032).

## Umsetzungsschritte

1. `sw.js` im Root: Cache-First für `index.html`, `manifest.json`, Icons, CDN-Skripte (Supabase, abcjs); Network-First-Fallback; Cache-Version-Konstante. Registrierung in index.html (`navigator.serviceWorker.register`, feature-detected).
2. CSP per `<meta http-equiv="Content-Security-Policy">`: `default-src 'self'`; CDNs whitelisten; wegen Inline-Script/-Handler zunächst `'unsafe-inline'` für script/style akzeptieren (dokumentierter Kompromiss — echte Nonce-CSP erst nach Modul-Schnitt).
3. Migration 008: `DROP POLICY IF EXISTS` vor beide `CREATE POLICY` (neue Migration oder direkt in 008 mit Kommentar — 008 wurde bereits ausgeführt, Anpassung in der Datei reicht für Idempotenz).
4. Deploy-Scope: In `deploy.yml` vor dem Upload die Nicht-App-Pfade ausschliessen (Doku-Ordner 01–11, db/, 05_Tests im Artefakt weglassen) — z. B. per rsync in einen `_site`-Ordner und `path: '_site'`.
5. Niedrig-Fixes: Unique-Index `choere (user_id, name)` als Mini-Migration gegen Seed-Race; `toggleBeitrag` patcht nur die eine Zeile statt Voll-Refetch.

## Abnahmekriterien

- [x] **Offline-Start und Set-Generierung** — im echten Chrome gegen einen lokalen Server geprüft, der genau das ausliefert, was deployed wird. Service Worker registriert (`scope /`, Zustand `activated`), Cache `chorapp-v1` enthält alle 9 Einträge (6 App-Dateien + 3 CDN-Bibliotheken). Danach **Server gestoppt** und neu geladen: Die App startet vollständig aus dem Cache (`navigation.workerStart > 0`), Schrift und Styling intakt, abcjs und jsPDF verfügbar. `generateSet()` liefert bei totem Server ein gültiges Set aus 6 Übungen in der Reihenfolge körper → atem → stimme ×3 → kanon (FA-001–003).
  **Einschränkung:** Das ist der Desktop-Ersatztest. Der eigentliche Flugmodus-Test aus dem iPhone-Homescreen steht aus — dafür braucht es das Gerät. iOS behandelt Service Worker in installierten PWAs teils eigen (eigener Speicher pro Homescreen-App, aggressiveres Verwerfen), das ist am Schreibtisch nicht abbildbar.
- [x] **CSP aktiv, App funktioniert vollständig.** Beim Browsertest fiel ein echter Verstoss auf, den die statische Suche übersehen hatte: DM Sans wird per `@import` *innerhalb* eines `<style>`-Blocks geladen, nicht über ein `<link>`. `fonts.googleapis.com` (style-src) und `fonts.gstatic.com` (font-src) nachgetragen; danach ist DM Sans nachweislich geladen. Supabase, abcjs und jsPDF laden unter der CSP, ein jsPDF-Blob liess sich erzeugen (3156 Bytes), `connect-src` zu Supabase funktioniert. **Gegenprobe:** `fetch('https://example.com/')` wird von `connect-src` blockiert — die CSP ist also wirksam und nicht nur vorhanden.
  **Einschränkung:** Ohne Zugangsdaten liessen sich die eingeloggten Abläufe (PDF-Export, Notenbild, E-Mail-Dialog) nicht durchklicken.
- [x] **Deploy-Scope.** Der neue `Assemble site`-Schritt lokal nachgestellt: Ergebnis sind genau 12 Dateien (index.html, manifest.json, sw.js, icons/, css/, js/, data/), kein `db/`, kein `supabase/`, keine Doku-Ordner. YAML mit `js-yaml` validiert. Nach dem Deploy zusätzlich an der Live-Site geprüft.
- [x] **Migration 008 mehrfach ausführbar** — `DROP POLICY IF EXISTS` vor beiden `CREATE POLICY`. **Nicht erneut gegen die Datenbank ausgeführt**: 008 ist bereits eingespielt, die Datei stellt nur die Wiederholbarkeit her. Ein Testlauf im SQL-Editor wäre unschädlich, wurde aber nicht durchgeführt.

## Voraussetzungen

AP-0404 empfohlen zuerst (Deploy-Test-Step und SW-Precache-Liste hängen zusammen).

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M–L

## Dokumentation

- **Erledigt am**: 2026-09-07
- **Abweichungen**:
  - **index.html wird Network-First ausgeliefert, nicht Cache-First** wie in Schritt 1 vorgeschlagen. Die Datei *ist* die gesamte App; Cache-First hiesse, dass Anja nach jedem Deploy auf einer alten Version sitzt, bis der Cache irgendwann erneuert wird — bei einer App, die gerade laufend Sicherheitsfixes bekommt, das falsche Verhalten. Offline greift die zwischengespeicherte Kopie, der Offline-Fall bleibt also erfüllt. Statische Dateien und die versionierten CDN-URLs bleiben Cache-First.
  - Supabase-Anfragen werden vom Service Worker **nie** bedient. Veraltete Mitglieder- oder Beitragsdaten auszuliefern wäre schlimmer als ein sichtbarer Fehler, und ein zwischengespeichertes Auth-Token wäre ein Sicherheitsproblem.
  - CDN-Bibliotheken werden „best effort" vorgeladen (`allSettled`), die App-Dateien mit `addAll`. Ist beim Installieren eine CDN-Datei nicht erreichbar, soll die App trotzdem offline startfähig werden — ohne abcjs fehlt nur das Notenbild, ohne jsPDF nur der PDF-Export.
  - `skipWaiting()` und `clients.claim()`: Ein wartender Service Worker würde bedeuten, dass ein Fehler in `sw.js` erst nach dem Schliessen aller Tabs verschwindet.
  - **`frame-ancestors` fehlt in der CSP.** Die Direktive wird in einem `<meta>`-Element ignoriert und bräuchte einen HTTP-Header; GitHub Pages erlaubt keine eigenen Header. Clickjacking-Schutz ist damit nicht abgedeckt — bewusst offengelassen, nicht vergessen.
  - **Niedrig-Befund Beitrags-Re-Render:** `toggleBeitrag` zieht die geschriebene Zeile per `.select().single()` zurück in den Cache und zeichnet lokal neu, statt die komplette Liste erneut vom Server zu holen. Kein chirurgisches Aktualisieren einer einzelnen DOM-Zeile — das hätte einen zweiten Renderpfad geschaffen, der mit `renderBeitTable` auseinanderlaufen kann. Der teure Teil war ohnehin die Netzrunde, nicht das Zeichnen von 40 Zeilen.
  - **Migration 014 muss noch eingespielt werden** (Unique-Index auf `choere (user_id, name)`). Der Client fängt den Konflikt bereits ab. Voraussetzung geprüft: Stand 2026-09-07 enthält `choere` drei Zeilen — eine ohne `user_id` sowie je eine für Gianluca und Anja, alle „Mein Chor". Auf `(user_id, name)` gibt es damit **keine** Duplikate (NULL zählt in Unique-Indizes als verschieden), der Index lässt sich also anlegen.
- **Nicht umgesetzt**: nichts aus der AP-Liste.
- **Offen**: Flugmodus-Test auf dem iPhone; Migration 014 in Supabase ausführen.
- **Nicht ausgeliefert (Stand 2026-09-07)**: Die geänderte `deploy.yml` liegt als eigener, noch nicht gepushter Commit vor. GitHub lehnt Änderungen unter `.github/workflows/` ab, solange dem Token der `workflow`-Scope fehlt (`gh auth refresh -s workflow`). Bis dahin gilt weiter der alte Deploy mit `path: '.'`, das komplette Repository wird also nach wie vor veröffentlicht — Befund 15 ist im Code behoben, in der Laufzeit noch nicht.

## Status

- [x] Bereit zur Ausführung
- [x] In Arbeit
- [x] Abgenommen (Code); iPhone-Test und Migration 014 stehen aus
