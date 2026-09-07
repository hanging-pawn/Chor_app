---
context:
  read: toc
  tokens: ~9500
  covers: [lastenheft, einsingen, mehrchor, repertoire, jahresplanung, mitglieder, buchhaltung, anforderungen, abnahmekriterien, supabase, supabase-storage, responsive, planungsmodus, durchfuehrungsmodus, roadmap]
  read_when: "Funktionsumfang, Anforderungen, Abnahme oder Architektur-Constraints klären; Supabase-Anbindung planen; Erweiterungsanforderungen prüfen"
  skip_when: "reine Code-/Deployment-Details ohne Anforderungsbezug"
  updated: 2026-06-12
---

# Lastenheft: Chorapp — Funktion «Einsingen»

## Metadaten

| Feld | Inhalt |
|------|--------|
| Dokumentversion | 1.6 (Entwurf) |
| Datum | 2026-06-12 |
| Autor | Gianluca La Rocca |
| Auftraggeberin | Anja (Chorleiterin) |
| Projektname | Chorapp |
| Status | Entwurf — offene Punkte geklärt, zur Freigabe |

**Versionshistorie**

| Version | Datum | Änderung | Autor |
|---------|-------|----------|-------|
| 1.0 | 2026-06-12 | Erstversion (Fokus Einsingen) | Gianluca La Rocca |
| 1.1 | 2026-06-12 | Offene Punkte OP-001 bis OP-003 mit Auftraggeberin geklärt; Anforderungen, Risiken und Roadmap entsprechend präzisiert | Gianluca La Rocca |
| 1.2 | 2026-06-12 | Supabase als Backend-Service eingeführt; Architektur-Constraints und NFRs entsprechend erweitert; supabase.js config angelegt | Gianluca La Rocca |
| 1.3 | 2026-06-12 | Erweiterungsanforderungen F-1 bis F-5 eingearbeitet (Repertoire, Eigene Übungen mit Audio, Notizfeld, Jahresplanung, Mitglieder & Buchhaltung); Roadmap und offene Punkte aktualisiert | Gianluca La Rocca |
| 1.4 | 2026-06-12 | Use-Case-Präzisierung: Zwei Nutzungskontexte (PC-Planung / Mobile-Durchführung), Mehrchor-Support, Supabase als MUSS-Komponente (Sync), offene Punkte OP-F1-01/F2-01 gelöst, NFRs und Architektur aktualisiert | Gianluca La Rocca |
| 1.5 | 2026-06-12 | Buchhaltungs-Use-Case präzisiert: E-Mail im Mitgliederprofil, definierbarer Halbjahresbeitrag, Spesenerfassung per Eingabemaske, steuerkonformer anonymisierter Abrechnungsexport pro Chor | Gianluca La Rocca |
| 1.6 | 2026-06-12 | Anja-Dialog eingearbeitet: Stimmlage (optional), Liedstatus, E-Mail-Versand aus App, Anwesenheit Out-of-Scope bestätigt, Supabase Auth als Login-Lösung (löst OP-F5-01), Steuerabrechnung-Felder präzisiert; Architektur und NFRs aktualisiert | Gianluca La Rocca |

---

## 1. Einleitung

### 1.1 Zweck des Dokuments

Dieses Lastenheft beschreibt die Anforderungen an die Chorapp — eine mobile Companion-App für die Chorleiterin. Es dient als Grundlage für die Entwicklung und als Abnahmemassstab. In dieser Version ist ausschliesslich die erste Teilfunktion **«Einsingen»** im Detail spezifiziert. Weitere Funktionen werden in späteren Versionen ergänzt.

### 1.2 Abkürzungen und Definitionen

| Begriff | Definition |
|---------|------------|
| Einsing-Set | Eine zusammengestellte Folge von 5–6 Übungen für eine Probe |
| Übung | Eine einzelne Einsing-Einheit, einer Kategorie zugeordnet |
| Kategorie | Gliederung der Übungen: Körper, Atem, Stimme, Abschluss |
| Kanon | Mehrstimmiges Lied, in dem Stimmen zeitversetzt einsetzen |
| PWA | Progressive Web App — Web-App, die wie eine native App nutzbar ist |

---

## 2. Ausgangssituation (Ist-Zustand)

### 2.1 Aktuelle Situation

Anja leitet mehrere Chöre mit unterschiedlichem Repertoire, eigener Mitgliederbasis und separaten Proben- und Auftrittskalendern. Die Vorbereitung jeder Probe — Einsingen zusammenstellen, Lieder auswählen, Termine koordinieren — erfolgt aktuell manuell aus Erfahrung, Notizen und Gedächtnis, verteilt auf verschiedene Geräte und ohne zentrales Werkzeug.

**Nutzungskontext:** Die Chorleiterin arbeitet in zwei klar getrennten Situationen:

