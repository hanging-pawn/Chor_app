# AP-0304: „Dem Pianisten mitteilen" — Dropdown + Verwaltung + Migration `pianisten`

## Ziel

Unter den Probennotizen ein zusätzliches Feld „Dem Pianisten mitteilen": ein Dropdown mit den Pianisten und ein Versand, der nur die Liederliste einer Probe/eines Konzerts enthält — nicht Anjas persönliche Notizen.

## Kontext

Es gibt bereits „☑ Dem Chor mitteilen" (Feld `markiert` auf `probennotizen`) plus `sendProbeninfo()` für den E-Mail-Versand an Mitglieder. Eine Pianisten-Entität existiert noch nicht. **Entscheidung Anja/Gianluca:** Pianisten kommen in eine EIGENE Tabelle `pianisten` (nicht als Mitglieder-Rolle). Die Mitteilung an den Pianisten enthält ausschliesslich die Liederliste (Titel in Reihenfolge) der gewählten Probe aus `proben_lieder` — keine `probennotizen`-Inhalte.

## Inputs

| Typ | Quelle / Inhalt |
|-----|----------------|
| Datei | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` |
| Datei (neu) | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/supabase/007_pianisten.sql` |
| Information | Tabelle `pianisten`: `id uuid pk default gen_random_uuid(), chor_id uuid, name text, email text, created_at timestamptz default now()`. |
| Referenz | `sendProbeninfo()`, `probennotizen`-Editor (`#notizenView`), `proben_lieder`-Liederliste, `_liederCache` für Titel. |

## Umsetzungsschritte

1. Migrations-SQL `supabase/007_pianisten.sql` erstellen (Tabelle `pianisten`, chor-gefiltert). Manueller Supabase-Schritt.
2. Kleine Pianisten-Verwaltung: Liste anlegen/löschen (Name + E-Mail). Minimal — z. B. ein kleiner Abschnitt im Notiz-Editor oder in den Mitglieder-/Einstellungen. CRUD `loadPianisten()`, `addPianist()`, `deletePianist()`.
3. Unter dem Probennotiz-Editor einen Block „Dem Pianisten mitteilen": Dropdown `#pianistSelect` (aus `pianisten`) + Button „Liederliste senden".
4. Mitteilungsinhalt bauen: die `proben_lieder` der aktuell gewählten Probe (Datum) laden, Titel via `_liederCache` in Reihenfolge auflisten. NUR Titelzeilen, keine `inhalt`-Notizen. Betreff z. B. „Liederliste Probe <Datum>".
5. Versand über die bestehende Funktion `callSendEmail({ to, subject, body, chor_id, typ })` (Supabase Edge Function, dieselbe die `sendProbeninfo` nutzt). Ziel-E-Mail = die des gewählten Pianisten; `body` = nur die Liederliste.
6. Verifizieren: `node --check`; Sichtprüfung (Pianist anlegen, Probe wählen, senden — Inhalt enthält nur Lieder, keine persönlichen Notizen).

## Output

**Datei**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` (bearbeitet) + `…/supabase/007_pianisten.sql` (neu)
**Format**: HTML/JS inline + SQL
**Muss enthalten**:
- Tabelle `pianisten` (Migration) + minimale Verwaltung.
- Dropdown + Versand, dessen Nachricht ausschliesslich die Liederliste der gewählten Probe enthält.

## Abnahmekriterien

- [ ] Tabelle `pianisten` existiert; mehrere Pianisten anleg- und wählbar.
- [ ] Der Versand enthält nur die Liederliste (Titel in Reihenfolge) der gewählten Probe — keine persönlichen Notizen.
- [ ] Dropdown listet alle Pianisten des aktiven Chors.
- [ ] `node --check` läuft fehlerfrei; „Dem Chor mitteilen" funktioniert unverändert.

## Voraussetzungen

| AP-ID | Warum benötigt |
|-------|----------------|
| — | Unabhängig; braucht nur bestehende `proben_lieder`/`probennotizen`. |

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Code/Repo) — Migration manuell in Supabase.
**Modell (Empfehlung)**: Claude – grösstes (Versandweg + Trennung Liederliste/Notizen sauber umsetzen)

## Grösse

**Schätzung**: M

**Begründung**: Migration + kleine Verwaltung + Dropdown + Nachrichtenbau + Versand; mehrere Teile, aber abgegrenzt.

## Notizen / Offene Punkte

**Entschieden (2026-08-01):** Versand über die bestehende `callSendEmail`-Funktion (Supabase Edge Function), NICHT `mailto:` — versendet direkt, konsistent mit „Dem Chor mitteilen".
**Default:** Pianisten-Verwaltung als kompakter Abschnitt direkt beim Mitteilen-Block.

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
