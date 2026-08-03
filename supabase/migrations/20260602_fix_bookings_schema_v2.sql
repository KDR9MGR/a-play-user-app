-- Migration: Fix bookings table schema (v2 - Safe version)
-- Date: 2026-06-02
-- Purpose: Add missing columns to match application code

-- Add missing columns to bookings table (safe, won't fail if already exist)
ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS zone_id UUID,
  ADD COLUMN IF NOT EXISTS amount DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;

-- Add foreign key constraint for zone_id (only if zones table exists)
-- Skip if constraint already exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'bookings_zone_id_fkey'
  ) THEN
    -- Check if zones table exists first
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'zones') THEN
      ALTER TABLE bookings ADD CONSTRAINT bookings_zone_id_fkey
        FOREIGN KEY (zone_id) REFERENCES zones(id);
    END IF;
  END IF;
END $$;

-- Create indexes for faster lookups (safe, won't fail if already exist)
CREATE INDEX IF NOT EXISTS idx_bookings_transaction_id ON bookings(transaction_id);
CREATE INDEX IF NOT EXISTS idx_bookings_zone_id ON bookings(zone_id);

-- Note: We don't migrate existing data because we don't know which old columns exist
-- New bookings will populate these fields correctly