| Kontext | Gerät | Tätigkeit |
|---------|-------|-----------|
| Zuhause (Vorbereitung) | PC / Desktop-Browser | Proben planen, Repertoire pflegen, Jahresplanung, Mitglieder verwalten |
| Chorprobe / Aufführung | iPhone oder iPad | Einsing-Set durchführen, Noten zu den geplanten Liedern abrufen, Tagesprobe-Übersicht |

**Mehrchor:** Jeder Chor hat eigenes Repertoire, eigene Mitglieder und eigene Planung. Einsingübungen sind chorübergreifend geteilt.

### 2.2 Problemstellung / Auslöser

Die Vorbereitung kostet unverhältnismässig viel Zeit, und Daten (Repertoire, Notizen, Mitglieder) sind nicht geräteübergreifend verfügbar. An der Probe fehlt eine strukturierte Übersicht, die Einsingen und geplante Lieder mit Noten auf einen Blick zeigt. Es besteht zudem die Tendenz, immer dieselben Einsingübungen zu verwenden.

### 2.3 Betroffene Stakeholder

| Stakeholder | Rolle | Betroffenheit |
|-------------|-------|---------------|
| Anja | Chorleiterin, Auftraggeberin, Hauptnutzerin | Nutzt die App zur Probenvorbereitung und -durchführung |
| Chormitglieder | Indirekt Begünstigte | Profitieren von abwechslungsreichem, strukturiertem Einsingen |

---

## 3. Projektziel (Soll-Zustand)

### 3.1 Übergeordnetes Ziel

Die Chorleiterin kann alle ihre Chöre über eine einzige App verwalten — von der Vorbereitung zuhause am PC bis zur Durchführung an der Probe auf dem iPhone oder iPad. Die App ist auf beiden Geräten über denselben Datenstand verfügbar.

### 3.2 Teilziele

- [ ] Auf Knopfdruck steht ein vollständiges Einsing-Set für die Probe bereit (chorübergreifend).
- [ ] Das Set ist nach dem Prinzip Körper → Atem → Stimme → Abschluss aufgebaut.
- [ ] Mehrere Chöre sind getrennt verwaltbar (Repertoire, Mitglieder, Planung pro Chor).
- [ ] Die Probe-Ansicht auf dem iPhone/iPad zeigt Einsing-Set und geplante Lieder mit Noten kompakt auf einen Blick.
- [ ] Die Planungsansicht am PC erlaubt komfortables Verwalten von Repertoire, Jahresplanung und Mitgliedern.
- [ ] Daten sind geräteübergreifend synchronisiert (PC ↔ iPhone/iPad) via Supabase.

### 3.3 Explizit außerhalb des Projekts (Out-of-Scope)

- Mehrbenutzer-/Kollaborationssystem; die App ist auf die Nutzung durch eine einzige Chorleiterin ausgelegt.
- Tonwiedergabe/Audioausgabe der eingebauten Stimmübungen (Text + Notenbild genügt; optionale Audio-Uploads durch die Nutzerin folgen später).
- Anwesenheitsverwaltung der Chormitglieder *(von Auftraggeberin explizit abgelehnt, 2026-06-12).*

### 3.4 Ausblick / Roadmap (grob)

Die folgenden Teilfunktionen wurden durch direkten Input der Auftraggeberin (2026-06-12) spezifiziert und sind vollständig in Abschnitt 6 als funktionale Anforderungen aufgeführt. Reihenfolge basiert auf Priorität und Abhängigkeiten:

| Schritt | Teilfunktion | Priorität (Anja) | Details |
|---------|-------------|------------------|---------|
| v1.0 | **Einsingen** | — | Läuft; Set-Generierung, Notendarstellung |
| v1.1 | **Notizfeld Chorprobe** | Mittel | Niedrige Komplexität, hoher Alltagsnutzen; lokale Persistenz |
| v1.2 | **Repertoireliste** | Hoch | Abhängig von PDF-Speicher-Entscheidung (OP-F1-01) |
| v1.3 | **Jahresplanung** | Mittel | Termine, Auftritte, Deadlines, Ideensammlung |
| v2.0 | **Mitgliederliste & Buchhaltung** | Hoch | Höchste Komplexität; Datenschutz vor Implementierung klären (OP-F5-01) |

Die Architektur soll alle Erweiterungen ermöglichen (NF-021). Offene technische Entscheidungen (Dateispeicher, Datenschutz) sind in Abschnitt 12 dokumentiert und müssen vor der jeweiligen Teilfunktion geklärt werden.

---

## 4. Systemkontext & Abgrenzung

### 4.1 Systemübersicht

Die App ist eine Web-App (PWA), gehostet auf GitHub Pages, die auf zwei Gerätetypen mit unterschiedlichen Nutzungskontexten betrieben wird:

- **PC / Desktop-Browser:** Planungsmodus — Repertoire, Jahresplanung, Mitglieder, Probenplanung
- **iPhone / iPad:** Durchführungsmodus — Einsing-Set, Tagesprobe-Ansicht mit Noten

