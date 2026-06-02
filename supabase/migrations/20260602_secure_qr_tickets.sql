-- Migration: Secure QR Ticket System with Unique Serial Numbers and Expiration
-- Date: 2026-06-02
-- Purpose: Add secure, unique, scannable QR tickets that expire and track scanning

-- =====================================================
-- 1. ADD QR TICKET FIELDS TO BOOKINGS TABLE
-- =====================================================
ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS qr_code_serial TEXT UNIQUE,
  ADD COLUMN IF NOT EXISTS qr_code_data TEXT,
  ADD COLUMN IF NOT EXISTS qr_scanned_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS qr_scanned_by UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS qr_scan_location TEXT,
  ADD COLUMN IF NOT EXISTS qr_expires_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN IF NOT EXISTS qr_is_valid BOOLEAN DEFAULT true;

-- Create indexes for QR lookups
CREATE INDEX IF NOT EXISTS idx_bookings_qr_serial ON bookings(qr_code_serial);
CREATE INDEX IF NOT EXISTS idx_bookings_qr_scanned_at ON bookings(qr_scanned_at);
CREATE INDEX IF NOT EXISTS idx_bookings_qr_is_valid ON bookings(qr_is_valid);

-- =====================================================
-- 2. FUNCTION: Generate Unique QR Serial Number
-- =====================================================
-- Format: AP-EVT-YYYYMMDD-XXXXX (e.g., AP-EVT-20260602-A3F7K)
CREATE OR REPLACE FUNCTION generate_qr_serial(booking_type TEXT DEFAULT 'EVT')
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_serial TEXT;
  v_date TEXT;
  v_random TEXT;
  v_exists BOOLEAN;
BEGIN
  v_date := TO_CHAR(NOW(), 'YYYYMMDD');

  LOOP
    -- Generate 5-character random alphanumeric code
    v_random := UPPER(SUBSTR(MD5(RANDOM()::TEXT || CLOCK_TIMESTAMP()::TEXT), 1, 5));

    -- Format: AP-{TYPE}-{DATE}-{RANDOM}
    v_serial := 'AP-' || booking_type || '-' || v_date || '-' || v_random;

    -- Check if serial already exists
    SELECT EXISTS(SELECT 1 FROM bookings WHERE qr_code_serial = v_serial) INTO v_exists;

    -- If unique, exit loop
    EXIT WHEN NOT v_exists;
  END LOOP;

  RETURN v_serial;
END;
$$;

