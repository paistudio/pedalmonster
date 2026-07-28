-- Derived-field maintenance and cross-table logic that used to live in Rails model
-- callbacks/associations — see docs/19-supabase-only-backend-plan.md's "Postgres Functions &
-- Triggers". All SECURITY DEFINER where they need to write across RLS boundaries (e.g. bumping
-- another user's post's counter) since the calling user only has RLS rights over their own rows.

-- Creates the matching profiles row on sign-up. Standard Supabase pattern — see
-- docs/03-auth-user-profile.md. username is a NOT NULL, unique column, so this needs *some*
-- value immediately; deriving it from the email's local part risks a unique-constraint
-- collision on signup (two different people can share an email prefix), which would fail the
-- whole auth.users insert since this trigger runs in the same transaction. A UUID-derived
-- placeholder is guaranteed unique; docs/03-auth-user-profile.md's "Basic profile setup on
-- first login" is exactly where the user overwrites this with their real chosen username.
create or replace function handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, 'rider_' || substr(new.id::text, 1, 8));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- comment_count on the parent post — same idea as Rails' counter_cache on the parent
-- association.
create or replace function bump_comment_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT' and new.type = 'comment') then
    update posts set comment_count = comment_count + 1 where id = new.parent_id;
  elsif (tg_op = 'DELETE' and old.type = 'comment') then
    update posts set comment_count = greatest(comment_count - 1, 0) where id = old.parent_id;
  end if;
  return null;
end;
$$;

drop trigger if exists posts_bump_comment_count on posts;
create trigger posts_bump_comment_count
  after insert or delete on posts
  for each row execute function bump_comment_count();

-- like_count on the liked post/comment row.
create or replace function bump_like_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT') then
    update posts set like_count = like_count + 1 where id = new.post_id;
  elsif (tg_op = 'DELETE') then
    update posts set like_count = greatest(like_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end;
$$;

drop trigger if exists post_likes_bump_like_count on post_likes;
create trigger post_likes_bump_like_count
  after insert or delete on post_likes
  for each row execute function bump_like_count();

-- member_count on the group.
create or replace function bump_member_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if (tg_op = 'INSERT') then
    update groups set member_count = member_count + 1 where id = new.group_id;
  elsif (tg_op = 'DELETE') then
    update groups set member_count = greatest(member_count - 1, 0) where id = old.group_id;
  end if;
  return null;
end;
$$;

drop trigger if exists group_memberships_bump_member_count on group_memberships;
create trigger group_memberships_bump_member_count
  after insert or delete on group_memberships
  for each row execute function bump_member_count();

-- @mention extraction on comments — only usernames matching a real account count, per
-- docs/02-data-model.md. Recomputed on every save (insert or update), same as the Rails
-- model callback did, so editing a comment keeps mentions in sync.
create or replace function extract_mentions()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  handles text[];
begin
  if new.type != 'comment' then
    return new;
  end if;

  select coalesce(array_agg(distinct lower(m[1])), '{}')
  into handles
  from regexp_matches(coalesce(new.description, ''), '@([a-zA-Z0-9._]+)', 'g') as m;

  select coalesce(array_agg(id), '{}')
  into new.mentioned_user_ids
  from profiles
  where lower(username) = any(handles);

  return new;
end;
$$;

drop trigger if exists posts_extract_mentions on posts;
create trigger posts_extract_mentions
  before insert or update on posts
  for each row execute function extract_mentions();

-- Deletes a group's group_post rows when the group itself is deleted. group_id lives inside
-- Post#type_data (jsonb), not a real FK column, so this can't be a normal ON DELETE CASCADE —
-- same manual-cascade reasoning as the Rails Group model, see docs/10-groups.md's Delete Group.
create or replace function cascade_group_post_delete()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from posts where type = 'group_post' and type_data ->> 'group_id' = old.id::text;
  return old;
end;
$$;

drop trigger if exists groups_cascade_post_delete on groups;
create trigger groups_cascade_post_delete
  before delete on groups
  for each row execute function cascade_group_post_delete();
