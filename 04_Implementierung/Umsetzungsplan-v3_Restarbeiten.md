---
context:
  read: full
  tokens: ~2600
  covers: [restarbeiten, ak-005, op-email-01, tests, service-worker, phase-9-v2-audio, prompt-pakete, modellwahl]
  read_when: "verbleibende Arbeitspakete nach v2.0 umsetzen oder Reihenfolge/Priorität klären"
  skip_when: "abgeschlossene Phasen 0-V2–8-V2 relevant sind — dafür Umsetzungsplan-v2.md"
  updated: 2026-07-07
---

# Umsetzungsplan v3: Restarbeiten nach v2.0

Basis: Code-Abgleich vom 2026-07-07 (siehe `dashboard.md`). Alle Phasen 0-V2 bis 8-V2 aus
`Umsetzungsplan-v2.md` sind implementiert. Fünf Punkte sind offen — zwei davon rein manuell,
drei davon Umsetzungsaufgaben mit fertigem Prompt-Paket.

## Übersicht

| # | Punkt | Typ | Modell | Story Points |
|---|-------|-----|--------|---------------|
| 1 | AK-005 Nutzungstest mit Anja | Manuell | — | 2sp |
| 2 | OP-EMAIL-01 E-Mail-Absender klären & einrichten | Manuell/Entscheidung | — | 1sp |
| 3 | Tests & QA | Standard-Umsetzung | Claude – mittleres Modell (Sonnet) | 3sp |
| 4 | Service Worker / Offline-Fähigkeit | Standard-Umsetzung | Claude – mittleres Modell (Sonnet) | 5sp |
| 5 | Phase 9-V2 Audio-Übungen | Standard-Umsetzung | Claude – mittleres Modell (Sonnet) | 3sp |

**Empfohlene Reihenfolge:** 1 → 2 → 3 → 4 → 5 (Audio optional, niedrigste Priorität).

Begründung: AK-005 ist der letzte offene Abnahmepunkt von v1.0 und liefert echtes Nutzerfeedback,
das die Priorität der übrigen Punkte noch verschieben kann (OP-ALL-01). OP-EMAIL-01 ist reine
Konfiguration und blockiert die bereits fertig codierte E-Mail-Funktion (Phase 8-V2) — ohne die
zwei Secrets läuft `send-email` nicht. Tests vor Service Worker, weil ein Service Worker Fehler in
der Core-Logik verschleiern kann, wenn er zwischenspeichert. Audio ist die einzige „Kann“-Erweiterung.

---

## 1. AK-005 — Nutzungstest mit Anja auf dem iPhone

**Ziel:** Letzten offenen Abnahmepunkt aus v1.0 schliessen — «Die App ist auf dem iPhone-Browser
flüssig und einhändig bedienbar.»

**Typ:** Vollständig manuell — erfordert eine echte Person (Anja) und ein echtes Gerät. Kein
Modell kann das übernehmen.

### Test-Skript (zum direkten Verwenden mit Anja)

1. App auf Anjas iPhone im Browser öffnen (Safari/Chrome), Homescreen-Icon nutzen falls installiert.
2. Einsingen-Set per Knopfdruck generieren — beobachten: Erreichbarkeit des Buttons mit einer Hand,
   Lesbarkeit von Titel/Anleitung/Notenbild ohne Zoomen.
3. Zweites Set generieren — prüfen ob spürbar andere Übungen erscheinen (FA-004).
4. Eigene Übung hinzufügen (Titel, Kategorie, Anleitung) — prüfen ob Formular einhändig bedienbar ist.
5. App neu laden (Reload) — prüfen ob eigene Übung erhalten bleibt.
6. Falls weitere Tabs bereits genutzt werden (Probennotizen, Repertoire, Jahresplan, Mitglieder,
   Buchhaltung): kurz durchklicken, offensichtliche Probleme (zu kleine Touch-Targets, Overflow,
   unleserlicher Text) notieren — auch wenn ausserhalb von AK-005, wertvolles Zusatzfeedback.
7. Anja nach subjektivem Eindruck fragen: Was fehlt? Was stört? Würde sie es wöchentlich nutzen?

