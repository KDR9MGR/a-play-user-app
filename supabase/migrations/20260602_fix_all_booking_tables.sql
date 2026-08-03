-- Migration: Ensure all booking tables have required payment fields
-- Date: 2026-06-02
-- Purpose: Add transaction_id and payment fields to all booking tables

-- =====================================================
-- 1. FIX CLUB_BOOKINGS TABLE (if it exists)
-- =====================================================
DO $$
BEGIN
  -- Check if club_bookings table exists
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'club_bookings') THEN
    -- Add payment columns if they don't exist
    ALTER TABLE club_bookings
      ADD COLUMN IF NOT EXISTS transaction_id TEXT,
      ADD COLUMN IF NOT EXISTS payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
      ADD COLUMN IF NOT EXISTS payment_method TEXT,
      ADD COLUMN IF NOT EXISTS payment_reference TEXT,
      ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(10,2),
      ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'GHS';

    -- Create indexes
    CREATE INDEX IF NOT EXISTS idx_club_bookings_transaction_id ON club_bookings(transaction_id);
    CREATE INDEX IF NOT EXISTS idx_club_bookings_payment_status ON club_bookings(payment_status);

    -- Update existing bookings
    UPDATE club_bookings
    SET payment_status = 'pending'
    WHERE payment_status IS NULL;

    RAISE NOTICE 'club_bookings table updated successfully';
  ELSE
    RAISE NOTICE 'club_bookings table does not exist, skipping';
  END IF;
END $$;

-- =====================================================
-- 2. VERIFY RESTAURANT_BOOKINGS TABLE
-- =====================================================
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'restaurant_bookings') THEN
    -- Ensure all payment columns exist (in case migration was missed)
    ALTER TABLE restaurant_bookings
      ADD COLUMN IF NOT EXISTS transaction_id TEXT,
      ADD COLUMN IF NOT EXISTS payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
      ADD COLUMN IF NOT EXISTS payment_method TEXT,
      ADD COLUMN IF NOT EXISTS payment_reference TEXT,
      ADD COLUMN IF NOT EXISTS amount_paid DECIMAL(10,2),
      ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'GHS';

    CREATE INDEX IF NOT EXISTS idx_restaurant_bookings_transaction_id ON restaurant_bookings(transaction_id);
    CREATE INDEX IF NOT EXISTS idx_restaurant_bookings_payment_status ON restaurant_bookings(payment_status);

    RAISE NOTICE 'restaurant_bookings table verified/updated successfully';
  ELSE
    RAISE NOTICE 'restaurant_bookings table does not exist, skipping';
  END IF;
END $$;

-- =====================================================
-- 3. VERIFY BOOKINGS TABLE (events)
-- =====================================================
-- Already handled by previous migration 20260602_fix_bookings_schema.sql
-- Just verify columns exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'bookings' AND column_name = 'transaction_id'
  ) THEN
    RAISE WARNING 'bookings table missing transaction_id column! Run FIX_BOOKINGS_SIMPLE.sql first';
  ELSE
    RAISE NOTICE 'bookings table (events) already has required columns';
  END IF;
END $$;

-- =====================================================
-- 4. CREATE PUB_BOOKINGS TABLE (if needed)
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pub_bookings') THEN
    CREATE TABLE pub_bookings (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
      pub_id UUID NOT NULL REFERENCES pubs(id) ON DELETE CASCADE,

      booking_date DATE NOT NULL,
      start_time TIMESTAMP WITH TIME ZONE NOT NULL,
      end_time TIMESTAMP WITH TIME ZONE NOT NULL,
      party_size INTEGER NOT NULL CHECK (party_size > 0),

      -- Payment fields
      transaction_id TEXT,
      payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')) DEFAULT 'pending',
      payment_method TEXT,
      payment_reference TEXT,
      amount_paid DECIMAL(10,2),
      currency TEXT DEFAULT 'GHS',

      -- Booking status
      status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
      special_requests TEXT,

      -- Timestamps
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      cancelled_at TIMESTAMP WITH TIME ZONE
    );

    -- Indexes
    CREATE INDEX idx_pub_bookings_user_id ON pub_bookings(user_id);
    CREATE INDEX idx_pub_bookings_pub_id ON pub_bookings(pub_id);
    CREATE INDEX idx_pub_bookings_transaction_id ON pub_bookings(transaction_id);
    CREATE INDEX idx_pub_bookings_status ON pub_bookings(status);
    CREATE INDEX idx_pub_bookings_date ON pub_bookings(booking_date);

    RAISE NOTICE 'pub_bookings table created successfully';
  ELSE
    RAISE NOTICE 'pub_bookings table already exists';
  END IF;
END $$;

-- =====================================================
-- 5. CREATE BEACH_BOOKINGS TABLE (if needed)
-- =====================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'beach_bookings') THEN
    CREATE TABLE beach_bookings (
      id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
      user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
      beach_id UUID NOT NULL REFERENCES beaches(id) ON DELETE CASCADE,

      booking_date DATE NOT NULL,
      start_time TIMESTAMP WITH TIME ZONE NOT NULL,
      end_time TIMESTAMP WITH TIME ZONE NOT NULL,
      party_size INTEGER NOT NULL CHECK (party_size > 0),

      -- Beach-specific fields
      cabana_rental BOOLEAN DEFAULT false,
      equipment_rental TEXT[],  -- ['surfboard', 'umbrella', etc.]

      -- Payment fields
      transaction_id TEXT,
      payment_status TEXT CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')) DEFAULT 'pending',
      payment_method TEXT,
      payment_reference TEXT,
      amount_paid DECIMAL(10,2),
      currency TEXT DEFAULT 'GHS',

      -- Booking status
      status TEXT NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
      special_requests TEXT,

      -- Timestamps
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      cancelled_at TIMESTAMP WITH TIME ZONE
    );

    -- Indexes
    CREATE INDEX idx_beach_bookings_user_id ON beach_bookings(user_id);
    CREATE INDEX idx_beach_bookings_beach_id ON beach_bookings(beach_id);
    CREATE INDEX idx_beach_bookings_transaction_id ON beach_bookings(transaction_id);
    CREATE INDEX idx_beach_bookings_status ON beach_bookings(status);
    CREATE INDEX idx_beach_bookings_date ON beach_bookings(booking_date);

    RAISE NOTICE 'beach_bookings table created successfully';
  ELSE
    RAISE NOTICE 'beach_bookings table already exists';
  END IF;
END $$;

-- =====================================================
-- 6. SUMMARY QUERY
-- =====================================================
-- Show which tables exist and have transaction_id column
SELECT
  t.table_name,
  CASE WHEN c.column_name IS NOT NULL THEN '✓' ELSE '✗' END AS has_transaction_id,
  CASE WHEN p.column_name IS NOT NULL THEN '✓' ELSE '✗' END AS has_payment_status
FROM information_schema.tables t
LEFT JOIN information_schema.columns c
  ON t.table_name = c.table_name AND c.column_name = 'transaction_id'
LEFT JOIN information_schema.columns p
  ON t.table_name = p.table_name AND p.column_name = 'payment_status'
WHERE t.table_name IN ('bookings', 'club_bookings', 'restaurant_bookings', 'pub_bookings', 'beach_bookings')
  AND t.table_schema = 'public'
ORDER BY t.table_name;
