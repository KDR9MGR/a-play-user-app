-- ============================================================================
-- Add Unique Constraint for Active Subscriptions
-- ============================================================================
-- Date: 2026-04-24
-- Purpose: Prevent users from having multiple active subscriptions
-- Impact: Data integrity - ensures one active subscription per user
-- ============================================================================

-- Create partial unique index - only enforces uniqueness for active subscriptions
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_one_active_subscription
ON user_subscriptions (user_id)
WHERE status = 'active';

-- Add comment for documentation
COMMENT ON INDEX idx_user_one_active_subscription IS
  'Ensures a user can only have one active subscription at a time. Does not affect expired, cancelled, or other statuses.';

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Unique constraint added: One active subscription per user';
  RAISE NOTICE '   Index: idx_user_one_active_subscription';
  RAISE NOTICE '   Scope: Only applies to status = ''active''';
END $$;