### Manuelle Schritte
1. Termin mit Anja vereinbaren und Test durchführen — *Warum manuell*: erfordert eine reale
   Testperson und physisches Gerät.
2. Ergebnis protokollieren unter `08_Meetings/2026-XX-XX_Nutzungstest-Anja.md` — *Warum manuell*:
   Beobachtungen und Zitate von Anja müssen von Gianluca erfasst werden.
3. Bei Bedarf: Prioritäten in `dashboard.md` und Umsetzungsplänen anpassen — *Warum manuell*:
   Entscheidung über Konsequenzen aus dem Feedback (OP-ALL-01).

---

## 2. OP-EMAIL-01 — E-Mail-Absender klären & einrichten

**Ziel:** Die bereits implementierte E-Mail-Funktion (`supabase/functions/send-email/index.ts`,
Phase 8-V2) freischalten. Der Code erwartet zwei Supabase-Secrets, die noch nicht gesetzt sind:
`RESEND_API_KEY` und `SENDER_EMAIL`.

**Typ:** Entscheidung + Konfiguration. Kein Code nötig — der Code ist fertig und wartet auf die
Secrets.

**Empfehlung:** Resend ist im Code bereits fest verdrahtet (`RESEND_BATCH_URL`, Payload-Format)
— eine andere Dienstwahl würde die Edge Function neu erfordern. Resend beibehalten.

### Schritte
1. Mit Anja klären: Welche Absenderadresse? (z. B. `chor@ihre-domain.ch` oder eine neue
   `noreply@`-Adresse). Muss eine Domain sein, auf die Zugriff für DNS-Einträge besteht.
2. Resend-Konto anlegen/nutzen (resend.com), Domain dort hinzufügen.
3. Von Resend angezeigte DNS-Einträge (SPF, DKIM, ggf. Return-Path) beim Domain-Registrar/DNS-
   Anbieter der gewählten Domain eintragen.
4. Verifizierung in Resend abwarten (kann bis 48h dauern, meist Minuten).
5. API-Key in Resend erzeugen.
6. In Supabase Dashboard → Edge Functions → Secrets: `RESEND_API_KEY` und `SENDER_EMAIL` setzen.
7. Testversand: Rundmail an einen Test-Mitglied-Datensatz (eigene E-Mail-Adresse) senden, im
   Posteingang und Spam-Ordner prüfen.

### Manuelle Schritte
1. Alle 7 Schritte oben — *Warum manuell*: erfordert Login bei Resend, Zugriff auf DNS-
   Verwaltung der Domain und Zugriff auf das Supabase-Dashboard (Secrets). Kein Modell hat
   diese Zugänge.

---

## 3. Tests & QA

**Ziel:** `05_Tests` ist aktuell leer. Mindestens die Kernlogik (`generateSet()`) und die
sicherheitskritischen RLS-Policies sollen abgesichert sein, bevor weitere Phasen (Service Worker,
Audio) draufgebaut werden.

### Prompt

