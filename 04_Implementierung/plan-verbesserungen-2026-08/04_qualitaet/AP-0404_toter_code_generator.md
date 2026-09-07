# AP-0404: Toten Code konsolidieren — Generator, FA-004, Tests in CI

## Ziel

Es gibt nur noch **eine** Generator-Implementierung; FA-004 (Wiederholungsvermeidung) ist im Produkt wirksam; die Tests prüfen den Live-Code und laufen vor jedem Deploy. Schliesst Review-Befund 5 (Hoch) und Teil von 15.

## Kontext

`js/generator.js`, `js/app.js`, `js/supabase.js`, `css/style.css`, `data/uebungen.json` werden von index.html **nirgends eingebunden** — toter Code aus der Gerüst-Phase. Tückisch: `js/generator.js` ist mit 5'199 grünen Assertions getestet und implementiert FA-002–004, während die *live* laufende Inline-Version (index.html Z. 4934) abweicht: fix 1+1+3+1 statt 5–6 Übungen, Kategorien `körper/kanon` statt `koerper/abschluss`, **keine** Wiederholungsvermeidung. Die grüne Test-Suite erzeugt falsche Sicherheit. `deploy.yml` hat keinen Test-Step.

## Entscheidung (Default)

Die Inline-Version ist die fachlich aktuelle (Kanon-Noten, POOL inline). Daher: **Tests auf die Live-Logik umschreiben, FA-004 in die Inline-Version übernehmen, toten Code löschen.** (Alternative — Modul wieder einbinden — nur falls sich beim Umsetzen zeigt, dass die Inline-Logik dupliziert werden müsste.)

## Umsetzungsschritte

1. FA-004 in den Inline-Generator übernehmen: `recentIds` in localStorage (letzte 2 Sets), Auswahl bevorzugt Übungen, die nicht in `recentIds` sind; graceful fallback wenn Pool zu klein. Muster aus `js/generator.js` übernehmen.
2. Generator-Logik testbar machen: die reinen Funktionen (Set-Bau, Pool-Filter, Recent-Logik) in `js/einsingen-core.js` auslagern, von index.html per `<script src>` einbinden **und** von Node aus requirebar machen (UMD-Mini-Pattern wie in js/generator.js).
3. `05_Tests/generator.test.js` auf die neue Datei umschreiben (Kategorien der Live-Version!); alte Erwartungen (5–6, koerper/abschluss) an die Realität anpassen oder als bewusste Abweichung im Lastenheft-Abgleich dokumentieren.
4. Toten Code löschen: `js/generator.js`, `js/app.js`, `data/uebungen.json` (`js/supabase.js` prüfen — laut CLAUDE.md dort referenziert; nur löschen wenn wirklich uneingebunden, sonst CLAUDE.md aktualisieren).
5. `deploy.yml`: Test-Step `node 05_Tests/generator.test.js` vor dem Pages-Upload.

## Abnahmekriterien

- [ ] Zwei aufeinanderfolgende Generierungen wiederholen höchstens 1 Übung (FA-004, localStorage).
- [ ] Tests laufen grün gegen den Code, den die App tatsächlich lädt.
- [ ] Kein uneingebundenes JS/JSON mehr im Repo (oder begründet in CLAUDE.md).
- [ ] Deploy schlägt fehl, wenn Tests fehlschlagen.

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel–gross (Refactoring mit Testumbau) · **Grösse**: L

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen**: {keine / Beschreibung}

## Status

- [x] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
