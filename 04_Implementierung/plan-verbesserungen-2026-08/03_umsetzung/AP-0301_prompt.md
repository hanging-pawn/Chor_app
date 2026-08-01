# Umsetzungsprompt — AP-0301: Einsingen-Layout

**Ausführungsumgebung:** Claude Code (im Repo-Root, direkte Edits an `index.html`)
**Modell-Empfehlung:** Claude – grösstes (Layout-Umbau in grosser Datei, Regressionsrisiko)
**Grösse:** M

---

## Prompt (zum Einfügen in Claude Code)

```
Du arbeitest an der Chor_App (Datei: index.html im Repo-Root, ~7.6k Zeilen, komplett inline,
kein Build-Step). Ignoriere js/*.js — das ist totes Alt-Gerüst.

Ziel: Die Einsingen-Seite (Default-Tab) auf Anjas gewohntes Layout umbauen. Reihenfolge im
<main id="main"> soll sein: 1. Notizen zur Probe, 2. Warm-up-Set, 3. Lieder der nächsten Probe.

Kontext, den du kennen musst:
- Aktuell im #main: #emptyState / #setView (Warm-up) → #heuteSection (Lieder) → #eigeneSection.
- Probennotizen liegen in Supabase-Tabelle `probennotizen` (Felder datum, inhalt, markiert),
  chor-gefiltert über APP_STATE.chorId. CRUD-Muster: saveNotiz(), loadNotizenAndRender().
- ENTSCHEIDUNG: Notizen kommen alle zusammen. Das neue Notizfeld auf der Einsingen-Seite und
  der bestehende Notiz-Tab müssen dieselbe probennotizen-Zeile nutzen (datum = Datum der
  nächsten Probe, ermittelt wie in loadHeuteAndRender: proben_lieder, .gte('datum', todayStr()),
  frühestes Datum; Fallback todayStr()). Keine zweite Wahrheit.

Aufgaben:
1. Neuen Block #einsingenNotizSection VOR #setView/#emptyState einfügen: Überschrift
   „Notizen zur Probe", <textarea id="einsingenNotizInhalt"> und Speicher-Button. Design wie
   bestehende Cards (gleiche CSS-Tokens).
2. Reihenfolge sicherstellen: #einsingenNotizSection → Warm-up → #heuteSection → #eigeneSection.
3. Funktion loadEinsingenNotiz() schreiben: Datum der nächsten Probe ermitteln, zugehörige
   probennotizen-Zeile laden, Textarea füllen. Speichern per Upsert-Logik analog saveNotiz
   (Update wenn Zeile existiert, sonst Insert; markiert unverändert lassen).
4. loadEinsingenNotiz() beim Öffnen des Einsingen-Tabs und nach saveProbe() aufrufen.

Verifikation vor Abschluss:
- Inline-<script> extrahieren und `node --check` laufen lassen — muss fehlerfrei sein.
- Prüfen: eine im Einsingen-Feld gespeicherte Notiz erscheint (gleiches Datum) auch im Notiz-Tab.
- Keine Regression in den anderen Tabs.

Ändere nur index.html. Frage nicht zurück, wenn die Schritte klar sind — arbeite sie ab.
```

## Manuelle Schritte

Keine. (Keine Migration nötig.)

## Nach Ausführung (verbindlich)

1. Im AP `AP-0301_einsingen_layout.md` den Dokumentations-Block ausfüllen (Datum, Abweichungen, Output-Pfad) und Status auf „Abgenommen" setzen, sobald geprüft.
2. Diesen Prompt bei sauberem Abschluss nach `…/03_umsetzung/archiv/AP-0301_prompt.md` verschieben.
3. Übersicht `00_projekt_uebersicht.md`: AP-0301-Checkbox auf erledigt.
