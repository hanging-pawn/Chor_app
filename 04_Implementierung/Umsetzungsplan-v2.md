---
context:
  read: full
  tokens: ~5800
  covers: [umsetzungsplan-v2, phasen, prompts, modellwahl, supabase, mehrchor, repertoire, jahresplanung, mitglieder, buchhaltung, auth, email]
  read_when: "Umsetzung einer V2-Teilfunktion planen, Prompt für eine Phase brauchen, Modellwahl klären"
  skip_when: "Funktion Einsingen (v1.0) — dafür Umsetzungsplan.md"
  updated: 2026-06-12
---

# Umsetzungsplan v2: Chorapp — Erweiterungen nach Einsingen

Basis: `01_Anforderungen/Lastenheft.md` v1.6 und `01_Anforderungen/2026-06-12_Anforderungen-Erweiterung-v2.md`. Aufbauend auf v1.0 (Einsingen vollständig umgesetzt, AK-001–003 ✅, AK-004 ❌ offen, AK-005 🔲 ausstehend).

## Was v1.0 hinterlässt

| Bestand | Status | Datei |
|---------|--------|-------|
| Set-Generierung (FA-001–003) | ✅ | `index.html`, `js/generator.js` |
| Übungs-Bibliothek JSON | ✅ | `data/uebungen.json` |
| Notenbild abcjs (FA-021) | ✅ | `index.html` |
| PWA-Manifest, Icons | ✅ | `manifest.json`, `icons/` |
| GitHub Pages Deployment | ✅ | `.github/workflows/deploy.yml` |
| Supabase-Config | ✅ (leer) | `js/supabase.js` |
| **Eigene Übungen (FA-031)** | ❌ **Nicht implementiert** | — |

> **Priorität 0 dieser Planung:** FA-031 ist AK-004 — offener Abnahme-Restpunkt aus v1.0.

---

## Leitprinzipien

- **Schrittweise Aktivierung von Supabase:** Tabellen werden genau dann angelegt, wenn die zugehörige Teilfunktion beginnt (CLAUDE.md-Vorgabe).
- **Mehrchor ab Phase 1-V2:** Alle neuen Daten (Notizen, Repertoire, Mitglieder) sind von Anfang an einer `chor_id` zugeordnet — so ist keine Migration nötig.
- **Auth erst bei Personendaten (Phase 5-V2):** Bis v1.3 kein Login nötig; ab v2.0 (Mitglieder) wird Supabase Auth eingeführt — RLS auf alle Tabellen nachziehen.
- **Desktop/Mobile-Split ab Phase 1-V2:** Navigation und Layout trennen Planungsmodus (PC) von Durchführungsmodus (iPhone/iPad).
- **Daten immer getrennt vom Code** (AR-002): Supabase-Schemas als SQL-Migrations-Skripte im Repo ablegen.

---

## Phasenüberblick

| Phase | Version | Inhalt | Deckt ab | Modell |
|-------|---------|--------|----------|--------|
| 0-V2 | v1.1 | Navigation, Multi-Chor-Fundament | FA-000, FA-001a–e | Sonnet 4.6 |
| 1-V2 | v1.1 | Eigene Übungen + Audio-Vorbereitung | FA-031, FA-032, AK-004 | Haiku 4.5 |
| 2-V2 | v1.1 | Notizfeld Chorprobe | FA-040–042 | Sonnet 4.6 |
| 3-V2 | v1.2 | Repertoireliste + Tagesprobe-Ansicht | FA-050–055 | **Opus 4.8** |
| 4-V2 | v1.3 | Jahresplanung | FA-070–073 | Sonnet 4.6 |
| 5-V2 | v2.0 | Supabase Auth + RLS | NF-014, NF-013 | **Opus 4.8** |
| 6-V2 | v2.0 | Mitgliederliste | FA-080, FA-081 | Sonnet 4.6 |
| 7-V2 | v2.0 | Buchhaltung + PDF-Abrechnung | FA-085–098 | **Opus 4.8** |
| 8-V2 | v2.0 | E-Mail-Versand | FA-100–104 | Sonnet 4.6 |
| 9-V2 | v2.x | Audio-Übungen | FA-060, FA-061 | Sonnet 4.6 |

---

## Phase 0-V2 — Navigation & Multi-Chor-Fundament
**Sonnet 4.6**

**Ziel:** Die App erhält eine persistente Navigation und die Datenarchitektur unterstützt mehrere Chöre. Alle nachfolgenden Phasen bauen darauf auf.

