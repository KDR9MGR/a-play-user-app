-- Applied live via `supabase db query` on 2026-07-08; tracked here.

-- handle_new_user previously hardcoded is_organizer=false / role='user',
-- silently discarding the metadata the organiser app sends at signUp. With
-- email confirmation enabled, the client can't fix the profile up after the
-- fact either (signUp returns no session), so every email-confirmed
-- organiser signup ended up a regular user. Read the flags from
-- raw_user_meta_data instead, defaulting to a plain user when absent.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
declare
  v_is_organizer boolean;
  v_role text;
begin
  v_is_organizer := coalesce(
    (new.raw_user_meta_data->>'is_organizer')::boolean,
    lower(coalesce(new.raw_user_meta_data->>'role', '')) = 'organizer',
    false
  );
  v_role := case
    when lower(coalesce(new.raw_user_meta_data->>'role', '')) in ('organizer', 'user')
      then lower(new.raw_user_meta_data->>'role')
    when v_is_organizer then 'organizer'
    else 'user'
  end;

  insert into public.profiles (
    id,
    email,
    full_name,
    display_name,
    avatar_url,
    photo_url,
    phone,
    organizer_category,
    role,
    is_active,
    is_premium,
    is_subscribed,
    current_tier,
    subscription_tier,
    is_approved,
    is_organizer,
    created_at,
    updated_at,
    last_sign_in_time,
    user_metadata
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      new.raw_user_meta_data->>'display_name',
      'User'
    ),
    coalesce(
      new.raw_user_meta_data->>'display_name',
      new.raw_user_meta_data->>'name',
      split_part(coalesce(new.email, 'user'), '@', 1),
      'User'
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture'
    ),
    coalesce(
      new.raw_user_meta_data->>'picture',
      new.raw_user_meta_data->>'avatar_url'
    ),
    nullif(new.raw_user_meta_data->>'phone', ''),
    nullif(lower(coalesce(new.raw_user_meta_data->>'organizer_category', '')), ''),
    v_role,
    true,
    false,
    false,
    'Free',
    'Free',
    true,
    v_is_organizer,
    now(),
    now(),
    now(),
    new.raw_user_meta_data
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = excluded.full_name,
    display_name = excluded.display_name,
    avatar_url = excluded.avatar_url,
    photo_url = excluded.photo_url,
    updated_at = now(),
    last_sign_in_time = now(),
    user_metadata = excluded.user_metadata;

  return new;
end;
$function$;
