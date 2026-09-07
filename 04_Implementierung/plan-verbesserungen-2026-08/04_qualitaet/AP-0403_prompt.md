# Umsetzungsprompt — AP-0403: Zeitzonenfix

**Umgebung:** Claude Code (Repo-Root) · **Modell:** klein–mittel · **Grösse:** S

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei index.html (inline JS, kein Build). Zeitzonenfix gemäss Code Review
2026-08-15, Befund 4: todayStr() (ca. Z. 6584) nutzt toISOString() → UTC-Datum; in
Europe/Zurich liefert das zwischen 00:00 und 02:00 Lokalzeit den Vortag.

Aufgaben:
1. todayStr() auf Lokalzeit umstellen:
   const d = new Date();
   return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
2. Per Grep alle weiteren Vorkommen von toISOString().split('T')[0] finden (mind.
   Z. 5765, 6051, 6331, 6448) und auf todayStr() umstellen.
3. fmtDateDE (ca. Z. 5795): wenn der Input ein voller ISO-Timestamp ist (enthält 'T'),
   new Date(iso).toLocaleDateString('de-CH') verwenden; bei reinen YYYY-MM-DD-Strings
   das bisherige Verhalten behalten. Betrifft die Anzeige von bezahlt_am (Tabelle + PDF).

NICHT anfassen: formatNotizenDate mit dem 'T12:00:00'-Trick und die Montag-first-
Kalenderlogik — beides ist korrekt.

Verifikation: Inline-<script> extrahieren, node --check fehlerfrei. Keine Regression.
Nur index.html anfassen.
```

## Nach Ausführung (verbindlich)

1. Doku-Block in `AP-0403_zeitzonen_fix.md` ausfüllen, Status setzen.
2. Prompt nach `…/04_qualitaet/archiv/` verschieben. Übersicht/Dashboard aktualisieren.