```
Die Chorapp (Chor_App) hat eine lauffähige Einsingen-Funktion. Lies CLAUDE.md und
js/generator.js — die Datei exportiert bereits generateSet, pickRandom und poolForCategory
über module.exports für Node-Tests.

Deine Aufgabe: Schreibe Unit-Tests für js/generator.js mit Node's eingebautem Test-Runner
(node:test + node:assert/strict) — kein zusätzliches Test-Framework, kein Build-Step
(Projektvorgabe: kein Build-Step angestrebt).

Testdatei: 05_Tests/generator.test.js

Abzudeckende Regeln (aus den Docstrings in js/generator.js):
- FA-002: generateSet() liefert 5 oder 6 Übungen zurück (über mehrere Durchläufe geprüft,
  z. B. 50 Wiederholungen, beide Längen müssen vorkommen)
- FA-003: Genau eine "abschluss"-Übung, immer an letzter Stelle; jede Hauptkategorie
  (koerper, atem, stimme) mindestens einmal vertreten
- FA-004: Bei injiziertem recentIds (über options.recentIds) werden kürzlich gezeigte
  Übungen bevorzugt gemieden, solange die Kategorie genug Alternativen hat; Fallback auf
  volle Kategorie wenn alle IDs "recent" sind
- pickRandom(arr, n): liefert n eindeutige Elemente, mutiert arr nicht, funktioniert auch
  wenn n > arr.length (liefert dann arr.length Elemente)
- poolForCategory: filtert korrekt nach Kategorie und bevorzugt Nicht-recent-IDs

Nutze ein kleines Fixture-Array von Testübungen (mindestens 3 pro Kategorie inkl. abschluss)
direkt in der Testdatei, keine externe Datei nötig. Teste generateSet ausschliesslich mit
options.recentIds (nie über echtes localStorage, das in Node nicht existiert).

Zusätzlich: Schreibe eine manuelle Verifikations-Checkliste (kein Code) als
05_Tests/RLS-Checkliste.md — Schritte, um bei einem eingeloggten Test-User in Supabase zu
prüfen, dass jede Tabelle (choere, probennotizen, lieder, proben_lieder, termine,
termine_lieder, ideen, mitglieder, beitraege, ausgaben, email_versand) nur Zeilen mit
passendem user_id zurückgibt und dass ein nicht eingeloggter Request 0 Zeilen liefert.
Diese Checkliste kann nicht automatisiert im Sandbox-Kontext ausgeführt werden, da sie
Zugriff auf das echte Supabase-Projekt braucht — sie ist für Gianluca zur manuellen
Durchführung gedacht.

Abnahme: `node --test 05_Tests/generator.test.js` läuft ohne Fehler durch.
Code-Kommentare auf Englisch.
```

### Modellempfehlung

**Modell:** Claude – mittleres Modell (Sonnet)

**Begründung:** Klar umrissene Standard-Coding-Aufgabe mit bereits vorhandenem, dokumentiertem
Code als Grundlage. Kein architektonischer Ermessensspielraum nötig.

### Manuelle Schritte
1. `node --test 05_Tests/generator.test.js` lokal ausführen und Ergebnis prüfen — *Warum
   manuell*: Ausführung ausserhalb des Sandbox-Kontexts, auf Gianlucas Rechner oder in CI.
2. RLS-Checkliste gegen das echte Supabase-Projekt durchgehen — *Warum manuell*: erfordert
   Zugriff auf das Supabase-Dashboard/Projekt-Credentials, die nicht im Claude-Kontext liegen
   (CLAUDE.md: kein API-Key teilen).

### Bezug
**Betrifft:** Launch-Punkt „Tests & QA“ in `dashboard.md`.

---

## 4. Service Worker / Offline-Fähigkeit

**Ziel:** Die Einsingen-Funktion (Kernfeature, FA-001–004) soll auch ohne Internetverbindung
funktionieren, da sie keine Supabase-Daten braucht (`data/uebungen.json` + `localStorage`).
Andere Tabs (Probennotizen, Repertoire, Jahresplan, Mitglieder, Buchhaltung) brauchen Supabase
und können offline nicht vollständig funktionieren — dafür reicht ein klarer Hinweis statt
Absturz.

### Prompt

