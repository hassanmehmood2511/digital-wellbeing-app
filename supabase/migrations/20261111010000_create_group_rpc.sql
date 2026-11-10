-- =============================================================================
-- Behtar — create a group and add its creator as a member in ONE step.
--
-- Doing this as two separate inserts from the app could leave a half-created
-- group or be blocked by row security. This function does both atomically
-- and returns a clear error message if anything is wrong.
-- =============================================================================

create or replace function public.create_group(
  p_id uuid,
  p_name text,
  p_description text,
  p_visibility text,
  p_invite_code text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'You need to be logged in to create a group.';
  end if;

  insert into public.groups (id, creator_id, name, description, visibility, invite_code)
  values (
    p_id,
    auth.uid(),
    trim(p_name),
    trim(p_description),
    p_visibility,
    upper(trim(p_invite_code))
  );

  insert into public.group_members (group_id, user_id)
  values (p_id, auth.uid());
end;
$$;

revoke all on function public.create_group(uuid, text, text, text, text) from public, anon;
grant execute on function public.create_group(uuid, text, text, text, text) to authenticated;
