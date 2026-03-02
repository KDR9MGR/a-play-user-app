-- Create youtube_content table for storing video/podcast content
CREATE TABLE IF NOT EXISTS public.youtube_content (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  video_id VARCHAR(20) NOT NULL UNIQUE,
  title TEXT NOT NULL,
  description TEXT,
  category VARCHAR(100),
  year INTEGER,
  maturity_rating VARCHAR(20),
  seasons VARCHAR(50),
  content_type VARCHAR(20) DEFAULT 'video', -- 'featured', 'popular', 'trending', 'action'
  section_name VARCHAR(50),
  is_featured BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  image_url TEXT,
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_youtube_content_video_id ON public.youtube_content(video_id);
CREATE INDEX IF NOT EXISTS idx_youtube_content_section ON public.youtube_content(section_name);
CREATE INDEX IF NOT EXISTS idx_youtube_content_featured ON public.youtube_content(is_featured);
CREATE INDEX IF NOT EXISTS idx_youtube_content_type ON public.youtube_content(content_type);

-- Enable RLS (Row Level Security)
ALTER TABLE public.youtube_content ENABLE ROW LEVEL SECURITY;

-- Create policy for admin-only insert (assuming you have an admin role or specific admin user)
-- Policy for SELECT: Anyone can read
CREATE POLICY "Anyone can view youtube content" ON public.youtube_content
  FOR SELECT USING (true);

-- Policy for INSERT: Only admins can insert
CREATE POLICY "Only admins can insert youtube content" ON public.youtube_content
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND (
        auth.users.raw_user_meta_data->>'role' = 'admin' 
        OR auth.users.email LIKE '%@admin.%'
        OR auth.users.id IN (
          SELECT user_id FROM user_roles 
          WHERE role_name = 'admin'
        )
      )
    )
  );

-- Policy for UPDATE: Only admins can update
CREATE POLICY "Only admins can update youtube content" ON public.youtube_content
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND (
        auth.users.raw_user_meta_data->>'role' = 'admin' 
        OR auth.users.email LIKE '%@admin.%'
        OR auth.users.id IN (
          SELECT user_id FROM user_roles 
          WHERE role_name = 'admin'
        )
      )
    )
  );

-- Policy for DELETE: Only admins can delete
CREATE POLICY "Only admins can delete youtube content" ON public.youtube_content
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM auth.users 
      WHERE auth.users.id = auth.uid() 
      AND (
        auth.users.raw_user_meta_data->>'role' = 'admin' 
        OR auth.users.email LIKE '%@admin.%'
        OR auth.users.id IN (
          SELECT user_id FROM user_roles 
          WHERE role_name = 'admin'
        )
      )
    )
  );

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_youtube_content_updated_at 
  BEFORE UPDATE ON public.youtube_content 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert the existing content from podcast_screen.dart
INSERT INTO public.youtube_content (
  video_id, title, description, category, year, maturity_rating, seasons, 
  content_type, section_name, is_featured, display_order, image_url, thumbnail_url
) VALUES 
-- Featured Content
('xAt1xcC6qfM', 'The Future of Technology and Innovation', 
 'Exploring the next decade of technological advancement and its impact on society, business, and daily life.',
 'Technology • Innovation • Future', 2024, 'All Ages', 'Documentary Series',
 'featured', 'hero_carousel', true, 1,
 'https://img.youtube.com/vi/xAt1xcC6qfM/maxresdefault.jpg',
 'https://img.youtube.com/vi/xAt1xcC6qfM/hqdefault.jpg'),

('M8ICGx4p0lA', 'Mindfulness and Success Strategies',
 'How mindfulness practices and meditation can transform your professional and personal life for lasting success.',
 'Self-Help • Motivation • Wellness', 2024, 'All Ages', 'Educational Series',
 'featured', 'hero_carousel', true, 2,
 'https://img.youtube.com/vi/M8ICGx4p0lA/maxresdefault.jpg',
 'https://img.youtube.com/vi/M8ICGx4p0lA/hqdefault.jpg'),

('LLTStbLZYaI', 'Business Innovation Stories',
 'Stories of entrepreneurs who disrupted entire industries and changed the way we do business forever.',
 'Business • Entrepreneurship • Innovation', 2024, 'All Ages', 'Business Series',
 'featured', 'hero_carousel', true, 3,
 'https://img.youtube.com/vi/LLTStbLZYaI/maxresdefault.jpg',
 'https://img.youtube.com/vi/LLTStbLZYaI/hqdefault.jpg'),

