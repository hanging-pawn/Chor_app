# AP-0405: Datenzugriffe robust machen

## Ziel

Die fünf mittleren Korrektheits-/Performance-Befunde aus dem Code Review 2026-08-15 (Befunde 6–10) sind behoben: gescopte Queries, atomares Speichern, keine Race Conditions beim Chorwechsel, sichtbare Fehler, gebatchte Updates.

## Kontext (Befunde, alle index.html)

| Befund | Zeile | Problem |
|--------|-------|---------|
| 6 | 7821–7823 | `termine_lieder` ohne chor-Scope und ohne Limit geladen |
| 7 | 6979–6996, 8209–8222 | Delete-then-Insert ohne Transaktion (`saveProbe`, `submitTerminForm`) — Datenverlust bei Netzabbruch |
| 8 | 4580–4615, 7193–7194 | Chorwechsel-Race: langsame Antwort des alten Chors überschreibt Anzeige des neuen |
| 9 | 7515–7528, 7799–7804, 7258 | `error` nicht destrukturiert → still leere Dropdowns/Jahresplan |
| 10 | 5975–5982 | N+1: `applyBeitragshoehe` updatet sequentiell pro Mitglied |

## Umsetzungsschritte

1. `termine_lieder`-Query mit `.in('termin_id', _termineCache.map(t => t.id))` scopen.
2. `saveProbe`/`submitTerminForm` auf Upsert mit `onConflict` umstellen (Muster: `proben_set`-Upsert Z. 7306–7309); entfernte Zeilen gezielt per `.delete().in(...)` statt Voll-Delete.
3. Loader-Guard: beim Start `const cid = APP_STATE.chorId` merken, nach jedem `await` vor Cache-Write `if (cid !== APP_STATE.chorId) return;` — in allen Loadern, die in globale Caches schreiben.
4. Alle Supabase-Aufrufe: `error` destrukturieren, mind. `console.warn` + definierter Fallback; in `saveProbeNotiz` den `selErr`-Pfad korrigieren (nicht stillschweigend in Insert laufen).
5. `applyBeitragshoehe`: ein Update per `.in('id', ids)`, Fehler per `alert`, Loading-State am Button.

## Abnahmekriterien

- [x] Keine Query ohne chor-/id-Scope mehr. Skript über alle 60 `.from(...)`-Ketten: von den lesenden Queries bleibt genau eine ohne `.eq`/`.in` — `choere.select('id, name')`, die Chorliste selbst. Dort *gibt* es keine `chor_id`, und RLS aus Migration 005 begrenzt sie bereits auf `auth.uid()`. Die drei weiteren Treffer sind Inserts mit `.select()` für die zurückgegebene Zeile, also durch den Insert gebunden.
- [x] Probe speichern bei simuliertem Insert-Fehler: alter Stand bleibt erhalten. Mit gefälschtem Supabase-Client in Node geprüft — bei Insert-Fehler wird kein Delete abgesetzt (Ablauf: `select → insert`), und die Nutzerin bekommt eine Meldung. Gegenprobe Erfolgsfall: `select → insert → delete → reload`.
- [x] Schneller doppelter Chorwechsel zeigt konsistent den zuletzt gewählten Chor. Geprüft mit verzögerter Antwort für Chor A und Wechsel auf B während der Abfrage: Cache und Anzeige bleiben bei B. Gegenprobe ohne Wechsel: Cache wird normal gefüllt und gerendert.
- [x] `node --check` über das Inline-Script fehlerfrei; bestehende Flows unverändert.

**Gegenprobe:** Dieselben vier Verhaltensprüfungen gegen den Stand *vor* der Änderung ausgeführt — alle vier schlagen dort fehl (altes `saveProbe` löscht vor dem Insert; alter Loader überschreibt den Cache mit der veralteten Antwort). Die Tests messen also tatsächlich das behobene Verhalten.

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M–L

## Dokumentation

- **Erledigt am**: 2026-09-07
- **Abweichungen**:
  - **Befund 7, kein `upsert` mit `onConflict`.** Der vorgeschlagene Weg setzt einen Unique-Constraint voraus. `proben_lieder` hat aber nur eine Surrogat-PK auf `id` und keinen Constraint auf `(chor_id, datum, lied_id)` — ein Upsert ist dort schlicht nicht möglich. Einen nachzurüsten hiesse: weitere Migration, die an bereits vorhandenen Duplikaten scheitern kann. Stattdessen wurde die **Reihenfolge umgedreht**: alte Zeilen-ids merken, neue Auswahl einfügen, danach die alten ids löschen. Bricht die Verbindung dazwischen ab, stehen im schlimmsten Fall beide Stände da — sichtbar und durch erneutes Speichern reparierbar. Der bisherige Weg (erst löschen) verlor die Probe ersatzlos. Das Datenverlust-Risiko ist damit beseitigt, ohne Schemaänderung.
  - `termine_lieder` hat zwar die PK `(termin_id, lied_id)`, wurde aber aus Konsistenzgründen ebenfalls per Abgleich gelöst statt per Upsert: fehlende ergänzen, entfallene löschen. Das kommt ohne den `.not(...in...)`-Filter aus, spart Schreibvorgänge und ist dieselbe Fehlerlogik wie bei `saveProbe`.
  - **Befund 8** wurde in **zehn** Loadern umgesetzt, nicht nur in den beiden genannten Zeilen: `loadMitglieder`, `loadBeitraege`, `loadBuchhaltung`, `loadNotizen`, `loadLieder`, `loadProben`, `loadHeute`, `loadPianisten`, `loadPianistenForProbe`, `loadTermine`, `loadIdeen`. Die Queries nutzen zusätzlich die gemerkte `cid` statt `APP_STATE.chorId`, damit Abfrage und Prüfung garantiert dieselbe Chor-ID verwenden.
  - **Befund 6:** Der fehlende Scope war gravierender als notiert — `termine_lieder` trägt keine eigene `user_id`, RLS greift dort also nicht. Ohne `.in('termin_id', …)` lieferte die Query die Zuordnungen *aller* Termine aller Nutzerinnen.
  - **Befund 10:** zusätzlich zum gebündelten Update ein `id` am Button ergänzt (`btnBeitragAnwenden`), weil er vorher keines hatte und der Loading-State sonst nicht anzusteuern war.
- **Nicht getestet**: Die Änderungen sind gegen einen gefälschten Supabase-Client geprüft, nicht gegen die echte Datenbank. Ein Durchlauf in der App (Probe speichern, Termin mit Liedern bearbeiten, Beitragshöhe übernehmen) steht aus.

## Status

- [x] Bereit zur Ausführung
- [x] In Arbeit
- [x] Abgenommen (Code); Durchlauf in der App steht aus
