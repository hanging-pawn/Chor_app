-- Migration 008: email_versand — send log (FA-104, KANN)
-- Stores envelope metadata only; no message content is persisted (privacy by design).
-- Scoped per choir; protected by RLS (NF-013 / NF-014).
--
-- Run in Supabase SQL editor after 007_buchhaltung.sql.

-- ── Table ────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.email_versand (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  chor_id           uuid        NOT NULL REFERENCES public.choere(id) ON DELETE CASCADE,
  datum             timestamptz NOT NULL DEFAULT now(),
  empfaenger_anzahl integer     NOT NULL CHECK (empfaenger_anzahl >= 0),
  betreff           text        NOT NULL,
  -- typ: 'rundmail' | 'zahlungserinnerung' | 'probeninfo'
  typ               text        NOT NULL CHECK (typ IN ('rundmail', 'zahlungserinnerung', 'probeninfo'))
);

-- ── Indexes ──────────────────────────────────────────────────────────────────

-- Descending date is the default access pattern (latest first per choir).
CREATE INDEX IF NOT EXISTS email_versand_chor_datum_idx
  ON public.email_versand (chor_id, datum DESC);

-- ── Row-Level Security ───────────────────────────────────────────────────────

ALTER TABLE public.email_versand ENABLE ROW LEVEL SECURITY;

-- Authenticated user may only see / write rows that belong to her own account.
-- DROP vor CREATE, damit die Migration mehrfach ausführbar ist (AP-0406,
-- Befund 14): CREATE POLICY kennt kein IF NOT EXISTS und brach beim zweiten
-- Lauf mit "policy already exists" ab. Die Migration wurde bereits ausgeführt;
-- die Ergänzung hier stellt nur die Wiederholbarkeit her und ändert nichts am
-- Ergebnis.
DROP POLICY IF EXISTS "owner_select" ON public.email_versand;
CREATE POLICY "owner_select" ON public.email_versand
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "owner_insert" ON public.email_versand;
CREATE POLICY "owner_insert" ON public.email_versand
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- No UPDATE or DELETE — the log is append-only.
