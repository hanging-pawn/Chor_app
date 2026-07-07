-- Migration 002: probennotizen
-- Probe notes table — FA-040 (free note field), FA-041 (history), FA-042 (mark flag)
-- Run once in the Supabase SQL editor AFTER migration 001_choere.sql.
-- Requires the `choere` table (chor_id foreign key).

-- ── Table ────────────────────────────────────────────────────────────────────
create table if not exists probennotizen (
  id          uuid        not null default gen_random_uuid() primary key,
  chor_id     uuid        not null references choere(id) on delete cascade,
  datum       date        not null,
  inhalt      text,
  markiert    boolean     not null default false,
  erstellt_am timestamptz not null default now()
);

-- ── Index ────────────────────────────────────────────────────────────────────
-- Fast reverse-chronological lookup per choir (primary query pattern)
create index if not exists idx_probennotizen_chor_datum
  on probennotizen (chor_id, datum desc);

-- ── Row-Level Security ───────────────────────────────────────────────────────
-- Currently open (no auth in v1.0–v1.3, NF-010).
-- Will be replaced with user-scoped policies in v2.0 (Supabase Auth, NF-014).
alter table probennotizen enable row level security;

create policy "probennotizen_allow_all" on probennotizen
  for all
  using (true)
  with check (true);
