-- =============================================================================
-- Migration 009: Notiztypen für probennotizen
-- Trennt allgemeine Probennotizen von Mitteilungen an den Chor.
-- Ersetzt fachlich das Boolean `markiert` (FA-042).
--
-- Voraussetzung: 002_probennotizen.sql
-- Idempotent: mehrfaches Ausführen ist unschädlich.
-- =============================================================================

-- ── 1. Neue Spalte ───────────────────────────────────────────────────────────
-- Default 'allgemein', damit Bestandszeilen gültig bleiben.
alter table probennotizen
  add column if not exists typ text not null default 'allgemein';

-- CHECK separat, damit die Migration bei erneutem Lauf nicht scheitert.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'probennotizen_typ_check'
  ) then
    alter table probennotizen
      add constraint probennotizen_typ_check
      check (typ in ('allgemein', 'mitteilung'));
  end if;
end $$;

-- ── 2. Bestandsdaten übernehmen ──────────────────────────────────────────────
-- "Dem Chor mitteilen" (markiert = true) wird zur Mitteilung.
update probennotizen
   set typ = 'mitteilung'
 where markiert = true
   and typ = 'allgemein';

-- ── 3. Duplikate zusammenführen ──────────────────────────────────────────────
-- Der Unique-Index unten verlangt höchstens eine Zeile je (chor_id, datum, typ).
-- Ältere Datenbestände können mehrere Notizen pro Datum enthalten; diese werden
-- inhaltlich zusammengeführt (chronologisch, durch Leerzeile getrennt), damit
-- kein Text verloren geht.
-- array_agg statt min(): für uuid existiert keine min()-Aggregatfunktion.
with ranked as (
  select id, chor_id, datum, typ, inhalt, erstellt_am,
         row_number() over (partition by chor_id, datum, typ
                            order by erstellt_am, id) as rn
    from probennotizen
),
merged as (
  select chor_id, datum, typ,
         string_agg(coalesce(inhalt, ''), E'\n\n' order by rn) as inhalt_neu,
         (array_agg(id order by rn))[1]                        as keep_id
    from ranked
   group by chor_id, datum, typ
  having count(*) > 1
)
update probennotizen p
   set inhalt = m.inhalt_neu
  from merged m
 where p.id = m.keep_id;

delete from probennotizen p
 using (
   select id,
          row_number() over (partition by chor_id, datum, typ
                             order by erstellt_am, id) as rn
     from probennotizen
 ) r
 where p.id = r.id
   and r.rn > 1;

-- ── 4. Eindeutigkeit erzwingen ───────────────────────────────────────────────
-- Pro Chor und Datum genau eine allgemeine Notiz und eine Mitteilung.
-- Die App arbeitet mit Upsert auf diesem Schlüssel.
create unique index if not exists uq_probennotizen_chor_datum_typ
  on probennotizen (chor_id, datum, typ);

-- ── 5. Hinweis zu `markiert` ─────────────────────────────────────────────────
-- Die Spalte bleibt vorerst bestehen (Altdaten, Rollback-Sicherheit).
-- Die App schreibt sie nicht mehr. Entfernen in einer späteren Migration:
--   alter table probennotizen drop column markiert;