**Supabase ist ab v1.1 eine MUSS-Komponente** (nicht mehr optional), da Daten geräteübergreifend synchronisiert werden müssen. Einsingübungen (v1.0) bleiben weiterhin lokal als JSON (kein DB-Zugriff nötig).

```
  [Anja / PC-Browser]          [Anja / iPhone oder iPad]
   Planungsmodus                Durchführungsmodus
          |                              |
          └──────────┬───────────────────┘
                     │
               [ CHORAPP ]
            (PWA, GitHub Pages)
                     │
        ┌────────────┴────────────────────┐
        │  Supabase                       │  ← MUSS ab v1.1
        │  - Auth (Login, RLS)            │  ← MUSS ab v2.0
        │  - PostgreSQL: Repertoire,      │
        │    Probenplanung, Jahresplan,   │
        │    Mitglieder, Buchhaltung      │
        │  - Storage: PDFs, Audio         │
        └─────────────────────────────────┘
                     │
        ┌────────────┴────────────────────┐
        │  E-Mail-Dienst (z. B. Resend)   │  ← MUSS ab E-Mail-Funktion
        │  via Supabase Edge Function     │
        └─────────────────────────────────┘
        ┌─────────────────────────────────┐
        │  Lokale Daten (JSON, lokal)     │  ← v1.0 (Einsingübungen)
        └─────────────────────────────────┘
```

**Mehrchor-Kontext:** Jeder Chor ist in Supabase als eigene Einheit gespeichert. Die Chorleiterin wählt beim Öffnen der App den aktiven Chor; alle Ansichten (Repertoire, Mitglieder, Planung) beziehen sich auf den gewählten Chor. Einsingübungen sind chorübergreifend.

### 4.2 Schnittstellen zu Fremdsystemen

| System | Richtung | Beschreibung | Priorität |
|--------|----------|--------------|-----------|
| GitHub Pages | — | Hosting der statischen App | MUSS |
| Supabase PostgreSQL | Beides | Persistente Daten, geräteübergreifend; Tabellenstruktur folgt je Teilfunktion | MUSS ab v1.1 |
| Supabase Storage | Beides | PDF- und Audiodatei-Ablage (löst OP-F1-01, OP-F2-01) | MUSS ab v1.2 |
| Supabase Auth | Ausgehend | Login (E-Mail + Passwort), Session-Management, RLS auf alle Mitglieder-/Buchhaltungsdaten | MUSS ab v2.0 |
| E-Mail-Dienst (Resend o.ä.) | Ausgehend | Transaktionale E-Mails (Zahlungserinnerung, Probeninfo) via Supabase Edge Function | MUSS ab E-Mail-Funktion *(OP-EMAIL-01)* |
| Browser-Speicher (lokal) | Lokal | Einsingübungen v1.0; Cache für Offline-Toleranz | SOLL |

Supabase-Konfiguration: `js/supabase.js` (URL + anon key). Tabellenstruktur wird mit jeder Teilfunktion angelegt — nicht vorzeitig.

### 4.3 Datenmigration

Keine Datenmigration erforderlich (Neuentwicklung ohne Altdaten).

---

## 5. Nutzer & Benutzergruppen

| Nutzergruppe | Gerät | Häufigkeit | Technisches Level | Kontext |
|-------------|-------|------------|-------------------|---------|
| Chorleiterin (Anja) — Planungsmodus | PC / Desktop-Browser | Wöchentlich, vor der Probe | Niedrig–mittel | Zuhause, sitzend, Maus & Tastatur |
| Chorleiterin (Anja) — Durchführungsmodus | iPhone oder iPad | Jede Probe | Niedrig–mittel | Probelokal, stehend, eine Hand, ggf. wenig Licht |

Die App hat genau eine Nutzerin. In v1.0–v1.3 ist kein Login erforderlich (keine Personendaten). Ab v2.0 (Mitglieder & Buchhaltung) wird ein **richtiger Login via Supabase Auth** (E-Mail + Passwort) eingeführt — entschieden von der Auftraggeberin am 2026-06-12 (löst OP-F5-01).

---

## 6. Funktionale Anforderungen

Priorisierung nach MoSCoW: **MUSS** = abnahmekritisch, **SOLL** = wichtig/verhandelbar, **KANN** = spätere Phase.

