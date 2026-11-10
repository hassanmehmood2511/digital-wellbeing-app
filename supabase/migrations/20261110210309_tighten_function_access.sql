-- Trigger-only functions: nobody needs to call these through the API
-- (triggers still run them).
revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.refresh_challenge_participant_count() from public, anon, authenticated;

-- Used by row-security rules for signed-in users only.
revoke execute on function public.is_group_member(uuid) from public, anon;
grant execute on function public.is_group_member(uuid) to authenticated;

-- Fixed search path (security best practice).
alter function public.set_updated_at() set search_path = public;
