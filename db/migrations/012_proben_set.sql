-- =============================================================================
-- Migration 012: Einsing-Set pro Probe speichern
--
-- Bis hierher lebte das generierte Set nur im Browser-Speicher (currentSet) und
-- war nach einem Reload verschwunden. Für das Pianisten-PDF muss es abrufbar
-- sein, auch Tage nach dem Generieren.
--
-- set_json ist ein vollständiger Snapshot der Übungen, nicht eine Liste von IDs:
-- ein späteres Ändern der Übungsdatenbank soll ein bereits versendetes Programm
-- nicht rückwirkend verfälschen.
--
-- Voraussetzung: 001_choere.sql
-- Idempotent.
-- =============================================================================

create table if not exists proben_set (
  chor_id     uuid        not null references choere(id) on delete cascade,
  datum       date        not null,
  set_json    jsonb       not null,
  erstellt_am timestamptz not null default now(),
  primary key (chor_id, datum)
);

comment on column proben_set.set_json is
  'Snapshot der 5–6 Übungen: [{id, titel, kategorie, dauer, beschreibung, noten}].';

alter table proben_set enable row level security;

drop policy if exists "proben_set_allow_all" on proben_set;
create policy "proben_set_allow_all" on proben_set
  for all using (true) with check (true);