**Aufgaben:**
- Bottom-Navigation (Mobile) / Sidebar (Desktop): Einsingen | Probennotizen | Repertoire | Jahresplan | Mitglieder
- Aktivitätsstatus pro Tab (aktuell aktiv, noch nicht implementiert → ausgegraut/gesperrt)
- Multi-Chor-Selektor: `chor_id` als globaler App-State; Wechsel oben in der Navigation (FA-000, FA-001a)
- Supabase-Tabelle `choere` anlegen (id, name, erstellt_am)
- Eingebaute Chöre-Daten (Start: 1 Chor per Default, erweiterbar)
- Breakpoint-Logik: `window.innerWidth > 900` → Planungsmodus-Layout; kleiner → Durchführungsmodus (FA-001c/d)

**Deliverable:** Navigierbare Shell mit aktiver Einsingen-Seite; Chor-Auswahl funktioniert; restliche Tabs sind Platzhalter.

**Abnahme:** Chor wechseln lässt Titel in der Navigation ändern; Tabs sind erreichbar; Layout wechselt bei Viewport-Änderung.

**Prompt:**
> Die Chorapp hat eine lauffähige Einsingen-Funktion (v1.0). Lies `CLAUDE.md`, `04_Implementierung/Umsetzungsplan.md` (Phase 0–6) und `01_Anforderungen/Lastenheft.md` Abschnitte 4–6.0.
>
> Deine Aufgabe: App-Navigation + Multi-Chor-Fundament (Phase 0-V2).
>
> **Navigation:** Füge eine persistente Bottom-Navigation (Mobile) und eine Sidebar (Desktop, Breakpoint 900 px) ein mit den Tabs: Einsingen (aktiv), Probennotizen (Platzhalter), Repertoire (Platzhalter), Jahresplan (Platzhalter), Mitglieder (Platzhalter). Platzhalter-Tabs sind sichtbar, aber noch nicht navigierbar — visuell als «coming soon» markiert.
>
> **Multi-Chor:** Füge einen Chor-Selektor in den Header ein (Dropdown mit Chorname). Erzeuge eine Supabase-Tabelle `choere (id uuid primary key, name text not null, erstellt_am timestamptz default now())` und lege einen Default-Chor «Mein Chor» an, falls die Tabelle leer ist. Speichere den aktiven `chor_id` im App-State (globale Variable) und zeige den Chornamen im Header.
>
> **Layout-Split:** Desktop (>900 px) zeigt das Planungsmodus-Layout (Sidebar, mehr Platz, tabellarisch). Mobile zeigt das Durchführungsmodus-Layout (Bottom-Nav, Karten, grosse Touch-Targets). Die Einsingen-Funktion bleibt unverändert.
>
> Lege das SQL-Migration-Skript unter `db/migrations/001_choere.sql` ab. Code-Kommentare auf Englisch. Lade den Skill `my-design-system` für die Navigation.

**Modell:** **Sonnet 4.6** — Architektur klar definiert; Sonnet setzt das präzise um.

---

## Phase 1-V2 — Eigene Übungen (AK-004 schliessen)
**Haiku 4.5**

**Ziel:** Anja kann eigene Einsingübungen erfassen. Schliesst den offenen Abnahme-Punkt AK-004.

**Aufgaben:**
- Formular: Titel, Kategorie (Körper/Atem/Stimme/Abschluss), Anleitung
- Speicherung in `localStorage` (NF-011 — bleibt auf Gerät, kein Supabase nötig)
- Merge mit eingebauter Bibliothek bei `generateSet()`
- Bearbeiten + Löschen (FA-032, KANN)
- Hinweis-Text: «Eigene Übungen sind gerätespezifisch — sie bleiben erhalten, bis der Browser-Cache geleert wird.» (R-003)

**Deliverable:** Funktionierendes Formular; hinzugefügte Übung erscheint im nächsten Set; Reload-sicher.

**Abnahme (AK-004):** Anja fügt eine eigene Übung hinzu → sie erscheint in der Set-Generierung → bleibt nach Reload erhalten.

