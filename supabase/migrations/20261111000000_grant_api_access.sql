-- =============================================================================
-- Behtar — give the app (signed-in users) access to its tables.
--
-- Newer Supabase projects no longer grant table privileges to the API roles
-- automatically, which caused "permission denied for table ...".
-- Row Level Security policies (from the first migration) still decide WHICH
-- rows each user can see or change; these grants only open the tables to them.
-- =============================================================================

grant usage on schema public to anon, authenticated;

grant select, insert, update, delete on table
  public.profiles,
  public.habits,
  public.habit_logs,
  public.challenges,
  public.challenge_participants,
  public.groups,
  public.group_members,
  public.reward_transactions,
  public.tracked_apps,
  public.app_usage_daily
to authenticated;

-- Server-side roles used by Supabase itself.
grant all on table
  public.profiles,
  public.habits,
  public.habit_logs,
  public.challenges,
  public.challenge_participants,
  public.groups,
  public.group_members,
  public.reward_transactions,
  public.tracked_apps,
  public.app_usage_daily
to service_role;

-- App functions.
grant execute on function public.join_group_with_code(text) to authenticated;
grant execute on function public.get_my_group_members() to authenticated;
grant execute on function public.delete_my_account() to authenticated;
grant execute on function public.is_group_member(uuid) to authenticated;
