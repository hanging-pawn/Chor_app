-- =============================================================================
-- Migration 014: Unique-Index auf choere (user_id, name)
--
-- Schliesst den Niedrig-Befund «Seed-Race» aus dem Code Review 2026-08-15
-- (AP-0406, Umsetzungsschritt 5).
--
-- initChoere() liest die Chorliste und legt «Mein Chor» an, wenn sie leer ist.
-- Zwei parallele Aufrufe — zwei offene Tabs, ein Reload während der ersten
-- Abfrage — sehen beide eine leere Liste und legen beide einen Chor an. Die
-- Nutzerin hat dann zwei identisch benannte Chöre, und die Daten verteilen
-- sich unbemerkt auf beide. Genau dieser Zustand liegt in der Produktivdaten-
-- bank bereits vor (drei Zeilen «Mein Chor», Stand 2026-09-07).
--
-- Der Index macht den zweiten Insert unmöglich; der Client behandelt den
-- Fehler und liest stattdessen den bereits angelegten Chor.
--
-- NULL-Werte in user_id kollidieren nicht: Postgres behandelt NULL in Unique-
-- Indizes als voneinander verschieden. Die verwaiste Zeile ohne Besitzer
-- bleibt also bestehen und blockiert nichts.
--
-- Voraussetzung: 001_choere.sql, 005_auth_rls.sql
-- Idempotent: create unique index if not exists.
--
-- WICHTIG: Der Index kann nur angelegt werden, wenn es aktuell keine echten
-- Duplikate gibt. Vorher prüfen:
--   select user_id, name, count(*) from choere
--   group by user_id, name having count(*) > 1;
-- Erwartet: keine Zeilen. Andernfalls die Duplikate erst zusammenführen.
-- =============================================================================

create unique index if not exists idx_choere_user_name
  on choere (user_id, name);

-- =============================================================================
-- Ende Migration 014. Verifikation:
--   select indexname, indexdef from pg_indexes
--   where tablename = 'choere' and indexname = 'idx_choere_user_name';
-- =============================================================================
