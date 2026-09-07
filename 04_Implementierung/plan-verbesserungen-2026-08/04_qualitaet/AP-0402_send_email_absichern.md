# AP-0402: Edge Function send-email absichern

## Ziel

Die E-Mail-Funktion versendet nur noch an bekannte Empfänger des eigenen Chors, mit Rate-Limit und eingeschränktem CORS. Schliesst Review-Befunde 3, 12 und den Niedrig-Befund «subject ungefiltert» (Code Review 2026-08-15).

## Kontext

`supabase/functions/send-email/index.ts` prüft nur ein gültiges JWT, aber nicht *an wen* gesendet wird: `to` ist voll client-kontrolliert, kein Rate-Limit → Quasi-Open-Relay bei offener Supabase-Registrierung. Zusätzlich: CORS `*` statt konkreter Origin (Z. 34–37); Identitätsprüfung nutzt den service_role-Key als Client-Basis statt anon-Key (Z. 66–68); `subject` wird nicht auf Zeilenumbrüche gefiltert.

## Umsetzungsschritte

1. Empfänger-Validierung: `to` serverseitig gegen `mitglieder` und `pianisten` des aufrufenden `user_id` (+ `chor_id` aus dem Request) prüfen; unbekannte Adressen ablehnen (400 mit Liste).
2. Rate-Limit: Zähler über `email_versand` (z. B. max. N Sendungen / 24 h pro user_id); bei Überschreitung 429.
3. CORS auf die GitHub-Pages-Origin einschränken.
4. `auth.getUser()` über einen anon-Key-Client mit durchgereichtem Authorization-Header; service_role nur fürs Logging behalten.
5. `subject.replace(/[\r\n]+/g, ' ')` vor Versand.
6. Manuell prüfen: Supabase-Dashboard → Auth → Signups deaktivieren (Single-User-App).

## Abnahmekriterien

- [x] CORS-Header enthält nur noch die Pages-Origin (`ALLOWED_ORIGINS`, im Code verifizierbar).
- [x] Syntax-/Typprüfung fehlerfrei — `tsc --strict --noEmit` gegen Ambient-Deklarationen für die Deno- und Supabase-Imports, Exit 0. **Nicht** `deno check`: Deno ist auf dem Rechner nicht installiert.
- [x] Bestehender Versand an Mitglieder funktioniert unverändert — Aufrufvertrag geprüft: alle vier Aufrufer in `index.html` (Rundmail, Einzel- und Sammel-Zahlungserinnerung, Probeninfo) senden `chor_id: APP_STATE.chorId`, und `_mitgliederCache` wird mit `.eq('chor_id', APP_STATE.chorId)` geladen. Antwortformat `{sent, failed}` und Fehlerfeld `error` unverändert.
- [ ] Versand an eine Adresse, die weder in `mitglieder` noch `pianisten` des Aufrufers steht → 400. **Nicht getestet** — Function ist nicht deployed (404), Laufzeittest erst nach Deploy möglich.
- [ ] Rate-Limit greift (429). Implementiert und dokumentiert, Laufzeittest steht wie oben aus.

## Voraussetzungen

Keine (unabhängig von AP-0403 ff.). Deploy der Function: `supabase functions deploy send-email` (manuell, Gianluca).

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M

## Dokumentation

- **Erledigt am**: 2026-09-07 (Code); Deploy und Laufzeitabnahme stehen aus
- **Abweichungen**:
  - Umsetzungsschritt 6 (Signups deaktivieren) wurde vorgezogen und bereits am 2026-09-07 im Supabase-Dashboard ausgeführt.
  - Zusätzlich zur Spezifikation: `chor_id` wird gegen `choere` des Aufrufers geprüft (403 bei fremdem Chor), und die Adressvalidierung nutzt eine bewusst strenge Regex ohne `,` `;` `<` `>`, damit eine Adresse keinen zweiten Empfänger schmuggeln kann.
  - Empfänger- und Quota-Abfragen laufen über den anon-Key-Client, nicht über service_role. Damit erzwingt Postgres per RLS, dass die Function fremde Mitglieder gar nicht lesen kann — die Prüfung hängt nicht allein an der Filterlogik im Code. Möglich wurde das erst durch Migration 013.
  - Der Rate-Limit-Check schlägt bei Fehler fehl (fail closed, 500) statt durchzulassen.
  - Grenzwerte: 20 Sendungen und 500 Empfänger je 24 h und Benutzerin, 100 Empfänger je Request (entspricht dem Resend-Batch-Limit).
- **Verbleibende offene Punkte**:
  - Deploy blockiert durch **OP-EMAIL-01**: ohne festgelegte Absenderadresse mit DKIM/SPF lässt sich `SENDER_EMAIL` nicht setzen.
  - Nach dem Deploy: Negativtest (fremde Adresse → 400) und Rate-Limit-Test (429) nachholen.
  - Bei einem Chor mit mehr als 100 Mitgliedern greift `MAX_RECIPIENTS_PER_REQUEST` und der Versand bricht mit 400 ab. Für Anjas Chorgrösse unkritisch; sonst müsste die Function wieder in Chunks senden.
  - Lokale Entwicklung gegen die Function ist durch die CORS-Einschränkung nicht mehr möglich — dafür müsste die Origin in `ALLOWED_ORIGINS` ergänzt werden.

## Status

- [x] Bereit zur Ausführung
- [x] In Arbeit
- [ ] Abgenommen (blockiert durch OP-EMAIL-01 / Deploy)
