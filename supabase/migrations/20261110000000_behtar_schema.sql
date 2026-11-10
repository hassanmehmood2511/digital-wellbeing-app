-- =============================================================================
-- Behtar — Supabase schema
-- Run this whole file once in: Supabase Dashboard -> SQL Editor -> New query.
-- It is safe to run again (it skips objects that already exist).
-- =============================================================================

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- Shared helper: keep updated_at current
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =============================================================================
-- PROFILES (one row per auth user, created automatically on sign up)
-- =============================================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  email text not null default '',
  phone text not null default '',
  language text not null default 'English',
  notifications_enabled boolean not null default true,
  habit_reminders_enabled boolean not null default true,
  daily_check_in_enabled boolean not null default true,
  wellbeing_tips_enabled boolean not null default false,
  gentle_reminders_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Create the profile when a user signs up (email or Google).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, phone)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'name',
      ''
    ),
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'phone', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill profiles for any users created before this script ran.
insert into public.profiles (id, full_name, email, phone)
select
  u.id,
  coalesce(u.raw_user_meta_data ->> 'full_name', u.raw_user_meta_data ->> 'name', ''),
  coalesce(u.email, ''),
  coalesce(u.raw_user_meta_data ->> 'phone', '')
from auth.users u
on conflict (id) do nothing;

-- =============================================================================
-- HABITS + daily completion logs
-- =============================================================================
create table if not exists public.habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 80),
  description text not null default '',
  category text not null default 'General',
  frequency text not null default 'Daily',
  target_count int not null default 1 check (target_count between 1 and 100),
  icon text not null default '✅',
  priority text not null default 'Medium' check (priority in ('High', 'Medium', 'Low')),
  current_streak int not null default 0 check (current_streak >= 0),
  last_completed_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists habits_user_idx on public.habits (user_id);

drop trigger if exists habits_set_updated_at on public.habits;
create trigger habits_set_updated_at
  before update on public.habits
  for each row execute function public.set_updated_at();

create table if not exists public.habit_logs (
  habit_id uuid not null references public.habits (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  log_date date not null,
  completed_count int not null default 0 check (completed_count >= 0),
  updated_at timestamptz not null default now(),
  primary key (habit_id, log_date)
);
create index if not exists habit_logs_user_date_idx on public.habit_logs (user_id, log_date);

-- =============================================================================
-- CHALLENGES (7-day) + participants
-- =============================================================================
create table if not exists public.challenges (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  title text not null check (char_length(title) between 1 and 60),
  description text not null check (char_length(description) between 1 and 280),
  goal text not null check (char_length(goal) between 1 and 80),
  starts_on date not null,
  visibility text not null default 'public' check (visibility in ('public', 'private')),
  participant_count int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists challenges_visibility_idx on public.challenges (visibility, starts_on);

create table if not exists public.challenge_participants (
  challenge_id uuid not null references public.challenges (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  daily_progress real[] not null default '{0,0,0,0,0,0,0}',
  is_active boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key (challenge_id, user_id),
  check (array_length(daily_progress, 1) = 7)
);
create index if not exists challenge_participants_user_idx on public.challenge_participants (user_id);

-- Keep challenges.participant_count in sync with active participants.
create or replace function public.refresh_challenge_participant_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target uuid := coalesce(new.challenge_id, old.challenge_id);
begin
  update public.challenges c
  set participant_count = (
    select count(*) from public.challenge_participants p
    where p.challenge_id = target and p.is_active
  )
  where c.id = target;
  return null;
end;
$$;

drop trigger if exists challenge_participants_count on public.challenge_participants;
create trigger challenge_participants_count
  after insert or update or delete on public.challenge_participants
  for each row execute function public.refresh_challenge_participant_count();

-- =============================================================================
-- GROUPS + members
-- =============================================================================
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null check (char_length(name) between 3 and 40),
  description text not null check (char_length(description) between 8 and 240),
  visibility text not null default 'public' check (visibility in ('public', 'private')),
  invite_code text not null unique,
  invite_expires_on date not null default (current_date + 30),
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups (id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);
create index if not exists group_members_user_idx on public.group_members (user_id);

-- Security-definer helper so policies can check membership without recursion.
create or replace function public.is_group_member(p_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.group_members
    where group_id = p_group_id and user_id = auth.uid()
  );
$$;

-- =============================================================================
-- REWARDS (points ledger)
-- =============================================================================
create table if not exists public.reward_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  reward_key text not null,
  activity_name text not null,
  points int not null check (points between 1 and 100),
  type text not null check (type in ('habit', 'challenge')),
  earned_at timestamptz not null default now(),
  unique (user_id, reward_key)
);
create index if not exists reward_transactions_user_idx on public.reward_transactions (user_id, earned_at desc);

-- =============================================================================
-- APP USAGE (tracked apps, limits, daily usage)
-- =============================================================================
create table if not exists public.tracked_apps (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  app_name text not null check (char_length(app_name) between 1 and 60),
  daily_limit_minutes int not null default 60 check (daily_limit_minutes between 0 and 1440),
  is_tracked boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  primary key (user_id, app_name)
);

create table if not exists public.app_usage_daily (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  app_name text not null,
  usage_date date not null,
  usage_minutes int not null default 0 check (usage_minutes between 0 and 1440),
  primary key (user_id, app_name, usage_date)
);

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.profiles enable row level security;
alter table public.habits enable row level security;
alter table public.habit_logs enable row level security;
alter table public.challenges enable row level security;
alter table public.challenge_participants enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.reward_transactions enable row level security;
alter table public.tracked_apps enable row level security;
alter table public.app_usage_daily enable row level security;

-- Profiles: you can read and edit only your own row.
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles
  for select to authenticated using (id = auth.uid());
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles
  for insert to authenticated with check (id = auth.uid());

-- Owner-only tables (habits, logs, rewards, apps, usage).
do $$
declare
  t text;
begin
  foreach t in array array[
    'habits', 'habit_logs', 'reward_transactions', 'tracked_apps', 'app_usage_daily'
  ] loop
    execute format('drop policy if exists "%1$s_owner_all" on public.%1$I', t);
    execute format(
      'create policy "%1$s_owner_all" on public.%1$I for all to authenticated '
      'using (user_id = auth.uid()) with check (user_id = auth.uid())',
      t
    );
  end loop;
end;
$$;

-- Challenges: public ones are visible to everyone signed in; private ones only
-- to their creator and participants. Only the creator can edit or delete.
drop policy if exists "challenges_select" on public.challenges;
create policy "challenges_select" on public.challenges
  for select to authenticated using (
    visibility = 'public'
    or creator_id = auth.uid()
    or exists (
      select 1 from public.challenge_participants p
      where p.challenge_id = challenges.id and p.user_id = auth.uid()
    )
  );
drop policy if exists "challenges_insert" on public.challenges;
create policy "challenges_insert" on public.challenges
  for insert to authenticated with check (creator_id = auth.uid());
drop policy if exists "challenges_update" on public.challenges;
create policy "challenges_update" on public.challenges
  for update to authenticated using (creator_id = auth.uid()) with check (creator_id = auth.uid());
drop policy if exists "challenges_delete" on public.challenges;
create policy "challenges_delete" on public.challenges
  for delete to authenticated using (creator_id = auth.uid());

-- Challenge participation: you manage only your own row, and only for a
-- challenge you are allowed to see.
drop policy if exists "challenge_participants_select" on public.challenge_participants;
create policy "challenge_participants_select" on public.challenge_participants
  for select to authenticated using (user_id = auth.uid());
drop policy if exists "challenge_participants_insert" on public.challenge_participants;
create policy "challenge_participants_insert" on public.challenge_participants
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.challenges c
      where c.id = challenge_id
        and (c.visibility = 'public' or c.creator_id = auth.uid())
    )
  );
