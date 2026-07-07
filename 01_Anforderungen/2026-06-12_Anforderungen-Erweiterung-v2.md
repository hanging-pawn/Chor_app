---
context:
  read: full
  tokens: ~1500
  covers: [anforderungen, repertoire, jahresplanung, mitglieder, buchhaltung, audio, pdf, notizfeld]
  read_when: "Erweiterungsanforderungen über Einsingen hinaus klären oder planen"
  skip_when: "nur Einsingen-Funktion relevant"
  updated: 2026-06-12
---

# Anforderungen v2 — Erweiterung Chorapp

**Datum:** 2026-06-12  
**Quelle:** Direkter Input von Anja (Auftraggeberin)  
**Bezug:** Ergänzt Lastenheft v1.1 (Fokus Einsingen)

---

## Übersicht der neuen Teilfunktionen

| # | Funktion | Priorität (Anja) | Architektur-Implikation |
|---|----------|------------------|------------------------|
| F-1 | Repertoireliste mit PDF-Verknüpfung | Hoch | Datei-Upload → kein reines statisches Hosting |
| F-2 | Eigene Einsingübungen mit Audio | Mittel | Audio-Upload, LocalStorage oder Datei-Ablage |
| F-3 | Notizfeld Chorprobe | Mittel | Lokale Persistenz |
| F-4 | Jahresplanung (Termine, Auftritte, Deadlines, Ideen) | Mittel | Strukturierte Datenhaltung |
| F-5 | Mitgliederliste + Buchhaltung | Hoch | Personendaten → Datenschutz, Export nötig |
| F-6 | Übungen generieren | (in v1.0 bereits FA-001) | — |

---

## F-1: Repertoireliste

### Beschreibung
Anja führt eine Liste aller Chorlieder. Für jede Probe wählt sie aus dieser Liste aus, welche Lieder heute geprobt werden — und fügt diese zum Tagesprogramm (zusammen mit dem Einsingen) hinzu.

### User Stories
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-101 | Chorleiterin | alle Lieder des Repertoires in einer Liste sehen | ich einen Überblick über das gesamte Programm habe |
| US-102 | Chorleiterin | pro Probe die zu probenden Lieder auswählen | das Tagesprogramm automatisch zusammengestellt wird |
| US-103 | Chorleiterin | jedem Lied eine PDF-Datei mit Noten verknüpfen | ich die Noten schnell aufrufen kann |
| US-104 | Chorleiterin | PDFs vom PC in die App hochladen | ich die Dateien einmalig ablegen kann |
| US-105 | Chorleiterin | das Tagesprogramm (Einsingen + Lieder) in einer Ansicht sehen | ich die Probe strukturiert durchführen kann |

### Architektur-Hinweis
PDF-Upload vom PC erfordert eine Datei-Ablage. Optionen:
- **Option A:** IndexedDB im Browser (kein Server, Dateien bleiben lokal, aber gerätegebunden)
- **Option B:** GitHub-basierter Upload (Noten als Assets im Repo — einmaliger Setup, dann statisch)
- **Option C:** Cloud-Ablage (z. B. Google Drive Link statt Upload) — kein Upload nötig, nur Verlinkung

→ **Entscheidung offen:** Muss mit Anja geklärt werden (wie technisch-affin ist sie beim PC-Upload?).

---

## F-2: Eigene Einsingübungen mit Audio

### Beschreibung
Anja kann eigene Einsingübungen erfassen — ergänzend zur eingebauten Bibliothek. Zu jeder Übung kann eine Audiodatei hinterlegt werden, die in der App abgespielt wird.

### User Stories
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-201 | Chorleiterin | eigene Übungen mit Titel, Kategorie und Beschreibung erfassen | die Bibliothek meinen Bedürfnissen entspricht |
| US-202 | Chorleiterin | zu einer Übung eine Audiodatei hochladen | der Chor die Übung direkt anhören kann |
| US-203 | Chorleiterin | die Audiodatei in der App abspielen | ich das Gerät nicht wechseln muss |

### Architektur-Hinweis
Audio-Upload ähnlich wie PDF: IndexedDB (lokal) oder Datei als Asset im Repo. Dateigrössen beachten (GitHub Pages: 100 MB/Datei, 1 GB/Repo).

---

## F-3: Notizfeld Chorprobe

### Beschreibung
Für jede Probe gibt es ein freies Notizfeld — für Bemerkungen, Infos die dem Chor mitgeteilt werden müssen, Beobachtungen während der Probe.

