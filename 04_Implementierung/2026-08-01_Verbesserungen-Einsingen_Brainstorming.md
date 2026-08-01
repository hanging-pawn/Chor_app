# Brainstorming — Verbesserungen (Einsingen, To-Do, Pianisten-Mitteilung)

**Datum:** 2026-08-01
**Quelle:** Rückmeldung Anja (Chorleitung)
**Codebasis:** App vollständig inline in `index.html` (~7.6k Zeilen). `js/*.js` = Alt-Gerüst, nicht produktiv.

## Geklärte Grundsatzentscheidungen
- **Pianisten:** eigene Supabase-Tabelle `pianisten` (nicht als Mitglieder-Rolle).
- **Notizen:** eine einzige Datenquelle. Notizfeld auf der Einsingen-Seite und der Notiz-Tab greifen auf dieselbe datumsgebundene `probennotizen`-Zeile zu — keine zweite Wahrheit.

---

## 1. Noten für Einsing-Kanon
**Ist:** Kanon-Pool (`index.html` ~Z. 4623) hat nur `title` + `anleitung`, kein `noten`-Feld. `renderCard()` zeigt Notenbild nur bei vorhandenem `ex.noten`. abcjs + `renderNotations()` sind bereits eingebunden und funktionsfähig.
**Umsetzung:** Zu jedem der 5 Kanons ABC-Notation als `noten`-String ergänzen. Kein neuer Code, nur Daten. Kanons sind gemeinfrei.
**Offen:** ABC (empfohlen, responsiv, schon verdrahtet) vs. PDF-Upload.
**Aufwand:** Klein–mittel (Arbeit = korrektes Notieren der Melodien).
**Keine Migration.**

## 2. „Heute · Probe" → nächste geplante Probe
**Ist:** `loadHeuteAndRender()` filtert `.eq('datum', todayStr())` → nur exakt heute.
**Umsetzung:** Query auf `.gte('datum', todayStr())` + `order('datum')`, frühestes Datum nehmen. Label dynamisch: „Heute" wenn heute, sonst „Nächste Probe · Fr, 25. Juli".
**Offen:** Verhalten wenn keine Probe geplant (aktueller Leertext bleibt).
**Aufwand:** Klein.
**Keine Migration.**

## 3. Layout: eine Seite — 1. Notizen, 2. Warm-up, 3. Lieder mit Notizzeile
**Ist:** Einsingen-Tab hat Warm-up (`setView`) + „Heute"-Liederliste. Notizen sind separater Tab; Lieder haben keine Notizzeile.
**Umsetzung:** Auf der Einsingen-Seite oben Notizfeld für die nächste Probe (gekoppelt an dieselbe `probennotizen`-Zeile, siehe Grundsatzentscheidung), darunter Warm-up, darunter Liederliste mit je einer Notizzeile pro Song.
**Migration:** neue Spalte `proben_lieder.notiz text`.
**Offen:** Bleibt der separate Notiz-Tab bestehen oder wird er redundant?
**Aufwand:** Mittel.

## 4. Neuer Reiter „To-Do"
**Ist:** 6 Tabs, kein To-Do. Muster Tab → View → Supabase-CRUD mehrfach vorhanden (Repertoire, Notizen) → gut kopierbar.
**Umsetzung:** Nav-Eintrag (Sidebar + Bottom-Nav), neue View, abhakbare Liste. Toggle analog `toggleProbeLied`.
**Migration:** Tabelle `todos` (`id, chor_id, text, erledigt bool, reihenfolge, created_at`).
**Offen:** Chor-gebunden oder persönlich? Fälligkeitsdatum/Priorität nötig oder simple Liste?
**Aufwand:** Mittel.

## 5. „Dem Pianisten mitteilen" (Dropdown, nur Liederliste)
**Ist:** „☑ Dem Chor mitteilen" + `sendProbeninfo()` (E-Mail) existieren. Keine Pianisten-Entität.
**Umsetzung:** Unter dem Notiz-Editor Dropdown „Pianist" (aus `pianisten`) + Button „Liederliste senden". Inhalt = **nur** die `proben_lieder` der gewählten Probe (Titel in Reihenfolge), keine persönlichen Notizen. Versand über denselben Mechanismus wie `sendProbeninfo`.
**Migration:** Tabelle `pianisten` (`id, chor_id, name, email, created_at`). Ggf. kleine Verwaltungs-UI (anlegen/löschen).
**Offen:** An welches Probe-Datum ist die Mitteilung gekoppelt? Versandweg `mailto:` vs. bestehende E-Mail-Funktion?
**Aufwand:** Mittel.

---

## Empfohlene Reihenfolge
1. **Quick Wins ohne Migration:** #2 (nächste Probe), #1 (Kanon-Noten).
2. **Probe-/Notiz-Block zusammen:** #3 (Layout + `proben_lieder.notiz`) und #5 (Pianisten-Mitteilung + `pianisten`) — thematisch gekoppelt, eine Session.
3. **#4 To-Do** eigenständig.

## Migrationen (neu anzulegen)
- `proben_lieder.notiz text` (für #3)
- `todos` (für #4)
- `pianisten` (für #5)

Konform zu CLAUDE.md: Tabellen erst mit der jeweiligen Funktion anlegen.