```
Die Chorapp (Chor_App) ist eine Single-File-PWA (index.html) mit manifest.json und Icons,
aber ohne Service Worker. Lies CLAUDE.md, manifest.json und die Einsingen-Sektion in
index.html (generateSet, data/uebungen.json-Laden).

Deine Aufgabe: Füge Offline-Fähigkeit über einen Service Worker hinzu (kein Build-Step,
kein npm/Bundler).

**sw.js (im Repo-Root):**
- Cache-Name mit Versionsnummer (z. B. chorapp-cache-v1) zum gezielten Invalidieren bei
  Updates
- Im install-Event: App-Shell vorcachen — index.html, manifest.json, data/uebungen.json,
  data/uebungen.schema.json, alle Dateien unter icons/
- Im fetch-Event: Cache-First für die oben genannten App-Shell-Dateien; Network-First mit
  Cache-Fallback für alles andere (insbesondere Supabase-Requests dürfen NICHT gecacht
  werden — die brauchen immer frische Daten oder einen klaren Fehler)
- Im activate-Event: alte Cache-Versionen löschen

**Registrierung in index.html:**
- Am Ende des Body oder in einem <script>-Block: navigator.serviceWorker.register('sw.js')
  mit try/catch bzw. .catch() (nicht jeder Browser unterstützt Service Worker, App muss
  auch ohne funktionieren)
- Bei Update-Erkennung (controllerchange oder waiting-Worker): dezenter Hinweis "Neue Version
  verfügbar — neu laden" statt automatischem Reload (Nutzer nicht mitten in der Probe stören)

**Offline-Hinweis für Supabase-abhängige Tabs:**
- Wenn ein Supabase-Request fehlschlägt weil offline (navigator.onLine === false oder
  Fetch-Fehler): zeige in den betroffenen Tabs (Probennotizen, Repertoire, Jahresplan,
  Mitglieder, Buchhaltung) einen dezenten Banner "Offline — diese Funktion braucht eine
  Internetverbindung." Der Einsingen-Tab bleibt davon unberührt und funktioniert normal weiter.

Teste konzeptionell: App im Flugmodus laden (nach einmaligem Online-Besuch) — Einsingen-Tab
muss vollständig funktionieren (Set generieren, eigene Übung hinzufügen), andere Tabs zeigen
den Offline-Hinweis statt eines kaputten UI-Zustands oder einer Endlos-Ladeanzeige.

Code-Kommentare auf Englisch.
```

### Modellempfehlung

**Modell:** Claude – mittleres Modell (Sonnet)

**Begründung:** Bekanntes PWA-Standardmuster (Cache-First/Network-First), klar abgegrenzter
Scope innerhalb einer bestehenden, gut dokumentierten Codebasis.

### Manuelle Schritte
1. Tatsächlichen Offline-Test auf Anjas iPhone (Flugmodus) durchführen — *Warum manuell*:
   Service-Worker-Verhalten unterscheidet sich je nach Gerät/Browser-Cache-Zustand und lässt
   sich nur auf echtem Gerät zuverlässig prüfen.
2. Nach Deployment: prüfen, dass GitHub Pages den Service Worker mit korrektem Scope/MIME-Type
   ausliefert — *Warum manuell*: erfordert Zugriff auf das Live-Deployment.

### Bezug
**Betrifft:** Launch-Punkt „Offline-Fähigkeit (PWA Service Worker)“ in `dashboard.md`.

---

## 5. Phase 9-V2 — Audio-Übungen (optional, niedrigste Priorität)

**Ziel:** Zu eigenen Einsingübungen kann eine Audiodatei hinterlegt werden.

**Hinweis:** Vollständiger Prompt existiert bereits in `04_Implementierung/Umsetzungsplan-v2.md`,
Abschnitt „Phase 9-V2 — Audio-Übungen“ (Zeilen ~412–430) — hier nicht dupliziert, um
Divergenz zwischen zwei Kopien zu vermeiden. Vor Umsetzung dort nachlesen.

### Modellempfehlung

**Modell:** Claude – mittleres Modell (Sonnet) — bereits in Umsetzungsplan-v2.md so empfohlen,
da das Storage-Upload-Muster aus Phase 3-V2 (Repertoire-PDFs) wiederverwendet werden kann.

### Manuelle Schritte
1. Priorität bestätigen (laut Anforderungserweiterung v2 „Mittel“, laut Anja im Ursprungsgespräch
   nicht als dringend markiert) — *Warum manuell*: Priorisierungsentscheidung, ggf. abhängig
   vom Ergebnis des Nutzungstests (Punkt 1).
2. Nach Umsetzung: Audiodatei-Upload und Wiedergabe auf iPhone testen — *Warum manuell*:
   Speicherverhalten/Wiedergabe-UX auf mobilem Safari nur am echten Gerät verlässlich prüfbar.

### Bezug
**Betrifft:** `dashboard.md` Punkt „Phase 9-V2: Audio-Übungen“.