### 6.0 Mehrchor-Verwaltung & Nutzungskontexte

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-000 | MUSS | Das System MUSS mehrere Chöre verwalten können. Repertoire, Mitglieder, Probenplanung und Jahresplanung sind pro Chor getrennt. |
| FA-001a | MUSS | Die Chorleiterin MUSS beim Öffnen der App den aktiven Chor auswählen oder wechseln können. Alle chor-spezifischen Ansichten beziehen sich auf den gewählten Chor. |
| FA-001b | MUSS | Einsingübungen (Bibliothek) sind chorübergreifend geteilt — nicht chor-spezifisch. |
| FA-001c | MUSS | Die App MUSS auf dem Desktop-Browser (PC) und auf dem iPhone/iPad-Browser gleichermassen funktionieren. Das Layout passt sich dem Gerät an (responsive). |
| FA-001d | MUSS | Der PC-Browser zeigt den **Planungsmodus** (Repertoire, Jahresplan, Mitglieder verwalten). Der iPhone/iPad-Browser zeigt den **Durchführungsmodus** (Einsing-Set, Tagesprobe-Ansicht). |
| FA-001e | MUSS | Alle Daten (ausser den eingebauten Einsingübungen) werden über Supabase synchronisiert, sodass Änderungen am PC sofort auf dem iPhone/iPad sichtbar sind. |

### 6.1 Einsing-Set generieren

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-001 | MUSS | Das System MUSS der Chorleiterin ermöglichen, per Knopfdruck ein neues Einsing-Set zu generieren, sodass für jede Probe ein frisches Set bereitsteht. |
| FA-002 | MUSS | Das System MUSS jedes Set aus 5–6 Übungen zusammenstellen, gegliedert und didaktisch aufbauend in der Reihenfolge Körper → Atem → Stimme → Abschluss. |
| FA-003 | MUSS | Das System MUSS pro Kategorie mindestens eine passende Übung in das Set aufnehmen und die Abschluss-Einheit (kurzes Lied oder Kanon) ans Ende stellen. |
| FA-004 | KANN | Das System KANN bei der Generierung die zuletzt gezeigten Übungen meiden, um Wiederholungen zu reduzieren. *(In v1.0 genügt zufällige Auswahl; Wiederholungen sind akzeptiert.)* |

### 6.2 Kategorien & Übungsinhalte

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-010 | MUSS | Das System MUSS Übungen der Kategorie **Körper** anbieten: Körper leicht aktivieren, Zwerchfell aktivieren; darf spielerisch/lustig sein. |
| FA-011 | MUSS | Das System MUSS Übungen der Kategorie **Atem** anbieten: Fokus Zwerchfellatmung, Öffnung im Brustraum, Bauchatmung, Stütze aktivieren. |
| FA-012 | MUSS | Das System MUSS Übungen der Kategorie **Stimme** anbieten: Einsingübungen, nach Intervallen aufbauend gesteigert bis zur Oktave. |
| FA-013 | MUSS | Das System MUSS als **Abschluss** ein einfaches kurzes Lied oder einen Kanon bereitstellen. |

### 6.3 Übungsdarstellung

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-020 | MUSS | Das System MUSS jede Übung mit Titel, Kategorie und einer textlichen Anleitung darstellen. |
| FA-021 | SOLL | Das System SOLL Stimm-/Intervallübungen zusätzlich mit einem **echten Notenbild im Fünfliniensystem** darstellen, sodass der Tonverlauf korrekt notiert sichtbar ist *(Entscheidung OP-002)*. Umsetzung als vorbereitete Notengrafik je Übung oder via Notensatz-Bibliothek. Die Notendarstellung darf später als die Set-Generierung fertiggestellt werden (siehe R-002) und blockiert die Abnahme der Set-Funktion nicht. |
| FA-022 | SOLL | Das System SOLL das gesamte Set übersichtlich auf einem Bildschirm durchblätterbar/scrollbar darstellen. |

### 6.4 Eigene Übungen

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-030 | MUSS | Das System MUSS eine eingebaute Grund-Bibliothek mit Übungen aller Kategorien mitliefern. **Zielumfang: mindestens 12 Übungen pro Kategorie** für hohe Abwechslung *(Entscheidung OP-001)*. Der Start erfolgt mit einem kleineren Grundbestand; der Vorrat wird über die Wochen schrittweise auf den Zielumfang aufgefüllt (Wiederholungen anfangs akzeptiert). |
| FA-031 | SOLL | Das System SOLL der Chorleiterin ermöglichen, eigene Übungen (Titel, Kategorie, Anleitung) hinzuzufügen, sodass die Bibliothek erweiterbar ist. |
| FA-032 | KANN | Das System KANN das Bearbeiten und Löschen eigener Übungen ermöglichen. |

### 6.5 Notizfeld Chorprobe (v1.1)

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-040 | SOLL | Das System SOLL für jede Chorprobe ein freies Notizfeld bereitstellen, in dem die Chorleiterin Beobachtungen, Infos und Bemerkungen festhalten kann. |
| FA-041 | SOLL | Das System SOLL vergangene Probennotizen abrufbar machen, sodass der Verlauf nachvollziehbar bleibt. |
| FA-042 | KANN | Das System KANN das Markieren einzelner Punkte ermöglichen, die dem Chor mitgeteilt werden müssen. |

