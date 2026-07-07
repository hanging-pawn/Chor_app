---
context:
  read: full
  tokens: ~2600
  covers: [umsetzungsplan, phasen, prompts, modellwahl, einsingen]
  read_when: "Umsetzung der Funktion Einsingen planen, Prompt für eine Phase brauchen, Modellwahl klären"
  skip_when: "reine Anforderungsklärung (dafür Lastenheft.md)"
  updated: 2026-06-12
---

# Umsetzungsplan: Chorapp — Funktion «Einsingen»

Basis: `01_Anforderungen/Lastenheft.md` v1.1. Ziel ist die schrittweise, abnahmegetriebene Umsetzung der ersten Teilfunktion als statische PWA auf GitHub Pages.

## Leitprinzipien

- **Abnahmegetrieben:** Jede Phase erfüllt konkrete Anforderungen (FA/NF) und schliesst mit prüfbaren Abnahmekriterien (AK) ab.
- **MUSS zuerst:** Set-Generierung und Bibliothek (AK-001, AK-002, AK-004) haben Vorrang. Das Notenbild (AK-003, FA-021) ist entkoppelt und kann nachgereicht werden (Risiko R-002).
- **Daten getrennt vom Code:** Übungen liegen als JSON vor (AR-002, NF-020).
- **Kein Build-Step:** Vanilla HTML/CSS/JS, statisch auslieferbar (NF-004, AR-001).
- **Freigabe abwarten:** App-Code wird erst nach Freigabe von Lastenheft + diesem Plan generiert (CLAUDE.md).

## Phasenüberblick

| Phase | Inhalt | Deckt ab | Priorität |
|-------|--------|----------|-----------|
| 0 | Setup, Architektur, Datenmodell | AR-001, AR-002, NF-004 | MUSS |
| 1 | Übungs-Bibliothek (JSON) | FA-010–013, FA-030 | MUSS |
| 2 | Set-Generierung (Kernlogik) | FA-001–003, NF-001 | MUSS |
| 3 | Mobile UI / Darstellung | FA-020, FA-022, NF-001, NF-002 | MUSS |
| 4 | Eigene Übungen + Persistenz | FA-031, FA-032, NF-011 | SOLL |
| 5 | Notenbild Fünfliniensystem | FA-021 | SOLL (entkoppelt) |
| 6 | PWA-Schliff, Test, Doku, Deploy | NF-002, AK-005, Doku | MUSS |

---
Modell-Logik: **Opus 4.8** für Phase 1 (Übungsinhalte/Chordidaktik) und Phase 5 (Notensatz – aufwendigster Teil). **Sonnet 4.6** als Arbeitspferd für Logik/UI. **Haiku 4.5** für Routine (Doku, Formulare).
## Phase 0 — Setup & Architektur
**Opus 4.8**
**Ziel:** Lauffähiges, leeres Gerüst auf GitHub Pages; Datenmodell festgelegt.
**Aufgaben:** Repo-Struktur (`index.html`, `css/`, `js/`, `data/`), GitHub-Pages-Konfiguration, ADR zum Stack, JSON-Schema für eine Übung (id, kategorie, titel, anleitung, optional noten-Feld).
**Deliverable:** Deploybares Skelett + `02_Architektur/ADR-001_Stack.md`.
**Abnahme:** Seite ist über GitHub-Pages-URL erreichbar; leere App lädt ohne Fehler.

**Prompt:**
> Du baust eine statische PWA «Chorapp» für GitHub Pages (Vanilla HTML/CSS/JS, **kein Build-Step**). Lies `01_Anforderungen/Lastenheft.md`, Abschnitte 4 und 8. Erstelle: (1) das Dateigerüst `index.html`, `css/style.css`, `js/app.js`, `data/uebungen.json`; (2) ein dokumentiertes JSON-Schema für eine Übung mit Feldern `id`, `kategorie` (koerper|atem|stimme|abschluss), `titel`, `anleitung`, optional `noten` (für Phase 5); (3) eine GitHub-Pages-taugliche Minimal-`index.html`, die `app.js` lädt und «Chorapp» anzeigt; (4) `02_Architektur/ADR-001_Stack.md` mit Begründung. Halte dich an AR-001, AR-002, NF-004. App-Code ins Repo-Root, Doku in die Ordnerstruktur. Noch keine Logik — nur Gerüst.

