-- Migration: Fix bookings table schema
-- Date: 2026-06-02
-- Purpose: Add missing columns to match application code

-- Add missing columns to bookings table
ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS zone_id UUID REFERENCES zones(id),
  ADD COLUMN IF NOT EXISTS amount DECIMAL(10, 2),
  ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;

-- Create index for transaction_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_bookings_transaction_id ON bookings(transaction_id);

-- Create index for zone_id
CREATE INDEX IF NOT EXISTS idx_bookings_zone_id ON bookings(zone_id);

-- Update existing records to populate new columns from old ones
UPDATE bookings
SET
  transaction_id = payment_reference,
  amount = total_price,
  booking_date = created_at
WHERE transaction_id IS NULL OR amount IS NULL OR booking_date IS NULL;

-- Add comment to explain the column mapping
COMMENT ON COLUMN bookings.transaction_id IS 'PayStack transaction reference ID';
COMMENT ON COLUMN bookings.zone_id IS 'Foreign key to zones table for event seating zones';
COMMENT ON COLUMN bookings.amount IS 'Total amount paid (mirrors total_price for compatibility)';
COMMENT ON COLUMN bookings.booking_date IS 'Date when booking was made (mirrors created_at for compatibility)';
