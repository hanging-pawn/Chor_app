# Umsetzungsprompt — AP-0303: To-Do-Reiter

**Ausführungsumgebung:** Claude Code (Repo-Root)
**Modell-Empfehlung:** Claude – mittleres
**Grösse:** M
**Voraussetzung:** Migration (siehe manueller Schritt) in Supabase ausgeführt.

---

## Manuelle Schritte (ZUERST!)

Migration im Supabase-SQL-Editor ausführen:

```sql
create table if not exists todos (
  id uuid primary key default gen_random_uuid(),
  chor_id uuid not null,
  text text not null,
  erledigt boolean not null default false,
  reihenfolge int,
  created_at timestamptz not null default now()
);
```

Falls die bestehenden Tabellen RLS-Policies nutzen, für `todos` analoge Policy anlegen (Zugriff auf eigene `chor_id`). Das SQL zusätzlich als `supabase/006_todos.sql` im Repo ablegen.

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei index.html (inline, kein Build). Ziel: ein neuer Reiter „To-Do" mit einer Liste
einzelner Positionen zum Hinzufügen, Abhaken und Löschen, persistiert in Supabase.

Voraussetzung (erledigt): Tabelle todos existiert (id, chor_id, text, erledigt, reihenfolge,
created_at).

Muster: Die App hat 6 Tabs über data-tab-Buttons (Sidebar-nav + Bottom-nav) und je eine
#…View. Kopiere dieses Muster (z. B. von Repertoire/Notizen). Alle Queries mit
.eq('chor_id', APP_STATE.chorId).

Aufgaben:
1. Lege supabase/006_todos.sql mit dem Create-Statement an.
2. Nav-Eintrag „To-Do" (data-tab="todo", passendes Icon) in Sidebar-nav UND Bottom-nav.
3. Neue View #todoView: Eingabefeld + „Hinzufügen"-Button + Liste #todoList.
4. View-Umschaltlogik um 'todo' erweitern (#pageTitle „To-Do", #todoView zeigen/verstecken,
   loadTodosAndRender() bzw. initTodoIfNeeded() aufrufen).
5. CRUD: loadTodosAndRender() (chor-gefiltert, sortiert nach reihenfolge/created_at),
   addTodo(text), toggleTodo(id) (setzt erledigt), deleteTodo(id). Checkbox-Interaktion analog
   toggleProbeLied.

Verifikation: `node --check` fehlerfrei; hinzufügen/abhaken/neu laden/löschen funktioniert;
Status bleibt nach Reload erhalten; die 6 bestehenden Tabs unverändert.

Nur index.html + die neue .sql-Datei anfassen.

Default-Annahmen (falls nicht anders gesagt): Liste ist chor-gebunden, ohne Fälligkeitsdatum/
Priorität.
```

## Nach Ausführung (verbindlich)

1. Dokumentations-Block in `AP-0303_todo_reiter.md` ausfüllen, Status setzen.
2. Prompt nach `…/03_umsetzung/archiv/AP-0303_prompt.md` verschieben.
3. Übersicht aktualisieren.
