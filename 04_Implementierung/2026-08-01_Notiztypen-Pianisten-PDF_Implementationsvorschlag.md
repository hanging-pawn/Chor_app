# Implementationsvorschlag: Notiztypen, Probenübersicht, Pianisten-PDF

Datum: 2026-08-01 · Status: **umgesetzt im Code**, Migrationen noch nicht in Supabase ausgeführt

> **Nächster Schritt:** Migrationen 009–012 im Supabase SQL-Editor ausführen, danach `index.html` committen und pushen. Vorher zeigt die App Fehler, weil die neuen Spalten und Tabellen fehlen.

## Ziel

1. Notizen bekommen einen **Typ**: allgemein / liedbezogen / Mitteilung an den Chor
2. Diese Typen werden in der **Probenübersicht getrennt** angezeigt
3. Register «Einsingen» heisst neu **«Nächste Probe»**
4. Alle Inhalte der nächsten Probe (inkl. Einsing-Set) gehen als **PDF an den Pianisten**

---

## 1. Datenmodell

### Migration 009 — Notiztypen

```sql
alter table probennotizen add column if not exists typ text
  not null default 'allgemein'
  check (typ in ('allgemein','mitteilung'));

-- Bestandsdaten übernehmen: "Dem Chor mitteilen" → Mitteilung
update probennotizen set typ = 'mitteilung' where markiert = true;

-- Pro Chor/Datum genau eine allgemeine Notiz und eine Mitteilung
create unique index if not exists uq_probennotizen_chor_datum_typ
  on probennotizen (chor_id, datum, typ);
```

> `markiert` bleibt als Spalte bestehen (Altdaten), wird von der App aber nicht mehr geschrieben. Der Unique-Index schlägt fehl, falls für ein Datum bereits mehrere Zeilen gleichen Typs existieren — vorher prüfen.

### Migration 010 — Liedbezogene Notiz

```sql
alter table lieder add column if not exists notiz text;  -- dauerhafte Notiz am Lied
```

**Eine Ebene** (entschieden 2026-08-01): Die Notiz hängt dauerhaft am Lied und gilt für jede Probe («Tenor-Einsatz T. 24 ist heikel»). Eingabe im Repertoire-Tab.

Probenspezifisches («heute nur Strophe 1–2») gehört in die allgemeine Probennotiz. Falls sich später zeigt, dass eine zweite, probenbezogene Ebene fehlt, ist das eine einzelne Spalte (`proben_lieder.notiz`) — bewusst zurückgestellt.

### Migration 011 — Pianisten

```sql
create table if not exists pianisten (
  id          uuid primary key default gen_random_uuid(),
  chor_id     uuid not null references choere(id) on delete cascade,
  vorname     text not null,
  nachname    text not null,
  email       text not null,
  telefon     text,
  aktiv       boolean not null default true,
  erstellt_am timestamptz not null default now()
);

create table if not exists proben_pianist (
  chor_id    uuid not null references choere(id) on delete cascade,
  datum      date not null,
  pianist_id uuid not null references pianisten(id) on delete cascade,
  primary key (chor_id, datum)
);
```

### Migration 012 — Einsing-Set persistieren

**Notwendig.** Das Set lebt heute nur in `currentSet` im Speicher und ist nach einem Reload weg. Ohne Persistenz liesse sich das PDF nur unmittelbar nach dem Generieren erzeugen.

```sql
create table if not exists proben_set (
  chor_id     uuid not null references choere(id) on delete cascade,
  datum       date not null,
  set_json    jsonb not null,       -- die 5–6 Übungen als Snapshot
  erstellt_am timestamptz not null default now(),
  primary key (chor_id, datum)
);
```

Snapshot statt IDs, damit ein späteres Ändern der Übungsdatenbank ein bereits versendetes Programm nicht verfälscht.

---

## 2. UI

### Register-Umbenennung

Nur die sichtbaren Strings ändern (Sidebar + Bottom-Nav + `aria-label`), **`data-tab="einsingen"` intern beibehalten** — die ID steckt an ~15 Stellen in `switchTab()`, Router und Icon-Mapping. Reines Label-Rename, null Regressionsrisiko.

### Notiz-Tab

Checkbox «☑ Dem Chor mitteilen» → **Segmented Control** mit zwei Optionen:

```
[ Allgemeine Notiz ]  [ Mitteilung an den Chor ]
```

Die Liste vergangener Notizen bekommt pro Eintrag ein Badge (`Allgemein` / `Mitteilung`) und einen Filter.

