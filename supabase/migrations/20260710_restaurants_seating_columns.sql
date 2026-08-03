-- Applied live via `supabase db query` on 2026-07-10; tracked here.

-- Admin dashboard's restaurant create/edit forms manage seating capacity and
-- table count, but the live table never had these columns, so BOTH create
-- and edit failed with "Could not find the 'seating_capacity' column of
-- 'restaurants' in the schema cache".
ALTER TABLE restaurants
  ADD COLUMN IF NOT EXISTS seating_capacity integer,
  ADD COLUMN IF NOT EXISTS total_tables integer;
