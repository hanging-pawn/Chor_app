---
context:
  read: full
  tokens: ~566
  covers: [chorapp, einsingen, stack, supabase, ordnerstruktur, arbeitshinweise]
  read_when: "jede Session in diesem Projekt — Einstiegspunkt für Stack, Supabase-Config und Arbeitsregeln"
  skip_when: "nie"
  updated: 2026-06-12
---

# CLAUDE.md — Chor_App

## Projekt
Companion-App für die Chorleiterin (Auftraggeberin: Anja). Unterstützt Organisation, Planung und Strukturierung der Chorarbeit.

**Erste Funktion (Fokus):** Einsingen — auf Knopfdruck wird ein neues, wöchentliches Einsing-Set generiert. Aufbau: Körper → Atem → Stimme → kurzes Lied/Kanon (5–6 Übungen).

Weitere Teilfunktionen folgen später in eigenen Sessions.

**Repo:** https://github.com/hanging-pawn/Chor_app.git
**Zielplattform:** Mobile Browser (iPhone-first), GitHub Pages

## Stack
- Vanilla HTML/CSS/JS oder PWA
- GitHub Pages als Hosting
- Kein Build-Step angestrebt (statische Dateien)
- **Supabase** (PostgreSQL, Free Tier) als Backend-Service — vorbereitet, Tabellen folgen mit den jeweiligen Teilfunktionen
  - URL: `https://guxvlbrxzmgylojbxjew.supabase.co`
  - Config: `js/supabase.js` (anon key, lazy-initialized client)
  - Region: Frankfurt (eu-west-1)

## Ordnerstruktur
```
Chor_App/
├── INDEX.md              ← Projektindex
├── CLAUDE.md             ← Diese Datei
├── 01_Anforderungen/     ← User Stories, Epics, Lastenheft
├── 02_Architektur/       ← ADRs, App-Struktur
├── 03_Design/            ← UI/UX, Wireframes
├── 04_Implementierung/   ← Tech-Specs
├── 05_Tests/             ← Testpläne
├── 06_Dokumentation/     ← Docs
├── 07_Deployment/        ← GitHub Actions, CI/CD
├── 08_Meetings/          ← Entscheidungslog
└── 09_Referenzen/        ← Externe Quellen
```

## Arbeitshinweise
- **Sprache:** Deutsch (Code-Kommentare auf Englisch)
- **Benennung:** `YYYY-MM-DD_Titel.md` für Protokolle, `ADR-001_Titel.md` für Architekturentscheidungen
- **App-Code** gehört ins Repo-Root (für GitHub Pages), nicht in diese Ordnerstruktur
- **App erst nach Freigabe** von Lastenheft und Projektplan generieren
- **Supabase-Tabellen** erst anlegen, wenn die zugehörige Teilfunktion implementiert wird — nicht vorzeitig
- **Kein API-Key** in Claude-Kontext teilen; der anon key liegt bereits in `js/supabase.js`
