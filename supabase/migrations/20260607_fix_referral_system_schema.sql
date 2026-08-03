-- Fix Referral System Schema
-- Date: June 7, 2026
-- Issue: referrals table schema doesn't match code expectations

-- ============================================================================
-- 1. Add referral_code to profiles table
-- ============================================================================

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS referral_count INTEGER DEFAULT 0;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_referral_code ON profiles(referral_code);

-- ============================================================================
-- 2. Generate referral codes for existing subscribed users
-- ============================================================================

UPDATE profiles
SET referral_code = 'REF' || UPPER(SUBSTRING(id::text, 1, 8))
WHERE is_subscribed = true
  AND referral_code IS NULL;

-- ============================================================================
-- 3. Create function to generate referral code on subscription
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_referral_code_on_subscribe()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Generate referral code when user becomes subscribed
  IF NEW.is_subscribed = true AND OLD.is_subscribed = false THEN
    IF NEW.referral_code IS NULL THEN
      NEW.referral_code := 'REF' || UPPER(SUBSTRING(NEW.id::text, 1, 8));
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_generate_referral_code ON profiles;

-- Create trigger
CREATE TRIGGER trigger_generate_referral_code
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION generate_referral_code_on_subscribe();

-- ============================================================================
-- 4. Update apply_referral_code function to use new schema
-- ============================================================================

CREATE OR REPLACE FUNCTION apply_referral_code(
  p_referral_code TEXT,
  p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_referrer_id UUID;
  v_already_applied BOOLEAN;
BEGIN
  -- Check if user has already applied a referral code
  SELECT EXISTS(
    SELECT 1 FROM referral_history
    WHERE referred_user_id = p_user_id
  ) INTO v_already_applied;

  IF v_already_applied THEN
    RAISE EXCEPTION 'You have already used a referral code';
  END IF;

  -- Find the referrer by code (from profiles table now)
  SELECT id INTO v_referrer_id
  FROM profiles
  WHERE referral_code = UPPER(p_referral_code);

  IF v_referrer_id IS NULL THEN
    RAISE EXCEPTION 'Invalid referral code';
  END IF;

  -- Cannot refer yourself
  IF v_referrer_id = p_user_id THEN
    RAISE EXCEPTION 'You cannot use your own referral code';
  END IF;

  -- Create referral history record
  INSERT INTO referral_history (
    referrer_user_id,
    referred_user_id,
    referral_code_used,
    points_earned,
    created_at
  ) VALUES (
    v_referrer_id,
    p_user_id,
    p_referral_code,
    0, -- Points will be earned when referred user subscribes
    NOW()
  );

  -- Increment referral count in profiles
  UPDATE profiles
  SET referral_count = referral_count + 1,
      updated_at = NOW()
  WHERE id = v_referrer_id;

END;
$$;

-- ============================================================================
-- 5. Verify setup
-- ============================================================================

DO $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Check if referral_code column exists
  SELECT COUNT(*) INTO v_count
  FROM information_schema.columns
  WHERE table_name = 'profiles'
    AND column_name = 'referral_code';

  IF v_count = 0 THEN
    RAISE EXCEPTION 'referral_code column not created!';
  END IF;

  -- Check how many subscribed users have referral codes
  SELECT COUNT(*) INTO v_count
  FROM profiles
  WHERE is_subscribed = true
    AND referral_code IS NOT NULL;

  RAISE NOTICE '✓ Referral system fixed!';
  RAISE NOTICE '  - referral_code column added to profiles';
  RAISE NOTICE '  - % subscribed users have referral codes', v_count;
  RAISE NOTICE '  - Trigger created for auto-generation';
  RAISE NOTICE '  - apply_referral_code function updated';
END $$;
