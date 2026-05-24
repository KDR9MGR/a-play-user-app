-- Migration: Add booking cancellations table
-- Date: April 10, 2026
-- Description: Adds support for booking cancellations with refund tracking

-- Create booking_cancellations table
CREATE TABLE IF NOT EXISTS public.booking_cancellations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    refund_status TEXT NOT NULL CHECK (refund_status IN ('full_refund', 'partial_refund', 'no_refund')),
    refund_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    refund_percentage DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    hours_before_event INTEGER NOT NULL,
    cancelled_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    refund_processed_at TIMESTAMP WITH TIME ZONE,
    refund_transaction_id TEXT,
    admin_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_booking_cancellations_booking_id ON public.booking_cancellations(booking_id);
CREATE INDEX idx_booking_cancellations_user_id ON public.booking_cancellations(user_id);
CREATE INDEX idx_booking_cancellations_refund_status ON public.booking_cancellations(refund_status);
CREATE INDEX idx_booking_cancellations_cancelled_at ON public.booking_cancellations(cancelled_at DESC);

-- Add RLS (Row Level Security) policies
ALTER TABLE public.booking_cancellations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own cancellations
CREATE POLICY "Users can view own cancellations"
    ON public.booking_cancellations
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy: Users can insert their own cancellations
CREATE POLICY "Users can create own cancellations"
    ON public.booking_cancellations
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy: Admin can view all cancellations (for admin panel - future)
CREATE POLICY "Service role can manage all cancellations"
    ON public.booking_cancellations
    FOR ALL
    USING (auth.role() = 'service_role');

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_booking_cancellations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_booking_cancellations_updated_at
    BEFORE UPDATE ON public.booking_cancellations
    FOR EACH ROW
    EXECUTE FUNCTION update_booking_cancellations_updated_at();

-- Add comment to table
COMMENT ON TABLE public.booking_cancellations IS 'Tracks booking cancellations and refund status';
COMMENT ON COLUMN public.booking_cancellations.refund_status IS 'Refund eligibility: full_refund (48+ hours), partial_refund (24-48 hours), no_refund (<24 hours)';
COMMENT ON COLUMN public.booking_cancellations.refund_percentage IS 'Percentage of booking amount refunded (0-100)';
COMMENT ON COLUMN public.booking_cancellations.hours_before_event IS 'Number of hours before event when cancellation was made';

-- Grant permissions
GRANT SELECT, INSERT ON public.booking_cancellations TO authenticated;
GRANT ALL ON public.booking_cancellations TO service_role;