**Prompt:**
> Die Chorapp hat eine lauffähige Einsingen-Funktion und Navigation (Phase 0-V2). Lies `04_Implementierung/Umsetzungsplan.md` Phase 4 und `01_Anforderungen/Lastenheft.md` FA-031, FA-032.
>
> Deine Aufgabe: Eigene Übungen (FA-031/032) — schliesst AK-004.
>
> Füge im Tab «Einsingen» einen «+ Übung hinzufügen»-Button ein. Formular-Felder: Titel (Text), Kategorie (Select: Körper/Atem/Stimme/Abschluss), Anleitung (Textarea). Speicherung in `localStorage` unter Key `eigeneUebungen`. Beim Aufruf von `generateSet()` werden eigene + eingebaute Übungen zusammengeführt — eigene Übungen nehmen an der Zufallsauswahl teil. Liste der eigenen Übungen anzeigen mit Bearbeiten- und Löschen-Funktion (FA-032). Zeige einen dezenten Hinweis auf die Gerätegebundenheit (R-003). UI im Stil der bestehenden App (my-design-system). Code-Kommentare auf Englisch.

**Modell:** **Haiku 4.5** — Standard-CRUD mit klar definiertem Muster; schnell und ausreichend.

---

## Phase 2-V2 — Notizfeld Chorprobe (v1.1)
**Sonnet 4.6**

**Ziel:** Für jede Probe gibt es ein Notizfeld — schnell erreichbar, persistent.

**Aufgaben:**
- Supabase-Tabelle `probennotizen (id, chor_id, datum, inhalt, markiert, erstellt_am)`
- Tab «Probennotizen» aktivieren
- Mobile: Aktuelles Datum vorgewählt; grosses Textarea; Speichern-Button
- Desktop: Notiz-Liste links, Editor rechts (split view)
- Vergangene Notizen abrufbar (chronologisch, FA-041)
- Punkte markieren (toggle, FA-042)

**Deliverable:** Notizen werden in Supabase gespeichert und sind auf PC und iPhone sichtbar.

**Abnahme:** Notiz auf PC erfassen → auf iPhone sichtbar; vergangene Notizen abrufbar.

**Prompt:**
> Die Chorapp hat Navigation + Multi-Chor + eigene Übungen. Lies `01_Anforderungen/Lastenheft.md` FA-040–042 und `02_Architektur/ADR-001_Stack.md` (Supabase-Config in `js/supabase.js`).
>
> Deine Aufgabe: Notizfeld Chorprobe (Phase 2-V2).
>
> **Supabase:** Lege Tabelle `probennotizen (id uuid default gen_random_uuid() primary key, chor_id uuid references choere(id), datum date not null, inhalt text, markiert boolean default false, erstellt_am timestamptz default now())` an. SQL-Migrationsskript: `db/migrations/002_probennotizen.sql`.
>
> **Mobile-UI (Durchführungsmodus):** Tab «Probennotizen» zeigt ein grosses Textarea mit dem aktuellen Datum als Titel (änderbar), Speichern-Button. Darunter: scrollbare Liste vergangener Notizen als kompakte Karten (Datum + erste 80 Zeichen), antippen öffnet die Notiz zum Lesen/Bearbeiten.
>
> **Desktop-UI (Planungsmodus):** Zwei-Spalten-Layout: links Notizliste, rechts Editor. Jede Notiz hat einen Markierungs-Toggle (☑ «Dem Chor mitteilen», FA-042). Markierte Notizen sind visuell hervorgehoben.
>
> Daten immer gefiltert nach aktivem `chor_id`. Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — klar definiertes CRUD mit Supabase-Anbindung.

---

## Phase 3-V2 — Repertoireliste & Tagesprobe-Ansicht (v1.2)
**Opus 4.8**

**Ziel:** Vollständige Liedverwaltung mit PDF-Noten und die zentrale Tagesprobe-Ansicht auf dem iPhone.

**Aufgaben:**
- Supabase-Tabellen: `lieder (id, chor_id, titel, status, pdf_pfad, erstellt_am)` + `proben_lieder (id, chor_id, datum, lied_id, reihenfolge)`
- Supabase Storage Bucket `noten-pdfs` (mit RLS: anon kann lesen, kein Auth nötig bis v2.0)
- Desktop: Repertoire-Liste (alle Lieder), CRUD, Status-Badge (in Bearbeitung / einstudiert / konzertbereit), PDF-Upload
- Desktop: Probe planen — Datum wählen + Lieder aus Repertoire per Drag-or-checkbox zuordnen
- **Mobile (Durchführungsmodus, FA-052):** Tagesprobe-Ansicht = generiertes Einsing-Set + geplante Lieder des heutigen Datums mit «Noten öffnen»-Button (öffnet PDF aus Storage in neuem Tab)
- PDF-Uploader (nur im Desktop-Planungsmodus, FA-054)

