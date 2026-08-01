# Umsetzungsprompt — AP-0304: Pianisten-Mitteilung

**Ausführungsumgebung:** Claude Code (Repo-Root)
**Modell-Empfehlung:** Claude – grösstes (Versandweg + saubere Trennung Liederliste/Notizen)
**Grösse:** M
**Voraussetzung:** Migration (siehe manueller Schritt) in Supabase ausgeführt. Versandweg entschieden: bestehende `callSendEmail`-Funktion.

---

## Manuelle Schritte (ZUERST!)

Migration im Supabase-SQL-Editor ausführen:

```sql
create table if not exists pianisten (
  id uuid primary key default gen_random_uuid(),
  chor_id uuid not null,
  name text not null,
  email text,
  created_at timestamptz not null default now()
);
```

Bei bestehendem RLS analoge Policy (Zugriff auf eigene `chor_id`). SQL zusätzlich als `supabase/007_pianisten.sql` im Repo ablegen.

Versandweg ist entschieden: bestehende `callSendEmail`-Funktion (Supabase Edge Function), die auch `sendProbeninfo` nutzt. Signatur: `callSendEmail({ to, subject, body, chor_id, typ })`.

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei index.html (inline, kein Build). Ziel: unter den Probennotizen ein Feld
„Dem Pianisten mitteilen" mit Pianisten-Dropdown; der Versand enthält NUR die Liederliste einer
Probe (Titel in Reihenfolge), nicht die persönlichen Notizen.

Kontext: Es gibt bereits „☑ Dem Chor mitteilen" (Feld markiert auf probennotizen) + Funktion
sendProbeninfo() für E-Mail an Mitglieder. ENTSCHEIDUNG: Pianisten in eigener Tabelle pianisten
(id, chor_id, name, email). Liederliste kommt aus proben_lieder (Titel via _liederCache, in
reihenfolge). Alle Queries chor-gefiltert.

Versandweg: bestehende Funktion callSendEmail({ to, subject, body, chor_id, typ }) — dieselbe
Edge Function wie sendProbeninfo. to = E-Mail des gewählten Pianisten.

Aufgaben:
1. Lege supabase/007_pianisten.sql mit dem Create-Statement an.
2. Minimale Pianisten-Verwaltung: Liste anlegen/löschen (Name + E-Mail) — kompakter Abschnitt
   beim Mitteilen-Block. CRUD loadPianisten(), addPianist(), deletePianist().
3. Unter dem Probennotiz-Editor Block „Dem Pianisten mitteilen": Dropdown #pianistSelect (aus
   pianisten) + Button „Liederliste senden".
4. Nachricht bauen: proben_lieder der gewählten Probe (Datum) laden, Titel in Reihenfolge als
   Liste. NUR Titel, KEINE probennotizen-Inhalte. Betreff „Liederliste Probe <Datum>".
5. Versand über den oben festgelegten Weg an die E-Mail des gewählten Pianisten.

Verifikation: `node --check` fehlerfrei; Pianist anlegen, Probe wählen, senden — die Nachricht
enthält ausschliesslich die Liederliste, keine persönlichen Notizen; „Dem Chor mitteilen"
unverändert.

Nur index.html + die neue .sql-Datei anfassen.
```

## Nach Ausführung (verbindlich)

1. Dokumentations-Block in `AP-0304_pianisten_mitteilung.md` ausfüllen, Status setzen.
2. Prompt nach `…/03_umsetzung/archiv/AP-0304_prompt.md` verschieben.
3. Übersicht aktualisieren.
