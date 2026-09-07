# Umsetzungsprompt — AP-0405: Datenzugriffe robust machen

**Umgebung:** Claude Code (Repo-Root) · **Modell:** mittel · **Grösse:** M–L
**Voraussetzung:** AP-0403 abgeschlossen (vermeidet Diff-Konflikte in index.html).

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei index.html (inline JS). Fünf Korrektheits-Fixes gemäss Code Review
2026-08-15 (Befunde 6–10), Report: 04_Implementierung/plan-verbesserungen-2026-08/
04_qualitaet/2026-08-15_Code-Review.md

1. Z. 7821–7823: Die termine_lieder-Query lädt ungescopte Daten. Fix:
   .in('termin_id', _termineCache.map(t => t.id)) ergänzen (Cache liegt davor vor).
2. saveProbe (Z. 6979–6996) und submitTerminForm (Z. 8209–8222): Delete-then-Insert
   ohne Transaktion. Fix: Upsert mit onConflict (Muster: proben_set-Upsert Z. 7306–7309);
   nicht mehr vorhandene Zuordnungen danach gezielt per .delete().in(...) entfernen.
   Reihenfolge: erst Upsert (Daten sichern), dann Aufräum-Delete.
3. Chorwechsel-Race (onChorChange Z. 4580 ff., loadHeuteAndRender Z. 7193 f.):
   In jedem Loader, der in globale Caches (_liederCache, _termineCache, …) schreibt,
   beim Start const cid = APP_STATE.chorId merken und nach jedem await prüfen:
   if (cid !== APP_STATE.chorId) return;
4. Verschluckte Fehler: Z. 7515–7521, 7523–7528, 7799–7804 destrukturieren error nicht.
   Fix: { data, error } destrukturieren, bei error console.warn + leerer Fallback.
   In saveProbeNotiz (Z. 7258): bei selErr abbrechen mit alert, nicht in den
   Insert-Zweig laufen.
5. applyBeitragshoehe (Z. 5975–5982): sequentielle Einzel-Updates ersetzen durch EIN
   Update .in('id', ids); Fehler per alert melden; Button-Loading-State wie bei den
   anderen Speicher-Buttons.

Verifikation: node --check auf extrahiertem Inline-Script; Smoke-Test der Flows
Probe speichern, Termin bearbeiten, Chorwechsel, Beitragshöhe anwenden.
Nur index.html anfassen.
```

## Nach Ausführung (verbindlich)

1. Doku-Block in `AP-0405_datenzugriffe_robust.md` ausfüllen, Status setzen.
2. Prompt nach `…/04_qualitaet/archiv/` verschieben. Übersicht/Dashboard aktualisieren.
