-- =============================================================================
-- Migration 007: Buchhaltung (Phase 7-V2, v2.0)
-- Accounting — member contributions (FA-085/086) and expenses (FA-090),
-- the data source for the cash-balance widget (FA-092) and the tax-style,
-- anonymised PDF statement (FA-095–097, NF-013a).
--
-- Prerequisites: migrations 001–006 must be applied first
--   (needs choere, mitglieder and the auth/RLS foundation from 005).
--
-- Run ONCE in the Supabase SQL editor:
--   Dashboard → SQL Editor → New query
--   https://supabase.com/dashboard/project/guxvlbrxzmgylojbxjew/sql
--
-- What this migration does:
--   1. Create table `beitraege` — one contribution row per member per half-year.
--   2. Create table `ausgaben`  — one row per expense.
--   3. Enable RLS and add the owner policy on both — same pattern as 005/006.
--
-- Idempotent: safe to re-run (IF [NOT] EXISTS / DROP POLICY IF EXISTS guards).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Table: beitraege — FA-085 (define amount per half-year), FA-086 (paid status)
-- One row records a single member's contribution for one half-year period.
-- `halbjahr` uses the text format 'YYYY-H1' / 'YYYY-H2' (e.g. '2026-H1').
-- A member has at most one row per (chor_id, mitglied_id, halbjahr).
-- -----------------------------------------------------------------------------
create table if not exists beitraege (
  id           uuid        default gen_random_uuid() primary key,
  user_id      uuid        references auth.users(id) on delete cascade
                           default auth.uid(),
  chor_id      uuid        references choere(id)     on delete cascade,
  mitglied_id  uuid        references mitglieder(id) on delete cascade,

  halbjahr     text        not null,            -- 'YYYY-H1' | 'YYYY-H2'
  betrag       numeric(10,2) not null,          -- contribution amount (CHF)
  bezahlt      boolean     default false,       -- paid? (FA-086)
  bezahlt_am   timestamptz,                     -- timestamp of payment, NULL if open

  erstellt_am  timestamptz default now(),

  -- One contribution row per member and period — lets the app upsert on toggle.
  unique (chor_id, mitglied_id, halbjahr)
);

-- Lookup index for the per-period table view (Mitglieder → Beiträge).
create index if not exists beitraege_chor_halbjahr_idx
  on beitraege (chor_id, halbjahr);


-- -----------------------------------------------------------------------------
-- Table: ausgaben — FA-090 (record expenses), feeds FA-092 cash balance and the
-- «Ausgaben» section of the statement (FA-095).
-- -----------------------------------------------------------------------------
create table if not exists ausgaben (
  id           uuid        default gen_random_uuid() primary key,
  user_id      uuid        references auth.users(id) on delete cascade
                           default auth.uid(),
  chor_id      uuid        references choere(id)     on delete cascade,

  datum        date        not null,            -- expense date
  betrag       numeric(10,2) not null,          -- expense amount (CHF)
  beschreibung text        not null,            -- what the money was spent on
  kategorie    text,                            -- optional grouping

  erstellt_am  timestamptz default now()
);

-- Date index for range filtering in the statement (Zeitraum von/bis, FA-095).
create index if not exists ausgaben_chor_datum_idx
  on ausgaben (chor_id, datum);


-- -----------------------------------------------------------------------------
-- Row-Level Security — NF-014
-- Both tables hold financial data tied to members; restrict every row to the
-- authenticated user who owns it. Pattern is identical to migrations 005/006.
-- USING gates SELECT/UPDATE/DELETE; WITH CHECK blocks inserting a foreign
-- user_id. Gating directly on user_id is the authoritative check and does not
-- depend on the parent choir's or member's policy.
-- -----------------------------------------------------------------------------
alter table beitraege enable row level security;
drop policy if exists "beitraege_owner" on beitraege;
create policy "beitraege_owner" on beitraege
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);

alter table ausgaben enable row level security;
drop policy if exists "ausgaben_owner" on ausgaben;
create policy "ausgaben_owner" on ausgaben
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =============================================================================
-- End of migration 007. Verify in SQL editor:
--   select tablename, policyname, qual from pg_policies
--   where tablename in ('beitraege','ausgaben');
-- Each table must show exactly one *_owner policy with qual = (auth.uid() = user_id).
-- =============================================================================
