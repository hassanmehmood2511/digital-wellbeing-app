-- =============================================================================
-- Behtar — make room for the Behtar schema without deleting anything.
--
-- The project already had tables from an earlier setup (e.g. a `profiles`
-- table without `full_name`). Any existing table whose columns don't match
-- what the app needs is RENAMED to <name>_legacy (data kept, nothing dropped),
-- so the next migration can create the correct table.
--
-- It also removes old sign-up triggers on auth.users that write into the old
-- tables (they would make every new sign-up fail), and old versions of the
-- functions the app defines, so they can be recreated with the right shape.
-- =============================================================================

do $$
declare
  required jsonb := jsonb_build_object(
    'profiles', jsonb_build_array('id', 'full_name', 'email', 'phone', 'language',
      'notifications_enabled', 'habit_reminders_enabled', 'daily_check_in_enabled',
      'wellbeing_tips_enabled', 'gentle_reminders_enabled', 'created_at', 'updated_at'),
    'habits', jsonb_build_array('id', 'user_id', 'title', 'description', 'category',
      'frequency', 'target_count', 'icon', 'priority', 'current_streak',
      'last_completed_on', 'created_at', 'updated_at'),
    'habit_logs', jsonb_build_array('habit_id', 'user_id', 'log_date',
      'completed_count', 'updated_at'),
    'challenges', jsonb_build_array('id', 'creator_id', 'title', 'description', 'goal',
      'starts_on', 'visibility', 'participant_count', 'created_at'),
    'challenge_participants', jsonb_build_array('challenge_id', 'user_id',
      'daily_progress', 'is_active', 'joined_at'),
    'groups', jsonb_build_array('id', 'creator_id', 'name', 'description',
      'visibility', 'invite_code', 'invite_expires_on', 'created_at'),
    'group_members', jsonb_build_array('group_id', 'user_id', 'joined_at'),
    'reward_transactions', jsonb_build_array('id', 'user_id', 'reward_key',
      'activity_name', 'points', 'type', 'earned_at'),
    'tracked_apps', jsonb_build_array('user_id', 'app_name', 'daily_limit_minutes',
      'is_tracked', 'sort_order', 'created_at'),
    'app_usage_daily', jsonb_build_array('user_id', 'app_name', 'usage_date',
      'usage_minutes')
  );
  -- Columns that must be uuid for the app's security rules to work.
  uuid_columns text[] := array['id', 'user_id', 'creator_id', 'habit_id',
    'challenge_id', 'group_id'];
  t text;
  col text;
  mismatch boolean;
  new_name text;
  trg record;
begin
  -- 1. Rename tables that don't match. Children first so foreign keys follow.
  foreach t in array array['habit_logs', 'challenge_participants', 'group_members',
    'reward_transactions', 'app_usage_daily', 'tracked_apps', 'habits',
    'challenges', 'groups', 'profiles'] loop
    if to_regclass('public.' || t) is null then
      continue;
    end if;

    mismatch := false;
    for col in select jsonb_array_elements_text(required -> t) loop
      if not exists (
        select 1 from information_schema.columns c
        where c.table_schema = 'public' and c.table_name = t and c.column_name = col
          and (col <> all (uuid_columns) or c.data_type = 'uuid')
      ) then
        mismatch := true;
        exit;
      end if;
    end loop;

    if mismatch then
      new_name := t || '_legacy';
      if to_regclass('public.' || new_name) is not null then
        new_name := t || '_legacy_' || to_char(now(), 'YYYYMMDDHH24MISS');
      end if;
      execute format('alter table public.%I rename to %I', t, new_name);
      raise notice 'Renamed old table public.% to public.% (data kept)', t, new_name;
    end if;
  end loop;

  -- 2. Remove old custom triggers on auth.users (e.g. an old "create profile on
  --    sign up" trigger). The next migration installs the correct one.
  for trg in
    select tg.tgname
    from pg_trigger tg
    join pg_proc p on p.oid = tg.tgfoid
    join pg_namespace n on n.oid = p.pronamespace
    where tg.tgrelid = 'auth.users'::regclass
      and not tg.tgisinternal
      and n.nspname = 'public'
  loop
    execute format('drop trigger if exists %I on auth.users', trg.tgname);
    raise notice 'Removed old trigger % on auth.users', trg.tgname;
  end loop;
end;
$$;

-- 3. Old versions of the app's functions may have a different signature or
--    return type, which "create or replace" cannot change.
drop function if exists public.join_group_with_code(text) cascade;
drop function if exists public.get_my_group_members() cascade;
drop function if exists public.delete_my_account() cascade;
drop function if exists public.handle_new_user() cascade;
drop function if exists public.refresh_challenge_participant_count() cascade;
drop function if exists public.is_group_member(uuid) cascade;
