-- Structured, persistent log for the Apple IAP purchase flow. debugPrint()
-- output in iap_service.dart is invisible once the app is running on a real
-- user's device (TestFlight/App Store) - there was no way to see what
-- actually happened when a purchase failed for a real user. This table is
-- written to from both the client (every step of the StoreKit flow) and the
-- verify-apple-receipt edge function (every receipt verification attempt),
-- so a failed purchase can be diagnosed by querying by user_id/email after
-- the fact instead of needing to reproduce it live.
CREATE TABLE IF NOT EXISTS iap_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  source text NOT NULL DEFAULT 'client', -- 'client' | 'server'
  event text NOT NULL,
  level text NOT NULL DEFAULT 'info', -- 'info' | 'warn' | 'error'
  product_id text,
  transaction_id text,
  platform text,
  app_version text,
  message text,
  detail jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS iap_events_user_id_created_at_idx ON iap_events (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS iap_events_transaction_id_idx ON iap_events (transaction_id);
CREATE INDEX IF NOT EXISTS iap_events_event_idx ON iap_events (event);

ALTER TABLE iap_events ENABLE ROW LEVEL SECURITY;

-- Users can write and read their own breadcrumbs (client-side logging calls
-- run under the user's own JWT, not service role).
CREATE POLICY "users insert own iap events" ON iap_events
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "users read own iap events" ON iap_events
  FOR SELECT USING (auth.uid() = user_id);

-- Admins (and the service role, e.g. verify-apple-receipt) can read/write
-- everything - this is what makes the table useful for support/debugging.
CREATE POLICY "admins manage iap events" ON iap_events
  FOR ALL USING (is_user_admin());

-- Convenience view for the common support question: "what happened the last
-- time this user tried to subscribe?"
CREATE OR REPLACE VIEW iap_events_recent AS
SELECT e.*, p.email, p.full_name
FROM iap_events e
LEFT JOIN profiles p ON p.id = e.user_id
ORDER BY e.created_at DESC;
