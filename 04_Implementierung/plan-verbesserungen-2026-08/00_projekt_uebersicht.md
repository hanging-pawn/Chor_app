# Projektübersicht: Chor_App — Verbesserungen Einsingen & Proben (2026-08)

## Metadaten

| Feld | Inhalt |
|------|--------|
| Projektname | Chor_App Verbesserungen 2026-08 |
| Startdatum | 2026-08-01 |
| Zieldatum | offen |
| Status | Aktiv |
| Typ | Erweiterung (Brownfield) |
| Komplexität | Klein (5 APs) |

## Projektziel

Umsetzung der drei offenen Rückmeldungen von Anja zur Chor_App: (1) die Einsingen-Seite auf das gewohnte Layout umbauen (Probennotiz → Warm-up → zu probende Lieder mit Notizzeile pro Song), (2) einen neuen To-Do-Reiter mit abhakbaren Punkten, (3) eine „Dem Pianisten mitteilen"-Funktion mit Pianisten-Dropdown, die nur die Liederliste einer Probe/eines Konzerts versendet. Zwei weitere Rückmeldungen (Kanon-Noten, „nächste Probe") sind bereits umgesetzt und gepusht.

## Kontext (bereits erledigt, nicht Teil dieses Plans)

- **#1 Kanon-Noten:** ABC-Notation für Frère Jacques, Dona nobis pacem, Jubilate Deo ergänzt (abcjs). Kookaburra + „Make new friends" bewusst ohne Noten (Urheberrecht / keine gemeinfreie Quelle).
- **#2 Nächste Probe:** `loadHeuteAndRender` zeigt jetzt die kommende Probe (`.gte(datum, heute)`), Titel dynamisch.
- Beides ist in `index.html` committet und via GitHub Pages gepusht.

## Deliverables

| # | Deliverable | Phase | Status |
|---|-------------|-------|--------|
| 1 | Einsingen-Seite: Probennotiz oben + Reihenfolge Notizen→Warm-up→Lieder | 03_umsetzung | [ ] offen |
| 2 | Notizzeile pro Lied in der Probenliste + Migration `proben_lieder.notiz` | 03_umsetzung | [ ] offen |
| 3 | To-Do-Reiter + Migration `todos` | 03_umsetzung | [ ] offen |
| 4 | Pianisten-Mitteilung + Verwaltung + Migration `pianisten` | 03_umsetzung | [ ] offen |
| 5 | Verifikation, Test & Deploy | 04_qualitaet | [ ] offen |

## Projektphasen & Fortschritt

| Phase | Ziel | APs | Fortschritt |
|-------|------|-----|-------------|
| 03_umsetzung | Die drei Features implementieren | 4 | [ ] |
| 04_qualitaet | Verifizieren, testen, deployen | 1 | [ ] |

## Rahmenbedingungen

### Technologien

- **Vanilla HTML/CSS/JS**, komplett inline in `index.html` (~7.6k Zeilen). `js/*.js` ist totes Alt-Gerüst — nicht anfassen.
- **Supabase** (PostgreSQL, Frankfurt) als Backend. Client lazy-initialisiert via `getSupabase()`. Alle Queries mit `.eq('chor_id', APP_STATE.chorId)` gefiltert.
- **GitHub Pages** Deploy via `.github/workflows/deploy.yml` bei Push auf `main`.

### Ressourcen

- Claude / KI-Tools: **Claude Code** (Code/Repo/Terminal) für alle Umsetzungs-APs. Cowork für Nicht-Code entfällt hier.
- Menschliche Arbeit: SQL-Migrationen im Supabase-SQL-Editor ausführen; Git-Commit/Push vom Mac; Live-Sichtprüfung am iPhone.

### Einschränkungen

- CLAUDE.md: App-Code gehört ins Repo-Root; Supabase-Tabellen erst mit der zugehörigen Funktion anlegen; kein API-Key in den Claude-Kontext.
- Git-Repo liegt im iCloud-Vault → Git-Operationen nur auf dem echten Mac, nicht aus der Cowork-Sandbox.

## Abhängigkeiten & Risiken

| # | Abhängigkeit / Risiko | Auswirkung | Massnahme |
|---|-----------------------|------------|-----------|
| 1 | Migrationen müssen VOR dem zugehörigen Code-Feature in Supabase laufen | Mittel | Jeder Umsetzungsprompt enthält den manuellen Supabase-Schritt zuerst |
| 2 | Änderungen an der grossen `index.html` können bestehende Views brechen | Mittel | Nach jedem AP `node --check` über den Inline-Script + Sichtprüfung |
| 3 | „Notizen kommen alle zusammen": eine Datenquelle (`probennotizen`) für Einsingen-Seite und Notiz-Tab | Mittel | AP-0301 koppelt an dieselbe datumsgebundene Zeile, keine zweite Wahrheit |
| 4 | Git-in-iCloud kann Objekte beschädigen | Niedrig–Mittel | Mittelfristig Repo aus iCloud nehmen (separates AP/Empfehlung) |

## Offene Punkte

Alle am 2026-08-01 entschieden:

| # | Frage | Entscheidung |
|---|-------|--------------|
| 1 | Bleibt der separate Notiz-Tab bestehen? | Ja — behalten (zeigt Notiz-Historie, gleiche Datenquelle) |
| 2 | To-Do: Umfang? | Einfach & chor-gebunden, ohne Fälligkeitsdatum/Priorität |
| 3 | Pianisten-Versand? | Bestehende E-Mail-Funktion `callSendEmail` (nicht `mailto:`) |

## Verlinkung Arbeitspakete

### 03 Umsetzung
- [x] [AP-0301 Einsingen-Layout](03_umsetzung/AP-0301_einsingen_layout.md) — Code fertig (Live-Test offen) · Prompt: `AP-0301_prompt.md`
- [ ] [AP-0302 Notizzeile pro Lied](03_umsetzung/AP-0302_notizzeile_pro_lied.md) — Prompt: `AP-0302_prompt.md`
- [ ] [AP-0303 To-Do-Reiter](03_umsetzung/AP-0303_todo_reiter.md) — Prompt: `AP-0303_prompt.md`
- [ ] [AP-0304 Pianisten-Mitteilung](03_umsetzung/AP-0304_pianisten_mitteilung.md) — Prompt: `AP-0304_prompt.md`

### 04 Qualität
- [ ] [AP-0401 Verifikation & Deploy](04_qualitaet/AP-0401_verifikation_deploy.md) — Prompt: `AP-0401_prompt.md`

## Empfohlene Reihenfolge

1. **AP-0301** (Einsingen-Layout, keine Migration) — sofort startbar.
2. **AP-0302** (Notizzeile/Lied, Migration `proben_lieder.notiz`) — nach 0301.
3. **AP-0303** (To-Do) und **AP-0304** (Pianisten) — unabhängig, in beliebiger Reihenfolge.
4. **AP-0401** (QS & Deploy) — am Ende jedes Features bzw. gesammelt.
