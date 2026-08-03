-- Applied live via `supabase db query` on 2026-07-12; tracked here.
-- S3: server-side expected-amount ledger. The `paystack` edge function
-- recomputes the correct charge from live prices and records it here keyed
-- by reference; the `paystack-webhook` function cross-checks the actually
-- charged amount against this before fulfilling. Service-role only.
CREATE TABLE IF NOT EXISTS payment_intents (
  reference text PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  purchase_type text NOT NULL,
  expected_amount_kobo integer NOT NULL,
  currency text NOT NULL DEFAULT 'GHS',
  metadata jsonb DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE payment_intents ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "service role manages payment intents" ON payment_intents;
CREATE POLICY "service role manages payment intents" ON payment_intents
  FOR ALL USING (auth.role() = 'service_role');
