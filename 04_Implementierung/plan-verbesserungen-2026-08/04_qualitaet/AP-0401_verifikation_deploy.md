# AP-0401: Verifikation, Test & Deploy

## Ziel

Die umgesetzten Features prüfen (Syntax, Funktion, keine Regression) und live auf GitHub Pages bringen.

## Kontext

Kein automatisiertes Test-Setup vorhanden; Verifikation erfolgt über `node --check` des extrahierten Inline-Scripts, ggf. abcjs-`parseOnly` bei Notation, und manuelle Sichtprüfung am iPhone/Browser. Deploy via GitHub Actions bei Push auf `main`. **Git läuft nur auf dem echten Mac** (Repo im iCloud-Vault); Commit/Push sind manuelle Schritte.

## Inputs

| Typ | Quelle / Inhalt |
|-----|----------------|
| Datei | `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/index.html` |
| Info | Migrationen aus AP-0302/0303/0304 müssen VOR dem Live-Test in Supabase ausgeführt sein. |
| Referenz | `.github/workflows/deploy.yml`; Repo-Settings → Pages → Source = „GitHub Actions". |

## Umsetzungsschritte

1. Inline-Script aus `index.html` extrahieren und `node --check` laufen lassen — muss fehlerfrei sein.
2. Manuell im Browser prüfen: Einsingen-Reihenfolge (Notizen→Warm-up→Lieder), Pro-Lied-Notiz persistiert, To-Do hinzufügen/abhaken/löschen, Pianisten-Mitteilung enthält nur Lieder. Die 6 Alt-Tabs stichprobenartig gegenprüfen.
3. Sicherstellen, dass alle Migrationen (`005`,`006`,`007`) im Supabase-SQL-Editor ausgeführt wurden.
4. **Manueller Git-Schritt (Mac):** im Projektordner `git add -A && git commit -m "…" && git push`.
5. Auf github.com unter „Actions" prüfen, ob der Deploy-Lauf grün ist; Settings → Pages → Source = „GitHub Actions" bestätigen.
6. Live prüfen: `https://hanging-pawn.github.io/Chor_app` (Cache umgehen).

## Output

**Datei**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/04_Implementierung/plan-verbesserungen-2026-08/04_qualitaet/AP-0401_verifikation_deploy_output.md` (kurzes Testprotokoll)
**Format**: Markdown
**Muss enthalten**:
- Ergebnis `node --check`.
- Checkliste der manuellen Sichtprüfungen (bestanden/nicht).
- Bestätigung Deploy grün + Live-URL geprüft.

## Abnahmekriterien

- [ ] `node --check` fehlerfrei.
- [ ] Alle vier Features manuell verifiziert und im Protokoll abgehakt.
- [ ] Actions-Deploy-Lauf grün; Live-Seite zeigt die neuen Features.
- [ ] Testprotokoll-Datei existiert unter dem Output-Pfad.

## Voraussetzungen

| AP-ID | Warum benötigt |
|-------|----------------|
| AP-0301 | Feature muss umgesetzt sein. |
| AP-0302 | Feature + Migration `proben_lieder.notiz`. |
| AP-0303 | Feature + Migration `todos`. |
| AP-0304 | Feature + Migration `pianisten`. |

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code für `node --check`/Extraktion; Git-Commit/Push und Supabase-Migrationen sind manuelle Schritte des Nutzers.
**Modell (Empfehlung)**: Claude – mittleres

## Grösse

**Schätzung**: S

**Begründung**: Prüfen + Protokoll; die eigentliche Arbeit steckt in den Umsetzungs-APs.

## Notizen / Offene Punkte

> ⚠️ OFFEN: Kann pro Feature einzeln deployt werden (empfohlen) oder gesammelt am Ende? Beides möglich.

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen von den Umsetzungsschritten**: {keine / Beschreibung}
- **Tatsächlicher Output-Pfad**: `/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App/04_Implementierung/plan-verbesserungen-2026-08/04_qualitaet/AP-0401_verifikation_deploy_output.md`
- **Verbleibende offene Punkte**: {keine / Verweis}

## Status

- [ ] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
- [ ] Abgelehnt / neu planen