('Lb6v6AUFWrM', 'Premium Content Experience',
 'Discover exclusive content and premium features that enhance your viewing experience.',
 'Entertainment • Premium • Exclusive', 2024, 'All Ages', 'Premium Series',
 'featured', 'hero_carousel', true, 4,
 'https://img.youtube.com/vi/Lb6v6AUFWrM/maxresdefault.jpg',
 'https://img.youtube.com/vi/Lb6v6AUFWrM/hqdefault.jpg'),

-- Popular Content
('RRKJiM9Njr8', 'Climate Change Solutions', null,
 'Science • Environment', 2024, 'All Ages', null,
 'popular', 'Popular on APlay', false, 1,
 'https://img.youtube.com/vi/RRKJiM9Njr8/maxresdefault.jpg',
 'https://img.youtube.com/vi/RRKJiM9Njr8/hqdefault.jpg'),

('ZWCq52FHGSY', 'Cryptocurrency Future', null,
 'Finance • Technology', 2024, 'All Ages', null,
 'popular', 'Popular on APlay', false, 2,
 'https://img.youtube.com/vi/ZWCq52FHGSY/maxresdefault.jpg',
 'https://img.youtube.com/vi/ZWCq52FHGSY/hqdefault.jpg'),

-- Add the same video with different context for popular section
('xAt1xcC6qfM', 'Future Technology Trends', null,
 'Technology • Innovation', 2024, 'All Ages', null,
 'popular', 'Popular on APlay', false, 3,
 'https://img.youtube.com/vi/xAt1xcC6qfM/maxresdefault.jpg',
 'https://img.youtube.com/vi/xAt1xcC6qfM/hqdefault.jpg'),

('M8ICGx4p0lA', 'Mindfulness Meditation', null,
 'Wellness • Self-Help', 2024, 'All Ages', null,
 'popular', 'Popular on APlay', false, 4,
 'https://img.youtube.com/vi/M8ICGx4p0lA/maxresdefault.jpg',
 'https://img.youtube.com/vi/M8ICGx4p0lA/hqdefault.jpg'),

('Lb6v6AUFWrM', 'Premium Content Hub', null,
 'Entertainment • Premium', 2024, 'All Ages', null,
 'popular', 'Popular on APlay', false, 5,
 'https://img.youtube.com/vi/Lb6v6AUFWrM/maxresdefault.jpg',
 'https://img.youtube.com/vi/Lb6v6AUFWrM/hqdefault.jpg'),

-- Trending Content
('LLTStbLZYaI', 'Startup Success Stories', null,
 'Business • Entrepreneurship', 2024, 'All Ages', null,
 'trending', 'Trending Now', false, 1,
 'https://img.youtube.com/vi/LLTStbLZYaI/maxresdefault.jpg',
 'https://img.youtube.com/vi/LLTStbLZYaI/hqdefault.jpg'),

('RRKJiM9Njr8', 'Environmental Innovation', null,
 'Science • Innovation', 2024, 'All Ages', null,
 'trending', 'Trending Now', false, 2,
 'https://img.youtube.com/vi/RRKJiM9Njr8/maxresdefault.jpg',
 'https://img.youtube.com/vi/RRKJiM9Njr8/hqdefault.jpg'),

('ZWCq52FHGSY', 'Digital Currency Revolution', null,
 'Finance • Cryptocurrency', 2024, 'All Ages', null,
 'trending', 'Trending Now', false, 3,
 'https://img.youtube.com/vi/ZWCq52FHGSY/maxresdefault.jpg',
 'https://img.youtube.com/vi/ZWCq52FHGSY/hqdefault.jpg'),

-- Action Content
('xAt1xcC6qfM', 'Tech Innovation Breakthroughs', null,
 'Technology • Innovation', 2024, 'All Ages', null,
 'action', 'Action', false, 1,
 'https://img.youtube.com/vi/xAt1xcC6qfM/maxresdefault.jpg',
 'https://img.youtube.com/vi/xAt1xcC6qfM/hqdefault.jpg'),

('M8ICGx4p0lA', 'Personal Development Mastery', null,
 'Self-Help • Personal Growth', 2024, 'All Ages', null,
 'action', 'Action', false, 2,
 'https://img.youtube.com/vi/M8ICGx4p0lA/maxresdefault.jpg',
 'https://img.youtube.com/vi/M8ICGx4p0lA/hqdefault.jpg'),

('LLTStbLZYaI', 'Business Transformation', null,
 'Business • Leadership', 2024, 'All Ages', null,
 'action', 'Action', false, 3,
 'https://img.youtube.com/vi/LLTStbLZYaI/maxresdefault.jpg',
 'https://img.youtube.com/vi/LLTStbLZYaI/hqdefault.jpg')

ON CONFLICT (video_id) DO NOTHING; 