### 6.6 Repertoireliste (v1.2)

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-050 | MUSS | Das System MUSS alle Lieder eines Chors in einer Liste darstellen (Repertoire pro Chor getrennt). |
| FA-051 | MUSS | Das System MUSS es ermöglichen, am PC pro Probe die zu probenden Lieder auszuwählen, sodass ein Tagesplan entsteht. |
| FA-052 | MUSS | Das System MUSS auf dem iPhone/iPad eine **Tagesprobe-Ansicht** darstellen: generiertes Einsing-Set + geplante Lieder mit Noten-Abruf, kompakt und scrollbar. |
| FA-053 | MUSS | Das System MUSS jedem Lied eine PDF-Datei mit Noten verknüpfen können. PDFs werden in **Supabase Storage** abgelegt und direkt in der App geöffnet (löst OP-F1-01). |
| FA-054 | MUSS | Das System MUSS das Hochladen von PDFs vom PC (Desktop-Browser) ermöglichen. |
| FA-055 | MUSS | Das System MUSS für jedes Lied einen Status erfassen und anzeigen können: **«in Bearbeitung»**, **«einstudiert»**, **«konzertbereit»**. Der Status ist pro Chor separat. |

### 6.7 Eigene Einsingübungen mit Audio (Erweiterung zu 6.4)

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-031 | SOLL | Das System SOLL der Chorleiterin ermöglichen, eigene Übungen (Titel, Kategorie, Anleitung) hinzuzufügen, sodass die Bibliothek erweiterbar ist. *(aus v1.0 übernommen)* |
| FA-032 | KANN | Das System KANN das Bearbeiten und Löschen eigener Übungen ermöglichen. *(aus v1.0 übernommen)* |
| FA-060 | SOLL | Das System SOLL ermöglichen, zu einer eigenen Übung eine Audiodatei hochzuladen. Audiodateien werden in **Supabase Storage** abgelegt (löst OP-F2-01). |
| FA-061 | SOLL | Das System SOLL die hinterlegte Audiodatei direkt in der App abspielen können, ohne Gerätewechsel. |

### 6.8 Jahresplanung (v1.3)

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-070 | SOLL | Das System SOLL das Erfassen von Auftritten und Konzertterminen ermöglichen, sodass alle Daten auf einen Blick sichtbar sind. |
| FA-071 | SOLL | Das System SOLL das Zuordnen von Liedern zu Terminen ermöglichen, sodass Deadlines für das Einstudieren klar sind. |
| FA-072 | SOLL | Das System SOLL eine Ideensammlung für Konzertprogramme bereitstellen, sodass Ideen nicht verloren gehen. |
| FA-073 | KANN | Das System KANN die Jahresplanung wahlweise als Kalender oder Liste darstellen. |

### 6.9 Mitgliederliste & Buchhaltung (v2.0)

*⚠️ Dieser Bereich verarbeitet personenbezogene Daten. Implementierung erst nach Klärung von OP-F5-01 (Datenschutz/Speicherort). Mitgliederliste und Buchhaltung sind pro Chor getrennt.*

**Mitgliederliste**

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-080 | MUSS | Das System MUSS das Erfassen, Bearbeiten und Entfernen von Chormitgliedern ermöglichen. Pflichtfelder: Name, E-Mail-Adresse. Optionale Felder: Adresse, Telefonnummer, Stimmlage (Sopran / Mezzosopran / Alt / Tenor / Bariton / Bass). |
| FA-081 | SOLL | Das System SOLL die Mitgliederliste exportierbar machen (CSV/Excel). *(abhängig von OP-F5-02)* |

**Mitgliederbeitrag**

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-085 | MUSS | Das System MUSS der Chorleiterin ermöglichen, den Mitgliederbeitrag pro Chor und pro Halbjahr in der App zu definieren (Betrag und Periode). |
| FA-086 | MUSS | Das System MUSS pro Mitglied und pro Halbjahr den Zahlungsstatus des Mitgliederbeitrags erfassen und anzeigen (bezahlt / offen). |
| FA-087 | SOLL | Das System SOLL eine Übersicht aller Mitglieder mit aktuellem Beitragsstatus darstellen, sodass ausstehende Zahlungen auf einen Blick sichtbar sind. |

**Spesen & Ausgaben**

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-090 | MUSS | Das System MUSS das Erfassen von Ausgaben und Spesen über eine Eingabemaske ermöglichen. Felder: Datum, Betrag, Beschreibung/Kategorie. |
| FA-091 | SOLL | Das System SOLL das Erfassen weiterer Einnahmen (z. B. Konzerteinnahmen) ermöglichen. |
| FA-092 | SOLL | Das System SOLL eine laufende Übersicht über den Kassenstand darstellen (Beiträge eingegangen − Ausgaben). |

