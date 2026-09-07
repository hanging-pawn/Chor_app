# Code Review: Chor_App (Gesamt-Review)

**Datum:** 2026-08-15 · **Stand:** Commit `db2e80a` («Notiztypen, Liednotiz, Pianisten-PDF, Probenübersicht»), Working Tree clean (nur .DS_Store / Doku untracked)
**Umfang:** index.html (8'582 Zeilen), js/, css/, supabase/functions/send-email, db/migrations 001–012, deploy.yml, Tests

## Summary

Die App ist ein sauber strukturierter Single-File-Monolith mit durchdachtem RLS-Modell (Migration 005) und konsequentem HTML-Escaping — mit zwei kritischen Ausnahmen, die zusammen eine ausnutzbare persistente XSS-Kette bilden. Dazu kommen ein Zeitzonenfehler in der «Heute»-Logik und toter, aber getesteter Code, der falsche Sicherheit vermittelt.

**Verdict: Request Changes** — Befunde 1+2 vor dem nächsten Deploy schliessen.

## Kritische Befunde

| # | Datei | Zeile | Befund | Severity |
|---|-------|-------|--------|----------|
| 1 | `db/migrations/011_pianisten.sql`<br>`db/migrations/012_proben_set.sql` | 47–56<br>27–31 | **RLS-Rückfall:** `pianisten`, `proben_pianist`, `proben_set` haben `for all using (true) with check (true)`-Policies und keine `user_id`-Spalte. Jeder mit dem (per Design öffentlichen) anon-Key kann **ohne Login** Pianisten-Kontaktdaten (Name, E-Mail, Telefon) aller Chöre lesen und ändern — DSGVO/DSG-relevant, widerspricht NF-013/NF-014. Migration 005 hatte genau dieses Muster bewusst entfernt; 011/012 führen es wieder ein. | 🔴 Kritisch |
| 2 | `index.html` | 4977–4981 | **Stored XSS in `renderCard()`:** `ex.title`, `ex.anleitung`, `ex.kategorie` werden ungeescaped in `innerHTML` interpoliert — einzige Ausnahme in einer sonst durchgehend escapten App. Quellen: eigene Übungen (localStorage) und `proben_set.set_json` aus der DB (`restoreProbeSet()` → `renderSet()` → `renderCard()`, Z. 7336–7340). Kombiniert mit Befund 1: Angreifer schreibt mit anon-Key ein präpariertes `set_json` → Payload läuft beim nächsten Seitenaufruf in Anjas authentifizierter Session. **Fix:** `escHtml()` anwenden (existiert bereits, Z. 4732). | 🔴 Kritisch |

## Hohe Priorität

| # | Datei | Zeile | Befund | Severity |
|---|-------|-------|--------|----------|
| 3 | `supabase/functions/send-email/index.ts` | 76–121 | **E-Mail-Funktion als Quasi-Open-Relay:** prüft nur gültiges JWT, aber nicht *an wen* gesendet wird — `to` ist voll client-kontrolliert, kein Rate Limit. Bei offener Supabase-Registrierung kann jeder Account beliebige Mails von der verifizierten Absenderadresse verschicken. **Fix:** Empfänger serverseitig gegen `mitglieder`/`pianisten` des Aufrufers validieren, Rate Limit, Signups deaktivieren (Single-User). | 🟠 Hoch |
| 4 | `index.html` | 6584 (u. 6331, 6448, 6051, 5765) | **Zeitzonenfehler:** `todayStr()` nutzt `toISOString()` → UTC-Datum. In Europe/Zurich zwischen 00:00 und 02:00 Lokalzeit liefert das den **Vortag**: falsche «nächste Probe» (`.gte('datum', todayStr())`, Z. 7080/7156), fehlendes Heute-Badge, falsch vorbelegtes Notizdatum — realistisch bei Nutzung spätabends nach der Probe. **Fix:** lokales Datum bilden (`getFullYear/getMonth/getDate`), zentral, alle 5 Stellen. | 🟠 Hoch |
| 5 | `05_Tests/generator.test.js`<br>`js/` (gesamt) | — | **Tests prüfen toten Code:** `js/generator.js`, `js/app.js`, `js/supabase.js`, `css/style.css`, `data/uebungen.json` werden von index.html **nirgends eingebunden**. Die 5'199 grünen Assertions testen ein Modul, das nie läuft; die Live-Inline-Version (Z. 4934) weicht ab: fix 1+1+3+1 statt 5–6 (FA-002), andere Kategorien, **keine Wiederholungsvermeidung (FA-004)** — stiller Feature-Verlust gegenüber der Spec. **Fix:** getestetes Modul einbinden oder toten Code löschen und Tests auf Live-Logik umschreiben. | 🟠 Hoch |
| 6 | `index.html` | 7821–7823 | `termine_lieder` wird ohne `chor_id`-Filter und ohne `.limit()` geladen — einzige unskopierte Query der App; bei mehreren Chören landen chorfremde Daten im Client. **Fix:** `.in('termin_id', _termineCache.map(t => t.id))`. | 🟠 Hoch |

## Mittlere Priorität

| # | Datei | Zeile | Befund | Kategorie |
|---|-------|-------|--------|-----------|
| 7 | `index.html` | 6979–6996, 8209–8222 | Delete-then-Insert ohne Transaktion (`saveProbe`, `submitTerminForm`): scheitert das Insert nach erfolgtem Delete (Netzabbruch), ist der alte Stand weg. Fix: Upsert mit `onConflict` (wie bei `proben_set` bereits korrekt) oder RPC. | Korrektheit |
| 8 | `index.html` | 4580–4615, 7193–7194 | Race Condition beim Chorwechsel: Loader schreiben nach `await` bedingungslos in globale Caches — langsame Antwort des alten Chors kann Anzeige des neuen überschreiben. Fix: `chorId` beim Start merken, vor Cache-Write vergleichen. | Korrektheit |
| 9 | `index.html` | 7515–7528, 7799–7804, 7258 | Still verschluckte Supabase-Fehler: `error` wird nicht destrukturiert → leere Dropdowns/Jahresplan ohne jeden Hinweis. Fix: `error` prüfen, mind. `console.warn` + Fallback. | Korrektheit |
| 10 | `index.html` | 5975–5982 | N+1: `applyBeitragshoehe` updatet sequentiell pro Mitglied (bis 40 Roundtrips, kein Loading-State, Fehler unsichtbar). Fix: ein Update mit `.in('id', ids)`. | Performance |
| 11 | Projekt-Root | — | Kein Service Worker: als Homescreen-PWA ohne Netz weisse Seite, obwohl Einsingen rein clientseitig wäre. Fix: minimaler SW mit Precache (index.html, CDNs). | PWA |
| 12 | `supabase/functions/send-email/index.ts` | 34–37, 66–68 | CORS `*` statt konkreter Pages-Origin; Identitätsprüfung nutzt unnötig den service_role-Key als Client-Basis (RLS-Bypass-Risiko bei künftigen Erweiterungen). Fix: Origin einschränken; für `auth.getUser()` anon-Key verwenden. | Security |
| 13 | `index.html` | — | Keine Content-Security-Policy — fehlende zweite Verteidigungslinie gegen XSS (Befund 2). Fix: restriktive CSP per `<meta>`; Inline-onclick-Handler erschweren das, schrittweise. | Security |
| 14 | `db/migrations/008_email_versand.sql` | 31, 34 | Einzige nicht-idempotente Migration: `CREATE POLICY` ohne `DROP POLICY IF EXISTS`. | Wartbarkeit |
| 15 | `.github/workflows/deploy.yml` | 33 | `path: '.'` deployt das ganze Repo inkl. Migrationen, Doku-Ordnern und totem Code — unnötige Informationspreisgabe. Zudem kein Test-Step vor dem Deploy. Fix: `public/`-Ordner oder Filter; `node 05_Tests/…` als CI-Step. | Wartbarkeit |

## Niedrige Priorität

`bezahlt_am` als UTC-Timestamp gespeichert, Anzeige per `slice(0,10)` zeigt um Mitternacht den Vortag (Z. 6020/6027 — buchhalterisch relevant); Seed-Race in `initChoere` kann doppeltes «Mein Chor» anlegen (Z. 4539–4546); voller Re-Render der Beitragstabelle pro Klick (Z. 6032); fehlende FK-/user_id-Indizes (003/004/006/007 — bei Chorgrösse unkritisch); inkonsistente Index-Namenskonventionen; `subject` in send-email nicht auf Zeilenumbrüche gefiltert.

**Korrektur aus der Verifikation:** Die von den Reviewern gemeldeten «fehlenden Icons» sind ein Artefakt der Analyse-Umgebung — `git ls-files` bestätigt, dass alle drei Icons committed und deployt sind. Kein Befund. (Lokal sind sie iCloud-Platzhalter, daher weiterhin `git add -A` meiden.)

## Was gut gelöst ist

Konsequentes Escaping via `escHtml`/`esc` an 60+ Stellen (Befund 2 ist die einzige Lücke). Migration 005 ist vorbildlich: begründet, idempotent, korrektes Owner-Modell mit `WITH CHECK`. Die Edge Function verlangt Auth, loggt keine Inhalte und versendet einzeln statt BCC. Saubere Guards gegen Doppel-Init (`_appStarted`, Listener-Cleanup), durchdachte Datumshelfer (`T12:00:00`-Trick, Montag-first-Kalender) — ironischerweise fehlt genau diese Sorgfalt nur bei `todayStr()`. Der Monolith ist aufgeräumt: ~25 betitelte Sektionen mit FA-Referenzen machen einen späteren Modul-Schnitt (8–9 Dateien, ohne Build-Step) fast mechanisch. Deploy-Workflow mit Least-Privilege-Permissions, keine Secrets im Code.

## Empfohlene Reihenfolge

1. **Migration 013:** Owner-RLS für `pianisten`/`proben_pianist`/`proben_set` (Befund 1)
2. **`escHtml()` in `renderCard`** (Befund 2) — zusammen mit 1 deployen
3. `todayStr()` auf Lokalzeit (Befund 4)
4. send-email: Empfänger-Validierung + Signups prüfen (Befund 3)
5. Toter-Code-Entscheid: `js/generator.js` einbinden oder löschen (Befund 5)
6. Rest nach Gelegenheit (Befunde 6–15)