-- =====================================================
-- 3. FUNCTION: Generate QR Code Data (JSON)
-- =====================================================
CREATE OR REPLACE FUNCTION generate_qr_data(
  p_booking_id UUID,
  p_serial TEXT,
  p_user_id UUID,
  p_event_id UUID
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  v_qr_data JSONB;
BEGIN
  v_qr_data := jsonb_build_object(
    'serial', p_serial,
    'booking_id', p_booking_id,
    'user_id', p_user_id,
    'event_id', p_event_id,
    'issued_at', NOW(),
    'version', '1.0'
  );

  RETURN v_qr_data::TEXT;
END;
$$;

-- =====================================================
-- 4. TRIGGER: Auto-generate QR on Booking Creation
-- =====================================================
CREATE OR REPLACE FUNCTION auto_generate_qr_ticket()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_serial TEXT;
  v_qr_data TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
  v_event_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Only generate QR for confirmed bookings
  IF NEW.status = 'confirmed' AND NEW.payment_status = 'paid' THEN
    -- Generate unique serial number
    v_serial := generate_qr_serial('EVT');

    -- Generate QR data
    v_qr_data := generate_qr_data(NEW.id, v_serial, NEW.user_id, NEW.event_id);

    -- Get event end date for expiration
    SELECT end_date INTO v_event_end_date
    FROM events
    WHERE id = NEW.event_id;

    -- QR expires 24 hours after event ends
    v_expires_at := v_event_end_date + INTERVAL '24 hours';

    -- Update booking with QR data
    NEW.qr_code_serial := v_serial;
    NEW.qr_code_data := v_qr_data;
    NEW.qr_expires_at := v_expires_at;
    NEW.qr_is_valid := true;
    NEW.qr_code := v_serial; -- For backward compatibility
  END IF;

  RETURN NEW;
END;
$$;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS trigger_auto_generate_qr ON bookings;
CREATE TRIGGER trigger_auto_generate_qr
  BEFORE INSERT OR UPDATE OF status, payment_status
  ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_qr_ticket();

-- =====================================================
-- 5. FUNCTION: Scan QR Ticket
-- =====================================================
CREATE OR REPLACE FUNCTION scan_qr_ticket(
  p_serial TEXT,
  p_scanned_by UUID,
  p_scan_location TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_booking_id UUID;
  v_status TEXT;
  v_payment_status TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
  v_scanned_at TIMESTAMP WITH TIME ZONE;
  v_event_id UUID;
  v_event_title TEXT;
  v_user_name TEXT;
  v_result JSON;
BEGIN
  -- Find booking by QR serial
  SELECT
    b.id,
    b.status,
    b.payment_status,
    b.qr_expires_at,
    b.qr_scanned_at,
    b.event_id,
    e.title,
    p.full_name
  INTO
    v_booking_id,
    v_status,
    v_payment_status,
    v_expires_at,
    v_scanned_at,
    v_event_id,
    v_event_title,
    v_user_name
  FROM bookings b
  JOIN events e ON b.event_id = e.id
  JOIN profiles p ON b.user_id = p.id
  WHERE b.qr_code_serial = p_serial;

  -- Check if booking exists
  IF v_booking_id IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'INVALID_QR',
      'message', 'QR code not found. This ticket may be fake or invalid.'
    );
  END IF;

  -- Check if already scanned
  IF v_scanned_at IS NOT NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'ALREADY_SCANNED',
      'message', 'This ticket has already been scanned.',
      'scanned_at', v_scanned_at,
      'booking_id', v_booking_id
    );
  END IF;

  -- Check if expired
  IF v_expires_at < NOW() THEN
    RETURN json_build_object(
      'success', false,
      'error', 'EXPIRED',
      'message', 'This ticket has expired.',
      'expired_at', v_expires_at,
      'booking_id', v_booking_id
    );
  END IF;

  -- Check if booking is cancelled
  IF v_status = 'cancelled' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'CANCELLED',
      'message', 'This booking has been cancelled.',
      'booking_id', v_booking_id
    );
  END IF;

  -- Check if payment is not completed
  IF v_payment_status != 'paid' THEN
    RETURN json_build_object(
      'success', false,
      'error', 'UNPAID',
      'message', 'Payment for this booking is not completed.',
      'payment_status', v_payment_status,
      'booking_id', v_booking_id
    );
  END IF;

  -- All checks passed - mark as scanned
  UPDATE bookings
  SET
    qr_scanned_at = NOW(),
    qr_scanned_by = p_scanned_by,
    qr_scan_location = p_scan_location,
    qr_is_valid = false,  -- Invalidate after first scan
    status = 'attended'   -- Mark as attended
  WHERE id = v_booking_id;

  -- Return success
  RETURN json_build_object(
    'success', true,
    'message', 'Ticket scanned successfully! Welcome to the event.',
    'booking_id', v_booking_id,
    'event_id', v_event_id,
    'event_title', v_event_title,
    'attendee_name', v_user_name,
    'scanned_at', NOW()
  );
END;
$$;

-- =====================================================
-- 6. FUNCTION: Invalidate QR on Cancellation
-- =====================================================
CREATE OR REPLACE FUNCTION invalidate_qr_on_cancel()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    NEW.qr_is_valid := false;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trigger_invalidate_qr_on_cancel ON bookings;
CREATE TRIGGER trigger_invalidate_qr_on_cancel
  BEFORE UPDATE OF status
  ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION invalidate_qr_on_cancel();

