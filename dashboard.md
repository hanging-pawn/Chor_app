---
projekt: Chor_app
verantwortlich: Gianluca
active: true
---

# Chor_app — Mobile PWA

> Aktualisiert 2026-07-07 nach Code-Abgleich (index.html, db/migrations, Lastenheft, Umsetzungsplan-v2). Vorheriger Stand war veraltet — Implementierung war weiter als hier vermerkt.

## Sprint 0 — Setup

- [x] App-Inhalt & Funktionen definieren `3sp`
- [x] Erste User Stories erfassen `3sp`
- [x] GitHub Pages konfigurieren `2sp`
- [x] Architekturentscheidungen dokumentieren `2sp`

## Anforderungen & Design

- [x] UI/UX (Design in index.html umgesetzt, my-design-system) `5sp`
- [x] Datenbankschema (Supabase, Migrations 001–008) `3sp`
- [x] Akzeptanzkriterien definieren `2sp`

## v1.0 — Einsingen (Kernfunktion)

- [x] Set-Generierung Körper→Atem→Stimme→Abschluss (FA-001–003) `5sp`
- [x] Notenbild (abcjs) `3sp`
- [x] Eigene Übungen (FA-031/032, AK-004) `3sp`
- [ ] Nutzungstest mit Anja auf dem iPhone (AK-005) `2sp`

## v1.1–v2.0 — Erweiterungen (Umsetzungsplan-v2)

- [x] Phase 0-V2: Navigation & Multi-Chor-Fundament `3sp`
- [x] Phase 2-V2: Notizfeld Chorprobe `3sp`
- [x] Phase 3-V2: Repertoireliste + Tagesprobe-Ansicht `8sp`
- [x] Phase 4-V2: Jahresplanung `5sp`
- [x] Phase 5-V2: Supabase Auth + RLS `5sp`
- [x] Phase 6-V2: Mitgliederliste + CSV-Export `3sp`
- [x] Phase 7-V2: Buchhaltung + anonymisierter PDF-Export `5sp`
- [x] Phase 8-V2: E-Mail-Versand (Rundmail, Zahlungserinnerung, Probeninfo) `3sp`
- [ ] Phase 9-V2: Audio-Übungen `3sp`
- [ ] OP-EMAIL-01 schriftlich bestätigen (Absenderadresse/Dienst, DKIM/SPF) `1sp`

## Implementierung (übergreifend)

- [x] Core-Features implementiert `8sp`
- [ ] Offline-Fähigkeit (PWA Service Worker) `5sp`
- [x] Supabase-Integration `5sp`

## Launch

- [ ] Tests & QA (05_Tests ist leer — kein automatisierter Test vorhanden) `3sp`
- [x] Deployment GitHub Pages (.github/workflows/deploy.yml) `2sp`
- [ ] Onboarding-Doku für Anja `2sp`

## Architektur

Siehe `02_Architektur/ADR-001_Stack.md`.

## Design

<!-- Ordner: 03_Design — noch keine Tasks erfasst -->

## Tests

<!-- Ordner: 05_Tests — leer. Keine Testdateien vorhanden. -->

## Dokumentation

<!-- Ordner: 06_Dokumentation — noch keine Tasks erfasst -->

## Deployment

Workflow vorhanden: `.github/workflows/deploy.yml`.

## Meetings

<!-- Ordner: 08_Meetings — leer. Kein Protokoll zum Nutzungstest (AK-005) oder zu OP-EMAIL-01 vorhanden. -->

## Referenzen

<!-- Ordner: 09_Referenzen — noch keine Tasks erfasst -->

## Notizen

Stack: HTML · CSS · JavaScript · GitHub Pages · Supabase. Repo: github.com/hanging-pawn/Chor_app

Detaillierter Plan für die Restarbeiten: `04_Implementierung/Umsetzungsplan-v3_Restarbeiten.md`
(Prompt-Pakete, Modellwahl, manuelle Schritte pro Punkt).

Offene Prioritäten (siehe auch 01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md):
1. Nutzungstest mit Anja (AK-005) — einziger offene Abnahmepunkt v1.0
2. OP-EMAIL-01 klären und dokumentieren
3. Tests nachziehen
4. Service Worker / Offline-Fähigkeit
5. Phase 9-V2 Audio-Übungen (optional, niedrige Priorität)
