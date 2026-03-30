-- Enable UUID extension if not enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing type if exists
DROP TYPE IF EXISTS request_status;

-- Create enum for request status
CREATE TYPE request_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Create or update the concierge_requests table
DROP TABLE IF EXISTS public.concierge_requests;
CREATE TABLE public.concierge_requests (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id uuid NOT NULL,
  category TEXT NOT NULL,
  service_name TEXT NOT NULL,
  description TEXT NOT NULL,
  status request_status NOT NULL DEFAULT 'pending'::request_status,
  is_urgent BOOLEAN DEFAULT false,
  requested_at TIMESTAMPTZ DEFAULT now(),
  additional_details JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES auth.users (id) ON DELETE CASCADE
);

-- Enable RLS
ALTER TABLE public.concierge_requests ENABLE ROW LEVEL SECURITY;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_concierge_requests_user_id ON public.concierge_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_concierge_requests_status ON public.concierge_requests(status);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS tr_concierge_requests_updated_at ON public.concierge_requests;

-- Create trigger for updated_at
CREATE TRIGGER tr_concierge_requests_updated_at
    BEFORE UPDATE ON public.concierge_requests
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.concierge_requests;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.concierge_requests;
DROP POLICY IF EXISTS "Enable update access for users based on user_id" ON public.concierge_requests;
DROP POLICY IF EXISTS "Enable delete access for users based on user_id" ON public.concierge_requests;

-- Create policies for authenticated users
CREATE POLICY "Enable read access for authenticated users"
ON public.concierge_requests
FOR SELECT
TO authenticated
USING (auth.uid() = user_id::uuid);

CREATE POLICY "Enable insert access for authenticated users"
ON public.concierge_requests
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = user_id::uuid
);

CREATE POLICY "Enable update access for users based on user_id"
ON public.concierge_requests
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id::uuid)
WITH CHECK (auth.uid() = user_id::uuid);

-- Create function to handle new requests
CREATE OR REPLACE FUNCTION public.handle_new_request()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Set the user_id from the auth context
  NEW.user_id := auth.uid()::uuid;
  
  -- Set default status if not provided
  IF NEW.status IS NULL THEN
    NEW.status := 'pending'::request_status;
  END IF;
  
  -- Set timestamps
  NEW.created_at := now();
  NEW.updated_at := now();
  NEW.requested_at := now();
  
  RETURN NEW;
END;
$$;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS tr_handle_new_request ON public.concierge_requests;

-- Create trigger for new requests
CREATE TRIGGER tr_handle_new_request
  BEFORE INSERT ON public.concierge_requests
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_request();

-- Grant necessary permissions
GRANT ALL ON public.concierge_requests TO postgres;
GRANT ALL ON public.concierge_requests TO authenticated;
GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Create admin access function
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 
    FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'is_admin' = 'true'
  );
$$;

-- Create admin policies
CREATE POLICY "Admin full access"
ON public.concierge_requests
FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin()); 