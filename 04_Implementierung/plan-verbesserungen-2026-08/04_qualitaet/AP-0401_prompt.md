# Umsetzungsprompt — AP-0401: Verifikation, Test & Deploy

**Ausführungsumgebung:** Claude Code für Syntaxprüfung; Git-Commit/Push und Supabase-Migrationen sind manuelle Nutzer-Schritte.
**Modell-Empfehlung:** Claude – mittleres
**Grösse:** S
**Voraussetzung:** AP-0301 bis AP-0304 umgesetzt; Migrationen 005/006/007 in Supabase ausgeführt.

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App. Verifiziere die Umsetzung der Features aus AP-0301 bis AP-0304 in index.html und
erstelle ein kurzes Testprotokoll.

1. Extrahiere den Inline-<script>-Block aus index.html und führe `node --check` aus — muss
   fehlerfrei sein.
2. Erstelle das Protokoll
   04_Implementierung/plan-verbesserungen-2026-08/04_qualitaet/AP-0401_verifikation_deploy_output.md
   mit: node-check-Ergebnis, einer Checkliste der manuellen Sichtprüfungen (Einsingen-Reihenfolge
   Notizen→Warm-up→Lieder; Pro-Lied-Notiz persistiert; To-Do add/toggle/delete; Pianisten-
   Mitteilung enthält nur Lieder; 6 Alt-Tabs unverändert), und einem Feld für Deploy-Status.
```

## Manuelle Schritte (Nutzer, auf dem Mac)

1. Sicherstellen, dass die Migrationen 005/006/007 im Supabase-SQL-Editor gelaufen sind.
2. Sichtprüfung im Browser/iPhone gemäss Checkliste durchgehen.
3. Deploy:
   ```
   cd "/Users/gianlucalarocca/Library/Mobile Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App"
   git add -A
   git commit -m "Verbesserungen: Layout, Notizzeile, To-Do, Pianisten-Mitteilung"
   git push
   ```
4. github.com → Actions: Deploy-Lauf grün? Settings → Pages → Source = „GitHub Actions".
5. Live prüfen: `https://hanging-pawn.github.io/Chor_app` (Cache umgehen).

## Nach Ausführung (verbindlich)

1. Protokoll-Datei ausfüllen; Dokumentations-Block in `AP-0401_verifikation_deploy.md` setzen.
2. Prompt nach `…/04_qualitaet/archiv/AP-0401_prompt.md` verschieben.
3. Übersicht auf abgeschlossen setzen; ggf. Projektabschluss (`templates/project_closure.md`) erstellen.
