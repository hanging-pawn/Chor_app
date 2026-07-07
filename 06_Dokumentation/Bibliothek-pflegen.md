---
context:
  read: full
  tokens: ~722
  covers: [uebungen, bibliothek, pool, daten, json]
  read_when: "Übungen hinzufügen, Bibliothek erweitern oder uebungen.json-Schema verstehen"
  skip_when: "App-Logik, UI, Deployment oder Anforderungen ohne Datenbank-Bezug"
  updated: 2026-06-12
---

# Bibliothek pflegen — Übungen erweitern

**Zielumfang:** ≥ 12 Übungen pro Kategorie (FA-030).  
Aktuell: 6 je Kategorie (`koerper`, `atem`, `stimme`, `abschluss`).

---

## 1. Wo liegen die Daten?

Die Übungen sind **inline im `<script>`-Block von `index.html`** in einem Objekt namens `POOL` abgelegt (Stand v1.0). Die externe Datei `data/uebungen.json` ist für eine spätere Refaktorierung vorbereitet, wird aber von `index.html` noch nicht geladen.

```
index.html          → POOL-Objekt, direkter Einsatz (aktiv)
data/uebungen.json  → Strukturierte Datei (vorbereitet, noch nicht verknüpft)
js/generator.js     → Generierungs-Logik (für spätere Nutzung mit uebungen.json)
```

---

## 2. Übung in `index.html` (POOL) hinzufügen

Öffne `index.html` und suche nach `const POOL = {`. Die Struktur je Kategorie:

```js
// Beispiel: neue Körper-Übung
körper: [
  // … bestehende Einträge …
  {
    title: "Schulter-Pendel",
    anleitung: "Arme locker hängen lassen und Schultern wechselseitig sanft pendeln. 15 Sekunden.",
  },
],
```

**Felder:**

| Feld | Typ | Pflicht | Beschreibung |
|------|-----|---------|-------------|
| `title` | String | ✅ | Kurzname der Übung |
| `anleitung` | String | ✅ | Textliche Anleitung für die Chorleiterin |
| `hasNotation` | Boolean | nur `stimme` | `true` wenn ein Notenbild vorhanden/geplant ist |

**Kategorie-Keys in `POOL`:**

| Key | Anzahl im Set |
|-----|--------------|
| `körper` | 1 |
| `atem` | 1 |
| `stimme` | 3 |
| `kanon` | 1 |

---

## 3. Übung in `data/uebungen.json` hinzufügen (zukünftig)

Sobald `index.html` auf `uebungen.json` umgestellt wird, gilt folgendes Format:

```json
{
  "id": "koerper-007",
  "kategorie": "koerper",
  "title": "Schulter-Pendel",
  "anleitung": "Arme locker hängen lassen und Schultern wechselseitig sanft pendeln. 15 Sekunden.",
  "hasNotation": false
}
```

**Regeln:**
- `id` muss eindeutig sein, Muster: `{kategorie}-{dreistellige Nummer}`
- `kategorie` ist einer von: `koerper`, `atem`, `stimme`, `abschluss`
- Keine Umlaute im `id`-Feld (URL-sicher)

---

## 4. Qualitätsprüfung vor dem Commit

```bash
# Schema-Validierung (wenn uebungen.json aktiv)
node -e "
  const d = require('./data/uebungen.json');
  const cats = ['koerper','atem','stimme','abschluss'];
  cats.forEach(c => {
    const n = d.uebungen.filter(u => u.kategorie === c).length;
    console.log(c + ': ' + n + ' Übungen');
  });
"

# Doppelte IDs prüfen
node -e "
  const d = require('./data/uebungen.json');
  const ids = d.uebungen.map(u => u.id);
  const dupes = ids.filter((id,i) => ids.indexOf(id) !== i);
  if (dupes.length) console.error('Doppelte IDs:', dupes);
  else console.log('Alle IDs eindeutig ✓');
"
```

---

## 5. Hinweis

Der aktuelle Mindestbestand reicht für einen Probebetrieb. Jede neue Übung erhöht sofort die Abwechslung — besonders `stimme` profitiert davon, da dort 3 Übungen pro Set gezogen werden.
