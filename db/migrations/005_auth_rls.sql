-- =============================================================================
-- Migration 005: Supabase Auth + Row-Level Security (Phase 5-V2, v2.0)
-- Security foundation — NF-014 (whole app behind Supabase Auth),
-- NF-013a (privacy by design), R-006 (RLS must isolate member data).
--
-- Run ONCE in the Supabase SQL editor AFTER 001–004:
--   Dashboard → SQL Editor → New query
--   https://supabase.com/dashboard/project/guxvlbrxzmgylojbxjew/sql
--
-- What this migration does, per table (choere, probennotizen, lieder,
-- proben_lieder, termine, termine_lieder, ideen):
--   1. Add a `user_id` column that defaults to the logged-in user (auth.uid()).
--   2. Enable row-level security (RLS).
--   3. Drop the previous OPEN policies (using(true) / to anon) from 002–004.
--   4. Add a single owner policy: a row is visible/writable ONLY to the user
--      whose id matches user_id.
--
-- Why dropping the old policies is mandatory: PostgreSQL combines permissive
-- policies with OR. An `using (true)` policy left in place would grant every
-- request access regardless of user_id, silently defeating the new isolation.
-- Each open policy is therefore removed before the owner policy is added.
--
-- Existing test rows keep user_id = NULL. Because every owner policy requires
-- auth.uid() = user_id and auth.uid() is never NULL for a logged-in user,
-- those old rows are invisible to everyone. The app re-seeds «Mein Chor» on the
-- first login (handled client-side in initChoere), so this is the intended
-- clean-slate behaviour, not data loss to worry about.
--
-- Idempotent: safe to re-run (IF [NOT] EXISTS / DROP POLICY IF EXISTS guards).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- choere — FA-000 (choir management). Had NO RLS until now (migration 001).
-- -----------------------------------------------------------------------------
alter table choere
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table choere enable row level security;

-- No prior policy existed on choere — nothing to drop.

-- Owner policy: a choir row belongs to exactly one user. USING gates SELECT/
-- UPDATE/DELETE to rows the caller owns; WITH CHECK forbids inserting/altering a
-- row to carry someone else's user_id. Together they make every choir — and via
-- the chor_id foreign keys, every dependent record — private to its owner.
drop policy if exists "choere_owner" on choere;
create policy "choere_owner" on choere
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- probennotizen — FA-040–042. Replaces the open policy from migration 002.
-- -----------------------------------------------------------------------------
alter table probennotizen
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table probennotizen enable row level security;

-- Remove the v1.x open policy (using(true)) — otherwise it would OR-grant all.
drop policy if exists "probennotizen_allow_all" on probennotizen;

-- Owner policy: rehearsal notes are scoped to their author. Even though notes
-- also carry chor_id, gating directly on user_id is the authoritative check —
-- it does not depend on the parent choir's policy and so cannot be bypassed by
-- a forged chor_id.
drop policy if exists "probennotizen_owner" on probennotizen;
create policy "probennotizen_owner" on probennotizen
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- lieder — FA-050–055. Replaces the open policy from migration 003.
-- -----------------------------------------------------------------------------
alter table lieder
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table lieder enable row level security;

drop policy if exists "lieder_allow_all" on lieder;

-- Owner policy: each song row is private to its creator. This restricts the
-- repertoire list (SELECT) and any edit/delete to the owner, so one user can
-- never read or modify another user's repertoire.
drop policy if exists "lieder_owner" on lieder;
create policy "lieder_owner" on lieder
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- proben_lieder — FA-051/052 (rehearsal plan). Replaces open policy from 003.
-- -----------------------------------------------------------------------------
alter table proben_lieder
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table proben_lieder enable row level security;

drop policy if exists "proben_lieder_allow_all" on proben_lieder;

-- Owner policy: a rehearsal-plan entry links a song to a date for one user.
-- Gating on user_id keeps each user's daily plan isolated and prevents writing
-- entries on behalf of another user.
drop policy if exists "proben_lieder_owner" on proben_lieder;
create policy "proben_lieder_owner" on proben_lieder
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- termine — FA-070. Replaces the `to anon` open policy from migration 004.
-- -----------------------------------------------------------------------------
alter table termine
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table termine enable row level security;

drop policy if exists "anon_all_termine" on termine;

-- Owner policy: events/appointments are private per user. Restricting both read
-- and write to auth.uid() = user_id ensures the year-planning calendar shows
-- only the owner's events.
drop policy if exists "termine_owner" on termine;
create policy "termine_owner" on termine
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- termine_lieder — FA-071 (song↔event junction). Replaces open policy from 004.
-- This junction table has no chor_id, so user_id is its ONLY ownership anchor.
-- -----------------------------------------------------------------------------
alter table termine_lieder
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table termine_lieder enable row level security;

drop policy if exists "anon_all_termine_lieder" on termine_lieder;

-- Owner policy: because this table only stores (termin_id, lied_id) pairs, a
-- direct user_id check is required to isolate the links — there is no other
-- column to scope by. USING/WITH CHECK on user_id keep one user's event-song
-- assignments invisible and unwritable to anyone else.
drop policy if exists "termine_lieder_owner" on termine_lieder;
create policy "termine_lieder_owner" on termine_lieder
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- ideen — FA-072 (idea collection). Replaces the open policy from migration 004.
-- -----------------------------------------------------------------------------
alter table ideen
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

alter table ideen enable row level security;

drop policy if exists "anon_all_ideen" on ideen;

-- Owner policy: programme ideas are private notes. Scoping read and write to
-- auth.uid() = user_id keeps each user's idea collection isolated.
drop policy if exists "ideen_owner" on ideen;
create policy "ideen_owner" on ideen
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- Storage: noten-pdfs bucket (FA-053). The read/insert/update/delete policies
-- from migration 003 carry NO `to` clause, so they apply to the `authenticated`
-- role as well — logged-in PDF upload/view keeps working after auth is enabled.
-- Per-user object isolation can be tightened later (path-prefix policy); not
-- required for this migration and intentionally left unchanged to avoid
-- breaking existing repertoire PDFs.
-- -----------------------------------------------------------------------------

-- =============================================================================
-- End of migration 005. Verify in SQL editor:
--   select tablename, policyname, qual from pg_policies
--   where tablename in ('choere','probennotizen','lieder','proben_lieder',
--                       'termine','termine_lieder','ideen');
-- Each table must show exactly one *_owner policy with qual = (auth.uid() = user_id).
-- =============================================================================
