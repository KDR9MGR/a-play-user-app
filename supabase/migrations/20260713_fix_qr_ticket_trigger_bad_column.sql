-- Applied live via `supabase db query` on 2026-07-13; tracked here.

-- Fixes a pre-existing bug in auto_generate_qr_ticket() surfaced by the S2
-- confirm-purchase fix: it referenced NEW.qr_code, a column that does not
-- exist on bookings (only qr_code_serial/qr_code_data do - "For backward
-- compatibility" was stale). This trigger only fires when status='confirmed'
-- AND payment_status='paid' simultaneously - the old client-side booking
-- insert never set payment_status at all, so this branch never ran and the
-- bad column reference was never hit until confirm-purchase correctly set
-- both fields together.
CREATE OR REPLACE FUNCTION public.auto_generate_qr_ticket()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
DECLARE
  v_serial TEXT;
  v_qr_data TEXT;
  v_expires_at TIMESTAMP WITH TIME ZONE;
  v_event_end_date TIMESTAMP WITH TIME ZONE;
BEGIN
  IF NEW.status = 'confirmed' AND NEW.payment_status = 'paid' THEN
    v_serial := generate_qr_serial('EVT');
    v_qr_data := generate_qr_data(NEW.id, v_serial, NEW.user_id, NEW.event_id);

    SELECT end_date INTO v_event_end_date
    FROM events
    WHERE id = NEW.event_id;

    v_expires_at := v_event_end_date + INTERVAL '24 hours';

    NEW.qr_code_serial := v_serial;
    NEW.qr_code_data := v_qr_data;
    NEW.qr_expires_at := v_expires_at;
    NEW.qr_is_valid := true;
  END IF;

  RETURN NEW;
END;
$function$;
