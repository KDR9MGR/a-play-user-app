-- =====================================================
-- A-PLAY STAGING DATABASE - SEED DATA
-- =====================================================
-- Created: December 16, 2024
-- Purpose: Sample data for testing
-- Order: Run this file FOURTH (after 02_functions_triggers.sql)
-- =====================================================

-- =====================================================
-- 1. SUBSCRIPTION PLANS (NEW SCHEMA)
-- =====================================================
-- 4 tiers: Free, Gold, Platinum, Black

INSERT INTO subscription_plans (id, name, description, price_monthly, price_yearly, tier_level, features, benefits) VALUES

-- FREE TIER
('free-tier', 'Free', 'Basic access to all events', 0.00, 0.00, 1,
'{
  "tier": "Free",
  "color": "#9E9E9E",
  "points_multiplier": 1,
  "discount_percentage": 0,
  "early_booking_hours": 0,
  "concierge_access": false,
  "concierge_hours": "none",
  "vip_entry": false,
  "priority_support": false,
  "free_reservations_per_month": 0,
  "vip_lounge_access": false,
  "points_per_booking": 10,
  "points_per_review": 5,
  "referral_limit": 5,
  "support_response_hours": 48,
  "badge_type": "basic"
}'::jsonb,
ARRAY['Browse all events', 'Basic booking', 'Standard support', 'View public reviews']
),

-- GOLD TIER
('gold-tier', 'Gold', 'Premium features and early access', 120.00, 1200.00, 2,
'{
  "tier": "Gold",
  "color": "#FFD700",
  "points_multiplier": 2,
  "discount_percentage": 10,
  "early_booking_hours": 48,
  "concierge_access": true,
  "concierge_hours": "business_hours",
  "vip_entry": false,
  "priority_support": true,
  "free_reservations_per_month": 3,
  "vip_lounge_access": true,
  "event_upgrades_per_month": 1,
  "concierge_requests_per_month": 3,
  "points_per_booking": 20,
  "points_per_review": 10,
  "referral_limit": 10,
  "support_response_hours": 12,
  "badge_type": "gold"
}'::jsonb,
ARRAY['10% discount on all bookings', '48-hour early booking', '3 free table reservations/month', 'VIP lounge access', 'Priority support', '2x reward points']
),

-- PLATINUM TIER
('platinum-tier', 'Platinum', 'VIP treatment and exclusive perks', 250.00, 2500.00, 3,
'{
  "tier": "Platinum",
  "color": "#E5E4E2",
  "points_multiplier": 3,
  "discount_percentage": 15,
  "early_booking_hours": 72,
  "concierge_access": true,
  "concierge_hours": "24/7",
  "vip_entry": true,
  "priority_support": true,
  "free_reservations_per_month": 999,
  "vip_lounge_access": true,
  "all_access_vip_lounge": true,
  "event_upgrades_per_month": 999,
  "concierge_requests_per_month": 999,
  "meet_greet_per_year": 2,
  "backstage_access_per_year": 2,
  "free_parking": true,
  "personal_coordinator": true,
  "quarterly_gifts": true,
  "points_per_booking": 30,
  "points_per_review": 15,
  "referral_limit": 999,
  "support_response_hours": 6,
  "badge_type": "platinum",
  "animated_badge": true
}'::jsonb,
ARRAY['15% discount on all bookings', '72-hour early access', 'Unlimited table reservations', 'All-access VIP lounge', 'Personal event coordinator', 'Free parking', 'Backstage access', '3x reward points']
),