**Abrechnung & Export**

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-095 | MUSS | Das System MUSS auf Verlangen eine **steuerkonform formatierte Abrechnung** pro Chor für einen wählbaren Zeitraum erstellen. Pflichtfelder: Zeitraum (von/bis), Chorname, Datum der Erstellung, Abschnitt «Einnahmen» mit Bezeichnung «Mitgliederbeiträge» und Gesamtbetrag, Abschnitt «Ausgaben» mit jeder Position (Datum, Beschreibung, Betrag), Saldo (Einnahmen − Ausgaben). |
| FA-096 | MUSS | Die Abrechnung MUSS Mitgliederbeiträge **anonymisiert** ausweisen — als «Mitglied 1», «Mitglied 2» usw. mit Einzelbetrag und Status, aber ohne Klarnamen. |
| FA-097 | MUSS | Die Abrechnung MUSS als **PDF** exportiert werden können (druckfertig, A4). |
| FA-098 | KANN | Das System KANN die Abrechnung zusätzlich als CSV/Excel exportieren. |

### 6.10 E-Mail-Versand (v2.0, zusammen mit Mitglieder-Funktion)

*Setzt Mitgliederliste mit E-Mail-Adressen (FA-080) und einen konfigurierten E-Mail-Dienst (OP-EMAIL-01) voraus.*

| ID | Priorität | Anforderung |
|----|-----------|-------------|
| FA-100 | MUSS | Das System MUSS ermöglichen, eine E-Mail an alle Mitglieder eines Chors zu senden (Rundmail). |
| FA-101 | MUSS | Das System MUSS ermöglichen, eine Zahlungserinnerung an einzelne Mitglieder mit offenem Beitrag zu senden — manuell ausgelöst durch die Chorleiterin. |
| FA-102 | SOLL | Das System SOLL eine einfache Textvorlage für Zahlungserinnerungen mitliefern, die angepasst werden kann. |
| FA-103 | SOLL | Das System SOLL ermöglichen, eine Probeninfo (z. B. Ausfall, Raumänderung) als E-Mail an alle oder ausgewählte Mitglieder zu senden. |
| FA-104 | KANN | Das System KANN einen Versandverlauf (Datum, Empfänger, Betreff) pro Chor protokollieren. |

---

## 7. Nicht-funktionale Anforderungen (NFRs)

*Bewusst schlank gehalten — persönliche App ohne Server, ohne sensible Daten, Einzelnutzerin.*

### 7.1 Bedienbarkeit & Performance

| ID | Anforderung | Messkriterium |
|----|-------------|---------------|
| NF-001 | Das System MUSS auf dem iPhone- und iPad-Browser flüssig und ohne spürbare Verzögerung bedienbar sein. | Set-Generierung < 1 s; Tagesprobe-Ansicht lädt < 2 s |
| NF-002 | Der Durchführungsmodus (iPhone/iPad) MUSS mit einer Hand und ohne Anleitung bedienbar sein. | Anja kann ohne Einweisung ein Set erzeugen und Noten öffnen |
| NF-003a | Das System MUSS responsiv sein: Der PC-Browser zeigt die Planungsansicht (breites Layout, Tabellen, Formulare); das iPhone/iPad zeigt die Durchführungsansicht (kompakte Karten, grosse Tipp-Ziele). | Breakpoint ca. 900 px |
| NF-003b | Datenänderungen am PC MÜSSEN nach spätestens einer Seiten-Aktualisierung auf dem iPhone/iPad sichtbar sein (Sync über Supabase). | — |

### 7.2 Verfügbarkeit & Betrieb

| ID | Anforderung |
|----|-------------|
| NF-003 | Das System wird online betrieben; ein Offline-Modus ist in v1.0 nicht erforderlich. |
| NF-004 | Das System MUSS als statische Seite ohne Build-Step über GitHub Pages auslieferbar sein. |

### 7.3 Sicherheit & Datenschutz

| ID | Anforderung |
|----|-------------|
| NF-010 | Das System verarbeitet keine personenbezogenen Daten; eine Anmeldung ist nicht erforderlich. |
| NF-011 | Eigene Übungen werden lokal im Browser gespeichert und nicht an Dritte übertragen. |
| NF-012 | Supabase-Datenbankzugriffe erfolgen ausschliesslich über den anon-Key mit Row-Level-Security. Tabellen werden erst angelegt, wenn die zugehörige Teilfunktion implementiert wird. |

### 7.3a Datenschutz (Erweiterung für v2.0)

| ID | Anforderung |
|----|-------------|
| NF-013 | Personenbezogene Daten (Mitgliederliste) MÜSSEN gemäss DSGVO/DSG behandelt werden. Speicherung und Zugriff sind vor Implementierung zu klären (OP-F5-01). |
| NF-013a | **Privacy by Design:** Exporte und Abrechnungen dürfen Mitgliedernamen NICHT enthalten. Mitglieder werden in allen Exporten ausschliesslich als «Mitglied 1», «Mitglied 2» usw. ausgewiesen. |
| NF-014 | Ab v2.0 MUSS die gesamte App mit **Supabase Auth** (E-Mail + Passwort) gesichert sein. Alle Mitglieder- und Buchhaltungsdaten sind via Row-Level-Security (RLS) auf den eingeloggten Benutzer beschränkt. *(Entschieden 2026-06-12, löst OP-F5-01)* |

