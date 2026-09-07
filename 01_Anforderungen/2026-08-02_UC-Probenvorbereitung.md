---
context:
  read: full
  tokens: ~2600
  covers: [use-case, probenvorbereitung, auftritte, probenuebersicht, pdf-export, noten-annotation]
  read_when: "Sprint Probenvorbereitung planen oder umsetzen; Anforderungen an Kalender/Proben/Auftritte/Übersicht klären"
  skip_when: "Nur Einsingen-Generator, Buchhaltung, Mitglieder oder Deployment betroffen"
  updated: 2026-08-02
---

# UC-Probenvorbereitung — Use-Case-Analyse (Sprint-Input)

**Datum:** 2026-08-02
**Quelle:** Vorgabe Gianluca / Bedarf Anja (Chorleitung)
**Status:** Analyse — bewusst **ohne Lösungsdesign**. Zweck: Nutzen und Umfang klären, damit der nächste Sprint darauf aufsetzen kann.
**Bezug:** `01_Anforderungen/Lastenheft.md`, `01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md`, `04_Implementierung/2026-08-01_Verbesserungen-Einsingen_Brainstorming.md`

---

## 1. Akteur und Kontext

**Primärakteur:** Die Chorleiterin (Anja). Einzige aktive Nutzerin der App.

**Situationen, in denen sie die App benutzt:**

| Situation | Ort / Gerät | Zeitdruck | Hände frei? |
|---|---|---|---|
| A — Vorbereitung | zu Hause, in Ruhe, evtl. Desktop | gering | ja |
| B — Durchführung | im Probelokal, am Klavier/Pult, iPhone | hoch | nein — sie dirigiert |
| C — Weitergabe | zwischendurch, unterwegs | mittel | ja |

Diese drei Situationen sind der Kern des Use Case: **Vorbereiten (A) → Überblick behalten (B) → Verteilen (C).** Sie stellen völlig unterschiedliche Anforderungen an dieselben Daten — A braucht Editierbarkeit und Vollständigkeit, B braucht Reduktion und Lesbarkeit auf Armlänge, C braucht ein exportierbares, teilbares Format.

**Sekundäre Empfänger (keine App-Nutzer):** Pianist:in, Vorstand, Chormitglieder. Sie erhalten Ergebnisse (PDF, E-Mail), arbeiten aber nicht in der App.

---

## 2. Problem heute (ohne App)

Die Vorbereitung liegt heute verteilt auf Papier, Kalender, Notizzettel und Kopf:

- Der Ablauf einer Probe wird handschriftlich oder gar nicht notiert; was letzte Woche liegen blieb, muss erinnert werden.
- Liedspezifische Hinweise („Takt 34 Sopran zu hoch", „diesmal a cappella") kleben lose in den Noten oder fehlen.
- Der Pianist erfährt die Liederauswahl kurzfristig, teils erst im Probelokal → er kann sich nicht vorbereiten.
- Bei Auftritten stehen Ort, Besammlungszeit und Programm in verschiedenen Mails; Rückfragen der Mitglieder landen einzeln bei der Chorleiterin.
- Während der Probe muss sie zwischen Ablaufblatt, Notenmappe und Handy wechseln.

**Kern des Nutzens:** Eine Probe / ein Auftritt wird zu **einem einzigen, benannten Objekt**, das vorbereitet, geöffnet, ergänzt, angezeigt und weitergegeben werden kann. Alles, was zu diesem Termin gehört, hängt daran — nicht an sechs Orten.

---

## 3. Teil-Use-Cases

### UC-1 — Probe im Voraus vorbereiten

**Ziel:** Die Chorleiterin plant eine künftige Probe vollständig, bevor sie stattfindet, und kann sie beliebig oft wieder öffnen und ändern.

**Ablauf (fachlich):**
1. Sie legt im Kalender einen Probentermin an (Datum, Uhrzeit, ggf. Ort).
2. Sie öffnet den Termin und definiert dazu:
   - **Einsingen** — welches Warm-up-Set für diese Probe gilt.
   - **Liederauswahl** — welche Stücke in welcher Reihenfolge, je mit **probenspezifischer Notiz** (gilt nur für den Termin am Tag X, nicht für das Lied allgemein).
   - **Pianist:in** — wer diese Probe begleitet.
   - **Mitteilung an den Chor** — was sie ankündigen will.
   - **Weitere Notizen** — nur für sie selbst.
