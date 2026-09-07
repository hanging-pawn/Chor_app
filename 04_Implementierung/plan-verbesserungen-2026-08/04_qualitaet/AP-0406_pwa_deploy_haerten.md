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

- [ ] Flugmodus-Test: App aus dem Homescreen startet und Einsingen-Set lässt sich generieren.
- [ ] CSP aktiv, App funktioniert vollständig (Konsole ohne CSP-Verstösse im Normalbetrieb).
- [ ] Deployte Site enthält keine `db/`- oder Doku-Ordner mehr (im Pages-Artefakt geprüft).
- [ ] Migration 008 mehrfach ausführbar ohne Fehler.

## Voraussetzungen

AP-0404 empfohlen zuerst (Deploy-Test-Step und SW-Precache-Liste hängen zusammen).

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M–L

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen**: {keine / Beschreibung}

## Status

- [x] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
