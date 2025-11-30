-- Migration for User Tier System
-- Create user_tiers table
CREATE TABLE IF NOT EXISTS user_tiers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    current_tier VARCHAR(20) DEFAULT 'gold' CHECK (current_tier IN ('gold', 'platinum', 'prestige')),
    total_points INTEGER DEFAULT 0,
    tier_progress INTEGER DEFAULT 0,
    next_tier_threshold INTEGER DEFAULT 1000,
    tier_benefits JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Create notifications table for tier upgrades
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create points_history table to track point transactions
CREATE TABLE IF NOT EXISTS points_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL,
    points_earned INTEGER NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Update subscription_plans table with new fields
ALTER TABLE subscription_plans 
ADD COLUMN IF NOT EXISTS plan_type VARCHAR(20) DEFAULT 'monthly' CHECK (plan_type IN ('weekly', 'monthly', 'quarterly', 'biannual', 'annual')),
ADD COLUMN IF NOT EXISTS tier_points_bonus INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS is_popular BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS discount_percentage DECIMAL(5,2),
ADD COLUMN IF NOT EXISTS original_price DECIMAL(10,2);

-- Update user_subscriptions table
ALTER TABLE user_subscriptions 
ADD COLUMN IF NOT EXISTS plan_type VARCHAR(20) DEFAULT 'monthly' CHECK (plan_type IN ('weekly', 'monthly', 'quarterly', 'biannual', 'annual')),
ADD COLUMN IF NOT EXISTS tier_points_earned INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS features_unlocked JSONB DEFAULT '[]'::jsonb;

