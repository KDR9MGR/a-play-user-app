-- Needed so the organiser app can subscribe to UPDATE events on `clubs`
-- (see main_navigation_screen.dart's _listenForVenueApprovals) and notify an
-- organizer in-app the instant admin approves their pending venue, instead
-- of them having to manually refresh to find out.
--
-- Applied live via `supabase db query` on 2026-07-07.

ALTER PUBLICATION supabase_realtime ADD TABLE clubs;
