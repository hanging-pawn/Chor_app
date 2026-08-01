# AP-0303: Neuer To-Do-Reiter mit abhakbaren Punkten + Migration `todos`

## Ziel

Ein neuer Reiter „To-Do" mit einer Liste einzelner Positionen, die hinzugefügt, abgehakt und gelöscht werden können — persistiert in Supabase.

## Kontext

Die App hat 6 Tabs (einsingen, probennotizen, repertoire, jahresplan, mitglieder, buchhaltung), verwaltet über `data-tab`-Buttons in Sidebar (`nav`) und Bottom-Nav, plus je eine View (`#…View`). Das Muster Tab → View → Supabase-CRUD existiert mehrfach; als Vorlage eignet sich die Repertoire-Liste (`renderProbePlanner`/`toggleProbeLied`) und die Notiz-Liste. Neue Tabelle `todos` nötig (manueller Supabase-Schritt).

## Inputs

| Typ | Quelle / Inhalt |
|-----|----------------|
| Datei | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` |
| Datei (neu) | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/supabase/006_todos.sql` |
| Information | Tabelle `todos`: `id uuid pk default gen_random_uuid(), chor_id uuid, text text, erledigt bool default false, reihenfolge int, created_at timestamptz default now()`. |
| Referenz | Bestehende Nav-Buttons (`data-tab`), View-Umschaltlogik, `getSupabase()`, `APP_STATE.chorId`. |

## Umsetzungsschritte

1. Migrations-SQL `supabase/006_todos.sql` erstellen (Tabelle `todos` inkl. `chor_id`-Filterspalte; RLS analog zu bestehenden Tabellen, falls dort verwendet). Manueller Supabase-Schritt.
2. Nav-Eintrag „To-Do" in Sidebar-`nav` und Bottom-Nav ergänzen (`data-tab="todo"`, Icon analog zu bestehenden).
3. Neue View `#todoView` mit Eingabefeld + „Hinzufügen"-Button und Liste `#todoList`.
4. In die View-Umschaltlogik `todo` aufnehmen (Titel „To-Do" im `#pageTitle`, `#todoView` ein-/ausblenden, `initTodoIfNeeded()`/`loadTodosAndRender()` aufrufen).
5. CRUD implementieren: `loadTodosAndRender()` (select chor-gefiltert, sortiert nach `reihenfolge`/`created_at`), `addTodo(text)`, `toggleTodo(id)` (setzt `erledigt`), `deleteTodo(id)`. Checkbox-Interaktion analog `toggleProbeLied`.
6. Verifizieren: `node --check`; Sichtprüfung (hinzufügen, abhaken, neu laden, löschen).

## Output

**Datei**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` (bearbeitet) + `…/supabase/006_todos.sql` (neu)
**Format**: HTML/JS inline + SQL
**Muss enthalten**:
- Tabelle `todos` (Migration).
- Neuer Tab + View mit funktionierendem Hinzufügen / Abhaken / Löschen, chor-gefiltert.

## Abnahmekriterien

- [ ] Neuer Reiter „To-Do" erscheint in Sidebar und Bottom-Nav und schaltet auf `#todoView`.
- [ ] Positionen lassen sich hinzufügen, abhaken (Status bleibt nach Neuladen erhalten) und löschen.
- [ ] Alle Queries sind mit `chor_id` gefiltert.
- [ ] `node --check` läuft fehlerfrei; die anderen 6 Tabs funktionieren unverändert.

## Voraussetzungen

| AP-ID | Warum benötigt |
|-------|----------------|
| — | Unabhängig von 0301/0302. |

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Code/Repo) — Migration manuell in Supabase.
**Modell (Empfehlung)**: Claude – mittleres (klares Muster kopieren)

## Grösse

**Schätzung**: M

**Begründung**: Tab + View + CRUD nach bestehendem Muster; mehrere Stellen, aber gut abgegrenzt.

## Notizen / Offene Punkte

**Entschieden (2026-08-01):** Einfache, chor-gebundene Liste — nur Text + Abhaken + Löschen, KEIN Fälligkeitsdatum, KEINE Priorität. Später erweiterbar.

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
