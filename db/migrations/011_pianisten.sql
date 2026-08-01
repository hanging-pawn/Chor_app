-- =============================================================================
-- Migration 011: Pianisten und ihre Zuordnung zu Proben
--
-- pianisten       — Stammdaten der Begleiterinnen und Begleiter je Chor
-- proben_pianist  — genau ein zugeordneter Pianist pro Probendatum
--
-- Der Sende-Dialog erlaubt trotzdem mehrere Empfänger (Vertretung,
-- Doppelbesetzung); nur die feste Zuordnung ist auf einen begrenzt.
--
-- Voraussetzung: 001_choere.sql
-- Idempotent.
-- =============================================================================

-- ── Tabelle: pianisten ───────────────────────────────────────────────────────
create table if not exists pianisten (
  id          uuid        not null default gen_random_uuid() primary key,
  chor_id     uuid        not null references choere(id) on delete cascade,
  vorname     text        not null,
  nachname    text        not null,
  email       text        not null,
  telefon     text,
  aktiv       boolean     not null default true,
  erstellt_am timestamptz not null default now()
);

-- Aktive zuerst, dann alphabetisch — entspricht der Anzeige in der App.
create index if not exists idx_pianisten_chor
  on pianisten (chor_id, aktiv desc, nachname, vorname);

-- ── Tabelle: proben_pianist ──────────────────────────────────────────────────
-- Primärschlüssel (chor_id, datum) erzwingt höchstens einen Pianisten je Probe.
-- on delete cascade: wird ein Pianist gelöscht, verschwindet auch die Zuordnung.
create table if not exists proben_pianist (
  chor_id     uuid        not null references choere(id)   on delete cascade,
  datum       date        not null,
  pianist_id  uuid        not null references pianisten(id) on delete cascade,
  erstellt_am timestamptz not null default now(),
  primary key (chor_id, datum)
);

create index if not exists idx_proben_pianist_pianist
  on proben_pianist (pianist_id);

-- ── Row-Level Security ───────────────────────────────────────────────────────
-- Gleiches Muster wie 002/003: vorerst offen (NF-010), wird in v2.0 durch
-- benutzerbezogene Policies ersetzt (NF-014).
alter table pianisten      enable row level security;
alter table proben_pianist enable row level security;

drop policy if exists "pianisten_allow_all" on pianisten;
create policy "pianisten_allow_all" on pianisten
  for all using (true) with check (true);

drop policy if exists "proben_pianist_allow_all" on proben_pianist;
create policy "proben_pianist_allow_all" on proben_pianist
  for all using (true) with check (true);