### User Stories
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-301 | Chorleiterin | für jede Probe ein Notizfeld haben | ich Infos und Beobachtungen festhalten kann |
| US-302 | Chorleiterin | vergangene Probennotizen abrufen können | ich den Verlauf nachvollziehen kann |
| US-303 | Chorleiterin | Punkte markieren, die dem Chor mitgeteilt werden müssen | nichts vergessen geht |

---

## F-4: Jahresplanung

### Beschreibung
Eine strukturierte Übersicht über das ganze Chorajahr: Auftritte, Probenplan, Deadlines für bestimmte Lieder, sowie eine Ideensammlung für Konzertprogramme.

### User Stories
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-401 | Chorleiterin | Auftritte und Konzerttermine eintragen | alle Daten auf einen Blick sichtbar sind |
| US-402 | Chorleiterin | je Termin Lieder zuordnen, die bis dann einstudiert sein müssen | Deadlines klar sind |
| US-403 | Chorleiterin | eine Ideensammlung für Konzertprogramme führen | Ideen nicht verloren gehen |
| US-404 | Chorleiterin | die Jahresplanung als Kalender oder Liste sehen | ich mich schnell orientieren kann |

---

## F-5: Mitgliederliste & Buchhaltung

### Beschreibung
Verwaltung der Chormitglieder mit Kontaktdaten sowie einfache Finanzverwaltung des Chors.

### User Stories — Mitgliederliste
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-501 | Chorleiterin | alle Mitglieder mit Name, Adresse, E-Mail und Telefonnummer verwalten | ich schnell Kontakt aufnehmen kann |
| US-502 | Chorleiterin | Mitglieder hinzufügen, bearbeiten und entfernen | die Liste aktuell bleibt |

### User Stories — Buchhaltung
| ID | Als … | möchte ich … | damit … |
|----|-------|--------------|---------|
| US-511 | Chorleiterin | Einnahmen und Ausgaben des Chors erfassen | ich den Überblick über die Finanzen behalte |
| US-512 | Chorleiterin | pro Mitglied verfolgen, ob der Halbjahresbeitrag bezahlt wurde | ausstehende Zahlungen sichtbar sind |
| US-513 | Chorleiterin | eine Übersicht über den aktuellen Kassenstand sehen | ich jederzeit informiert bin |

### Architektur-Hinweis — Datenschutz ⚠️
Personenbezogene Daten (Name, Adresse, Tel, E-Mail) unterliegen dem Datenschutz (DSGVO/DSG). Speicherung in einem ungesicherten Browser-Speicher ohne Passwort ist bei Personendaten kritisch.

**Offener Punkt (OP-F5-01):** Wo und wie werden Mitgliederdaten gespeichert?
- **Option A:** Nur lokal im Browser (IndexedDB) — einfach, aber nur auf einem Gerät; verloren bei Cache-Leerung
- **Option B:** Export/Import als verschlüsselte Datei (JSON/CSV) — sicherer, Backup möglich
- **Option C:** Passwortschutz für den Bereich (einfaches lokales Passwort)

→ Muss mit Anja geklärt werden, bevor dieser Bereich implementiert wird.

---

## F-6: Neue Übungen generieren

Bereits in v1.0 als **FA-001** definiert. Anja bestätigt dies als Kernfunktion.

---

## Offene Punkte (klären mit Anja)

| ID | Frage | Betrifft |
|----|-------|---------|
| OP-F1-01 | Wie sollen PDFs gespeichert werden? (Browser-lokal / GitHub-Asset / Cloud-Link) | F-1 |
| OP-F2-01 | Wie sollen Audiodateien gespeichert werden? (Browser-lokal / GitHub-Asset) | F-2 |
| OP-F5-01 | Datenschutz Mitgliederdaten: Wo speichern? Passwortschutz gewünscht? | F-5 |
| OP-F5-02 | Soll die Mitgliederliste exportierbar sein (z. B. als Excel/CSV)? | F-5 |
| OP-ALL-01 | Priorität und Reihenfolge der Teilfunktionen nach v1.0 (Einsingen) | Alle |

---

## Priorisierungsvorschlag (Reihenfolge nach v1.0)

Basierend auf Anjas Input und Abhängigkeiten:

1. **Einsingen** (v1.0 — läuft)
2. **Notizfeld + Tagesprogramm** (niedrige Komplexität, hoher Alltagsnutzen)
3. **Repertoireliste** (hängt von PDF-Entscheidung ab)
4. **Jahresplanung**
5. **Mitgliederliste + Buchhaltung** (höchste Komplexität, Datenschutz klären)
