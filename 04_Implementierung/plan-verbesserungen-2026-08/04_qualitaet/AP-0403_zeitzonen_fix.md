# AP-0403: Zeitzonenfehler beheben (todayStr + bezahlt_am)

## Ziel

Alle «Heute»-Berechnungen nutzen Lokalzeit (Europe/Zurich) statt UTC. Schliesst Review-Befund 4 (Hoch) und Niedrig-Befund `bezahlt_am` (Code Review 2026-08-15).

## Kontext

`todayStr()` (index.html Z. 6584) nutzt `new Date().toISOString().split('T')[0]` → UTC-Datum. Zwischen 00:00 und 02:00 Lokalzeit liefert das den **Vortag**: falsche «nächste Probe» (`.gte('datum', todayStr())`, Z. 7080/7156), fehlendes Heute-Badge (Z. 7028), falsch vorbelegte Notizformulare (Z. 6331, 6448). Gleiche UTC-Duplikate an Z. 6051 und 5765. Zusätzlich zeigt `fmtDateDE` (Z. ~5795) bei vollen Timestamps (`bezahlt_am`, Z. 6020/6027) per `slice(0,10)` das UTC-Datum an — buchhalterisch relevant.

## Umsetzungsschritte

1. Zentrale Funktion `todayStr()` auf Lokalzeit umstellen: `getFullYear`/`getMonth`/`getDate` mit padStart.
2. Alle UTC-Duplikate (Z. 5765, 6051, 6331, 6448) auf die zentrale Funktion umstellen — vorher per Grep `toISOString().split` alle Vorkommen finden.
3. `fmtDateDE`: bei vollen ISO-Timestamps `new Date(iso).toLocaleDateString('de-CH')`; bei reinen `YYYY-MM-DD`-Strings bisheriges Verhalten behalten.
4. Verifizieren: `node --check` über Inline-Script; manuell Systemzeit-Szenario durchdenken (23:59 vs. 00:30).

## Abnahmekriterien

- [x] Kein `toISOString().split('T')[0]` mehr im Live-Code für «heute». Per Grep verifiziert: von `toISOString` bleiben nur die beiden `bezahlt_am`-Inserts (Z. 6038/6045) übrig — die sind korrekt, siehe Abweichungen.
- [x] `todayStr()` liefert um 00:30 Lokalzeit das heutige Datum. Mit gestellter Uhr in Node unter `TZ=Europe/Zurich` geprüft: 22:30 UTC → `2026-07-09` (Sommer, UTC+2) und 23:30 UTC → `2026-01-16` (Winter, UTC+1). Gegenprobe mit der alten Implementierung liefert jeweils den Vortag.
- [x] `bezahlt_am`-Anzeige zeigt das lokale Datum — Beiträge-Tabelle (Z. 5966). **Einschränkung:** Im PDF kommt `bezahlt_am` gar nicht vor; das Kriterium war insofern zu weit gefasst. Das PDF zeigt `ausgaben.datum` (reine Datumsspalte, unverändert) sowie Zeitraum und Erstelldatum.
- [x] `node --check` über das Inline-Script fehlerfrei. Keine Regression in Kalender/Jahresplan: der `T12:00:00`-Trick (Z. 6490) und der Datumsaufbau aus expliziten `year`/`month`/`day` (Z. 7914) sind unangetastet.

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: klein–mittel · **Grösse**: S

## Dokumentation

- **Erledigt am**: 2026-09-07
- **Abweichungen**:
  - `bezahlt_am` wird weiterhin als voller ISO-Zeitstempel gespeichert (Z. 6038/6045). Die Spalte ist `timestamptz`; den exakten Zeitpunkt festzuhalten ist richtig, falsch war ausschliesslich die **Anzeige**. Der Fix sitzt deshalb in `fmtDateDE`, nicht beim Schreiben.
  - Zusätzlich zur AP-Liste umgestellt: Z. 6249, PDF-Fussnote «Erstellt am» — lief über `fmtDateDE(new Date().toISOString())` und zeigte damit ebenfalls UTC.
  - `fmtDateDE` formatiert die Zeitstempel-Variante von Hand als `TT.MM.JJJJ` statt über `toLocaleDateString('de-CH')` wie in Schritt 3 vorgeschlagen: de-CH liefert `7.9.2026` ohne führende Nullen und hätte die Darstellung gegenüber allen anderen Datumsfeldern inkonsistent gemacht.
  - Reine `YYYY-MM-DD`-Strings laufen bewusst **nicht** durch `new Date()` — sie würden sonst als UTC-Mitternacht gelesen und in westlichen Zeitzonen auf den Vortag rutschen. Das ist derselbe Fehler nur andersherum.
- **Prüfung**: 13 Zusicherungen in Node unter `TZ=Europe/Zurich` mit gestellter Uhr (Sommer-/Winterzeit, 00:30 und 23:59, führende Nullen, reines Datum vs. Zeitstempel, Postgres-Format mit Mikrosekunden und Offset, Leerwerte) — alle bestanden. Gegenprobe: die alte Implementierung fällt bei denselben Eingaben auf den Vortag.

## Status

- [x] Bereit zur Ausführung
- [x] In Arbeit
- [x] Abgenommen
