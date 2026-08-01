-- =============================================================================
-- Migration 010: Dauerhafte Notiz am Lied
-- Freitext-Hinweis, der bei jeder Probe zum Lied angezeigt wird
-- (z. B. «Tenor-Einsatz T. 24 heikel»). Eingabe im Repertoire-Tab.
--
-- Bewusst NUR am Lied, nicht zusätzlich an proben_lieder: probenspezifische
-- Hinweise gehören in die allgemeine Probennotiz (Entscheid 2026-08-01).
--
-- Voraussetzung: 003_repertoire.sql
-- Idempotent.
-- =============================================================================

alter table lieder
  add column if not exists notiz text;

comment on column lieder.notiz is
  'Dauerhafter Hinweis zum Lied; erscheint in der Probenübersicht und im Pianisten-PDF.';
