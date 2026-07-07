-- =============================================================================
-- Migration 006: Mitglieder (Phase 6-V2, v2.0)
-- Member management — FA-080 (CRUD), FA-081 (CSV export handled client-side),
-- NF-013 (DSGVO/DSG), NF-013a (Privacy by Design), NF-014 (Auth + RLS).
--
-- Prerequisites: migrations 001–005 must be applied first.
--
-- Run ONCE in the Supabase SQL editor:
--   Dashboard → SQL Editor → New query
--   https://supabase.com/dashboard/project/guxvlbrxzmgylojbxjew/sql
--
-- What this migration does:
--   1. Create table `mitglieder` with all required fields (FA-080).
--   2. Enable RLS and add the owner policy (NF-014) — same pattern as 005.
--
-- Stimmlage constraint: the CHECK enforces the six allowed voice types; NULL is
-- explicitly permitted because the field is optional (FA-080).
--
-- Idempotent: safe to re-run (IF [NOT] EXISTS / DROP POLICY IF EXISTS guards).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Table: mitglieder — FA-080
-- Stores choir members with personal contact and voice data.
-- Each row is owned by exactly one authenticated user (via user_id).
-- chor_id links to the choir the member belongs to (FA-000 multi-choir).
-- -----------------------------------------------------------------------------
create table if not exists mitglieder (
  id           uuid        default gen_random_uuid() primary key,
  user_id      uuid        references auth.users(id) on delete cascade
                           default auth.uid(),
  chor_id      uuid        references choere(id)    on delete cascade,

  -- Required fields (FA-080)
  vorname      text        not null,
  nachname     text        not null,
  email        text        not null,

  -- Optional fields (FA-080)
  adresse      text,
  telefon      text,

  -- Voice type — optional; NULL allowed (FA-080 "optional")
  -- Allowed values mirror the six classical choir voice classifications.
  stimmlage    text        check (stimmlage in (
                             'sopran', 'mezzosopran', 'alt',
                             'tenor',  'bariton',     'bass',
                             null
                           )),

  erstellt_am  timestamptz default now()
);


-- -----------------------------------------------------------------------------
-- Row-Level Security — NF-014
-- All member data is restricted to the authenticated user who owns it.
-- Pattern is identical to the owner policies in migration 005.
-- -----------------------------------------------------------------------------
alter table mitglieder enable row level security;

-- Owner policy: a member row is readable and writable ONLY by the user whose
-- id matches user_id. USING gates SELECT/UPDATE/DELETE; WITH CHECK prevents
-- inserting a row with a foreign user_id.
drop policy if exists "mitglieder_owner" on mitglieder;
create policy "mitglieder_owner" on mitglieder
  for all
  using  (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =============================================================================
-- End of migration 006. Verify in SQL editor:
--   select tablename, policyname, qual from pg_policies
--   where tablename = 'mitglieder';
-- Should show exactly one row: mitglieder | mitglieder_owner | (auth.uid() = user_id)
-- =============================================================================
