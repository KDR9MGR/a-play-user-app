-- Migration: Concierge Request Tracking
-- Purpose: Track monthly concierge request counts for tier limits
-- Date: 2026-03-21

-- Create concierge_request_tracking table
CREATE TABLE IF NOT EXISTS concierge_request_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
  year INTEGER NOT NULL CHECK (year >= 2020),
  request_count INTEGER DEFAULT 0 CHECK (request_count >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, month, year)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_concierge_tracking_user_date
  ON concierge_request_tracking(user_id, year DESC, month DESC);

-- Add user_id column to concierge_requests if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'concierge_requests'
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE concierge_requests
    ADD COLUMN user_id UUID REFERENCES profiles(id) ON DELETE CASCADE;

    CREATE INDEX idx_concierge_requests_user_id ON concierge_requests(user_id);
  END IF;
END $$;

-- Row Level Security for concierge_request_tracking
ALTER TABLE concierge_request_tracking ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own tracking records
CREATE POLICY "Users can view own tracking records"
  ON concierge_request_tracking
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: System can insert/update tracking records (service role)
CREATE POLICY "Service role can manage tracking records"
  ON concierge_request_tracking
  FOR ALL
  USING (auth.role() = 'service_role');

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_concierge_tracking_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update timestamp
CREATE TRIGGER trigger_update_concierge_tracking_timestamp
  BEFORE UPDATE ON concierge_request_tracking
  FOR EACH ROW
  EXECUTE FUNCTION update_concierge_tracking_timestamp();

-- Comment on table
COMMENT ON TABLE concierge_request_tracking IS 'Tracks monthly concierge request counts for enforcing tier limits (Gold tier: 3/month)';
COMMENT ON COLUMN concierge_request_tracking.user_id IS 'User who made the requests';
COMMENT ON COLUMN concierge_request_tracking.month IS 'Month number (1-12)';
COMMENT ON COLUMN concierge_request_tracking.year IS 'Year';
COMMENT ON COLUMN concierge_request_tracking.request_count IS 'Number of requests made in this month';