3. Sie speichert. Der Termin bleibt jederzeit erneut öffenbar und editierbar.

**Nutzen:**
- Vorbereitung wird **vom Probentag entkoppelt** — planbar, wenn Zeit da ist, statt 20 Minuten vorher.
- Mehrere Proben können **im Voraus** vorbereitet werden (Ferien, Auftrittsphase, Vertretung).
- Nichts geht verloren: eine unterbrochene Vorbereitung kann später fortgesetzt werden.
- **Probenspezifische Liednotizen** trennen sauber „was ist an diesem Stück grundsätzlich zu beachten" von „was mache ich damit an diesem Abend". Genau diese Trennung fehlt heute.

**Wichtigste fachliche Regel:** Notizen an einem Lied innerhalb einer Probe gehören der Probe, nicht dem Lied — sie dürfen die Repertoire-Notiz nicht überschreiben.

---

### UC-2 — Auftritt vorbereiten

**Ziel:** Wie UC-1, aber für Auftritte, mit zusätzlichen organisatorischen Angaben.

**Zusätzlich zu UC-1:**
- **Ort** — Adresse des Auftrittsorts; Wunsch: verlinkt/öffenbar in einer Karten-App (Google Maps o. ä.), damit Chormitglieder und Pianist:in direkt navigieren können.
- **Besammlungszeit** — wann sich der Chor vor Ort trifft (unterscheidet sich vom Auftrittsbeginn).

**Nutzen:**
- Auftritte sind der **fehleranfälligste Termin** — falsche Zeit oder falscher Ort ist ein echter Schaden. Genau diese zwei Felder verhindern die häufigsten Rückfragen.
- Ort und Besammlungszeit gehören ins gleiche Objekt wie Programm und Mitteilung, damit **eine** Information rausgeht statt drei.
- Auftritte und Proben unterscheiden sich nur um wenige Felder → gleiche Bedienung, kein zweiter Denkweg für die Nutzerin.

---

### UC-3 — Übersicht der aktuellen Probe / des Auftritts (Tab „Nächste Probe")

**Ziel:** Ein eigener Tab zeigt genau einen Termin in einer für die Probensituation optimierten Ansicht.

**Verhalten:**
- **Default:** immer der nächste anstehende Termin (Probe oder Auftritt).
- **Dropdown:** manuelle Auswahl eines anderen Termins (vorbereiten, nachschauen, zurückblicken).
- Inhalt: Einsingen, Lieder mit ihren probenspezifischen Notizen, Pianist:in, Mitteilung an den Chor, weitere Notizen; bei Auftritten zusätzlich Ort und Besammlungszeit.

**Nutzen:**
- Diese Ansicht ist der **Blick während der Probe** (Situation B): Sie beantwortet ohne Suchen „Was kommt als Nächstes und was muss ich dabei beachten?".
- Der Default entlastet: die App öffnet sich im Regelfall genau dort, wo sie gebraucht wird — **null Klicks** für den häufigsten Fall.
- Das Dropdown deckt die Ausnahmen ab (Probe vorziehen, letzte Probe nachlesen), ohne den Normalfall zu verkomplizieren.
- Klare Rollentrennung: **Kalender = bearbeiten, Übersicht = benutzen.** Zwei Modi desselben Objekts, statt eines überladenen Formulars.

---

### UC-4 — Übersicht als PDF exportieren und versenden

**Ziel:** Die Übersicht eines Termins wird zu einem Dokument, das an Pianist:in und andere gehen kann.

**Nutzen:**
- Die **Pianistin/der Pianist ist der wichtigste Empfänger**: Er/sie braucht die Liederliste rechtzeitig, um zu üben. Das ist der grösste externe Nutzen des ganzen Use Case.
- PDF, weil die Empfänger die App nicht haben und nicht bekommen sollen — ein PDF liest jede/r, auf jedem Gerät, und kann ausgedruckt aufs Klavier gelegt werden.
- Es macht die Vorbereitung **überprüfbar und archivierbar**: Was war am Termin X geplant, lässt sich später belegen.
- Reduziert Kommunikationsaufwand: ein Dokument statt mehrerer Nachrichten.