drop policy if exists "challenge_participants_update" on public.challenge_participants;
create policy "challenge_participants_update" on public.challenge_participants
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists "challenge_participants_delete" on public.challenge_participants;
create policy "challenge_participants_delete" on public.challenge_participants
  for delete to authenticated using (user_id = auth.uid());

-- Groups: members (and the creator) can see a group. Joining by invite code
-- goes through join_group_with_code() below.
drop policy if exists "groups_select" on public.groups;
create policy "groups_select" on public.groups
  for select to authenticated using (creator_id = auth.uid() or public.is_group_member(id));
drop policy if exists "groups_insert" on public.groups;
create policy "groups_insert" on public.groups
  for insert to authenticated with check (creator_id = auth.uid());
drop policy if exists "groups_update" on public.groups;
create policy "groups_update" on public.groups
  for update to authenticated using (creator_id = auth.uid()) with check (creator_id = auth.uid());
drop policy if exists "groups_delete" on public.groups;
create policy "groups_delete" on public.groups
  for delete to authenticated using (creator_id = auth.uid());

drop policy if exists "group_members_select" on public.group_members;
create policy "group_members_select" on public.group_members
  for select to authenticated using (public.is_group_member(group_id));
-- A creator adds themselves right after creating the group.
drop policy if exists "group_members_insert_creator" on public.group_members;
create policy "group_members_insert_creator" on public.group_members
  for insert to authenticated with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.groups g
      where g.id = group_id and g.creator_id = auth.uid()
    )
  );
drop policy if exists "group_members_delete_self" on public.group_members;
create policy "group_members_delete_self" on public.group_members
  for delete to authenticated using (user_id = auth.uid());

-- =============================================================================
-- RPC FUNCTIONS (called from the app)
-- =============================================================================

-- Join a group with an invite code.
-- Returns: joined | already_joined | invalid_code | expired_code
create or replace function public.join_group_with_code(p_code text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  g public.groups%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select * into g from public.groups
  where upper(invite_code) = upper(trim(p_code))
  limit 1;

  if not found then
    return 'invalid_code';
  end if;

  if exists (
    select 1 from public.group_members
    where group_id = g.id and user_id = auth.uid()
  ) then
    return 'already_joined';
  end if;

  if g.invite_expires_on < current_date then
    return 'expired_code';
  end if;

  insert into public.group_members (group_id, user_id) values (g.id, auth.uid());
  return 'joined';
end;
$$;

-- Members of every group the caller belongs to, with names and total points.
create or replace function public.get_my_group_members()
returns table (group_id uuid, user_id uuid, full_name text, points bigint)
language sql
stable
security definer
set search_path = public
as $$
  select
    gm.group_id,
    gm.user_id,
    coalesce(nullif(p.full_name, ''), 'Behtar member') as full_name,
    coalesce((
      select sum(r.points) from public.reward_transactions r
      where r.user_id = gm.user_id
    ), 0) as points
  from public.group_members gm
  left join public.profiles p on p.id = gm.user_id
  where gm.group_id in (
    select mine.group_id from public.group_members mine
    where mine.user_id = auth.uid()
  );
$$;

-- Permanently delete the signed-in user's account and all their data.
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.join_group_with_code(text) from public, anon;
revoke all on function public.get_my_group_members() from public, anon;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.join_group_with_code(text) to authenticated;
grant execute on function public.get_my_group_members() to authenticated;
grant execute on function public.delete_my_account() to authenticated;
