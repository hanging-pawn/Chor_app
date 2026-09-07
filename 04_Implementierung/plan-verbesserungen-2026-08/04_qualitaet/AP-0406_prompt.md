# Umsetzungsprompt — AP-0406: PWA & Deploy härten

**Umgebung:** Claude Code (Repo-Root) · **Modell:** mittel · **Grösse:** M–L
**Voraussetzung:** AP-0404 abgeschlossen. Neue Mini-Migration manuell in Supabase ausführen.

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App (statische PWA auf GitHub Pages). Härtung gemäss Code Review 2026-08-15
(Befunde 11/13/14/15 + zwei Niedrig-Befunde).

1. Service Worker: Neue Datei sw.js im Root. Cache-First mit Versions-Konstante
   (z. B. 'chor-app-v1') für: ./, index.html, manifest.json, icons/*, sowie die
   CDN-URLs von Supabase-js und abcjs (aus index.html Z. ~8562 ff. übernehmen).
   fetch-Handler: Cache-First, bei Miss Netz + Cache-Put; navigations-Fallback auf
   gecachte index.html. In index.html registrieren (feature-detected, nach load).
2. CSP als <meta http-equiv="Content-Security-Policy"> im <head>:
   default-src 'self'; script-src 'self' 'unsafe-inline' + die beiden CDN-Origins;
   style-src 'self' 'unsafe-inline'; connect-src 'self' https://guxvlbrxzmgylojbxjew.supabase.co;
   img-src 'self' data:. Kommentar dazu: 'unsafe-inline' ist bewusster Kompromiss
   bis zum Modul-Schnitt. App darf im Normalbetrieb keine CSP-Fehler werfen — testen.
3. db/migrations/008_email_versand.sql: vor beide CREATE POLICY ein
   DROP POLICY IF EXISTS setzen (Idempotenz, Muster der übrigen Migrationen).
4. Neue Migration db/migrations/014_choere_unique_seed.sql:
   create unique index if not exists choere_user_name_uidx on choere (user_id, name);
   (verhindert doppeltes «Mein Chor» beim parallelen Erststart; manueller
   Supabase-Schritt, im Dateikopf kennzeichnen).
5. .github/workflows/deploy.yml: App-Dateien vor dem Upload in _site/ kopieren
   (index.html, manifest.json, sw.js, icons/, js/, css/ falls genutzt) und
   path: '_site' setzen — Doku-Ordner, db/, 05_Tests nicht mehr deployen.
   Der Test-Step aus AP-0404 bleibt davor bestehen.
6. toggleBeitrag (index.html Z. ~6032): statt loadBeitraegeAndRender() nur den
   lokalen Cache-Eintrag aktualisieren und die eine Tabellenzeile patchen.

Verifikation: node --check; Lighthouse-PWA-Check installierbar; Flugmodus-Smoke-Test
beschreiben. Dateien: index.html, sw.js (neu), deploy.yml, 008er-SQL, 014er-SQL (neu).
```

## Nach Ausführung (verbindlich)

1. Doku-Block in `AP-0406_pwa_deploy_haerten.md` ausfüllen, Status setzen.
2. Prompt nach `…/04_qualitaet/archiv/` verschieben. Übersicht/Dashboard aktualisieren.
3. Dashboard-Punkt «Offline-Fähigkeit (PWA Service Worker) 5sp» abhaken.
