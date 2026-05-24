-- Migration: Add Payment Fields to Restaurant Bookings
-- Purpose: Enable payment tracking for restaurant table reservations
-- Date: 2026-03-21

-- Add payment-related columns to restaurant_bookings table
ALTER TABLE restaurant_bookings
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
  ADD COLUMN IF NOT EXISTS payment_method TEXT,
  ADD COLUMN IF NOT EXISTS payment_reference TEXT,
  ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(10,2),
  ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'GHS';

-- Create index for faster payment reference lookups
CREATE INDEX IF NOT EXISTS idx_restaurant_bookings_payment_ref
  ON restaurant_bookings(payment_reference);

CREATE INDEX IF NOT EXISTS idx_restaurant_bookings_transaction_id
  ON restaurant_bookings(transaction_id);

-- Create index for payment status queries
CREATE INDEX IF NOT EXISTS idx_restaurant_bookings_payment_status
  ON restaurant_bookings(payment_status);

-- Add constraint to ensure amount_paid is positive
ALTER TABLE restaurant_bookings
  ADD CONSTRAINT check_amount_paid_positive
  CHECK (amount_paid IS NULL OR amount_paid >= 0);

-- Update existing bookings to have 'pending' status if no payment status
UPDATE restaurant_bookings
SET payment_status = 'pending'
WHERE payment_status IS NULL;

-- Comment on new columns
COMMENT ON COLUMN restaurant_bookings.transaction_id IS 'PayStack transaction ID';
COMMENT ON COLUMN restaurant_bookings.payment_status IS 'Payment status: pending, paid, failed, refunded';
COMMENT ON COLUMN restaurant_bookings.payment_method IS 'Payment method used (paystack, apple_pay, etc.)';
COMMENT ON COLUMN restaurant_bookings.payment_reference IS 'Unique payment reference for idempotency';
COMMENT ON COLUMN restaurant_bookings.amount_paid IS 'Amount paid for the booking/deposit';
COMMENT ON COLUMN restaurant_bookings.currency IS 'Currency code (default: GHS)';