### Repertoire-Tab

Im Lied-Editor ein zusätzliches Feld **«Notiz zum Lied»** (`lieder.notiz`, mehrzeilig, optional). In der Liederliste als kleine graue Zeile unter dem Titel sichtbar.

### Probenübersicht (Seite «Nächste Probe»)

Neue Reihenfolge, vier klar getrennte Blöcke:

```
┌ Nächste Probe · Do 14.08.2026 ──────────────┐
│ Pianist: [ Dropdown ▾ ]   [ Als PDF senden ]│
├─────────────────────────────────────────────┤
│ 📌 Mitteilungen an den Chor                 │  ← typ = 'mitteilung'
│ 📝 Notizen zur Probe                        │  ← typ = 'allgemein'
├─────────────────────────────────────────────┤
│ 🎵 Lieder                                   │
│   01  Ave Verum          [♪ Noten]          │
│       » Tenor-Einsatz T. 24 heikel  (Lied)  │
│       » heute nur Str. 1–2       (Probe) ✎  │
├─────────────────────────────────────────────┤
│ 🎤 Einsingen — 6 Übungen   [Neues Set]      │
└─────────────────────────────────────────────┘
```

Die Notizzeile pro Lied ist inline editierbar (Blur → Upsert auf `proben_lieder.notiz`).

### Pianisten-Verwaltung

Kein siebter Tab. Neuer Abschnitt **«Pianisten»** im Mitglieder-Tab: Liste mit Name/E-Mail, Anlegen/Bearbeiten/Deaktivieren. Ein 7. Tab würde die Bottom-Nav auf dem iPhone sprengen.

---

## 3. PDF-Erzeugung

`generateProbePDF(datum)` — jsPDF ist bereits geladen und via `generateAbrechnungPDF()` erprobt, gleiche Bauweise wiederverwenden.

**Inhalt (A4, 1–2 Seiten):**

| Abschnitt | Quelle |
|---|---|
| Kopf: Chorname, Probendatum, «Für: \<Pianist\>» | `choere`, `proben_pianist` |
| Einsingen — 5–6 Übungen mit Titel + Kurzbeschreibung | `proben_set.set_json` |
| Lieder in Reihenfolge, je mit beiden Notizen | `proben_lieder` + `lieder` |
| Notizen zur Probe | `probennotizen` typ='allgemein' |
| Mitteilungen an den Chor | typ='mitteilung', **optional** |

Mitteilungen sind an den Chor gerichtet, nicht an den Pianisten → Checkbox im Sende-Dialog, **standardmässig aus**.

Noten-PDFs werden **nicht** angehängt, sondern als Links aufgeführt (Storage-Bucket ist public) — sonst wird die Mail schnell zu gross.

---

## 4. Versand

Die Edge Function `send-email` existiert, ist auth-geschützt und kennt `typ: 'probeninfo'` bereits im CHECK-Constraint. Sie kann heute aber nur Plaintext.

**Erweiterung** (~15 Zeilen, Resend unterstützt Anhänge nativ):

```ts
attachments: [{ filename: `Probe_${datum}.pdf`, content: base64Pdf }]
```

Client: `doc.output('datauristring')` → Base64-Teil extrahieren → `sb.functions.invoke('send-email', { body: { to:[pianist.email], subject, body, chor_id, typ:'probeninfo', attachments } })`.

**Fallback für Stufe 1** (falls der Resend-Key noch nicht steht): PDF lokal erzeugen und über die Web Share API teilen — funktioniert auf iOS Safari, öffnet direkt Mail/WhatsApp mit Anhang.

```js
const file = new File([doc.output('blob')], `Probe_${datum}.pdf`, { type:'application/pdf' });
if (navigator.canShare?.({ files:[file] })) await navigator.share({ files:[file], title:'Probe' });
else doc.save(`Probe_${datum}.pdf`);
```

---

## 5. Umsetzungsstand

| # | Schritt | Stand |
|---|---|---|
| 1 | Migrationen 009–012 geschrieben | ✅ Dateien da — **noch nicht in Supabase ausgeführt** |
| 2 | Notiz-Typen: Segmented Control, Speichern, Liste mit Badge | ✅ |
| 3 | Liednotiz: Feld im Lied-Modal + Zeile in der Probenübersicht + Chip in der Liste | ✅ |
| 4 | Register-Rename + Probenübersicht in vier Blöcken | ✅ |
| 5 | Einsing-Set persistieren (`proben_set`) | ✅ inkl. Wiederherstellung beim Laden |
| 6 | Pianisten-CRUD (Mitglieder → Pianisten) + Zuordnung pro Probe | ✅ |
| 7 | `buildProbePDF()` / `sendProbePDF()` | ✅ |
| 8 | Versand über Web Share API mit Download-Fallback | ✅ |
| 9 | Versand über Edge Function mit PDF-Anhang | ⬜ offen — erst wenn der Resend-Key steht |