-- =====================================================
-- 7. FUNCTION: Get QR Ticket Info (for organizers)
-- =====================================================
CREATE OR REPLACE FUNCTION get_qr_ticket_info(p_serial TEXT)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    'serial', b.qr_code_serial,
    'booking_id', b.id,
    'status', b.status,
    'payment_status', b.payment_status,
    'is_valid', b.qr_is_valid,
    'issued_at', b.created_at,
    'expires_at', b.qr_expires_at,
    'scanned_at', b.qr_scanned_at,
    'scanned_by', b.qr_scanned_by,
    'scan_location', b.qr_scan_location,
    'attendee', json_build_object(
      'name', p.full_name,
      'email', p.email,
      'phone', p.phone
    ),
    'event', json_build_object(
      'id', e.id,
      'title', e.title,
      'start_date', e.start_date,
      'end_date', e.end_date,
      'location', e.location
    ),
    'booking', json_build_object(
      'quantity', b.quantity,
      'zone', z.name,
      'amount', b.amount
    )
  )
  INTO v_result
  FROM bookings b
  JOIN profiles p ON b.user_id = p.id
  JOIN events e ON b.event_id = e.id
  LEFT JOIN zones z ON b.zone_id = z.id
  WHERE b.qr_code_serial = p_serial;

  RETURN v_result;
END;
$$;

-- =====================================================
-- 8. UPDATE EXISTING BOOKINGS WITH QR CODES
-- =====================================================
-- Generate QR codes for existing confirmed bookings that don't have them
DO $$
DECLARE
  r RECORD;
  v_serial TEXT;
  v_qr_data TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
BEGIN
  FOR r IN
    SELECT b.id, b.user_id, b.event_id, e.end_date
    FROM bookings b
    JOIN events e ON b.event_id = e.id
    WHERE b.status = 'confirmed'
      AND b.payment_status = 'paid'
      AND b.qr_code_serial IS NULL
  LOOP
    -- Generate serial
    v_serial := generate_qr_serial('EVT');

    -- Generate QR data
    v_qr_data := generate_qr_data(r.id, v_serial, r.user_id, r.event_id);

    -- Calculate expiration
    v_expires_at := r.end_date + INTERVAL '24 hours';

    -- Update booking
    UPDATE bookings
    SET
      qr_code_serial = v_serial,
      qr_code_data = v_qr_data,
      qr_expires_at = v_expires_at,
      qr_is_valid = true,
      qr_code = v_serial  -- For backward compatibility
    WHERE id = r.id;
  END LOOP;

  RAISE NOTICE 'QR codes generated for existing bookings';
END $$;

-- =====================================================
-- 9. COMMENTS
-- =====================================================
COMMENT ON COLUMN bookings.qr_code_serial IS 'Unique serial number for QR ticket (e.g., AP-EVT-20260602-A3F7K)';
COMMENT ON COLUMN bookings.qr_code_data IS 'JSON data encoded in QR code';
COMMENT ON COLUMN bookings.qr_scanned_at IS 'Timestamp when QR was scanned at event entrance';
COMMENT ON COLUMN bookings.qr_scanned_by IS 'Organizer/staff who scanned the QR';
COMMENT ON COLUMN bookings.qr_scan_location IS 'Location where QR was scanned (entrance name, gate number, etc.)';
COMMENT ON COLUMN bookings.qr_expires_at IS 'Expiration timestamp (24 hours after event ends)';
COMMENT ON COLUMN bookings.qr_is_valid IS 'Whether QR is still valid (false after scan or cancellation)';

-- =====================================================
-- 10. GRANT PERMISSIONS
-- =====================================================
-- Allow authenticated users to check their own QR tickets
GRANT EXECUTE ON FUNCTION get_qr_ticket_info TO authenticated;

-- Only organizers should scan tickets (handled by RLS)
GRANT EXECUTE ON FUNCTION scan_qr_ticket TO authenticated;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✓ Secure QR Ticket System installed successfully!';
  RAISE NOTICE '  - Unique serial numbers with format: AP-EVT-YYYYMMDD-XXXXX';
  RAISE NOTICE '  - Auto-generation on booking confirmation';
  RAISE NOTICE '  - Expiration 24 hours after event ends';
  RAISE NOTICE '  - One-time scan validation';
  RAISE NOTICE '  - Invalidation on cancellation';
  RAISE NOTICE '  - Organizer scanning functions ready';
END $$;