**Modell:** **Sonnet 4.6** — Standard-Setup ohne kniffligen Trade-off; schnell und präzise genug.

---

## Phase 1 — Übungs-Bibliothek (Datenbasis)
**Opus 4.8**
**Ziel:** Inhaltliche Grund-Bibliothek mit didaktisch sinnvollen Übungen.
**Aufgaben:** `data/uebungen.json` füllen — Start mit ~6 Übungen je Kategorie, Zielumfang 12+ (FA-030, klein starten). Kategorien gemäss FA-010–013: Körper (aktivieren, Zwerchfell), Atem (Stütze, Bauchatmung), Stimme (Intervalle bis Oktave), Abschluss (kurzes Lied/Kanon).
**Deliverable:** Valides, erweiterbares JSON; `06_Dokumentation/Bibliothek-pflegen.md`.
**Abnahme:** JSON ist valid, jede Kategorie ausreichend besetzt, Anleitungen verständlich.

**Prompt:**
> Fülle `data/uebungen.json` nach dem in Phase 0 definierten Schema. Erzeuge je Kategorie **6 Übungen zum Start** (Zielumfang 12+, FA-030): **Körper** (Körper aktivieren, Zwerchfell aktivieren, spielerisch erlaubt), **Atem** (Zwerchfellatmung, Brustraum öffnen, Bauchatmung, Stütze), **Stimme** (Einsingübungen nach Intervallen aufbauend bis zur Oktave), **Abschluss** (einfaches kurzes Lied oder Kanon). Jede Übung: klare, praxistaugliche `anleitung` (2–4 Sätze) für eine Chorleiterin. Bei Stimmübungen das `noten`-Feld vorbereiten (z. B. Tonfolge in abc-Notation als Platzhalter), aber noch nicht rendern. Achte auf Validität und gute Durchmischung.

**Modell:** **Opus 4.8** — Inhaltsqualität ist hier der Hebel: chordidaktisch korrekte, abwechslungsreiche Übungen lohnen das stärkere Modell. *(Sonnet 4.6 als günstigere Alternative ausreichend, wenn du die Inhalte selbst gegenprüfst.)*

---

## Phase 2 — Set-Generierung (Kernlogik)
**Sonnet 4.6**
**Ziel:** Knopfdruck erzeugt ein gültiges Set.
**Aufgaben:** Funktion, die aus der Bibliothek 5–6 Übungen in der Reihenfolge Körper → Atem → Stimme → Abschluss zieht; je Kategorie ≥1, Abschluss ans Ende (FA-001–003). Zufallsauswahl genügt; optionales Meiden der letzten Übungen (FA-004) als Stretch.
**Deliverable:** `js/generator.js` + Konsolen-/Demo-Nachweis.
**Abnahme (AK-001, AK-002):** Set hat 5–6 Übungen, korrekte Reihenfolge, jede Kategorie vertreten, Abschluss zuletzt; Erzeugung < 1 s (NF-001).

**Prompt:**
> Implementiere in `js/generator.js` die Set-Generierung gemäss FA-001–003. Funktion `generateSet(uebungen)` gibt ein Array aus 5–6 Übungen zurück, strikt in der Reihenfolge **Körper → Atem → Stimme → Abschluss**, mit mindestens einer Übung je Kategorie und genau einer Abschluss-Einheit am Ende. Auswahl per Zufall. Optional (FA-004): die zuletzt gezeigten Übungen meiden, wenn ohne grossen Aufwand machbar. Schreibe dazu kompakte Unit-Tests (reines JS, ohne Framework), die Länge, Reihenfolge und Kategorienabdeckung über viele Durchläufe prüfen. Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — klar umrissene Logik mit Tests; ideales Sonnet-Profil.
done
---

