---
context:
  read: full
  tokens: ~320
  covers: [index, navigation]
  read_when: "always — erste Datei die in jeder Session geladen wird"
  skip_when: "never"
  updated: 2026-06-12
---

# Context Index — Chor_App

Dieser Index ersetzt das Lesen jeder Datei einzeln. Immer zuerst laden.
Gesamtprojekt-Token (ohne diesen Index): **~12,641**

## Wie nutzen

1. Aufgabe in der Tabelle unten suchen
2. Nur die Dateien in der Spalte «Load» laden
3. Lese-Modus aus dem Datei-Header verwenden

## File Map

| Datei | Tokens | Themen | Laden wenn | Überspringen wenn |
|---|---:|---|---|---|
| [01_Anforderungen/Lastenheft.md](01_Anforderungen/Lastenheft.md) | ~3900 | anforderungen, supabase, roadmap | Anforderungen/Abnahme klären | Reine Code-Details |
| [04_Implementierung/Umsetzungsplan.md](04_Implementierung/Umsetzungsplan.md) | ~2874 | implementierung, phasen, einsingen | Phasenplanung oder nächste Implementierung | Anforderungen, Docs |
| [01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md](01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md) | ~1866 | roadmap, v2, teilfunktionen | Nächste Teilfunktion planen | v1.0-Arbeit ohne Roadmap-Bezug |
| [08_Meetings/2026-06-12_Abnahme-AK-001-005.md](08_Meetings/2026-06-12_Abnahme-AK-001-005.md) | ~971 | abnahme, status | Abnahme vorbereiten | Neue Features entwickeln |
| [02_Architektur/ADR-001_Stack.md](02_Architektur/ADR-001_Stack.md) | ~943 | stack, supabase, architektur | Stack-Entscheide, Supabase-Details | UI/Übungsinhalte |
| [06_Dokumentation/Bibliothek-pflegen.md](06_Dokumentation/Bibliothek-pflegen.md) | ~722 | uebungen, pool, json | Übungen hinzufügen | Alles ohne Datenbezug |
| [CLAUDE.md](CLAUDE.md) | ~566 | stack, supabase, regeln | Jede Session — Einstieg | Nie |
| [08_Meetings/2026-06-12_FA-021-Notenbild.md](08_Meetings/2026-06-12_FA-021-Notenbild.md) | ~539 | notenbild, abcjs | Notation anpassen | Alles ohne Notationsbezug |
| [INDEX.md](INDEX.md) | ~258 | projektstatus | Schnellübersicht | Inhaltliche Details |

## Aufgabe → Dateien (Cheat Sheet)

- **Neue Session starten** → `CLAUDE.md` (full) + `CONTEXT_INDEX.md`
- **Nächste Teilfunktion implementieren** → `01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md` + `04_Implementierung/Umsetzungsplan.md`
- **Supabase-Tabelle anlegen** → `CLAUDE.md` + `02_Architektur/ADR-001_Stack.md` + `01_Anforderungen/Lastenheft.md` (section: 4)
- **Übungen erweitern** → `06_Dokumentation/Bibliothek-pflegen.md`
- **Abnahme mit Anja vorbereiten** → `08_Meetings/2026-06-12_Abnahme-AK-001-005.md` + `01_Anforderungen/Lastenheft.md` (section: 9)
- **Notenbild / abcjs anpassen** → `08_Meetings/2026-06-12_FA-021-Notenbild.md`
- **Anforderungen klären oder Roadmap** → `01_Anforderungen/Lastenheft.md` (toc)

## Archive

Keine Dateien archiviert in diesem Optimierungslauf.

## Backup

Backup erstellt: `.context-optimizer-backup-20260612T120000/`