-- BLACK TIER
('black-tier', 'Black', 'Ultimate luxury experience', 500.00, 5000.00, 4,
'{
  "tier": "Black",
  "color": "#000000",
  "points_multiplier": 5,
  "discount_percentage": 20,
  "early_booking_hours": 168,
  "concierge_access": true,
  "concierge_hours": "24/7",
  "vip_entry": true,
  "priority_support": true,
  "free_reservations_per_month": 999,
  "vip_lounge_access": true,
  "all_access_vip_lounge": true,
  "event_upgrades_per_month": 999,
  "concierge_requests_per_month": 999,
  "meet_greet_per_year": 999,
  "backstage_access_per_year": 999,
  "free_parking": true,
  "personal_coordinator": true,
  "quarterly_gifts": true,
  "invite_only": true,
  "exclusive_first_access": true,
  "dedicated_concierge": true,
  "private_lounge_access": true,
  "valet_service": true,
  "dedicated_account_manager": true,
  "luxury_gifts": true,
  "private_events": true,
  "celebrity_access": true,
  "luxury_transport": true,
  "international_perks": true,
  "points_per_booking": 50,
  "points_per_review": 25,
  "referral_limit": 999,
  "support_response_hours": 1,
  "badge_type": "black",
  "animated_badge": true
}'::jsonb,
ARRAY['20% discount on all bookings', '1-week early access', 'Unlimited everything', 'Private lounge access', 'Dedicated account manager', 'Valet service', 'Luxury transportation', 'Celebrity meet & greet', 'International event perks', '5x reward points']
)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. SAMPLE EVENTS
-- =====================================================

INSERT INTO events (title, description, category, start_date, end_date, location, address, cover_image, price, total_capacity, available_capacity, is_featured, is_active) VALUES

