-- =============================================================================
-- Migration 013: Owner-RLS für pianisten, proben_pianist, proben_set
-- Schliesst den Sicherheitsbefund aus dem Code Review 2026-08-15 (Befund 1):
-- Die Migrationen 011/012 legten diese Tabellen mit offenen Policies
-- (using(true) / with check(true)) an — jeder Besitzer des öffentlichen
-- anon-Keys konnte ohne Login Pianisten-Kontaktdaten (Name, E-Mail, Telefon)
-- aller Chöre lesen und ändern sowie proben_set-Snapshots manipulieren
-- (persistenter XSS-Vektor in Kombination mit renderCard).
--
-- Vorgehen wie in Migration 005 (siehe dort für die Begründung, warum die
-- offenen Policies zwingend GEDROPPT werden müssen: permissive Policies
-- werden per OR kombiniert).
--
-- Zusätzlich zu 005: Backfill. Bestehende Zeilen tragen user_id = NULL und
-- wären nach dem Policy-Wechsel unsichtbar. Anders als bei 005 (bewusster
-- Clean-Slate vor dem ersten Login) existieren hier bereits produktive Daten
-- von Anja — user_id wird deshalb aus dem Chor-Besitzer (choere.user_id)
-- über chor_id hergeleitet, bevor die Owner-Policies greifen.
--
-- Voraussetzung: 005_auth_rls.sql, 011_pianisten.sql, 012_proben_set.sql
-- Idempotent: safe to re-run (IF [NOT] EXISTS / DROP POLICY IF EXISTS guards;
-- Backfill-Updates filtern auf user_id IS NULL).
-- =============================================================================


-- -----------------------------------------------------------------------------
-- pianisten — FA-090 ff. Ersetzt die offene Policy aus Migration 011.
-- -----------------------------------------------------------------------------
alter table pianisten
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

-- Backfill: Besitzer über den zugehörigen Chor herleiten.
update pianisten p
set user_id = c.user_id
from choere c
where p.chor_id = c.id
  and p.user_id is null;

alter table pianisten enable row level security;

drop policy if exists "pianisten_allow_all" on pianisten;

drop policy if exists "pianisten_owner" on pianisten;
create policy "pianisten_owner" on pianisten
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- proben_pianist — Zuordnung Pianist↔Probe. Ersetzt offene Policy aus 011.
-- -----------------------------------------------------------------------------
alter table proben_pianist
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

update proben_pianist pp
set user_id = c.user_id
from choere c
where pp.chor_id = c.id
  and pp.user_id is null;

alter table proben_pianist enable row level security;

drop policy if exists "proben_pianist_allow_all" on proben_pianist;

drop policy if exists "proben_pianist_owner" on proben_pianist;
create policy "proben_pianist_owner" on proben_pianist
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- -----------------------------------------------------------------------------
-- proben_set — Einsing-Set-Snapshots. Ersetzt offene Policy aus 012.
-- -----------------------------------------------------------------------------
alter table proben_set
  add column if not exists user_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

update proben_set ps
set user_id = c.user_id
from choere c
where ps.chor_id = c.id
  and ps.user_id is null;

alter table proben_set enable row level security;

drop policy if exists "proben_set_allow_all" on proben_set;

drop policy if exists "proben_set_owner" on proben_set;
create policy "proben_set_owner" on proben_set
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);


-- =============================================================================
-- Ende Migration 013. Verifikation im SQL-Editor:
--   select tablename, policyname, qual from pg_policies
--   where tablename in ('pianisten','proben_pianist','proben_set');
-- Jede Tabelle muss genau eine *_owner-Policy mit qual = (auth.uid() = user_id)
-- zeigen — keine *_allow_all-Policy mehr.
--
-- Negativtest (ohne Login, mit anon-Key):
--   curl "https://guxvlbrxzmgylojbxjew.supabase.co/rest/v1/pianisten?select=*" \
--     -H "apikey: <anon-key>"
-- erwartet: leeres Array [].
-- =============================================================================
