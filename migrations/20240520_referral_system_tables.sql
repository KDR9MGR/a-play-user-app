-- Create necessary migration file for the referral system database tables

-- Create membership_tiers table
CREATE TABLE IF NOT EXISTS public.membership_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    min_points INTEGER NOT NULL,
    max_points INTEGER,
    benefits TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create user_challenges table
CREATE TABLE IF NOT EXISTS public.user_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    challenge_type TEXT NOT NULL, -- 'booking', 'login', 'rating', 'subscription', etc.
    target_count INTEGER NOT NULL,
    period_days INTEGER NOT NULL,
    reward_points INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Create user_challenge_progress table
CREATE TABLE IF NOT EXISTS public.user_challenge_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES public.user_challenges(id) ON DELETE CASCADE,
    current_count INTEGER NOT NULL DEFAULT 0,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (user_id, challenge_id)
);

-- Create time_limited_offers table
CREATE TABLE IF NOT EXISTS public.time_limited_offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    multiplier DECIMAL(3,1) NOT NULL DEFAULT 1.0,
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    CHECK (multiplier > 0)
);

-- Create user_daily_logins table to track daily logins
CREATE TABLE IF NOT EXISTS public.user_daily_logins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    login_date DATE NOT NULL,
    points_awarded BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, login_date)
);

-- Create or update tables that may already exist

-- Update referrals table if it exists, otherwise create it
CREATE TABLE IF NOT EXISTS public.referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL UNIQUE,
    referral_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE,
    UNIQUE (user_id)
);

-- Update referral_history table if it exists, otherwise create it
CREATE TABLE IF NOT EXISTS public.referral_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    referred_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL,
    points_earned INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (referred_user_id)
);

-- Update user_points table if it exists, otherwise create it
CREATE TABLE IF NOT EXISTS public.user_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_points INTEGER NOT NULL DEFAULT 0,
    available_points INTEGER NOT NULL DEFAULT 0,
    lifetime_points INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id)
);

-- Update point_transactions table if it exists, otherwise create it
CREATE TABLE IF NOT EXISTS public.point_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL,
    transaction_type TEXT NOT NULL, -- 'referral', 'booking', 'daily_login', 'subscription', 'rating', 'challenge', 'redemption'
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_challenge_progress_user ON public.user_challenge_progress (user_id);
CREATE INDEX IF NOT EXISTS idx_user_challenge_progress_challenge ON public.user_challenge_progress (challenge_id);
CREATE INDEX IF NOT EXISTS idx_user_daily_logins_user ON public.user_daily_logins (user_id, login_date);
CREATE INDEX IF NOT EXISTS idx_point_transactions_user ON public.point_transactions (user_id);
CREATE INDEX IF NOT EXISTS idx_point_transactions_type ON public.point_transactions (transaction_type);
CREATE INDEX IF NOT EXISTS idx_referrals_code ON public.referrals (referral_code);
CREATE INDEX IF NOT EXISTS idx_membership_tiers_points ON public.membership_tiers (min_points, max_points);
CREATE INDEX IF NOT EXISTS idx_time_limited_offers_active ON public.time_limited_offers (active, start_date, end_date);

-- Enable Row Level Security
ALTER TABLE public.membership_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_challenge_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.time_limited_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_daily_logins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.referral_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.point_transactions ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Membership tiers can be viewed by everyone
CREATE POLICY "Membership tiers are viewable by everyone" 
ON public.membership_tiers FOR SELECT USING (true);

-- Only admins can modify membership tiers
CREATE POLICY "Membership tiers can be modified by admins only" 
ON public.membership_tiers FOR ALL TO authenticated 
USING (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'))
WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'));

-- User challenges can be viewed by everyone
CREATE POLICY "User challenges are viewable by everyone" 
ON public.user_challenges FOR SELECT USING (true);

-- Only admins can modify user challenges
CREATE POLICY "User challenges can be modified by admins only" 
ON public.user_challenges FOR ALL TO authenticated 
USING (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'))
WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'));

-- Users can view their own challenge progress
CREATE POLICY "Users can view own challenge progress" 
ON public.user_challenge_progress FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

-- Users can modify their own challenge progress
CREATE POLICY "Users can modify own challenge progress" 
ON public.user_challenge_progress FOR UPDATE TO authenticated 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Time-limited offers can be viewed by everyone
CREATE POLICY "Time-limited offers are viewable by everyone" 
ON public.time_limited_offers FOR SELECT USING (true);

-- Only admins can modify time-limited offers
CREATE POLICY "Time-limited offers can be modified by admins only" 
ON public.time_limited_offers FOR ALL TO authenticated 
USING (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'))
WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'));

-- Users can view their own daily logins
CREATE POLICY "Users can view own daily logins" 
ON public.user_daily_logins FOR SELECT TO authenticated 
USING (auth.uid() = user_id);

-- Insert initial membership tiers
INSERT INTO public.membership_tiers (name, min_points, max_points, benefits)
VALUES
    ('Bronze', 0, 999, 'Basic discounts and early access to select events'),
    ('Silver', 1000, 4999, 'All Bronze benefits plus 10% discount on bookings and priority customer service'),
    ('Gold', 5000, 9999, 'All Silver benefits plus exclusive access to premium events and one free VIP upgrade per month'),
    ('Platinum', 10000, NULL, 'All Gold benefits plus dedicated concierge service and unlimited VIP upgrades');

-- Insert sample challenges
INSERT INTO public.user_challenges (name, description, challenge_type, target_count, period_days, reward_points, active)
VALUES
    ('Daily Login Streak', 'Log in for 7 consecutive days', 'daily_login', 7, 7, 50, true),
    ('Booking Master', 'Book 3 events within 30 days', 'booking', 3, 30, 100, true),
    ('Premium Supporter', 'Subscribe to premium for 4 consecutive weeks', 'subscription', 4, 28, 200, true),
    ('Feedback Champion', 'Rate 5 different events', 'rating', 5, 60, 150, true);

-- Insert a sample time-limited offer
INSERT INTO public.time_limited_offers (name, description, multiplier, start_date, end_date, active)
VALUES
    ('Double Points Weekend', 'Earn double points on all activities this weekend!', 2.0, 
     CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '3 days', true);

-- Create or replace the trigger function to update user points when transactions are added
CREATE OR REPLACE FUNCTION update_user_points()
RETURNS TRIGGER AS $$
BEGIN
    -- Create user_points record if it doesn't exist
    INSERT INTO public.user_points (user_id, total_points, available_points, lifetime_points)
    VALUES (NEW.user_id, 0, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;
    
    -- Update the user points
    UPDATE public.user_points
    SET 
        total_points = total_points + NEW.points,
        available_points = CASE 
            WHEN available_points + NEW.points < 0 THEN 0
            ELSE available_points + NEW.points
        END,
        lifetime_points = CASE 
            WHEN NEW.points > 0 THEN lifetime_points + NEW.points
            ELSE lifetime_points
        END,
        last_updated = CURRENT_TIMESTAMP
    WHERE user_id = NEW.user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger if it doesn't exist
DROP TRIGGER IF EXISTS update_points_after_transaction ON public.point_transactions;
CREATE TRIGGER update_points_after_transaction
AFTER INSERT ON public.point_transactions
FOR EACH ROW
EXECUTE FUNCTION update_user_points(); 