-- Today's events
('Afrobeats Night', 'The hottest Afrobeats party in Accra', 'Music', NOW() + INTERVAL '6 hours', NOW() + INTERVAL '12 hours', 'Accra Sports Stadium', 'Independence Avenue, Accra', 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3', 50.00, 500, 450, true, true),

('Comedy Central', 'Stand-up comedy with Ghana''s best comedians', 'Comedy', NOW() + INTERVAL '8 hours', NOW() + INTERVAL '11 hours', 'National Theatre', 'Liberia Road, Accra', 'https://images.unsplash.com/photo-1527224857830-43a7acc85260', 30.00, 300, 280, false, true),

-- Tomorrow's events
('Jazz & Wine Night', 'Smooth jazz and premium wines', 'Music', NOW() + INTERVAL '1 day' + INTERVAL '7 hours', NOW() + INTERVAL '1 day' + INTERVAL '11 hours', 'Labadi Beach Hotel', 'Labadi, Accra', 'https://images.unsplash.com/photo-1511192336575-5a79af67a629', 80.00, 150, 120, true, true),

('Gospel Praise Concert', 'Worship night with top gospel artists', 'Music', NOW() + INTERVAL '1 day' + INTERVAL '5 hours', NOW() + INTERVAL '1 day' + INTERVAL '9 hours', 'Perez Dome', 'Dzorwulu, Accra', 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14', 25.00, 1000, 800, false, true),

-- This week's events
('Tech Startup Conference', 'Innovation and entrepreneurship summit', 'Conference', NOW() + INTERVAL '3 days', NOW() + INTERVAL '3 days' + INTERVAL '8 hours', 'Kempinski Hotel', 'Ridge, Accra', 'https://images.unsplash.com/photo-1540575467063-178a50c2df87', 100.00, 250, 200, true, true),

('Food Festival Ghana', 'Taste of Ghana - Food and culture celebration', 'Food & Drink', NOW() + INTERVAL '5 days', NOW() + INTERVAL '5 days' + INTERVAL '10 hours', 'Independence Square', 'High Street, Accra', 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1', 15.00, 2000, 1950, true, true),

('Hip Hop Block Party', 'Old school vs new school hip hop', 'Music', NOW() + INTERVAL '6 days' + INTERVAL '7 hours', NOW() + INTERVAL '7 days', 'Oxford Street', 'Osu, Accra', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f', 40.00, 800, 650, false, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 3. SAMPLE CLUBS
-- =====================================================

INSERT INTO clubs (name, description, logo_url, cover_image_url, address, city, phone, email, operating_hours, has_vip_section, has_restaurant, has_parking, average_rating, total_reviews, price_range, is_featured, is_active) VALUES

('Republic Bar & Grill', 'Upscale lounge with live DJ performances', 'https://via.placeholder.com/100', 'https://images.unsplash.com/photo-1566417713940-fe7c737a9ef2', 'Airport Residential Area', 'Accra', '+233 24 123 4567', 'info@republicbar.com', '{"monday": "5pm-2am", "friday": "5pm-4am", "saturday": "5pm-4am", "sunday": "closed"}'::jsonb, true, true, true, 4.5, 120, 3, true, true),

('Twist Nightclub', 'Premier nightclub with international DJs', 'https://via.placeholder.com/100', 'https://images.unsplash.com/photo-1571266028243-d220c6e2ca78', 'Osu Oxford Street', 'Accra', '+233 24 234 5678', 'info@twistclub.com', '{"thursday": "9pm-4am", "friday": "9pm-5am", "saturday": "9pm-5am"}'::jsonb, true, false, true, 4.2, 95, 3, true, true),

('Sandbox Beach Bar', 'Beach vibes with cocktails and sunset views', 'https://via.placeholder.com/100', 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf', 'Labadi Beach Road', 'Accra', '+233 24 345 6789', 'info@sandboxgh.com', '{"monday": "12pm-10pm", "friday": "12pm-12am", "saturday": "10am-12am", "sunday": "10am-10pm"}'::jsonb, true, true, true, 4.7, 200, 2, true, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 4. SAMPLE LOUNGES
-- =====================================================

INSERT INTO lounges (name, description, cover_image_url, address, phone, operating_hours, average_rating, total_reviews, price_range, is_featured, is_active) VALUES

('Royal Crown Lounge', 'Executive lounge with cigar room', 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34', 'Cantonments, Accra', '+233 24 456 7890', '{"monday": "3pm-11pm", "saturday": "3pm-12am", "sunday": "3pm-10pm"}'::jsonb, 4.3, 75, 4, true, true),

('Skyline Lounge', 'Rooftop lounge with panoramic city views', 'https://images.unsplash.com/photo-1514933651103-005eec06c04b', 'Airport City, Accra', '+233 24 567 8901', '{"monday": "4pm-12am", "friday": "4pm-2am", "saturday": "4pm-2am"}'::jsonb, 4.6, 110, 3, true, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 5. SAMPLE PUBS
-- =====================================================

INSERT INTO pubs (name, description, cover_image_url, address, phone, has_sports_viewing, has_live_music, average_rating, total_reviews, price_range, is_featured, is_active) VALUES

('Champions Sports Pub', 'Sports bar with 10 big screens', 'https://images.unsplash.com/photo-1504674900247-0877df9cc836', 'East Legon, Accra', '+233 24 678 9012', true, false, 4.1, 85, 2, true, true),

('The Lions Den Pub', 'Traditional pub with craft beers', 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd', 'Osu, Accra', '+233 24 789 0123', true, true, 4.4, 95, 2, true, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. SAMPLE ARCADE CENTERS
-- =====================================================

INSERT INTO arcade_centers (name, description, cover_image_url, address, phone, entry_fee, has_vr_games, has_console_games, has_arcade_machines, average_rating, total_reviews, is_featured, is_active) VALUES

('GameZone Accra', 'Ultimate gaming experience with VR and classic arcade', 'https://images.unsplash.com/photo-1550745165-9bc0b252726f', 'Accra Mall, Tetteh Quarshie', '+233 24 890 1234', 20.00, true, true, true, 4.8, 150, true, true),

('Pixel Paradise', 'Retro and modern gaming center', 'https://images.unsplash.com/photo-1511512578047-dfb367046420', 'West Hills Mall, Weija', '+233 24 901 2345', 15.00, false, true, true, 4.5, 80, false, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 7. SAMPLE BEACHES
-- =====================================================

INSERT INTO beaches (name, description, cover_image_url, address, phone, entry_fee, has_facilities, has_water_sports, has_restaurant, average_rating, total_reviews, is_featured, is_active) VALUES

('Kokrobite Beach', 'Popular beach with great waves and live reggae music', 'https://images.unsplash.com/photo-1559827260-dc66d52bef19', 'Kokrobite, Greater Accra', '+233 24 012 3456', 10.00, true, true, true, 4.6, 220, true, true),

('Labadi Beach', 'City beach with water sports and beach volleyball', 'https://images.unsplash.com/photo-1544551763-46a013bb70d5', 'Labadi, Accra', '+233 24 123 4567', 5.00, true, true, true, 4.2, 180, true, true),

('Cape Coast Beach', 'Scenic beach near historic castles', 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e', 'Cape Coast, Central Region', '+233 24 234 5678', 5.00, true, false, true, 4.4, 95, false, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 8. SAMPLE LIVE SHOWS
-- =====================================================

INSERT INTO live_shows (name, description, venue_name, cover_image_url, address, phone, show_date, show_time, ticket_price, available_tickets, show_type, average_rating, total_reviews, is_featured, is_active) VALUES

('Stonebwoy Live Concert', 'BHIM Nation President live in concert', 'Accra Sports Stadium', 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a', 'Independence Avenue, Accra', '+233 24 345 6789', CURRENT_DATE + INTERVAL '10 days', '19:00:00', 100.00, 5000, 'concert', 4.9, 350, true, true),

('Ghana Comedy Night', 'Featuring DKB, Clemento Suarez, and more', 'National Theatre', 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca', 'Liberia Road, Accra', '+233 24 456 7890', CURRENT_DATE + INTERVAL '15 days', '20:00:00', 50.00, 400, 'comedy', 4.7, 120, true, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- 9. SAMPLE RESTAURANTS
-- =====================================================

INSERT INTO restaurants (name, description, cover_image_url, address, city, phone, cuisine_type, operating_hours, price_range, has_delivery, has_takeaway, has_reservation, average_rating, total_reviews, is_featured, is_active) VALUES

('Chez Afrique', 'Contemporary African cuisine with a modern twist', 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0', 'Roman Ridge, Accra', 'Accra', '+233 24 567 8901', ARRAY['African', 'Continental'], '{"monday": "11am-10pm", "sunday": "11am-9pm"}'::jsonb, 3, true, true, true, 4.5, 190, true, true),

('Buka Restaurant', 'Authentic West African home cooking', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', 'Osu Oxford Street, Accra', 'Accra', '+233 24 678 9012', ARRAY['West African', 'Nigerian'], '{"monday": "10am-10pm", "sunday": "10am-8pm"}'::jsonb, 2, true, true, true, 4.3, 145, true, true),

('Santoku Japanese', 'Sushi and Japanese fusion dining', 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351', 'Airport Residential, Accra', 'Accra', '+233 24 789 0123', ARRAY['Japanese', 'Asian Fusion'], '{"tuesday": "12pm-10pm", "sunday": "closed"}'::jsonb, 4, true, false, true, 4.7, 210, true, true)

ON CONFLICT DO NOTHING;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Seed data inserted successfully!';
  RAISE NOTICE '📊 4 subscription plans created';
  RAISE NOTICE '🎉 7 sample events added';
  RAISE NOTICE '🍸 3 clubs, 2 lounges, 2 pubs added';
  RAISE NOTICE '🎮 2 arcade centers added';
  RAISE NOTICE '🏖️  3 beaches added';
  RAISE NOTICE '🎭 2 live shows added';
  RAISE NOTICE '🍽️  3 restaurants added';
  RAISE NOTICE '';
  RAISE NOTICE '🎯 Database setup complete!';
  RAISE NOTICE '📱 You can now test the user app';
END $$;
