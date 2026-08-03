-- Single 'media' bucket for vendor (organiser) and user uploads, labeled by
-- folder so the same bucket can serve multiple features while RLS still
-- validates ownership from the uid embedded in the path. Pattern taken from
-- an equivalent reference project (bottlesup-monorepo).
--
-- Folder convention:
--   flyers/{uid}/...            -> organiser event flyers
--   clubs/{uid}/...             -> organiser club/venue cover image
--   venues/{uid}/...            -> organiser venue gallery images
--   profiles/users/{uid}/...    -> user profile pictures
--   event-photos/{eventId}/...  -> user-submitted event photos (not uid-scoped)
--
-- Applied live via `supabase db query` on 2026-07-06; this file exists so
-- the change is tracked instead of only living in the database.
-- Existing buckets (avatars, event-images, images, podcast-covers,
-- podcast-cover-images, post-images) are untouched - out of scope here.

INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Media is publicly readable" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload media" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own media" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own media" ON storage.objects;

CREATE POLICY "Media is publicly readable"
ON storage.objects FOR SELECT
USING (bucket_id = 'media');

CREATE POLICY "Authenticated users can upload media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'media'
  AND (
    (storage.foldername(name))[2] = auth.uid()::text
    OR (storage.foldername(name))[3] = auth.uid()::text
    OR (storage.foldername(name))[1] = 'event-photos'
  )
);

CREATE POLICY "Users can update their own media"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'media'
  AND (
    (storage.foldername(name))[2] = auth.uid()::text
    OR (storage.foldername(name))[3] = auth.uid()::text
    OR (storage.foldername(name))[1] = 'event-photos'
  )
);

CREATE POLICY "Users can delete their own media"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'media'
  AND (
    (storage.foldername(name))[2] = auth.uid()::text
    OR (storage.foldername(name))[3] = auth.uid()::text
    OR (storage.foldername(name))[1] = 'event-photos'
  )
);
