-- Activity Points system (docs/02-data-model.md's Activity Points table) — missed in the
-- initial Supabase-only migration pass; caught while wiring the frontend. Two parts:
--
-- 1. A guard trigger so `points` can never be changed by a direct client update — the
--    existing `profiles` RLS update policy only checks `auth.uid() = id`, which means
--    without this guard a user could set their own points to anything via a plain
--    supabase-js `.update({ points: 999999 })` call. `pg_trigger_depth() = 1` distinguishes
--    a top-level client-initiated UPDATE from one cascading out of award_points() below
--    (which runs at trigger depth 2+), so only the latter can actually change the value.
create or replace function protect_points_column()
returns trigger
language plpgsql
as $$
begin
  if pg_trigger_depth() = 1 then
    new.points := old.points;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_protect_points on profiles;
create trigger profiles_protect_points
  before update on profiles
  for each row execute function protect_points_column();

-- 2. award_points() plus one trigger per qualifying action, matching
--    docs/02-data-model.md's table exactly: listing/community_post +2, comment +3,
--    comment receives a like +1 (to the comment's author), join or create a group +1
--    (creating auto-joins via groups_auto_join_owner below, so this single trigger covers
--    both cases without double-counting).
create or replace function award_points(p_user_id uuid, p_amount integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update profiles set points = points + p_amount where id = p_user_id;
end;
$$;

create or replace function award_points_on_post()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.type in ('listing', 'community_post') then
    perform award_points(new.user_id, 2);
  elsif new.type = 'comment' then
    perform award_points(new.user_id, 3);
  end if;
  return new;
end;
$$;

drop trigger if exists posts_award_points on posts;
create trigger posts_award_points
  after insert on posts
  for each row execute function award_points_on_post();

create or replace function award_points_on_like()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  liked_row posts%rowtype;
begin
  select * into liked_row from posts where id = new.post_id;
  if liked_row.type = 'comment' then
    perform award_points(liked_row.user_id, 1);
  end if;
  return new;
end;
$$;

drop trigger if exists post_likes_award_points on post_likes;
create trigger post_likes_award_points
  after insert on post_likes
  for each row execute function award_points_on_like();

create or replace function award_points_on_group_join()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform award_points(new.user_id, 1);
  return new;
end;
$$;

drop trigger if exists group_memberships_award_points on group_memberships;
create trigger group_memberships_award_points
  after insert on group_memberships
  for each row execute function award_points_on_group_join();

-- A group's creator wasn't otherwise auto-joined as a member anywhere in the Supabase-only
-- design (the original Rails plan did this in the controller) — without this, a new group
-- starts at member_count 0 with its own owner not a member, and the owner never gets the
-- join/create point either. This also means the points trigger above fires for group
-- creation "for free" via the resulting group_memberships insert.
create or replace function auto_join_own_group()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into group_memberships (group_id, user_id) values (new.id, new.created_by)
  on conflict do nothing;
  return new;
end;
$$;

drop trigger if exists groups_auto_join_owner on groups;
create trigger groups_auto_join_owner
  after insert on groups
  for each row execute function auto_join_own_group();