### 7.3b Dateiablage (Erweiterung für v1.2/v1.3)

| ID | Anforderung |
|----|-------------|
| NF-015 | PDF- und Audiodateien MÜSSEN auf eine Weise abgelegt werden, die auf dem iPhone-Browser abrufbar ist. Entscheidung für Speicherlösung (OP-F1-01, OP-F2-01) ist vor Implementierung zu treffen. |
| NF-016 | Dateigrössen-Limits sind einzuhalten: GitHub Pages (max. 100 MB/Datei, 1 GB/Repo); IndexedDB (Browser-abhängig, ca. 50–500 MB). |

### 7.4 Wartbarkeit

| ID | Anforderung |
|----|-------------|
| NF-020 | Das System SOLL so aufgebaut sein, dass die Übungs-Bibliothek leicht erweiterbar ist (Daten getrennt vom Code). |
| NF-021 | Das System SOLL so strukturiert sein, dass weitere Teilfunktionen später ergänzt werden können. |

---

## 8. Systemarchitektur-Constraints

### 8.1 Technologie-Vorgaben

| Constraint | Beschreibung | Begründung |
|-----------|-------------|------------|
| Hosting | GitHub Pages (statisch) | Bestehende Projektvorgabe, kostenlos, einfach |
| Stack | Vanilla HTML/CSS/JS oder PWA | Kein Build-Step angestrebt |
| Plattform | **Responsive: PC-Browser + iPhone/iPad** | Zwei Nutzungskontexte; Layout passt sich an |
| Backend-Service | **Supabase (PostgreSQL + Storage + Auth, Free Tier) — MUSS** | Datensynchronisation, Dateiablage, Login; Region Frankfurt |
| E-Mail-Dienst | **Transactional E-Mail (z. B. Resend) — MUSS ab E-Mail-Funktion** | Versand aus App; Supabase Edge Function als Vermittler *(Entscheidung OP-EMAIL-01 offen)* |

### 8.2 Technologie-Ausschlüsse

| Ausschluss | Begründung |
|-----------|------------|
| Login-/Benutzerverwaltung | Einzelnutzerin, kein Bedarf in v1.0 |

### 8.3 Architekturelle Anforderungen

| ID | Anforderung |
|----|-------------|
| AR-001 | Das System MUSS als statische Single-Page-App (optional PWA) ohne serverseitige Logik umgesetzt werden. |
| AR-002 | Übungsdaten MÜSSEN als strukturierte Datendatei (z. B. JSON) vom Anwendungscode getrennt vorliegen. |

---

## 9. Qualitätsanforderungen & Abnahmekriterien

### 9.1 Abnahmekriterien

| ID | Kriterium | Nachweisform |
|----|-----------|-------------|
| AK-001 | Knopfdruck erzeugt ein vollständiges Set aus 5–6 Übungen in der Reihenfolge Körper → Atem → Stimme → Abschluss. | Funktionsdemo |
| AK-002 | Jede Kategorie ist mit passenden Übungen aus der eingebauten Bibliothek vertreten; Abschluss ist Lied oder Kanon. | Funktionsdemo |
| AK-003 | Stimmübungen zeigen ein Notenbild; alle Übungen zeigen Titel und Anleitung. | Sichtprüfung |
| AK-004 | Anja kann mindestens eine eigene Übung hinzufügen, die danach in der Generierung berücksichtigt wird. | Funktionsdemo |
| AK-005 | Die App ist auf dem iPhone-Browser flüssig und einhändig bedienbar. | Nutzungstest mit Anja |

### 9.2 Zu liefernde Dokumentation

- [ ] Kurze Bedienungsanleitung für Anja (1 Seite, in der App oder als Hinweis)
- [ ] Knappe technische Notiz zur Pflege/Erweiterung der Übungs-Bibliothek

---

## 10. Projektrahmen

### 10.1 Zeitplan

| Meilenstein | Termin | Art | Begründung |
|-------------|--------|-----|------------|
| Freigabe Lastenheft + Projektplan | offen | Hart | App-Generierung erst nach Freigabe |
| Umsetzung Funktion «Einsingen» | nach Freigabe | Weich | — |

### 10.2 Budget

Privates Projekt, kein externes Budget (Eigenleistung).

---

## 11. Risiken & Abhängigkeiten

