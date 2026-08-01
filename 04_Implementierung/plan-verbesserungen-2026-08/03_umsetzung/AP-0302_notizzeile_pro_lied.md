# AP-0302: Notizzeile pro Lied in der Probenliste + Migration `proben_lieder.notiz`

## Ziel

In der Liederliste der nächsten Probe (auf der Einsingen-Seite) bekommt jedes Lied eine eigene Notizzeile, deren Inhalt pro Lied und Probe persistiert wird.

## Kontext

Die Lieder der nächsten Probe werden von `loadHeuteAndRender()` aus `proben_lieder` geladen und als `.heute-card` gerendert (Titel, Status, ggf. „Noten öffnen"). Bisher gibt es keine Pro-Lied-Notiz. Die Zuordnung Lied↔Probe steckt in `proben_lieder` (`chor_id, datum, lied_id, reihenfolge`). Für die Notiz wird dort eine neue Spalte `notiz text` gebraucht.

Die Migration ist ein **manueller Schritt** im Supabase-SQL-Editor (Claude hat keinen DB-Zugriff). CLAUDE.md: Tabellen/Spalten erst mit der Funktion anlegen — passt, da hier gleichzeitig implementiert.

## Inputs

| Typ | Quelle / Inhalt |
|-----|----------------|
| Datei | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` |
| Datei (neu) | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/supabase/` (Migrations-SQL ablegen) |
| Information | SQL: `alter table proben_lieder add column if not exists notiz text;` |
| Referenz | `loadHeuteAndRender()`, `saveProbe()` in `index.html`. |

## Umsetzungsschritte

1. Migrations-SQL-Datei erstellen (z. B. `supabase/005_proben_lieder_notiz.sql`) mit `alter table proben_lieder add column if not exists notiz text;`. Im Prompt als manueller Supabase-Schritt kennzeichnen.
2. In `loadHeuteAndRender()` das Select um `notiz` erweitern (`.select('datum, reihenfolge, notiz, lieder ( ... )')`).
3. In der `.heute-card`-Vorlage unter Titel/Status ein kompaktes `<input>`/`<textarea class="heute-notiz">` pro Lied rendern, vorbelegt mit `r.notiz`. Jedes Feld kennt seine `lied_id` und das `datum`.
4. Speichern: onblur/onchange schreibt die Notiz zurück — `update proben_lieder set notiz = … where chor_id = … and datum = … and lied_id = …`. Debounce/onblur reicht; kein globaler Speichern-Button nötig.
5. Verifizieren: `node --check` über Inline-Script; Sichtprüfung (Notiz eingeben, Tab wechseln, zurück — Notiz bleibt erhalten).

## Output

**Datei**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` (bearbeitet) + `…/supabase/005_proben_lieder_notiz.sql` (neu)
**Format**: HTML/JS inline + SQL
**Muss enthalten**:
- Migrations-SQL für Spalte `proben_lieder.notiz`.
- Pro-Lied-Notizfeld in der Probenliste, das lädt und speichert.

## Abnahmekriterien

- [ ] SQL-Migration existiert und legt `proben_lieder.notiz` an (idempotent, `if not exists`).
- [ ] Jedes Lied in der Probenliste hat eine eigene Notizzeile.
- [ ] Eine eingegebene Notiz bleibt nach Neuladen/Tab-Wechsel erhalten (pro Lied + Datum korrekt zugeordnet).
- [ ] `node --check` läuft fehlerfrei; bestehende Funktionen unverändert.

## Voraussetzungen

| AP-ID | Warum benötigt |
|-------|----------------|
| AP-0301 | Die Probenliste steht im neuen Layout nach dem Warm-up; Notizzeile baut darauf auf. |

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Code/Repo) — Migration wird manuell in Supabase ausgeführt.
**Modell (Empfehlung)**: Claude – mittleres (klar abgegrenzte CRUD-Erweiterung)

## Grösse

**Schätzung**: M

**Begründung**: Eine Migration + Select-Erweiterung + Feld-Rendering + Speicher-Handler, alles entlang bestehender Muster.

## Notizen / Offene Punkte

> ⚠️ OFFEN: Einzeiliges `<input>` oder mehrzeiliges `<textarea>` pro Lied? Default: einzeiliges Feld, wächst nicht.

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen von den Umsetzungsschritten**: {keine / Beschreibung}
- **Tatsächlicher Output-Pfad**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html`
- **Verbleibende offene Punkte**: {keine / Verweis}

## Status

- [ ] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
- [ ] Abgelehnt / neu planen
