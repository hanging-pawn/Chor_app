# Umsetzungsprompt — AP-0404: Toter Code / Generator-Konsolidierung

**Umgebung:** Claude Code (Repo-Root) · **Modell:** mittel–gross · **Grösse:** L
**Voraussetzung:** AP-0403 empfohlen zuerst (kleinere Diffs in index.html).

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App (statische PWA, kein Build-Step). Befund aus Code Review 2026-08-15 (#5):
js/generator.js, js/app.js, data/uebungen.json werden von index.html nirgends
eingebunden — toter Code. Die Tests (05_Tests/generator.test.js, 5199 Assertions)
testen dieses tote Modul; die Live-Inline-Version (index.html ca. Z. 4934, generateSet)
weicht ab und hat KEINE Wiederholungsvermeidung (FA-004).

Entscheidung: Live-Inline-Logik ist massgeblich. Aufgaben:

1. FA-004 in den Inline-Generator übernehmen: recentIds der letzten 2 Sets in
   localStorage (try/catch wie bei den anderen localStorage-Zugriffen), Auswahl
   bevorzugt nicht-kürzlich-verwendete Übungen, graceful fallback bei kleinem Pool.
   Das Muster steht in js/generator.js (dort getestet) — übernehmen, an die
   Live-Kategorien (körper/atem/stimme/kanon) anpassen.
2. Reine Logik (Set-Bau, Pool-Filter, Recent-Logik) in neue Datei js/einsingen-core.js
   auslagern: von index.html per <script src="js/einsingen-core.js"> VOR dem Inline-
   Script laden, und per UMD-Mini-Pattern (wie js/generator.js) von Node requirebar.
   POOL bleibt in index.html und wird als Parameter übergeben.
3. 05_Tests/generator.test.js auf js/einsingen-core.js umschreiben. Erwartungen an
   die Live-Logik anpassen (6 Übungen 1+1+3+1, Live-Kategorien, FA-004-Recent-Test).
4. Toten Code löschen: js/generator.js, js/app.js, data/uebungen.json,
   data/uebungen.schema.json. js/supabase.js und css/style.css nur löschen, wenn
   wirklich nirgends referenziert (grep) — sonst behalten und CLAUDE.md-Hinweis prüfen.
5. .github/workflows/deploy.yml: vor dem Pages-Upload einen Step einfügen:
   - name: Tests
     run: node 05_Tests/generator.test.js

Verifikation: node 05_Tests/generator.test.js grün; node --check auf extrahiertem
Inline-Script; App-Smoke-Test: Set generieren, 2x hintereinander → kaum Wiederholungen.
```

## Nach Ausführung (verbindlich)

1. Doku-Block in `AP-0404_toter_code_generator.md` ausfüllen, Status setzen.
2. Prompt nach `…/04_qualitaet/archiv/` verschieben. Übersicht/Dashboard aktualisieren.
