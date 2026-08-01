# AP-0301: Einsingen-Seite umbauen — Probennotiz oben, Reihenfolge Notizen → Warm-up → Lieder

## Ziel

Die Einsingen-Seite so umbauen, dass sie Anjas gewohntes Layout abbildet: ganz oben ein Probennotiz-Feld für die nächste Probe, darunter das generierte Warm-up-Set, darunter die zu probenden Lieder.

## Kontext

Die App ist komplett inline in `index.html` (~7.6k Zeilen), keine Build-Kette. Der Einsingen-Tab ist die Default-Ansicht. Aktuelle Reihenfolge im `<main id="main">`: `#emptyState` / `#setView` (Warm-up-Set) → `#heuteSection` (Lieder der nächsten Probe) → `#eigeneSection`. Die Probennotizen liegen bisher NUR im separaten Tab `#notizenView` (Supabase-Tabelle `probennotizen`, Felder `datum, inhalt, markiert`, chor-gefiltert). 

**Entscheidung Anja/Gianluca:** Notizen kommen alle zusammen — das neue Feld auf der Einsingen-Seite und der Notiz-Tab greifen auf DIESELBE datumsgebundene `probennotizen`-Zeile zu (Datum = das der nächsten Probe, gleiche Logik wie `loadHeuteAndRender`). Keine zweite Wahrheit, kein zweites Speicherziel.

Relevante bestehende Funktionen: `getSupabase()`, `APP_STATE.chorId`, `todayStr()`, `formatNotizenDate()`, `loadHeuteAndRender()` (ermittelt bereits das Datum der nächsten Probe), `saveNotiz()` / `loadNotizenAndRender()` (Muster für probennotizen-CRUD).

## Inputs

| Typ | Quelle / Inhalt |
|-----|----------------|
| Datei | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` |
| Information | Reihenfolge auf der Seite: 1. Probennotiz, 2. Warm-up-Set, 3. Lieder. |
| Information | Notiz-Feld an die `probennotizen`-Zeile mit `datum` = Datum der nächsten Probe koppeln (dasselbe Datum, das `loadHeuteAndRender` ermittelt). |
| Referenz | Bestehende Funktionen `loadHeuteAndRender`, `saveNotiz`, `loadNotizenAndRender` in derselben Datei. |

## Umsetzungsschritte

1. In `#main` (in `index.html`) VOR `#setView`/`#emptyState` einen neuen Block `#einsingenNotizSection` einfügen: Überschrift „Notizen zur Probe", ein `<textarea id="einsingenNotizInhalt">` und ein Speicher-Button. Dezent gestaltet, gleiche Design-Tokens wie bestehende Cards.
2. Sicherstellen, dass die DOM-/CSS-Reihenfolge im Einsingen-Tab ist: `#einsingenNotizSection` → `#setView`/`#emptyState` (Warm-up) → `#heuteSection` (Lieder) → `#eigeneSection`. `#heuteSection` ggf. verschieben, damit Lieder nach dem Warm-up stehen.
3. Neue Funktion `loadEinsingenNotiz()`: Datum der nächsten Probe wie in `loadHeuteAndRender` ermitteln (`proben_lieder`, `.gte('datum', todayStr())`, frühestes Datum; Fallback `todayStr()`), zugehörige `probennotizen`-Zeile laden und `#einsingenNotizInhalt` füllen. Beim Speichern dieselbe Upsert-Logik wie `saveNotiz` nutzen (Update wenn Zeile existiert, sonst Insert), Feld `markiert` unverändert lassen.
4. `loadEinsingenNotiz()` beim Öffnen des Einsingen-Tabs und nach `saveProbe()` aufrufen (dort wird bereits `loadHeuteAndRender()` getriggert).
5. Verifizieren: Inline-Script extrahieren und `node --check` laufen lassen; Sichtprüfung im Browser (Reihenfolge, Speichern, Konsistenz mit Notiz-Tab).

## Output

**Datei**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` (bearbeitet)
**Format**: HTML/JS inline
**Muss enthalten**:
- Neuer Block `#einsingenNotizSection` an erster Stelle im Einsingen-`#main`.
- Reihenfolge Notizen → Warm-up → Lieder.
- Funktion `loadEinsingenNotiz()` + Speicher-Handler, gekoppelt an dieselbe `probennotizen`-Zeile wie der Notiz-Tab.

## Abnahmekriterien

- [ ] Auf dem Einsingen-Tab erscheint oben ein Notiz-Feld, darunter das Warm-up-Set, darunter die Lieder der nächsten Probe.
- [ ] Eine im Einsingen-Notizfeld gespeicherte Notiz erscheint (gleiches Datum) auch im Notiz-Tab und umgekehrt — nur EINE `probennotizen`-Zeile pro Datum.
- [ ] `node --check` über den extrahierten Inline-Script läuft fehlerfrei.
- [ ] Bestehende Views (Repertoire, Jahresplan, Mitglieder, Buchhaltung) funktionieren unverändert.

## Voraussetzungen

| AP-ID | Warum benötigt |
|-------|----------------|
| — | Unabhängig, keine Migration nötig. |

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Code/Repo, direkte Edits an `index.html`)
**Modell (Empfehlung)**: Claude – grösstes (Layout-Umbau in grosser Datei, Regressionsrisiko)

## Grösse

**Schätzung**: M

**Begründung**: Mehrere abgegrenzte Schritte (DOM-Block, Reihenfolge, eine neue Lade-/Speicherfunktion), aber klar umrissen und ohne Migration.

## Notizen / Offene Punkte

**Entschieden (2026-08-01):** Der separate Notiz-Tab BLEIBT bestehen — er zeigt die Historie/Liste aller vergangenen Notizen (das kann die Einsingen-Seite nicht). Gleiche Datenquelle, keine Redundanz.

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: 2026-08-01 (Code umgesetzt; Live-Test durch Nutzer offen)
- **Abweichungen von den Umsetzungsschritten**: Statt eines separaten Tab-Open-Hooks wird `loadEinsingenNotiz()` zentral am Anfang von `loadHeuteAndRender()` aufgerufen — deckt Initial-Load, Chor-Wechsel und `saveProbe()` in einem ab (DRY, keine 5 Call-Sites). Speichern nutzt Upsert (select→update/insert), `markiert` bleibt bei Update unangetastet.
- **Neue Funktionen**: `getNaechsteProbeDatum()`, `loadEinsingenNotiz()`, `saveEinsingenNotiz()`, Var `_einsingenNotizDatum`. Neuer DOM-Block `#einsingenNotizSection` (Textarea `#einsingenNotizInhalt` + Button) zuoberst in `#main`.
- **Tatsächlicher Output-Pfad**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html`
- **Verifikation**: `node --check` über den Inline-Script fehlerfrei. Nur bestehende CSS-Klassen wiederverwendet.
- **Verbleibende offene Punkte**: Live-Sichtprüfung am iPhone + Deploy (git push) durch Nutzer (siehe AP-0401).

## Status

- [ ] Bereit zur Ausführung
- [x] In Arbeit (Code fertig, Live-Test offen)
- [ ] Abgenommen
- [ ] Abgelehnt / neu planen
