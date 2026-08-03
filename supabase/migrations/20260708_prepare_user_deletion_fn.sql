-- Applied live via `supabase db query` on 2026-07-08; tracked here.

-- Server-side data cleanup for account deletion. Called ONLY by the
-- delete-account edge function (service role) right before it deletes the
-- auth user via the Admin API. Handles the FKs that would otherwise block
-- auth-user deletion (NO ACTION refs), then lets ON DELETE CASCADE handle
-- the rest when auth.users row is removed.
CREATE OR REPLACE FUNCTION public.prepare_user_deletion(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
BEGIN
  -- Personal records that NO-ACTION-reference auth.users: must be removed
  DELETE FROM subscription_payments WHERE user_id = p_user_id;
  DELETE FROM user_subscriptions WHERE user_id = p_user_id;

  -- Attribution columns: keep the business records, drop the link
  UPDATE clubs SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE youtube_content SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE game_results SET verified_by = NULL WHERE verified_by = p_user_id;
  UPDATE content_reports SET reviewed_by = NULL WHERE reviewed_by = p_user_id;
  UPDATE user_warnings SET issued_by = NULL WHERE issued_by = p_user_id;
  UPDATE bookings SET qr_scanned_by = NULL WHERE qr_scanned_by = p_user_id;
  UPDATE restaurants SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE lounges SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE pubs SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE arcade_centers SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE beaches SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE live_shows SET created_by = NULL WHERE created_by = p_user_id;
  UPDATE app_settings SET updated_by = NULL WHERE updated_by = p_user_id;
END;
$$;

REVOKE ALL ON FUNCTION public.prepare_user_deletion(UUID) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.prepare_user_deletion(UUID) FROM anon;
REVOKE ALL ON FUNCTION public.prepare_user_deletion(UUID) FROM authenticated;
GRANT EXECUTE ON FUNCTION public.prepare_user_deletion(UUID) TO service_role;
