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

- [ ] Versand an eine Adresse, die weder in `mitglieder` noch `pianisten` des Aufrufers steht → 400.
- [ ] Rate-Limit greift (429) und ist im Code dokumentiert.
- [ ] CORS-Header enthält nur noch die Pages-Origin.
- [ ] `deno check` (bzw. Syntaxprüfung) fehlerfrei; bestehender Versand an Mitglieder funktioniert unverändert.

## Voraussetzungen

Keine (unabhängig von AP-0403 ff.). Deploy der Function: `supabase functions deploy send-email` (manuell, Gianluca).

## Ausführungsumgebung & Modell

**Umgebung**: Claude Code (Repo-Root) · **Modell**: mittel · **Grösse**: M

## Dokumentation (bei Ausführung auszufüllen)

- **Erledigt am**: {Datum}
- **Abweichungen**: {keine / Beschreibung}
- **Verbleibende offene Punkte**: {keine / Verweis}

## Status

- [x] Bereit zur Ausführung
- [ ] In Arbeit
- [ ] Abgenommen
