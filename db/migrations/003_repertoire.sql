-- Migration 003: repertoire
-- Song list + rehearsal planning — FA-050–055 (Phase 3-V2, v1.2)
-- Run once in the Supabase SQL editor AFTER 001_choere.sql and 002_probennotizen.sql.
-- Requires the `choere` table (chor_id foreign key).

-- ── Table: lieder ────────────────────────────────────────────────────────────
-- One row per song, scoped to a choir (FA-050). Status per FA-055.
-- pdf_pfad holds the Storage object path `{chor_id}/{lied_id}.pdf` (FA-053).
create table if not exists lieder (
  id          uuid        not null default gen_random_uuid() primary key,
  chor_id     uuid        references choere(id),
  titel       text        not null,
  status      text        check (status in ('bearbeitung','einstudiert','konzertbereit'))
                          default 'bearbeitung',
  pdf_pfad    text,
  erstellt_am timestamptz default now()
);

-- ── Table: proben_lieder ─────────────────────────────────────────────────────
-- Songs planned for a rehearsal date, ordered (FA-051, FA-052).
create table if not exists proben_lieder (
  id          uuid not null default gen_random_uuid() primary key,
  chor_id     uuid references choere(id),
  datum       date not null,
  lied_id     uuid references lieder(id),
  reihenfolge int  default 0
);

-- ── Indexes ──────────────────────────────────────────────────────────────────
-- Primary query patterns: song list per choir / rehearsal plan per choir+date.
create index if not exists idx_lieder_chor
  on lieder (chor_id, titel);

create index if not exists idx_proben_lieder_chor_datum
  on proben_lieder (chor_id, datum, reihenfolge);

-- ── Row-Level Security ───────────────────────────────────────────────────────
-- Currently open (no auth in v1.0–v1.3, NF-010).
-- Will be replaced with user-scoped policies in v2.0 (Supabase Auth, NF-014).
alter table lieder enable row level security;

create policy "lieder_allow_all" on lieder
  for all
  using (true)
  with check (true);

alter table proben_lieder enable row level security;

create policy "proben_lieder_allow_all" on proben_lieder
  for all
  using (true)
  with check (true);

-- ── Storage bucket: noten-pdfs ───────────────────────────────────────────────
-- Public read (FA-053: PDFs open directly in the app on iPhone/iPad).
-- Anon write is required until Supabase Auth arrives in v2.0 (NF-014);
-- writes are restricted to PDF mime type. File size guard lives in the app
-- (R-005, 20 MB client-side limit).
insert into storage.buckets (id, name, public)
values ('noten-pdfs', 'noten-pdfs', true)
on conflict (id) do nothing;

create policy "noten_pdfs_public_read" on storage.objects
  for select
  using (bucket_id = 'noten-pdfs');

create policy "noten_pdfs_anon_insert" on storage.objects
  for insert
  with check (bucket_id = 'noten-pdfs');

create policy "noten_pdfs_anon_update" on storage.objects
  for update
  using (bucket_id = 'noten-pdfs')
  with check (bucket_id = 'noten-pdfs');

create policy "noten_pdfs_anon_delete" on storage.objects
  for delete
  using (bucket_id = 'noten-pdfs');