**Deliverable:** Anja plant die Probe am PC → iPhone zeigt heute Einsingen + geplante Lieder mit Noten-Link.

**Abnahme:** Lied anlegen + PDF hochladen am PC → Lied erscheint in Tagesprobe-Ansicht auf iPhone; PDF öffnet korrekt.

**Prompt:**
> Die Chorapp hat Navigation, Notizfeld und eigene Übungen. Lies `01_Anforderungen/Lastenheft.md` FA-050–055 und `02_Architektur/ADR-001_Stack.md`.
>
> Deine Aufgabe: Repertoireliste + Tagesprobe-Ansicht (Phase 3-V2) — die komplexeste Phase.
>
> **Supabase-Tabellen:**
> ```sql
> lieder (id uuid default gen_random_uuid() primary key, chor_id uuid references choere(id),
>   titel text not null, status text check (status in ('bearbeitung','einstudiert','konzertbereit')) default 'bearbeitung',
>   pdf_pfad text, erstellt_am timestamptz default now())
>
> proben_lieder (id uuid default gen_random_uuid() primary key, chor_id uuid references choere(id),
>   datum date not null, lied_id uuid references lieder(id), reihenfolge int default 0)
> ```
> Storage Bucket `noten-pdfs` (public read). SQL unter `db/migrations/003_repertoire.sql`.
>
> **Desktop — Repertoire-Tab:**
> Liste aller Lieder des aktiven Chors. Spalten: Titel, Status (farbiges Badge), «Noten»-Chip (zeigt ob PDF vorhanden). CRUD: Lied hinzufügen/bearbeiten/löschen. PDF-Upload beim Bearbeiten → Upload in Supabase Storage unter Pfad `{chor_id}/{lied_id}.pdf`, Pfad in `pdf_pfad` speichern.
>
> **Desktop — Probe planen (Unteransicht im Repertoire-Tab):**
> Datum-Picker + Checkbox-Liste des Repertoires. Gespeicherte Probe erscheint als «Heute» oder Datum-Label in der Liste.
>
> **Mobile — Tagesprobe-Ansicht:**
> Hauptscreen (ersetzt oder ergänzt den Einsingen-Tab): Sektion 1 «Einsingen» (generiertes Set, wie bisher, aber kompakter). Sektion 2 «Heute» (Lieder der heutigen Probe in ihrer Reihenfolge). Jede Lied-Karte zeigt Titel, Status-Badge, und einen «Noten öffnen»-Button der die PDF-URL aus Storage öffnet. Wenn keine Probe für heute geplant: leerer Zustand mit Hinweis «Noch keine Lieder für heute geplant».
>
> Lede den Skill `my-design-system`. Alle Daten nach `chor_id` gefiltert. Code-Kommentare auf Englisch.

**Modell:** **Opus 4.8** — Supabase Storage-Integration, PDF-Upload, komplexe Tagesprobe-UX mit zwei Sektionen; hier entscheidet die Qualität.

---

## Phase 4-V2 — Jahresplanung (v1.3)
**Sonnet 4.6**

**Ziel:** Anja führt alle Auftritte, Probendeadlines und Ideen in der App.

**Aufgaben:**
- Supabase-Tabellen: `termine (id, chor_id, datum, titel, typ, notiz)` + `termine_lieder (termin_id, lied_id)` + `ideen (id, chor_id, inhalt, erstellt_am)`
- Desktop: Kalender- oder Listenansicht (Toggle), Termin hinzufügen, Lieder zuordnen (aus Repertoire)
- Mobile: Listenansicht der nächsten 5 Termine kompakt (FA-404 — Kalender als KANN, Liste als MUSS)
- Ideensammlung: Freies Textfeld je Idee, Liste + Löschen

**Deliverable:** Termine erscheinen auf PC und iPhone; Lieder-Deadlines sind je Termin sichtbar.