**Fachliche Frage (nicht hier zu lösen):** Was steht im PDF für wen? Persönliche Notizen der Chorleiterin sollen mutmasslich **nicht** an den Pianisten. → siehe offene Fragen.

---

### UC-5 — Noten während der Probe öffnen und annotieren

**Ziel:** Aus der Übersicht heraus führt ein Klick auf ein Lied direkt zu dessen Noten.

**Nutzen:**
- Kein Medienbruch mitten in der Probe: Ablauf und Noten sind **dasselbe Werkzeug**. Das spart nicht nur Zeit, es senkt den Stress in einer Situation, in der 30 Leute warten.
- Die Notenmappe muss nicht mehr vollständig mitgeschleppt/sortiert werden.

**Erweiterter Wunsch der Nutzerin:** Während die Noten offen sind, sollen **weitere liedbezogene Notizen** erfasst werden können — idealerweise direkt in das PDF geschrieben, falls technisch möglich.

**Nutzen dieses Wunsches:**
- Erkenntnisse entstehen **im Moment des Probens** („hier atmen", „Tenor Einsatz zu spät"). Wenn sie nicht sofort erfasst werden, sind sie weg.
- Heute ersetzt das der Bleistift im Notenblatt. Genau dieses Verhalten soll die App nicht schlechter machen als Papier — sonst wird sie im entscheidenden Moment umgangen.
- Aus den laufend entstehenden Notizen wird über die Zeit ein **Gedächtnis pro Lied** — Grundlage für die nächste Probenvorbereitung (Rückkopplung in UC-1).

**Bewusst offen:** Ob die Notiz *im* PDF landet oder als Text daneben, ist eine Lösungsfrage. Der Nutzen — „im Moment festhalten, ohne die Noten zu verlassen" — gilt unabhängig davon.

---

## 4. Nutzen in einem Satz je Teil-Use-Case

| # | Nutzen |
|---|---|
| UC-1 | Proben lassen sich in Ruhe im Voraus planen; nichts muss am Probentag erinnert werden. |
| UC-2 | Auftritte tragen Ort und Besammlungszeit mit — die zwei Angaben, deren Fehlen am meisten Schaden anrichtet. |
| UC-3 | Ein Blick genügt während der Probe; die richtige Probe ist ohne Klick schon da. |
| UC-4 | Der Pianist bekommt rechtzeitig, was er zum Üben braucht — als PDF, ohne App. |
| UC-5 | Erkenntnisse werden dort festgehalten, wo sie entstehen: an den Noten, während der Probe. |

**Übergeordneter Nutzen:** Die Chorleiterin verliert weniger Zeit mit Organisation und gewinnt sie für die Musik. Die App wird vom Einsing-Generator zum **Probenbegleiter über den ganzen Zyklus** — vorbereiten, durchführen, weitergeben, nachhalten.

---

## 5. Ist-Zustand (Stand 2026-08-02, faktisch — keine Bewertung)

Bereits vorhanden und in diesem Use Case wiederverwendbar:

| Baustein | Stand |
|---|---|
| Termine im Kalender (`termine`, Typ `probe`/`auftritt`/`deadline`/`sonstiges`, mit `notiz`) | vorhanden, Tab „Jahresplan" |
| Lieder pro Probe (`proben_lieder`, mit `reihenfolge` und `notiz`) | vorhanden |
| Liednotiz allgemein (`lieder.notiz`) und Noten-PDF (`lieder.pdf_pfad`, Supabase Storage, `openNoten()`) | vorhanden |
| Probennotizen datumsgebunden (`probennotizen`, Typen) | vorhanden |
| Pianist pro Probe (`pianisten`, `proben_pianist`) | vorhanden |
| Einsing-Set pro Probe (`proben_set`) | vorhanden |
| Ansicht „nächste Probe" (`loadHeuteAndRender`, `.gte(datum)`) | vorhanden, aktuell im Einsingen-Tab |
| PDF-Bau und -Versand (`buildProbePDF`, `sendProbePDF`, jsPDF) | vorhanden |
| E-Mail-Versand (`sendProbeninfo`, Edge Function) | vorhanden |

Noch nicht vorhanden:

