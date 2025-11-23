-- Create a function to get zones availability for a specific event and date
CREATE OR REPLACE FUNCTION get_zones_availability(
  p_event_id UUID,
  p_booking_date DATE
)
RETURNS TABLE (
  zone_id UUID,
  name TEXT,
  price NUMERIC,
  capacity INTEGER,
  booked INTEGER,
  available INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH zone_bookings AS (
    SELECT 
      b.zone_id,
      COALESCE(SUM(b.quantity), 0) as total_booked
    FROM bookings b
    WHERE b.event_id = p_event_id
      AND b.booking_date = p_booking_date
      AND b.status = 'confirmed'
    GROUP BY b.zone_id
  )
  SELECT 
    z.id as zone_id,
    z.name,
    z.price,
    z.capacity,
    COALESCE(zb.total_booked, 0) as booked,
    z.capacity - COALESCE(zb.total_booked, 0) as available
  FROM zones z
  LEFT JOIN zone_bookings zb ON z.id = zb.zone_id
  WHERE z.event_id = p_event_id
  ORDER BY z.name;
END;
$$ LANGUAGE plpgsql; 