**Prompt:**
> Die Chorapp hat Repertoire und Tagesprobe. Lies `01_Anforderungen/Lastenheft.md` FA-070–073.
>
> Deine Aufgabe: Jahresplanung (Phase 4-V2).
>
> **Supabase:**
> ```sql
> termine (id uuid default gen_random_uuid() primary key, chor_id uuid references choere(id),
>   datum date not null, titel text not null, typ text check (typ in ('auftritt','probe','deadline','sonstiges')),
>   notiz text, erstellt_am timestamptz default now())
>
> termine_lieder (termin_id uuid references termine(id) on delete cascade,
>   lied_id uuid references lieder(id) on delete cascade, primary key (termin_id, lied_id))
>
> ideen (id uuid default gen_random_uuid() primary key, chor_id uuid references choere(id),
>   inhalt text not null, erstellt_am timestamptz default now())
> ```
> SQL unter `db/migrations/004_jahresplanung.sql`.
>
> **Desktop (Planungsmodus):**
> Tab «Jahresplan» mit zwei Unteransichten (Toggle): **Kalender** (Monatsraster, Termine als farbige Chips je Typ) und **Liste** (chronologisch, expandierbar). Termin erstellen: Datum, Titel, Typ, Notiz, Lieder-Zuordnung (Multi-Select aus Repertoire). Ideensammlung: separater Bereich als Notiz-Karten.
>
> **Mobile (Durchführungsmodus):**
> Jahresplan-Tab zeigt die nächsten 5 Termine als Karten (Datum, Titel, Typ-Badge, zugeordnete Lieder als Tags). Ideensammlung als einfache scrollbare Liste.
>
> Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — strukturiertes CRUD; Kalender-Raster ist Standardaufgabe für Sonnet.
done
---

## Phase 5-V2 — Supabase Auth & Row-Level-Security (v2.0 Voraussetzung)
**Opus 4.8**

**Ziel:** Login absichern, bevor Personendaten gespeichert werden. Ab hier sind alle Daten via RLS auf den eingeloggten Benutzer beschränkt.

**Aufgaben:**
- Supabase Auth aktivieren (E-Mail + Passwort; FA-005, NF-014)
- Login-UI: E-Mail + Passwort, Formular, Fehlerbehandlung
- Session-Handling: automatischer Redirect zu Login wenn nicht eingeloggt; Session bei Reload erhalten
- RLS-Policies für alle bestehenden Tabellen (`choere`, `probennotizen`, `lieder`, `proben_lieder`, `termine`, `termine_lieder`, `ideen`): `using (auth.uid() = user_id)` — `user_id`-Spalte zu allen Tabellen hinzufügen
- Logout-Button in Navigation/Header
- SQL-Migrations für RLS unter `db/migrations/005_auth_rls.sql`

**Abnahme:** Nicht eingeloggte Anfragen liefern 0 Zeilen; eingeloggte Anfragen liefern nur eigene Daten.

**Prompt:**
> Die Chorapp hat alle v1.x-Funktionen ohne Auth. Lies `01_Anforderungen/Lastenheft.md` NF-013a, NF-014 und `02_Architektur/ADR-001_Stack.md`.
>
> Deine Aufgabe: Supabase Auth + RLS (Phase 5-V2) — Sicherheitsfundament für v2.0.
>
> **Auth:**
> Aktiviere Supabase Auth (E-Mail/Passwort). Erstelle eine Login-Seite (`login.html` oder Modal): E-Mail-Feld, Passwort-Feld, «Anmelden»-Button, Fehleranzeige. Speichere die Session via `supabase.auth.getSession()` und `onAuthStateChange`. Alle App-Seiten prüfen beim Laden: wenn keine Session → Weiterleitung zu Login. Logout-Button in der Navigation.
>
> **RLS — Alle Tabellen:**
> Füge jeder Tabelle (`choere`, `probennotizen`, `lieder`, `proben_lieder`, `termine`, `termine_lieder`, `ideen`) eine Spalte `user_id uuid references auth.users(id) default auth.uid()` hinzu. Erstelle RLS-Policies: `enable row level security`, `for all using (auth.uid() = user_id)`. Bestehende Test-Daten werden beim ersten Login neu angelegt.
>
> SQL-Migrationsskript: `db/migrations/005_auth_rls.sql`. Erkläre in einem Kommentar je Policy, warum diese Policy den Datenzugang korrekt einschränkt. Code-Kommentare auf Englisch.
>
> ⚠️ Diese Phase darf keinen bestehenden App-Code brechen — prüfe explizit, dass alle Supabase-Queries nach der Migration noch funktionieren.

**Modell:** **Opus 4.8** — Sicherheits-kritische Phase; RLS falsch konfiguriert → Datenleck (R-006). Stärkstes Modell zwingend.
w
---

## Phase 6-V2 — Mitgliederliste (v2.0)
**Sonnet 4.6**

**Ziel:** Anja verwaltet alle Chormitglieder mit Kontaktdaten.