### Was zusätzlich entstanden ist

- **Kollisionsschutz im Notiz-Tab:** Migration 009 erlaubt pro Datum und Typ nur eine Zeile. Statt den Datenbankfehler abzuwarten, prüft die App vorher und bietet an, den neuen Text an die bestehende Notiz anzuhängen — so geht kein Text verloren.
- **Leerer Text löscht die Notiz:** Wird ein Feld der Probenübersicht geleert und gespeichert, verschwindet die Zeile, statt eine leere Notiz zu hinterlassen.
- **`saveEinsingenNotiz()` bleibt als Alias** auf `saveProbeNotiz('allgemein')` bestehen — falls die Funktion irgendwo sonst noch referenziert wird.

## 6. Verifikation (2026-08-01)

| Prüfung | Ergebnis |
|---|---|
| `node --check` auf dem Inline-JS (146 kB) | keine Syntaxfehler |
| Alle 12 Migrationen gegen die echte PostgreSQL-Grammatik (libpg_query) | alle parsen |
| Seite in jsdom geladen, ohne CDN-Skripte | keine Laufzeitfehler |
| 13 neue DOM-Elemente vorhanden, 16 neue Funktionen definiert | vollständig |
| Typ-Umschalter, Subview-Wechsel, Tab-Wechsel durchgeklickt | verhält sich korrekt |
| `getElementById` ohne passendes `id`-Attribut | keine |
| PDF real erzeugt (jsPDF in Node), Text wieder ausgelesen | Umlaute, Zeilenumbruch und Seitenumbruch korrekt; alle sechs Abschnitte vorhanden |
| PDF-Leerfall (nichts gepflegt) | eine saubere Seite, kein Absturz |

Nicht geprüft (braucht die echte Datenbank): die Supabase-Abfragen selbst, das Zusammenführen von Duplikaten in Migration 009, und der Web-Share-Dialog auf dem iPhone.

---

## Entscheidungen (2026-08-01)

| # | Punkt | Entscheidung |
|---|---|---|
| 1 | Notiz am Lied | **Eine Ebene** — `lieder.notiz`, dauerhaft, Eingabe im Repertoire-Tab |
| 2 | Mitteilungen | **Ein Textfeld** pro Probe, mehrzeilig — keine Liste einzelner Einträge |
| 3 | Mitteilungen im PDF | **Immer mitschicken**, kein Toggle — eigener Abschnitt am Ende |
| 4 | Pianisten pro Probe | **Einer zugeordnet**, im Sende-Dialog weitere Empfänger zuwählbar |

## Deploy-Stand (Messung 2026-08-01, 18:10)

Die frühere Annahme «Repo korrupt / nichts gepusht» war zu pessimistisch. Tatsächlich:

- Lokaler HEAD **und** GitHub stehen auf `4b442c4` → Kanon-Noten (#1) und «Nächste Probe» (#2) sind **live**
- Uncommitted sind nur 136 Zeilen in `index.html` — AP-0301, das Notizfeld auf der Einsingen-Seite
- Der Blocker sind exakt drei Dateien: `icons/apple-touch-icon.png`, `icons/icon-192.png`, `icons/icon-512.png` sind iCloud-Platzhalter. git kann sie nicht lesen (`Resource deadlock avoided`), also scheitert jedes `git add -A`
- Git-**Schreibzugriffe** funktionieren aus der Cowork-Sandbox auf diesem iCloud-Mount grundsätzlich nicht (`unlink: Operation not permitted`). Commits müssen im Terminal laufen.

**Freizuschalten im Terminal:**

```bash
cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Projekte/Chor_app/Chor_App
rm -f .git/index.lock          # Rest eines fehlgeschlagenen Sandbox-Commits
brctl download icons/          # iCloud-Platzhalter materialisieren
git add index.html
git commit -m "Einsingen: Notizfeld für nächste Probe (AP-0301)"
git push
```

Dauerhafte Entschärfung (später): Repo aus dem iCloud-Vault herausziehen, Doku-Ordner in Obsidian belassen.
