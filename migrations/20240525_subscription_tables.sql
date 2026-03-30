-- Create user_subscriptions table for tracking premium subscriptions
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subscription_type TEXT NOT NULL, -- 'weekly', 'monthly', 'yearly', 'trial'
    plan_type TEXT NOT NULL DEFAULT 'monthly', -- 'trial', 'weekly', 'monthly', 'quarterly', 'biannual', 'annual'
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'GHS',
    status TEXT NOT NULL, -- 'active', 'expired', 'cancelled'
    payment_reference TEXT,
    payment_method TEXT NOT NULL, -- 'paystack', 'cash', 'trial', etc.
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_auto_renew BOOLEAN NOT NULL DEFAULT false,
    tier_points_earned INTEGER DEFAULT 0,
    features_unlocked TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, status) -- Ensure only one active subscription per user
);

-- Create subscription_plans table to define available plans
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    duration_days INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'GHS',
    plan_type TEXT NOT NULL DEFAULT 'monthly',
    features JSONB,
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_popular BOOLEAN NOT NULL DEFAULT false,
    discount_percentage DECIMAL(5, 2),
    original_price DECIMAL(10, 2),
    tier_points_bonus INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create subscription_payments table to track payment history
CREATE TABLE IF NOT EXISTS public.subscription_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subscription_id UUID NOT NULL REFERENCES public.user_subscriptions(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'GHS',
    payment_reference TEXT NOT NULL,
    payment_method TEXT NOT NULL,
    payment_status TEXT NOT NULL, -- 'success', 'failed', 'pending'
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions (user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON public.user_subscriptions (status);
CREATE INDEX IF NOT EXISTS idx_subscription_payments_user_id ON public.subscription_payments (user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_payments_subscription_id ON public.subscription_payments (subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscription_plans_is_active ON public.subscription_plans (is_active);

-- Enable Row Level Security
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_payments ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own subscriptions
CREATE POLICY "Users can view own subscriptions" 
ON public.user_subscriptions FOR SELECT 
USING (auth.uid() = user_id);

-- Users can create their own subscriptions
CREATE POLICY "Users can create own subscriptions" 
ON public.user_subscriptions FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Users can update their own subscriptions
CREATE POLICY "Users can update own subscriptions" 
ON public.user_subscriptions FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Anyone can view active subscription plans
CREATE POLICY "Anyone can view active subscription plans" 
ON public.subscription_plans FOR SELECT 
USING (is_active = true);

-- Only admins can modify subscription plans
CREATE POLICY "Only admins can modify subscription plans" 
ON public.subscription_plans FOR ALL 
USING (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'))
WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE role = 'admin'));

-- Users can view their own payment history
CREATE POLICY "Users can view own payment history" 
ON public.subscription_payments FOR SELECT 
USING (auth.uid() = user_id);

-- Users can create payment records for their own subscriptions
CREATE POLICY "Users can create own payment records" 
ON public.subscription_payments FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Insert sample subscription plans
INSERT INTO public.subscription_plans (id, name, description, duration_days, price, currency, plan_type, features, is_active, is_popular, tier_points_bonus)
VALUES
    ('trial_plan', '3-Day Free Trial', 'Experience all premium features completely free', 3, 0.00, 'GHS', 'trial',
     '{"ad_free": true, "exclusive_content": true, "priority_booking": true, "hd_streaming": true, "offline_download": true, "is_trial": true}', true, true, 25),
    ('weekly_plan', 'Weekly Access', 'Perfect for trying out our premium features', 7, 20.00, 'GHS', 'weekly',
     '{"premium_content": true, "hd_streaming": true, "offline_download": false, "ad_free": false}', true, false, 50),
    ('monthly_plan', 'Monthly Premium', 'Most popular choice for regular users', 30, 69.99, 'GHS', 'monthly',
     '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true}', true, true, 200),
    ('quarterly_plan', '3-Month Bundle', 'Save more with our quarterly plan', 90, 199.99, 'GHS', 'quarterly',
     '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true, "exclusive_content": true}', true, false, 650),
    ('annual_plan', 'Annual Ultimate', 'Ultimate experience with maximum savings', 365, 73.99, 'USD', 'annual',
     '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true, "exclusive_content": true, "priority_support": true, "early_access": true, "creator_meetups": true}', true, false, 3000);

-- Create function to check if subscription is expired and update status
CREATE OR REPLACE FUNCTION check_subscription_expiry()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if there are any expired active subscriptions
    UPDATE public.user_subscriptions
    SET status = 'expired', updated_at = CURRENT_TIMESTAMP
    WHERE status = 'active' AND end_date < CURRENT_TIMESTAMP;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to run check every hour
DROP TRIGGER IF EXISTS check_subscription_expiry_trigger ON public.user_subscriptions;
CREATE TRIGGER check_subscription_expiry_trigger
AFTER INSERT OR UPDATE ON public.user_subscriptions
EXECUTE FUNCTION check_subscription_expiry();