## Phase 3 — Mobile UI & Darstellung
**Sonnet 4.6**
**Ziel:** Einhändig bedienbarer iPhone-Screen.
**Aufgaben:** Großer «Neues Set»-Button; Set als durchscroll-/blätterbare Liste mit Titel, Kategorie, Anleitung je Übung (FA-020, FA-022). Mobile-first, flüssig (NF-001, NF-002).
**Deliverable:** Fertiges `index.html` + `css/style.css`, an `generator.js` angebunden.
**Abnahme (AK-005):** Auf dem iPhone-Browser flüssig, einhändig, ohne Anleitung bedienbar.

**Prompt:**
> Baue das UI der Chorapp (mobile-first, iPhone). Lade zuerst den Skill **my-design-system**. Ein zentraler, großer «Neues Set»-Button erzeugt über `generateSet` ein Set und zeigt es als gut lesbare, scrollbare Karten-Liste: pro Übung Titel, Kategorie-Label und Anleitung (FA-020, FA-022). Einhändig bedienbar, Touch-Targets groß, sofortige Reaktion (< 1 s, NF-001/002). Keine externen Frameworks, reines HTML/CSS/JS. Halte das Notenbild als leeren Platz pro Stimmübung frei (kommt in Phase 5).

**Modell:** **Sonnet 4.6** — mit `my-design-system`-Skill; gutes Verhältnis aus Tempo und UI-Qualität.

---

## Phase 4 — Eigene Übungen & Persistenz
**Sonnet 4.6**
**Ziel:** Anja kann eigene Übungen ergänzen.
**Aufgaben:** Formular (Titel, Kategorie, Anleitung); Speicherung lokal im Browser (localStorage), Merge mit Grund-Bibliothek bei der Generierung (FA-031, NF-011). Bearbeiten/Löschen als KANN (FA-032).
**Deliverable:** UI-Formular + Persistenzschicht.
**Abnahme (AK-004):** Hinzugefügte Übung erscheint in der Generierung; bleibt nach Reload erhalten.

**Prompt:**
> Ergänze die Chorapp um eigene Übungen (FA-031). Formular für Titel, Kategorie, Anleitung; Speicherung in **localStorage** (NF-011, nichts verlässt das Gerät). Bei der Set-Generierung werden eigene + eingebaute Übungen zusammengeführt. Eigene Übungen bleiben nach Reload erhalten. Optional (FA-032): Bearbeiten und Löschen. Weise dezent darauf hin, dass lokaler Speicher gelöscht werden kann (R-003). UI im bestehenden Stil (my-design-system).

**Modell:** **Sonnet 4.6** — Standard-CRUD; **Haiku 4.5** möglich, wenn das UI-Muster aus Phase 3 schon klar steht.
done
---

## Phase 5 — Notenbild im Fünfliniensystem (entkoppelt) — ✅ Umgesetzt 2026-06-12
**Opus 4.8**
**Ziel:** Stimmübungen mit echtem Notenbild (FA-021).
**Status:** ✅ Umgesetzt mit **abcjs 6.6.0** (jsDelivr-CDN, async, nicht-blockierend gem. R-002). Details: `08_Meetings/2026-06-12_FA-021-Notenbild.md`.
**Aufgaben:** Notensatz-Bibliothek (z. B. **abcjs** oder **VexFlow**, via CDN ohne Build-Step) einbinden; `noten`-Feld je Stimmübung rendern. Aufwendigster Teil — bewusst nach den MUSS-Phasen (R-002).
**Deliverable:** Gerendertes Notenbild pro Stimmübung.
**Abnahme (AK-003):** Stimmübungen zeigen ein korrektes Notenbild; alle Übungen zeigen Titel und Anleitung.

