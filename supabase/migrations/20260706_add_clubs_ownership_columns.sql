-- Adds organizer self-service ownership to `clubs` (previously admin-only:
-- id, name, description, logo_url, created_at, is_active).
--
-- Needed for the organiser app's venue-creation flow (a-play-organiser-main
-- lib/features/venue/): an organizer creates a club, it lands with
-- is_active = false (pending), and only becomes bookable once an admin
-- flips is_active to true - the same convention already used by the
-- pubs/lounges/beaches/restaurants/arcade_centers tables, which already
-- have their own `created_by` column.
--
-- Applied live via `supabase db query` on 2026-07-06; this file exists so
-- the change is tracked instead of only living in the database.

ALTER TABLE clubs
  ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id),
  ADD COLUMN IF NOT EXISTS address text,
  ADD COLUMN IF NOT EXISTS type text,
  ADD COLUMN IF NOT EXISTS capacity integer,
  ADD COLUMN IF NOT EXISTS images text[];

CREATE INDEX IF NOT EXISTS idx_clubs_created_by ON clubs(created_by);
