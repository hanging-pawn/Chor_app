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

- [ ] Kein `toISOString().split('T')[0]` mehr im Live-Code für «heute».
- [ ] `todayStr()` liefert um 00:30 Lokalzeit das heutige Datum.
- [ ] `bezahlt_am`-Anzeige (Tabelle + PDF) zeigt das lokale Datum.
- [ ] `node --check` fehlerfrei, keine Regression in Kalender/Jahresplan (dort ist der `T12:00:00`-Trick bereits korrekt — nicht anfassen).

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: klein–mittel · **Grösse**: S

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen**: {keine / Beschreibung}

## Status

- [x] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
