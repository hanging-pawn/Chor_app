-- Migration: 001_choere
-- Creates the choir management table and seeds a default choir.
--
-- Run this in the Supabase SQL editor:
--   https://supabase.com/dashboard/project/guxvlbrxzmgylojbxjew/sql

-- Create choere table (idempotent)
CREATE TABLE IF NOT EXISTS choere (
  id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text         NOT NULL,
  erstellt_am timestamptz  DEFAULT now()
);

-- Seed default choir if the table is empty
INSERT INTO choere (name)
SELECT 'Mein Chor'
WHERE NOT EXISTS (SELECT 1 FROM choere LIMIT 1);