**Aufgaben:**
- Supabase-Tabelle `mitglieder (id, user_id, chor_id, vorname, nachname, email, adresse, telefon, stimmlage, erstellt_am)`
- CRUD: Mitglied anlegen, bearbeiten, entfernen (FA-080)
- Stimmlage als optionales Feld (Sopran/Mezzosopran/Alt/Tenor/Bariton/Bass)
- Liste mit Suche + Filter (Stimmlage)
- Export als CSV (FA-081, SOLL)
- Desktop: tabellarische Ansicht; Mobile: Karten-Liste

**Deliverable:** Mitgliederliste vollständig, RLS aktiv, Export funktioniert.

**Prompt:**
> Die Chorapp hat Auth/RLS und alle v1.x-Funktionen. Lies `01_Anforderungen/Lastenheft.md` FA-080, FA-081, NF-013a.
>
> Deine Aufgabe: Mitgliederliste (Phase 6-V2).
>
> **Supabase:**
> ```sql
> mitglieder (id uuid default gen_random_uuid() primary key,
>   user_id uuid references auth.users(id) default auth.uid(),
>   chor_id uuid references choere(id),
>   vorname text not null, nachname text not null, email text not null,
>   adresse text, telefon text,
>   stimmlage text check (stimmlage in ('sopran','mezzosopran','alt','tenor','bariton','bass',null)),
>   erstellt_am timestamptz default now())
> ```
> RLS-Policy analog zu Phase 5-V2. SQL: `db/migrations/006_mitglieder.sql`.
>
> **Desktop (Planungsmodus):**
> Tab «Mitglieder» mit tabellarischer Ansicht (Name, E-Mail, Stimmlage, Aktionen). Suchfeld (Name). Filter nach Stimmlage. Inline-Formular für Hinzufügen/Bearbeiten. Löschen mit Bestätigung. «Export CSV»-Button lädt alle Mitglieder als CSV herunter (Felder: Vorname, Nachname, E-Mail, Adresse, Telefon, Stimmlage).
>
> **Mobile (Durchführungsmodus):**
> Mitglieder-Tab zeigt Karten-Liste (Name + Stimmlage-Badge). Karte antippen → Detail-Ansicht (alle Felder, kein Bearbeiten auf Mobile — Bearbeiten nur Desktop).
>
> Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — Standard-CRUD mit klaren Feldern und bekanntem RLS-Muster.
done
---

## Phase 7-V2 — Buchhaltung & PDF-Abrechnung (v2.0)
**Opus 4.8**

**Ziel:** Einnahmen/Ausgaben erfassen, Beitragsstatus pro Mitglied, druckfertiger PDF-Export.

**Aufgaben:**
- Supabase-Tabellen: `beitraege (id, user_id, chor_id, mitglied_id, halbjahr, betrag, bezahlt, bezahlt_am)` + `ausgaben (id, user_id, chor_id, datum, betrag, beschreibung, kategorie)`
- Desktop: Beitragsstatus-Übersicht (alle Mitglieder, Halbjahr wählen, bezahlt togglen)
- Ausgaben-Erfassung (Eingabemaske: Datum, Betrag, Beschreibung/Kategorie)
- Kassenstand-Widget (Einnahmen − Ausgaben)
- PDF-Abrechnung: Zeitraum wählen → anonymisierter Export (FA-095–097)
  - Felder: Zeitraum, Chorname, Datum, Einnahmen-Block («Mitglied 1 … Betrag»), Ausgaben-Block (Position/Datum/Betrag), Saldo
  - Namen NIEMALS im Export (NF-013a)
  - Download als A4-PDF

