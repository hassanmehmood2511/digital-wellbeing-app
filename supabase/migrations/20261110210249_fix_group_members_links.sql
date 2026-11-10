-- group_members was kept from the earlier setup but still pointed to the
-- renamed groups_legacy / profiles_legacy tables, so adding members failed.
alter table public.group_members drop constraint if exists group_members_group_id_fkey;
alter table public.group_members drop constraint if exists group_members_user_id_fkey;
alter table public.group_members
  add constraint group_members_group_id_fkey
    foreign key (group_id) references public.groups (id) on delete cascade,
  add constraint group_members_user_id_fkey
    foreign key (user_id) references auth.users (id) on delete cascade;
alter table public.group_members alter column user_id set default auth.uid();

-- Old policies from the earlier setup: they let anyone see every membership
-- and join any group without an invite code. The Behtar policies replace them.
drop policy if exists "Join groups" on public.group_members;
drop policy if exists "Leave groups" on public.group_members;
drop policy if exists "View group members" on public.group_members;

-- Repair groups created while this was broken: add each creator as a member.
insert into public.group_members (group_id, user_id)
select g.id, g.creator_id from public.groups g
where not exists (
  select 1 from public.group_members m
  where m.group_id = g.id and m.user_id = g.creator_id
);
