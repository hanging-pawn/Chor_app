# Umsetzungsprompt — AP-0302: Notizzeile pro Lied

**Ausführungsumgebung:** Claude Code (Repo-Root)
**Modell-Empfehlung:** Claude – mittleres
**Grösse:** M
**Voraussetzung:** AP-0301 abgeschlossen; Migration (siehe manueller Schritt) in Supabase ausgeführt.

---

## Manuelle Schritte (ZUERST!)

Migration im Supabase-SQL-Editor ausführen (Projekt `guxvlbrxzmgylojbxjew`):

```sql
alter table proben_lieder add column if not exists notiz text;
```

Grund: Claude hat keinen DB-Zugriff. Ohne diese Spalte schlägt das Speichern der Pro-Lied-Notiz fehl. Das SQL zusätzlich als Datei `supabase/005_proben_lieder_notiz.sql` im Repo ablegen (macht Claude im Prompt).

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei index.html (inline, kein Build). Ziel: In der Liederliste der nächsten Probe
(auf der Einsingen-Seite, gerendert von loadHeuteAndRender als .heute-card) bekommt jedes Lied
eine eigene Notizzeile, die pro Lied + Probe persistiert wird.

Voraussetzung (bereits erledigt): In Supabase existiert die Spalte proben_lieder.notiz (text).

Aufgaben:
1. Lege die Migrationsdatei supabase/005_proben_lieder_notiz.sql mit dem Inhalt
   `alter table proben_lieder add column if not exists notiz text;` an.
2. In loadHeuteAndRender() das Select um notiz erweitern:
   .select('datum, reihenfolge, notiz, lieder ( id, titel, status, pdf_pfad )')
3. In der .heute-card unter Titel/Status ein kompaktes einzeiliges Eingabefeld
   (class="heute-notiz") pro Lied rendern, vorbelegt mit dem gespeicherten notiz-Wert. Jedes
   Feld kennt lied_id und datum.
4. onblur/onchange speichert:
   update proben_lieder set notiz = <wert> where chor_id = APP_STATE.chorId and datum = <datum>
   and lied_id = <lied_id>. Kein globaler Speichern-Button.

Verifikation: Inline-<script> extrahieren, `node --check` fehlerfrei. Prüfen: Notiz eingeben,
Tab wechseln, zurück → Notiz bleibt beim richtigen Lied erhalten. Keine Regression.

Nur index.html + die neue .sql-Datei anfassen.
```

## Nach Ausführung (verbindlich)

1. Dokumentations-Block in `AP-0302_notizzeile_pro_lied.md` ausfüllen, Status setzen.
2. Prompt bei sauberem Abschluss nach `…/03_umsetzung/archiv/AP-0302_prompt.md` verschieben.
3. Übersicht aktualisieren.