**Prompt:**
> Die Chorapp hat Mitgliederliste + Auth/RLS. Lies `01_Anforderungen/Lastenheft.md` FA-085–098, NF-013a.
>
> Deine Aufgabe: Buchhaltung + PDF-Abrechnung (Phase 7-V2).
>
> **Supabase:**
> ```sql
> beitraege (id uuid default gen_random_uuid() primary key,
>   user_id uuid references auth.users(id) default auth.uid(),
>   chor_id uuid references choere(id), mitglied_id uuid references mitglieder(id),
>   halbjahr text not null, -- Format: '2026-H1'
>   betrag numeric(10,2) not null, bezahlt boolean default false,
>   bezahlt_am timestamptz)
>
> ausgaben (id uuid default gen_random_uuid() primary key,
>   user_id uuid references auth.users(id) default auth.uid(),
>   chor_id uuid references choere(id), datum date not null,
>   betrag numeric(10,2) not null, beschreibung text not null, kategorie text)
> ```
> RLS-Policies für beide Tabellen. SQL: `db/migrations/007_buchhaltung.sql`.
>
> **Desktop — Mitglieder-Tab, Unteransicht «Beiträge»:**
> Halbjahr-Selektor (Dropdown, aktuelle Periode vorgewählt). Tabelle: Mitglied-Nr (nicht Klarname), Betrag, Status (bezahlt/offen), Bezahlt-am. Toggle-Button je Zeile. Eingabefeld für Beitragshöhe pro Periode (FA-085).
>
> **Desktop — Buchhaltungs-Tab:**
> Kassenstand-Widget (Summe Beiträge eingegangen − Summe Ausgaben). Ausgaben-Liste mit Hinzufügen-Formular. Abschnitt «Abrechnung erstellen»: Zeitraum von/bis, «PDF generieren»-Button.
>
> **PDF-Abrechnung (FA-095–097):**
> Generiere ein druckfertiges A4-PDF (via `window.print()` oder jsPDF via CDN — kein Build-Step). Pflichtfelder: Zeitraum, Chorname, Erstellungsdatum, Abschnitt «Einnahmen» mit Zeilen «Mitglied 1 — CHF x.xx — bezahlt/offen», Abschnitt «Ausgaben» (Datum, Beschreibung, Betrag), Saldo. **Kein Klarname darf im PDF erscheinen** (NF-013a) — Mitglieder werden ausschliesslich als «Mitglied 1», «Mitglied 2» usw. referenziert.
>
> Code-Kommentare auf Englisch.

**Modell:** **Opus 4.8** — PDF-Generierung ohne Build-Step, anonymisierte Abrechnung mit Datenschutzanforderung; Qualität entscheidet.
w
---

## Phase 8-V2 — E-Mail-Versand (v2.0)
**Sonnet 4.6**

**Ziel:** Anja kann Rundmails und Zahlungserinnerungen direkt aus der App senden.

**Voraussetzung:** E-Mail-Dienst (Resend o.ä.) konfiguriert (OP-EMAIL-01 mit Anja klären).

**Aufgaben:**
- Supabase Edge Function `send-email` (Resend API, DKIM/SPF über Anjas Domain)
- Rundmail an alle Mitglieder eines Chors (FA-100)
- Zahlungserinnerung an Mitglieder mit offenem Beitrag (FA-101), manuell ausgelöst
- Vorlage für Zahlungserinnerung (editierbar, FA-102)
- Probeninfo senden (FA-103)
- Versandverlauf in Supabase speichern (FA-104, KANN)

**Prompt:**
> Die Chorapp hat Buchhaltung und Mitgliederliste. Lies `01_Anforderungen/Lastenheft.md` FA-100–104. Kläre zuerst mit mir (Gianluca) welche Absenderadresse und welcher E-Mail-Dienst (Resend empfohlen) verwendet wird — das ist OP-EMAIL-01.
>
> Deine Aufgabe: E-Mail-Versand (Phase 8-V2).
>
> **Supabase Edge Function** `supabase/functions/send-email/index.ts`:
> Nimmt `{to: string[], subject: string, body: string}` entgegen, sendet via Resend API (API-Key als Supabase Secret, nie im Frontend-Code). Gibt `{sent: number, failed: number}` zurück.
>
> **Desktop — Mitglieder-Tab, Aktionsbereich:**
> Button «Rundmail senden» → Modal mit Betreff-Feld, Textbereich, Empfänger-Vorschau («An alle X Mitglieder des Chors»). Senden-Button mit Bestätigung.
>
> Button «Zahlungserinnerungen» → Liste der Mitglieder mit offenen Beiträgen (als «Mitglied 1» usw. angezeigt). Pro Mitglied «Erinnerung senden»-Button; alternativ «Alle erinnern». Vorlage für Erinnerungs-E-Mail editierbar (FA-102).
>
> Probeninfo-Versand im Probennotizen-Tab: Button «Per E-Mail senden» neben markierten Punkten.
>
> Versandverlauf (FA-104, KANN): Tabelle `email_versand (id, user_id, chor_id, datum, empfaenger_anzahl, betreff, typ)` in Supabase — nur Metadaten, keine Inhalte. SQL: `db/migrations/008_email_versand.sql`.
>
> Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — Edge Function + API-Anbindung; klar definiert.

---

## Phase 9-V2 — Audio-Übungen (v2.x)
**Sonnet 4.6**

**Ziel:** Zu eigenen Einsingübungen kann eine Audiodatei hinterlegt werden.

