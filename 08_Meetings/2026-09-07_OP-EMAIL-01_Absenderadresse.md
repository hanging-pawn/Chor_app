# OP-EMAIL-01 — Absenderadresse und E-Mail-Dienst

**Datum:** 2026-09-07
**Status:** ⚠️ Teilgeklärt — Dienst entschieden, Absenderdomain offen (Entscheidung liegt bei Anja/Gianluca)
**Betrifft:** FA-100–104, R-008, AP-0402
**Teilnehmer:** Gianluca (technische Analyse)

---

## Ausgangsfrage

Von welcher Absenderadresse sollen die App-Mails (Rundmail, Zahlungserinnerung,
Probeninfo) versendet werden — von einer App-Adresse oder von Anjas eigener?

## Befund: Anjas Hotmail-Adresse geht nicht

Anja nutzt eine Adresse bei `hotmail.com`. Diese kann **nicht** als Absender für
den Serverversand dienen. Zwei unabhängige Gründe:

**1. Resend akzeptiert sie nicht.** Transaktionsdienste erlauben den Versand nur
von Domains, die per DNS-Eintrag verifiziert wurden (DKIM). `hotmail.com` gehört
Microsoft — wir haben dort keinen DNS-Zugriff und können die Domain nie
verifizieren. Das gilt für jeden Anbieter, nicht nur Resend. Resends Testdomain
`onboarding@resend.dev` sendet ausschließlich an die eigene Kontoadresse und ist
für einen Chor nutzlos.

**2. Die Zustellung wäre unzuverlässig.** DNS-Abfrage vom 2026-09-07:

```
hotmail.com  SPF:   "v=spf1 include:spf2.outlook.com -all"
hotmail.com  DMARC: "v=DMARC1; p=none; rua=...; ruf=...; fo=1:s:d"
```

Das `-all` ist ein Hard Fail: Microsoft erklärt jeden Versand über fremde Server
für ungültig. Resend steht nicht im Include. Jede Mail wäre also ein
SPF-Hardfail ohne DKIM-Alignment.

Das DMARC steht auf `p=none`, Microsoft würde die Zustellung also nicht selbst
per Policy blockieren. Darauf ist aber kein Verlass: Die Empfänger sind
Chormitglieder mit Postfächern bei Gmail, GMX und Web.de. Deren eigene Filter
bewerten SPF-Hardfail ohne Alignment als starkes Spam-Signal. Zahlungs-
erinnerungen im Spam-Ordner sind schlechter als gar keine — genau das Risiko,
das im Lastenheft als R-008 geführt wird.

## Entscheidung: Dienst

**Resend bleibt.** Der Dienst ist in der Edge Function fest verdrahtet
(`RESEND_BATCH_URL`, Payload-Format); ein Wechsel würde die Function erfordern,
ohne das eigentliche Problem — die fehlende Absenderdomain — zu lösen.

## Offene Entscheidung: Absenderdomain

Zu klären ist ausschließlich, **welche Domain** als Absender dient.

**Zuerst zu prüfen:** Hat der Chor bereits eine Domain (Vereinswebsite)? Dann
entfällt der Kauf und es geht nur noch um DNS-Zugriff.

**Andernfalls:** Eigene Domain registrieren, ca. 10–15 € pro Jahr.

### Empfohlene Konstruktion

Versand über die eigene Domain, Antworten an Anjas bestehendes Postfach:

```
From:     chor@<eigene-domain>     ← DKIM-signiert, SPF-konform
Reply-To: <Anjas Hotmail-Adresse>  ← Antworten landen wie gewohnt bei ihr
```

Anja braucht dadurch **kein neues Postfach**. Sie schreibt und liest weiter in
Hotmail; nur der technische Versandweg läuft über die eigene Domain.

Die Edge Function unterstützt das seit 2026-09-07 über das optionale Secret
`REPLY_TO_EMAIL`. Es ist bewusst ein Secret und keine Konstante im Code, damit
Anjas private Adresse nicht im öffentlichen Repository steht.

## Verworfene Alternativen

| Alternative | Warum verworfen |
|---|---|
| Versand über Anjas Hotmail-SMTP | Microsoft hat Basic Auth für private Konten abgeschafft; nur noch über OAuth. Deutlich mehr Aufwand, und ihre Zugangsdaten lägen im System — ein Rückschritt gegenüber dem gerade erreichten RLS-Stand. |
| Dauerhaft bei `mailto:` bleiben | Kein Versandprotokoll (FA-104), auf dem iPhone mit vielen Empfängern unangenehm, und die bereits gebaute Edge Function samt FA-100–104 wäre Rückbau. Als Übergang aber tauglich, siehe unten. |
| Anderer Transaktionsdienst | Löst das Problem nicht — jeder Dienst verlangt eine verifizierte Domain. |

## Übergangslösung bis zur Entscheidung (aktiv seit 2026-09-07)

Solange keine verifizierte Absenderdomain existiert, versendet die App über
`mailto:` — sie öffnet Anjas Mailprogramm mit fertig vorbereiteter Mail, sie
sendet selbst aus Hotmail. Damit gibt es keine Zustellprobleme, weil Hotmail
seine eigenen Mails ganz normal versendet.

- Umschalter: `MAIL_VERSAND_MODUS` in `index.html` (`'mailto'` / `'server'`).
- Mehrere Empfänger landen im **BCC**, damit die Mitglieder die Adressen der
  anderen nicht sehen (NF-013).
- Das Versandprotokoll (FA-104) wird nur nach ausdrücklicher Bestätigung
  geschrieben — der Browser erfährt nicht, ob tatsächlich gesendet wurde.
- Bei sehr langen Mails warnt die App, weil Mailprogramme lange `mailto:`-URLs
  stillschweigend kürzen.

## Nächste Schritte

1. Anja fragen: Hat der Chor eine Domain? → Falls ja, DNS-Zugriff klären.
2. Falls nein: Domain registrieren und auf einen Namen einigen.
3. Domain in Resend hinzufügen, angezeigte DNS-Einträge setzen (DKIM, SPF,
   Return-Path), Verifizierung abwarten.
4. Supabase → Edge Functions → Secrets: `RESEND_API_KEY`, `SENDER_EMAIL`,
   `REPLY_TO_EMAIL` setzen.
5. `supabase functions deploy send-email`.
6. `MAIL_VERSAND_MODUS` auf `'server'` stellen, committen, pushen.
7. Offene Abnahmekriterien aus AP-0402 nachholen: fremde Empfängeradresse → 400,
   Rate-Limit → 429.
8. Diesen Eintrag und die Zeile OP-EMAIL-01 im Lastenheft auf „Geklärt" setzen.

## Verweise

- `01_Anforderungen/Lastenheft.md` — FA-100–104, R-008, Offene Punkte
- `04_Implementierung/plan-verbesserungen-2026-08/04_qualitaet/AP-0402_send_email_absichern.md`
- `04_Implementierung/Umsetzungsplan-v3_Restarbeiten.md` — Abschnitt 2
- `supabase/functions/send-email/index.ts`
