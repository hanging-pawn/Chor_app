# Umsetzungsprompt — AP-0402: send-email absichern

**Umgebung:** Claude Code (Repo-Root) · **Modell:** mittel · **Grösse:** M
**Nach Abschluss manuell:** `supabase functions deploy send-email` + im Dashboard Signups deaktivieren.

---

## Prompt (zum Einfügen in Claude Code)

```
Chor_App, Datei supabase/functions/send-email/index.ts (Deno Edge Function, Resend-API).
Sicherheits-Härtung gemäss Code Review 2026-08-15 (Befunde 3/12), Report:
04_Implementierung/plan-verbesserungen-2026-08/04_qualitaet/2026-08-15_Code-Review.md

Aufgaben:
1. Empfänger-Validierung: Vor dem Versand alle Adressen in `to` gegen die Tabellen
   `mitglieder` und `pianisten` des aufrufenden Users prüfen (Query mit dem User-JWT,
   damit RLS greift — NICHT mit service_role). Unbekannte Adressen → 400 mit Auflistung.
2. Rate-Limit: Vor dem Versand count(*) auf `email_versand` der letzten 24h für diesen
   user_id; bei > 20 Sendungen → 429. Konstante klar benannt.
3. CORS: 'Access-Control-Allow-Origin' von '*' auf die konkrete GitHub-Pages-Origin
   ändern (aus dem Repo ableiten: https://hanging-pawn.github.io).
4. Identitätsprüfung: createClient mit SUPABASE_ANON_KEY + Authorization-Header des
   Aufrufers für auth.getUser(); der service_role-Client bleibt ausschliesslich für
   das Insert in email_versand (RLS-Bypass fürs Logging ist gewollt).
5. subject: Zeilenumbrüche entfernen: subject.replace(/[\r\n]+/g, ' ').

Verhalten sonst unverändert (Einzelversand statt BCC, 100er-Chunks, kein Body-Logging).
Nur diese eine Datei anfassen. Verifikation: deno check supabase/functions/send-email/index.ts
```

## Nach Ausführung (verbindlich)

1. Doku-Block in `AP-0402_send_email_absichern.md` ausfüllen, Status setzen.
2. Prompt nach `…/04_qualitaet/archiv/` verschieben. Übersicht/Dashboard aktualisieren.
