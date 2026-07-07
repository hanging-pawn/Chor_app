-- =============================================================================
-- Migration 004: Jahresplanung (FA-070–073)
-- Tables: termine, termine_lieder, ideen
--
-- Run in Supabase SQL editor: Dashboard → SQL Editor → New query
-- Prerequisites: 001_choere.sql, 003_repertoire.sql (lieder table)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- termine: appointments/events per choir (FA-070)
-- -----------------------------------------------------------------------------
create table if not exists termine (
  id          uuid        default gen_random_uuid() primary key,
  chor_id     uuid        references choere(id) on delete cascade,
  datum       date        not null,
  titel       text        not null,
  typ         text        check (typ in ('auftritt', 'probe', 'deadline', 'sonstiges')),
  notiz       text,
  erstellt_am timestamptz default now()
);

-- Index: fast date-range queries per choir
create index if not exists termine_chor_datum_idx
  on termine (chor_id, datum);

-- -----------------------------------------------------------------------------
-- termine_lieder: songs assigned to an event (FA-071)
-- CASCADE delete: removing a Termin clears its song links automatically.
-- -----------------------------------------------------------------------------
create table if not exists termine_lieder (
  termin_id uuid references termine(id) on delete cascade,
  lied_id   uuid references lieder(id)  on delete cascade,
  primary key (termin_id, lied_id)
);

-- -----------------------------------------------------------------------------
-- ideen: idea collection for concert programmes (FA-072)
-- -----------------------------------------------------------------------------
create table if not exists ideen (
  id          uuid        default gen_random_uuid() primary key,
  chor_id     uuid        references choere(id) on delete cascade,
  inhalt      text        not null,
  erstellt_am timestamptz default now()
);

-- -----------------------------------------------------------------------------
-- Row Level Security
-- v1.3 has no Auth yet — open anon policies (tightened in v2.0 with RLS+Auth).
-- -----------------------------------------------------------------------------
alter table termine       enable row level security;
alter table termine_lieder enable row level security;
alter table ideen         enable row level security;

-- anon: full access (read + write) — tightened to authenticated in v2.0
do $$
begin
  if not exists (
    select 1 from pg_policies where tablename = 'termine' and policyname = 'anon_all_termine'
  ) then
    execute $p$
      create policy anon_all_termine
        on termine for all to anon
        using (true) with check (true)
    $p$;
  end if;

  if not exists (
    select 1 from pg_policies where tablename = 'termine_lieder' and policyname = 'anon_all_termine_lieder'
  ) then
    execute $p$
      create policy anon_all_termine_lieder
        on termine_lieder for all to anon
        using (true) with check (true)
    $p$;
  end if;

  if not exists (
    select 1 from pg_policies where tablename = 'ideen' and policyname = 'anon_all_ideen'
  ) then
    execute $p$
      create policy anon_all_ideen
        on ideen for all to anon
        using (true) with check (true)
    $p$;
  end if;
end $$;
