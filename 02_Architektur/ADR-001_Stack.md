---
context:
  read: full
  tokens: ~943
  covers: [adr, stack, architektur, supabase, github-pages, vanilla-js]
  read_when: "Stack-Entscheide nachvollziehen, Supabase-Integration verstehen oder neue Architekturentscheidungen treffen"
  skip_when: "Übungsinhalte bearbeiten oder UI-Änderungen ohne Architekturrelevanz"
  updated: 2026-06-12
---

# ADR-001: Technologie-Stack

| Feld | Inhalt |
|------|--------|
| Status | Angenommen (v1.1 ergänzt) |
| Datum | 2026-06-12 |
| Entscheider | Gianluca La Rocca |
| Kontext | Chorapp, Funktion «Einsingen» (v1.0) |
| Bezug | AR-001, AR-002, NF-004, NF-020, NF-021 |

## Kontext

Die Chorapp ist eine persönliche Companion-App für eine einzelne Nutzerin (Chorleiterin), die primär auf dem iPhone-Browser läuft. Es werden keine personenbezogenen Daten verarbeitet und keine Mehrbenutzer-Funktionen benötigt. Das Lastenheft schreibt eine statische Auslieferung über GitHub Pages ohne Build-Step vor (NF-004) und verlangt, dass Übungsdaten getrennt vom Code vorliegen (AR-002).

## Entscheidung

Die App wird als **statische Single-Page-App in Vanilla HTML/CSS/JavaScript** umgesetzt, gehostet auf **GitHub Pages**. Es kommen weder ein Framework mit Build-Step noch ein Backend-Server oder eine Datenbank zum Einsatz. Die Übungs-Bibliothek wird als separate **JSON-Datei** (`data/uebungen.json`) geführt, gegen ein dokumentiertes JSON-Schema (`data/uebungen.schema.json`).

Struktur:

```
Chor_App/                 (Repo-Root = GitHub-Pages-Wurzel)
├── index.html            Einstiegsseite, lädt js/app.js
├── css/style.css         Styling (iPhone-first)
├── js/
│   ├── app.js            Anwendungslogik (folgt in späteren Sessions)
│   ├── generator.js      Set-Generator (Einsingen v1.0)
│   └── supabase.js       Backend-Config (URL + anon key, lazy client)
└── data/
    ├── uebungen.json     Übungsdaten (vom Code getrennt)
    └── uebungen.schema.json  Dokumentiertes Schema einer Übung
```

**Supabase** (ergänzt v1.1): PostgreSQL-Dienst auf Free Tier (Region Frankfurt) für spätere Teilfunktionen (Mitgliederverzeichnis, Buchhaltung, persistente Bibliothek). Tabellen werden erst bei Bedarf angelegt. `js/supabase.js` stellt einen lazy-initialisierten Client bereit und wird über CDN (`<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2">`) eingebunden.

## Begründung

Vanilla-Stack ohne Build-Step erfüllt NF-004 direkt: GitHub Pages liefert die Dateien unverändert aus, kein CI-Build nötig. Der Verzicht auf Server und Datenbank entspricht AR-001 und den Technologie-Ausschlüssen (Abschnitt 8.2 des Lastenhefts) und hält Betrieb und Wartung minimal. Die Trennung der Daten in eine JSON-Datei erfüllt AR-002 und NF-020 — die Bibliothek lässt sich erweitern, ohne Code anzufassen. Die modulare Ordnerstruktur (`js/`, `data/`) schafft Raum für spätere Teilfunktionen (NF-021: Probenplanung, Mitgliederverzeichnis, Buchhaltung).

Eigene Übungen (FA-031) werden in v1.0 im lokalen Browser-Speicher (Web Storage) gehalten — passend zu NF-011. Ab einer späteren Version kann die Bibliothek auf Supabase migriert werden.

## Konsequenzen

**Positiv:** Kostenloser, einfacher Betrieb; sofortiges Deployment per Git-Push; keine Abhängigkeit von Build-Tooling oder Laufzeit-Diensten; leicht wartbar und gut für KI-gestützte Weiterentwicklung lesbar.

**Negativ / Einschränkungen:** Kein Framework-Komfort (State-Management, Komponenten) — bei wachsendem Funktionsumfang ggf. mehr manueller Aufwand. Das echte Notenbild im Fünfliniensystem (FA-021) ist ohne Build-Step nur über vorbereitete Grafiken oder eine per CDN/statisch eingebundene Notensatz-Bibliothek umsetzbar; dies wird bei Bedarf in einer eigenen Entscheidung (Phase 5) behandelt. Lokaler Speicher kann durch den Nutzer gelöscht werden (R-003).

## Alternativen (verworfen)

Ein Framework wie React/Vue mit Build-Step wurde verworfen, da es NF-004 (kein Build-Step) widerspricht und für eine Einzelnutzer-App ohne erkennbaren Mehrwert Komplexität einführt. Ein Backend mit Datenbank wurde verworfen (AR-001, Abschnitt 8.2): unnötig, da keine serverseitige Logik und keine geteilten Daten anfallen.