**Prompt:**
> Setze FA-021 um: echtes Notenbild im Fünfliniensystem für Stimmübungen. Wähle eine CDN-fähige Notensatz-Bibliothek ohne Build-Step (Empfehlung: **abcjs**) und rendere das `noten`-Feld (abc-Notation) jeder Stimmübung an der in Phase 3 reservierten Stelle. Tonverlauf muss korrekt notiert sein. Fülle bei Bedarf fehlende `noten`-Felder der Intervallübungen sinnvoll (Intervalle aufbauend bis zur Oktave, FA-012). Saubere Darstellung auf schmalem iPhone-Screen. Diese Funktion darf die Set-Generierung nicht blockieren (R-002).

**Modell:** **Opus 4.8** — der technisch anspruchsvollste Teil (Musiknotation, Bibliotheks-Integration, musikalische Korrektheit). Stärkstes Modell empfohlen.

---

## Phase 6 — PWA-Schliff, Test, Doku, Deployment
**Sonnet 4.6**
**Ziel:** Abnahmereife.
**Aufgaben:** PWA-Manifest + «Zum Home-Bildschirm»-Tauglichkeit; Geräte-Test auf dem iPhone; Bedienungsanleitung (1 Seite, in-App), technische Pflegenotiz; finales GitHub-Pages-Deployment.
**Deliverable:** Live-App + `06_Dokumentation/Bedienung.md`.
**Abnahme (AK-005 + alle AK):** Nutzungstest mit Anja bestanden; vollständige Abnahme-Demo.

**Prompt:**
> Bring die Chorapp zur Abnahmereife. (1) PWA-Manifest + Icons, sodass die App auf dem iPhone «Zum Home-Bildschirm» hinzugefügt werden kann (NF-002). (2) Kurze Bedienungsanleitung (1 Seite, in der App erreichbar) und eine knappe technische Notiz `06_Dokumentation/Bibliothek-pflegen.md` zum Erweitern der Übungen. (3) Geh die Abnahmekriterien AK-001 bis AK-005 durch und liste pro Kriterium nach, wie es erfüllt ist. (4) Finalisiere das GitHub-Pages-Deployment. Melde offene Lücken klar zurück.

**Modell:** **Haiku 4.5** für Doku/Manifest/Routine; **Sonnet 4.6** für die Abnahme-Durchsicht.

---

## Modellwahl — Kurzfassung

| Phase | Empfehlung | Warum |
|-------|-----------|-------|
| 0 Setup | Sonnet 4.6 | Standard-Gerüst, kein Trade-off |
| 1 Bibliothek | **Opus 4.8** | Inhaltsqualität (Chordidaktik) zahlt sich aus |
| 2 Logik | Sonnet 4.6 | Klar umrissen, mit Tests |
| 3 UI | Sonnet 4.6 | Mit my-design-system-Skill |
| 4 Eigene Übungen | Sonnet 4.6 / Haiku 4.5 | Standard-CRUD |
| 5 Notenbild | **Opus 4.8** | Technisch anspruchsvollster Teil |
| 6 Schliff/Doku | Haiku 4.5 / Sonnet 4.6 | Routine + Abnahme-Review |

**Faustregel:** Opus 4.8 dort, wo Qualität/Komplexität entscheidet (Inhalte, Notensatz). Sonnet 4.6 als robustes Arbeitspferd für Logik und UI. Haiku 4.5 für Routine (Doku, einfache Formulare). Jede Phase in einer eigenen Session mit dem oben genannten Prompt starten.

## Empfohlene Reihenfolge

0 → 1 → 2 → 3 (MUSS-Kern, abnahmefähig nach Phase 3+4) → 4 → 6 für eine erste lauffähige Version, dann **5** als Ausbaustufe. So ist die Kernfunktion früh demonstrierbar (R-002), das Notenbild folgt entkoppelt.