**Aufgaben:**
- Supabase Storage Bucket `audio-uebungen`
- Erweiterung des `eigeneUebungen`-Schemas um `audio_pfad`
- Upload-UI in «Eigene Übungen»-Formular (nur Desktop, FA-060)
- Audio-Player in der Übungs-Karte (mobil nutzbar, FA-061)

**Prompt:**
> Die Chorapp hat alle v2.0-Funktionen und eigene Übungen. Lies `01_Anforderungen/Lastenheft.md` FA-060, FA-061.
>
> Deine Aufgabe: Audio-Übungen (Phase 9-V2).
>
> Erstelle Supabase Storage Bucket `audio-uebungen` (authenticated read). Erweitere das Eigene-Übungen-Formular (Phase 1-V2) um ein optionales Datei-Upload-Feld (Typ: Audio, max. 20 MB). Lade die Datei unter `{user_id}/{uuid}.mp3` in Storage hoch und speichere den Pfad in `eigeneUebungen` (localStorage + optional Supabase-Tabelle `eigene_uebungen` wenn Migration gewünscht). Zeige in der Übungs-Karte einen kompakten Audio-Player (`<audio controls>`) wenn ein Pfad vorhanden ist — playergetriggert, nicht autoplay. Hinweis auf Dateigrössen-Limit (NF-016). SQL: `db/migrations/009_audio_uebungen.sql`. Code-Kommentare auf Englisch.

**Modell:** **Sonnet 4.6** — Storage-Integration ist nach Phase 3-V2 bekanntes Muster.

---

## Modellwahl — Kurzfassung v2

| Phase | Empfehlung | Warum |
|-------|-----------|-------|
| 0-V2 Navigation | Sonnet 4.6 | Architektur klar, Standard-Implementation |
| 1-V2 Eigene Übungen | **Haiku 4.5** | Einfaches CRUD, Muster bekannt |
| 2-V2 Notizfeld | Sonnet 4.6 | CRUD + Supabase, klar definiert |
| 3-V2 Repertoire | **Opus 4.8** | Storage, Tagesprobe-UX, komplexeste Phase |
| 4-V2 Jahresplanung | Sonnet 4.6 | CRUD + Kalender-Standard |
| 5-V2 Auth/RLS | **Opus 4.8** | Sicherheitskritisch, R-006 |
| 6-V2 Mitglieder | Sonnet 4.6 | Standard-CRUD + CSV |
| 7-V2 Buchhaltung/PDF | **Opus 4.8** | PDF-Generierung + Datenschutz (NF-013a) |
| 8-V2 E-Mail | Sonnet 4.6 | Edge Function, API-Anbindung |
| 9-V2 Audio | Sonnet 4.6 | Storage-Muster bekannt |

**Faustregel V2:** Opus 4.8 für Phasen mit Sicherheitsrelevanz (Auth/RLS), komplexer UX (Tagesprobe) oder regulatorischen Anforderungen (PDF-Abrechnung anonymisiert). Sonnet 4.6 als robustes Arbeitspferd. Haiku 4.5 für simples CRUD mit klar definiertem Muster.

---

## Empfohlene Reihenfolge

```
Phase 1-V2 (AK-004 schliessen)
  → Phase 0-V2 (Navigationsfundament)
    → Phase 2-V2 (Notizfeld, einfach)
      → Phase 3-V2 (Repertoire, komplex)
        → Phase 4-V2 (Jahresplanung)
          → Phase 5-V2 (Auth — vor Mitglieder zwingend!)
            → Phase 6-V2 (Mitglieder)
              → Phase 7-V2 (Buchhaltung)
                → Phase 8-V2 (E-Mail)
                  → Phase 9-V2 (Audio, optional)
```

> **Wichtig:** Phase 5-V2 (Auth/RLS) muss **zwingend** vor Phase 6-V2 (Mitglieder) abgeschlossen sein — erst dann dürfen Personendaten in Supabase gespeichert werden (NF-014, DSGVO/DSG).

---

## Offene Punkte vor Start

| ID | Frage | Betrifft |
|----|-------|---------|
| OP-EMAIL-01 | Welcher E-Mail-Dienst? Von welcher Absenderadresse? | Phase 8-V2 |
| OP-F5-02 | CSV-Export Mitgliederliste — gewünscht? | Phase 6-V2 |
| OP-F5-03 | Steuerformat Abrechnung — reicht die definierte Struktur? | Phase 7-V2 |
| OP-ALL-01 | Gibt es Prioritätsverschiebungen nach Pilot-Feedback v1.0? | Alle |