-- Update subscription_payments table
ALTER TABLE subscription_payments 
ADD COLUMN IF NOT EXISTS tier_points_awarded INTEGER DEFAULT 0;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_tiers_user_id ON user_tiers(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tiers_total_points ON user_tiers(total_points DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_points_history_user_id ON points_history(user_id);
CREATE INDEX IF NOT EXISTS idx_points_history_created_at ON points_history(created_at DESC);

-- Create triggers for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_tiers_updated_at BEFORE UPDATE ON user_tiers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default subscription plans with new pricing structure
INSERT INTO subscription_plans (id, name, description, duration_days, price, currency, plan_type, tier_points_bonus, features, is_active, is_popular, created_at) VALUES
('weekly_plan', 'Weekly Access', 'Perfect for trying out our premium features', 7, 20.00, 'GHS', 'weekly', 50, '{"premium_content": true, "hd_streaming": true, "offline_download": false, "ad_free": false}', true, false, NOW()),
('monthly_plan', 'Monthly Premium', 'Most popular choice for regular users', 30, 69.99, 'GHS', 'monthly', 200, '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true}', true, true, NOW()),
('quarterly_plan', '3-Month Bundle', 'Save more with our quarterly plan', 90, 199.99, 'GHS', 'quarterly', 650, '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true, "exclusive_content": true}', true, false, NOW()),
('biannual_plan', '6-Month Premium', 'Best value for serious podcast enthusiasts', 180, 400.99, 'GHS', 'biannual', 1400, '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true, "exclusive_content": true, "priority_support": true}', true, false, NOW()),
('annual_plan', 'Annual Ultimate', 'Ultimate experience with maximum savings', 365, 73.99, 'USD', 'annual', 3000, '{"premium_content": true, "hd_streaming": true, "offline_download": true, "ad_free": true, "exclusive_content": true, "priority_support": true, "early_access": true, "creator_meetups": true}', true, false, NOW())
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    duration_days = EXCLUDED.duration_days,
    price = EXCLUDED.price,
    currency = EXCLUDED.currency,
    plan_type = EXCLUDED.plan_type,
    tier_points_bonus = EXCLUDED.tier_points_bonus,
    features = EXCLUDED.features,
    is_active = EXCLUDED.is_active,
    is_popular = EXCLUDED.is_popular;

-- Add discount information to plans
UPDATE subscription_plans 
SET original_price = 209.97, discount_percentage = 5.0 
WHERE id = 'quarterly_plan';

UPDATE subscription_plans 
SET original_price = 419.94, discount_percentage = 4.5 
WHERE id = 'biannual_plan';

-- Remove discount for annual plan since it's now at base price
UPDATE subscription_plans 
SET original_price = NULL, discount_percentage = NULL 
WHERE id = 'annual_plan';

-- Create RLS policies for security
ALTER TABLE user_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_history ENABLE ROW LEVEL SECURITY;

-- User tiers policies
CREATE POLICY "Users can view their own tier info" ON user_tiers
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own tier info" ON user_tiers
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Service can insert tier info" ON user_tiers
    FOR INSERT WITH CHECK (true);

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Service can insert notifications" ON notifications
    FOR INSERT WITH CHECK (true);

-- Points history policies
CREATE POLICY "Users can view their own points history" ON points_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Service can insert points history" ON points_history
    FOR INSERT WITH CHECK (true);

-- Create function to automatically create tier info for new users
CREATE OR REPLACE FUNCTION create_user_tier_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_tiers (user_id, current_tier, total_points, tier_progress, next_tier_threshold, tier_benefits)
    VALUES (
        NEW.id, 
        'gold', 
        0, 
        0, 
        1000, 
        '["Basic podcast access", "Standard quality streaming", "Monthly newsletter", "Basic customer support"]'::jsonb
    );
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to auto-create tier info for new users
DROP TRIGGER IF EXISTS create_user_tier_info_trigger ON auth.users;
CREATE TRIGGER create_user_tier_info_trigger
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION create_user_tier_info();

-- Create function to calculate tier based on points
CREATE OR REPLACE FUNCTION calculate_tier(points INTEGER)
RETURNS VARCHAR(20) AS $$
BEGIN
    IF points >= 3000 THEN
        RETURN 'prestige';
    ELSIF points >= 1000 THEN
        RETURN 'platinum';
    ELSE
        RETURN 'gold';
    END IF;
END;
$$ language 'plpgsql';

-- Create function to get tier benefits
CREATE OR REPLACE FUNCTION get_tier_benefits(tier VARCHAR(20))
RETURNS JSONB AS $$
BEGIN
    CASE tier
        WHEN 'gold' THEN
            RETURN '["Basic podcast access", "Standard quality streaming", "Monthly newsletter", "Basic customer support"]'::jsonb;
        WHEN 'platinum' THEN
            RETURN '["Premium podcast access", "HD quality streaming", "Weekly newsletter", "Early access to new content", "Ad-free experience", "Priority customer support", "10% discount on merchandise"]'::jsonb;
        WHEN 'prestige' THEN
            RETURN '["Exclusive premium content", "4K quality streaming", "Daily newsletter", "VIP early access", "Ad-free experience", "Direct creator messaging", "Exclusive events access", "VIP customer support", "20% discount on merchandise", "Monthly exclusive meetups", "Beta feature access"]'::jsonb;
        ELSE
            RETURN '[]'::jsonb;
    END CASE;
END;
$$ language 'plpgsql';

-- Create function to add points and update tier
CREATE OR REPLACE FUNCTION add_user_points(user_id_param UUID, points INTEGER, action_type VARCHAR(50), description TEXT DEFAULT NULL)
RETURNS JSONB AS $$
DECLARE
    current_tier_info RECORD;
    new_total_points INTEGER;
    new_tier VARCHAR(20);
    next_threshold INTEGER;
    tier_changed BOOLEAN := FALSE;
    result JSONB;
BEGIN
    -- Get current tier info
    SELECT * INTO current_tier_info FROM user_tiers WHERE user_id = user_id_param;
    
    -- Calculate new total points
    new_total_points := current_tier_info.total_points + points;
    
    -- Calculate new tier
    new_tier := calculate_tier(new_total_points);
    
    -- Determine next threshold
    next_threshold := CASE 
        WHEN new_tier = 'gold' THEN 1000
        WHEN new_tier = 'platinum' THEN 3000
        ELSE 3000
    END;
    
    -- Check if tier changed
    tier_changed := new_tier != current_tier_info.current_tier;
    
    -- Update user tier
    UPDATE user_tiers 
    SET 
        total_points = new_total_points,
        current_tier = new_tier,
        tier_progress = new_total_points - CASE 
            WHEN new_tier = 'gold' THEN 0
            WHEN new_tier = 'platinum' THEN 1000
            ELSE 3000
        END,
        next_tier_threshold = next_threshold,
        tier_benefits = get_tier_benefits(new_tier),
        updated_at = NOW()
    WHERE user_id = user_id_param;
    
    -- Insert points history
    INSERT INTO points_history (user_id, action_type, points_earned, description)
    VALUES (user_id_param, action_type, points, description);
    
    -- If tier changed, create notification
    IF tier_changed THEN
        INSERT INTO notifications (user_id, type, title, message, data)
        VALUES (
            user_id_param,
            'tier_upgrade',
            'Tier Upgraded!',
            'Congratulations! You''ve been upgraded to ' || upper(substring(new_tier from 1 for 1)) || substring(new_tier from 2) || ' tier.',
            jsonb_build_object(
                'old_tier', current_tier_info.current_tier,
                'new_tier', new_tier,
                'benefits', get_tier_benefits(new_tier)
            )
        );
    END IF;
    
    -- Return result
    result := jsonb_build_object(
        'success', TRUE,
        'points_added', points,
        'new_total_points', new_total_points,
        'new_tier', new_tier,
        'tier_changed', tier_changed
    );
    
    RETURN result;
END;
$$ language 'plpgsql';

-- Create view for leaderboard
CREATE OR REPLACE VIEW tier_leaderboard AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ut.total_points DESC) as rank,
    ut.user_id,
    ut.current_tier,
    ut.total_points,
    p.username,
    p.full_name,
    p.avatar_url
FROM user_tiers ut
LEFT JOIN profiles p ON ut.user_id = p.id
ORDER BY ut.total_points DESC;

COMMENT ON TABLE user_tiers IS 'Stores user tier information and points';
COMMENT ON TABLE notifications IS 'Stores user notifications including tier upgrades';
COMMENT ON TABLE points_history IS 'Tracks all point transactions for users';
COMMENT ON VIEW tier_leaderboard IS 'Leaderboard view showing user rankings by points';