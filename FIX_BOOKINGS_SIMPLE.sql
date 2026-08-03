-- Simple fix: Just add the missing columns
-- Run this in Supabase SQL Editor

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS transaction_id TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS zone_id UUID;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS amount DECIMAL(10, 2);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS booking_date TIMESTAMP WITH TIME ZONE;

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_bookings_transaction_id ON bookings(transaction_id);
CREATE INDEX IF NOT EXISTS idx_bookings_zone_id ON bookings(zone_id);

-- Verify the columns were added
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'bookings'
AND column_name IN ('transaction_id', 'zone_id', 'amount', 'booking_date')
ORDER BY column_name;
