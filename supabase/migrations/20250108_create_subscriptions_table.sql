-- ============================================================================
-- Supabase Migration: Apple IAP Subscriptions Table
-- Created: 2025-01-08
-- Purpose: Store and manage iOS/Android subscription state from Apple/Google
-- ============================================================================

-- Drop table if exists (for development only - remove in production)
DROP TABLE IF EXISTS public.subscriptions CASCADE;

-- ============================================================================
-- Main Subscriptions Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
  -- Primary key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- User reference (linked to Supabase Auth)
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Platform identification
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),

  -- Apple/Google product information
  product_id TEXT NOT NULL,

  -- Transaction tracking
  original_transaction_id TEXT,  -- Apple: originalTransactionId, Google: orderId
  latest_transaction_id TEXT UNIQUE,  -- Apple: transactionId, Google: purchaseToken

  -- Subscription status
  status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'canceled', 'grace_period', 'pending', 'refunded')),

  -- Environment (sandbox vs production)
  sandbox BOOLEAN DEFAULT FALSE,

  -- Subscription timing
  purchase_date TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,

  -- Additional metadata
  auto_renew_enabled BOOLEAN DEFAULT TRUE,
  billing_issue BOOLEAN DEFAULT FALSE,
  grace_period_expires_at TIMESTAMPTZ,

  -- Apple-specific fields
  apple_receipt_data TEXT,  -- Base64 encoded receipt
  apple_latest_receipt TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- Indexes for Performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id
  ON public.subscriptions(user_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_latest_tx
  ON public.subscriptions(latest_transaction_id);

CREATE INDEX IF NOT EXISTS idx_subscriptions_status
  ON public.subscriptions(status)
  WHERE status = 'active';

CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_at
  ON public.subscriptions(expires_at)
  WHERE expires_at IS NOT NULL;

-- Composite index for common queries
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status
  ON public.subscriptions(user_id, status, expires_at);

-- ============================================================================
-- Updated At Trigger
-- ============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================================================
-- Helper Function: Get Active Subscription for User
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_user_subscription(p_user_id UUID)
RETURNS TABLE (
  is_subscribed BOOLEAN,
  product_id TEXT,
  expires_at TIMESTAMPTZ,
  platform TEXT,
  status TEXT,
  auto_renew_enabled BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    TRUE as is_subscribed,
    s.product_id,
    s.expires_at,
    s.platform,
    s.status,
    s.auto_renew_enabled
  FROM public.subscriptions s
  WHERE s.user_id = p_user_id
    AND s.status IN ('active', 'grace_period')
    AND (s.expires_at IS NULL OR s.expires_at > NOW())
  ORDER BY s.expires_at DESC NULLS FIRST
  LIMIT 1;

  -- If no active subscription found, return default values
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL::TEXT, NULL::TIMESTAMPTZ, NULL::TEXT, NULL::TEXT, NULL::BOOLEAN;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Helper Function: Check if User has Active Subscription
-- ============================================================================
CREATE OR REPLACE FUNCTION public.user_has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  has_sub BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM public.subscriptions
    WHERE user_id = p_user_id
      AND status IN ('active', 'grace_period')
      AND (expires_at IS NULL OR expires_at > NOW())
  ) INTO has_sub;

  RETURN COALESCE(has_sub, FALSE);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- Row Level Security (RLS) Policies
-- ============================================================================

-- Enable RLS on subscriptions table
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can read their own subscriptions
CREATE POLICY "Users can read own subscriptions"
  ON public.subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Policy 2: Service role can do everything (for Edge Functions)
CREATE POLICY "Service role has full access"
  ON public.subscriptions
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Policy 3: Prevent direct writes from users (only Edge Functions can write)
-- Note: No INSERT/UPDATE/DELETE policies for authenticated users
-- This forces all writes to go through Edge Functions using service_role

-- ============================================================================
-- Subscription Events Table (Optional - for audit/history)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.subscription_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL, -- 'purchased', 'renewed', 'canceled', 'expired', 'refunded', 'grace_period'
  platform TEXT NOT NULL,
  product_id TEXT,
  transaction_id TEXT,
  details JSONB,  -- Store full Apple/Google response for debugging
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscription_events_user_id
  ON public.subscription_events(user_id);

CREATE INDEX IF NOT EXISTS idx_subscription_events_subscription_id
  ON public.subscription_events(subscription_id);

CREATE INDEX IF NOT EXISTS idx_subscription_events_type
  ON public.subscription_events(event_type);

-- Enable RLS on subscription_events
ALTER TABLE public.subscription_events ENABLE ROW LEVEL SECURITY;

-- Users can read their own events
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'subscription_events'
      AND polname = 'Users can read own subscription events'
  ) THEN
    EXECUTE $DDL$
      CREATE POLICY "Users can read own subscription events"
        ON public.subscription_events
        FOR SELECT
        TO authenticated
        USING (auth.uid() = user_id)
    $DDL$;
  END IF;
END $$;

-- Service role can do everything
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'subscription_events'
      AND polname = 'Service role has full access to events'
  ) THEN
    EXECUTE $DDL$
      CREATE POLICY "Service role has full access to events"
        ON public.subscription_events
        FOR ALL
        TO service_role
        USING (true)
        WITH CHECK (true)
    $DDL$;
  END IF;
END $$;

-- ============================================================================
-- Comments for Documentation
-- ============================================================================
COMMENT ON TABLE public.subscriptions IS
  'Stores iOS and Android subscription state. Updated by Edge Functions after Apple/Google verification.';

COMMENT ON COLUMN public.subscriptions.original_transaction_id IS
  'Apple: originalTransactionId, Google: orderId. Unique identifier for the first transaction in a subscription.';

COMMENT ON COLUMN public.subscriptions.latest_transaction_id IS
  'Apple: transactionId, Google: purchaseToken. Latest transaction ID for renewals.';

COMMENT ON COLUMN public.subscriptions.status IS
  'active: Currently valid subscription
   expired: Subscription ended naturally
   canceled: User canceled (may still be active until expiry)
   grace_period: Payment failed, in grace period
   pending: Awaiting payment
   refunded: Subscription was refunded';

COMMENT ON FUNCTION public.get_user_subscription IS
  'Returns current subscription details for a user. Returns is_subscribed=false if no active subscription.';

COMMENT ON FUNCTION public.user_has_active_subscription IS
  'Quick boolean check if user has an active subscription.';

-- ============================================================================
-- Success Message
-- ============================================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Subscriptions table created successfully';
  RAISE NOTICE '✅ RLS policies configured';
  RAISE NOTICE '✅ Helper functions created';
  RAISE NOTICE '⚠️  Next steps:';
  RAISE NOTICE '   1. Deploy Edge Functions (verify-apple-sub, get-subscription-status)';
  RAISE NOTICE '   2. Set environment variables in Supabase dashboard';
  RAISE NOTICE '   3. Test with Apple Sandbox environment';
END $$;