- **Auftritts-Felder** Ort (mit Karten-Verknüpfung) und Besammlungszeit.
- **Termin als editierbares Gesamtobjekt** — die Bestandteile existieren, sind aber über mehrere Tabs verteilt und über `datum` lose gekoppelt statt über eine Termin-ID.
- **Eigener Tab „Nächste Probe" mit Termin-Dropdown** — die Ansicht existiert, hängt aber im Einsingen-Tab und kennt nur „der nächste".
- **Auftritte in der Übersicht** — die Übersicht ist heute auf Proben ausgelegt.
- **Notizerfassung bei geöffnetem Notenblatt.**

**Wichtigste strukturelle Beobachtung für die Sprintplanung:** Proben-Bestandteile hängen heute am **Datum**, nicht am Termin. Ob das für Auftritte und für den Dropdown trägt, ist die zentrale Frage der Lösungsphase — hier bewusst nicht entschieden.

---

## 6. Abgrenzung — nicht Teil dieses Use Case

- Anwesenheitserfassung der Mitglieder pro Probe.
- Mehrere Chöre parallel in einer Übersicht.
- Zugriff für Pianist:in oder Mitglieder auf die App selbst (sie bleiben Empfänger).
- Automatische Programmvorschläge („welche Lieder sollte ich üben").
- Audio/Tonaufnahmen der Probe.

---

## 7. Offene Fragen an Anja / Gianluca

1. **Sichtbarkeit im PDF:** Welche Felder gehen an den Pianisten, welche bleiben privat? Braucht es zwei PDF-Varianten (intern / extern)?
2. **Versandweg:** Bestehender E-Mail-Mechanismus, `mailto:`, oder PDF teilen über das iPhone-Share-Sheet?
3. **Ort bei Auftritten:** freies Textfeld mit Kartenlink, oder strukturierte Adresse? Reicht ein Link, der die Karten-App öffnet?
4. **Vergangene Termine:** Wie weit zurück reicht das Dropdown? Werden alte Proben archiviert?
5. **Wiederholende Proben:** Ist eine Serie („jeden Dienstag") nötig, oder wird jeder Termin einzeln angelegt?
6. **Notizen bei offenen Noten:** Genügt eine Textnotiz neben dem Notenblatt, oder ist das Zeichnen/Schreiben *im* PDF die eigentliche Anforderung? (Entscheidet über den Aufwand massiv.)
7. **Einsingen pro Probe:** Wird das Set fix zur Probe gespeichert, oder jedes Mal neu generiert?
8. **Bestehender Notiz-Tab:** Bleibt er neben der neuen Übersicht bestehen, oder wird er redundant?
9. **Auftritt ohne Chor-Mitteilung:** Sollen Mitteilungen an den Chor auch bei Auftritten per E-Mail rausgehen, oder nur angezeigt werden?

---

## 8. Erfolgskriterien (Entwurf, für Abnahme im Sprint zu schärfen)

- Anja kann eine Probe drei Wochen im Voraus vollständig vorbereiten, schliessen und später unverändert wieder öffnen.
- Ein Auftritt enthält Ort und Besammlungszeit; der Ort lässt sich mit einem Tipp in einer Karten-App öffnen.
- Beim Öffnen des Übersichts-Tabs steht ohne weitere Eingabe der nächste anstehende Termin da.
- Ein anderer Termin ist über das Dropdown in höchstens zwei Tippern erreichbar.
- Aus der Übersicht entsteht in höchstens drei Tippern ein PDF, das versendet werden kann.
- Ein Lied in der Übersicht öffnet mit einem Tipp seine Noten; von dort ist eine Notiz erfassbar, ohne die Noten zu schliessen.
- Anja bestätigt nach einer realen Probe, dass sie die App währenddessen benutzt hat und kein Papier brauchte.

---

## 9. Empfehlung für den Sprintzuschnitt

Der Use Case zerfällt in zwei fachlich unabhängige Hälften mit unterschiedlichem Risiko:

- **Sicher planbar:** UC-1, UC-2, UC-3, UC-4 — bauen auf vorhandenen Bausteinen auf; der Aufwand liegt in Datenmodell-Klärung und UI, nicht in Unbekanntem.
- **Risikobehaftet:** UC-5, Teil „Notizen im PDF schreiben" — technisch offen, Aufwand nicht abschätzbar, bevor Frage 6 beantwortet ist. Sollte als eigener, abtrennbarer Block geführt werden, damit er den Rest nicht blockiert.