| ID | Risiko/Abhängigkeit | Wahrscheinlichkeit | Auswirkung | Maßnahme |
|----|--------------------|--------------------|------------|----------|
| R-001 | Eingebaute Übungs-Bibliothek anfangs zu klein → wenig Abwechslung | Mittel | Mittel | Mit ausreichend Übungen pro Kategorie starten; Eigenübungen ermöglichen (FA-031) |
| R-002 | Echtes Notenbild (Fünfliniensystem, OP-002) ist der technisch aufwendigste Teil | Mittel | Mittel | FA-021 als SOLL und entkoppelt von der Set-Funktion: Set-Generierung zuerst abnehmen, echte Noten ggf. als spätere Ausbaustufe nachreichen (vorbereitete Notengrafiken oder Notensatz-Bibliothek) |
| R-003 | Lokaler Browser-Speicher wird gelöscht → eigene Übungen verloren | Niedrig | Mittel | Hinweis an Nutzerin; Migration zu Supabase in späterer Version möglich |
| R-004 | Supabase Free Tier wird eingestellt oder Limits überschritten | Niedrig | Mittel | App läuft ohne Supabase weiter (v1.0-Funktionen sind rein lokal); Migration zu anderem Anbieter möglich |
| R-005 | PDF/Audio-Dateien überschreiten Supabase Storage Free-Tier-Limit (1 GB) | Niedrig | Mittel | Dateigrösse beim Upload prüfen/begrenzen; bei Bedarf auf kostenpflichtigen Tier upgraden |
| R-006 | Supabase Auth / RLS falsch konfiguriert → Mitgliederdaten ungeschützt | Niedrig | Hoch | RLS-Policies für alle Tabellen mit Personendaten vor Go-live testen; kein Deploy ohne Auth-Abnahme |
| R-008 | E-Mail-Dienst (Resend o.ä.) sendet E-Mails nicht zuverlässig oder wird als Spam markiert | Niedrig | Mittel | SPF/DKIM korrekt konfigurieren; Absenderadresse mit Anja klären (OP-EMAIL-01) |
| R-007 | IndexedDB-Daten werden bei Browser-/App-Reset gelöscht (Notizen, eigene Übungen, Mitglieder) | Mittel | Hoch | Export-Funktion für alle lokal gespeicherten Daten einplanen; Nutzerin informieren |

---

## 12. Anhang

### C. Offene Punkte

**Aus v1.0 — alle geklärt:**

| ID | Frage | Status | Entscheidung |
|----|-------|--------|--------------|
| OP-001 | Umfang der Start-Bibliothek: Wie viele Übungen pro Kategorie? | ✅ Geklärt | Zielumfang **12+ Übungen pro Kategorie**; klein starten und über die Wochen auffüllen (siehe FA-030). |
| OP-002 | Form der Notendarstellung (echte Notation vs. vereinfachte Grafik)? | ✅ Geklärt | **Echtes Notenbild im Fünfliniensystem**; als SOLL und entkoppelt von der Set-Funktion, darf später nachgereicht werden (siehe FA-021, R-002). |
| OP-003 | Sollen die nächsten Teilfunktionen bereits grob skizziert werden (Roadmap)? | ✅ Geklärt | **Ja**, in Roadmap (Abschnitt 3.4) aufgeführt. |

**Aus v1.3 — offen, vor jeweiliger Implementierung zu klären:**

| ID | Frage | Betrifft | Status |
|----|-------|---------|--------|
| OP-F1-01 | Wie sollen PDFs gespeichert werden? | FA-053, FA-054, NF-015 | ✅ Geklärt: **Supabase Storage** — geräteübergreifend verfügbar, kein GitHub-Repo-Ballast, kein gerätegebundenes IndexedDB |
| OP-F2-01 | Wie sollen Audiodateien gespeichert werden? | FA-060, FA-061, NF-015 | ✅ Geklärt: **Supabase Storage** — gleiche Entscheidung wie PDFs |
| OP-F5-01 | Datenschutz Mitgliederdaten: Login und Zugriffskontrolle | FA-080, NF-013, NF-014 | ✅ Geklärt: **Supabase Auth** (E-Mail + Passwort) + RLS. Entschieden 2026-06-12. |
| OP-F5-02 | Soll die Mitgliederliste exportierbar sein (z. B. als CSV/Excel)? | FA-081 | 🔲 Offen |
| OP-F5-03 | Welches Steuerformat gilt für die Abrechnung? | FA-095, FA-097 | ⚠️ Teilgeklärt: Pflichtfelder definiert (FA-095). Ob eine behördliche CH-Vorlage eingehalten werden muss, noch offen. |
| OP-EMAIL-01 | Welcher E-Mail-Dienst für den Versand? Von welcher Absenderadresse sollen E-Mails kommen (App-Adresse oder Anjas eigene)? | FA-100–104 | ⚠️ Teilgeklärt 2026-09-07: **Resend** bleibt. Anjas Hotmail-Adresse ist als Absender technisch ausgeschlossen (keine DNS-Hoheit für DKIM; SPF von hotmail.com endet auf `-all`). Offen ist nur noch die Absenderdomain. Übergangsweise Versand per `mailto:`. Siehe `08_Meetings/2026-09-07_OP-EMAIL-01_Absenderadresse.md` |
| OP-ALL-01 | Finale Priorisierung und Reihenfolge der Teilfunktionen nach v1.0-Abnahme | Alle | 🔲 Offen |
