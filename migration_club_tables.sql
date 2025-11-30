-- Create club_tables table
CREATE TABLE public.club_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    club_id UUID NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    capacity INTEGER NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    price_per_hour DECIMAL(10, 2) NOT NULL,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create club_bookings table for club table reservations
CREATE TABLE public.club_bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    club_id UUID NOT NULL REFERENCES public.clubs(id) ON DELETE CASCADE,
    table_id UUID NOT NULL REFERENCES public.club_tables(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index on club_tables
CREATE INDEX idx_club_tables_club_id ON public.club_tables (club_id);

-- Create indexes on club_bookings
CREATE INDEX idx_club_bookings_user_id ON public.club_bookings (user_id);
CREATE INDEX idx_club_bookings_club_id ON public.club_bookings (club_id);
CREATE INDEX idx_club_bookings_table_id ON public.club_bookings (table_id);
CREATE INDEX idx_club_bookings_date ON public.club_bookings (booking_date);

-- Enable Row Level Security
ALTER TABLE public.club_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.club_bookings ENABLE ROW LEVEL SECURITY;

-- RLS policies for club_tables
-- Everyone can read tables
CREATE POLICY "Club tables are viewable by everyone" 
ON public.club_tables FOR SELECT USING (true);

-- Only admins can insert/update/delete tables
CREATE POLICY "Club tables can be inserted by admins" 
ON public.club_tables FOR INSERT TO authenticated 
WITH CHECK (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
));

CREATE POLICY "Club tables can be updated by admins" 
ON public.club_tables FOR UPDATE TO authenticated 
USING (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
)) 
WITH CHECK (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
));

CREATE POLICY "Club tables can be deleted by admins" 
ON public.club_tables FOR DELETE TO authenticated 
USING (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.role = 'admin'
));

-- RLS policies for club_bookings

-- Users can view their own bookings and admins can view all bookings
CREATE POLICY "Users can view own club bookings, admins can view all" 
ON public.club_bookings FOR SELECT USING (
    auth.uid() = user_id OR 
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
    )
);

-- Users can create their own bookings
CREATE POLICY "Users can create own club bookings" 
ON public.club_bookings FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = user_id);

-- Users can update their own pending or confirmed bookings
CREATE POLICY "Users can update own pending club bookings" 
ON public.club_bookings FOR UPDATE TO authenticated 
USING (
    auth.uid() = user_id AND 
    (status = 'pending' OR status = 'confirmed')
)
WITH CHECK (
    auth.uid() = user_id AND 
    (status = 'pending' OR status = 'confirmed')
);

-- Admins can update any booking
CREATE POLICY "Admins can update any club booking" 
ON public.club_bookings FOR UPDATE TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
    )
);

-- Users can delete their own pending bookings
CREATE POLICY "Users can delete own pending club bookings" 
ON public.club_bookings FOR DELETE TO authenticated 
USING (
    auth.uid() = user_id AND status = 'pending'
);

-- Admins can delete any booking
CREATE POLICY "Admins can delete any club booking" 
ON public.club_bookings FOR DELETE TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.id = auth.uid() AND p.role = 'admin'
    )
);

-- Insert sample data for club tables
INSERT INTO public.club_tables (club_id, name, capacity, is_available, price_per_hour, location)
VALUES
-- Assuming club IDs from your existing clubs table
-- Replace these club_ids with actual values from your database
((SELECT id FROM public.clubs LIMIT 1 OFFSET 0), 'VIP Table 1', 6, true, 150.00, 'Main Floor'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 0), 'VIP Table 2', 8, true, 180.00, 'Main Floor'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 0), 'Regular Table 1', 4, true, 80.00, 'Bar Area'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 0), 'Lounge Area 1', 10, true, 220.00, 'Mezzanine'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 1), 'Premium Booth 1', 8, true, 200.00, 'Dance Floor'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 1), 'Premium Booth 2', 8, true, 200.00, 'Dance Floor'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 1), 'Bar Table 1', 2, true, 50.00, 'Bar'),
((SELECT id FROM public.clubs LIMIT 1 OFFSET 1), 'Bar Table 2', 2, true, 50.00, 'Bar'); 