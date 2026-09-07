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

- [ ] Keine Query ohne chor-/id-Scope mehr (Grep über `.select(` verifiziert).
- [ ] Probe speichern bei simuliertem Insert-Fehler: alter Stand bleibt erhalten.
- [ ] Schneller doppelter Chorwechsel zeigt konsistent den zuletzt gewählten Chor.
- [ ] `node --check` fehlerfrei; bestehende Flows unverändert.

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M–L

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen**: {keine / Beschreibung}

## Status

- [x] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
