-- Fills the gap flagged in docs/19-supabase-only-backend-plan.md's "Known Gap — Notifications
-- Are Never Created Server-Side": neither the superseded Rails plan nor the initial
-- Supabase-only pass ever added triggers to actually insert Notification rows, so the
-- inbox's Notifications tab was wired but permanently empty. Covers the three events
-- docs/02-data-model.md calls out (comment replies, likes, group joins) — @mention
-- notifications remain separately flagged as not wired up. All SECURITY DEFINER, same
-- reasoning as every other cross-user trigger in this file: the commenter/liker/joiner's own
-- RLS rights don't extend to inserting a row owned by (`user_id =`) a different user.

-- Notifies a post's owner when someone else comments on it. post_id always points at the
-- top-level post (not the comment row itself) — comments are excluded from feedStore.posts
-- client-side (`type != comment`), so App.vue's openNotification() can only resolve/route
-- using a top-level post id.
create or replace function notify_on_comment()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  parent_post posts%rowtype;
  commenter_username text;
begin
  if new.type != 'comment' or new.parent_id is null then
    return new;
  end if;

  select * into parent_post from posts where id = new.parent_id;
  if parent_post.id is null or parent_post.user_id = new.user_id then
    return new;
  end if;

  select username into commenter_username from profiles where id = new.user_id;

  insert into notifications (user_id, title, body, post_id)
  values (
    parent_post.user_id,
    'New comment on your post',
    coalesce(commenter_username, 'Someone') || ': ' || left(coalesce(new.description, ''), 80),
    parent_post.id
  );
  return new;
end;
$$;

drop trigger if exists posts_notify_on_comment on posts;
create trigger posts_notify_on_comment
  after insert on posts
  for each row execute function notify_on_comment();

-- Notifies the owner of a liked post OR comment. Same "resolve to the top-level post id"
-- reasoning as notify_on_comment above — a like on a comment still needs post_id to point at
-- the comment's parent post so the notification is clickable.
create or replace function notify_on_like()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  liked_row posts%rowtype;
  liker_username text;
  target_post_id uuid;
begin
  select * into liked_row from posts where id = new.post_id;
  if liked_row.id is null or liked_row.user_id = new.user_id then
    return new;
  end if;

  select username into liker_username from profiles where id = new.user_id;
  target_post_id := case when liked_row.type = 'comment' then liked_row.parent_id else liked_row.id end;

  insert into notifications (user_id, title, body, post_id)
  values (
    liked_row.user_id,
    case when liked_row.type = 'comment' then 'New like on your comment' else 'New like on your post' end,
    coalesce(liker_username, 'Someone') || ' liked your ' ||
      case when liked_row.type = 'comment' then 'comment' else 'post' end,
    target_post_id
  );
  return new;
end;
$$;

drop trigger if exists post_likes_notify_on_like on post_likes;
create trigger post_likes_notify_on_like
  after insert on post_likes
  for each row execute function notify_on_like();

-- Notifies a group's owner when someone joins. Skips the creator's own auto-join
-- (groups_auto_join_owner in 20260728000005_activity_points.sql) so creating a group doesn't
-- notify yourself.
create or replace function notify_on_group_join()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  target_group groups%rowtype;
  joiner_username text;
begin
  select * into target_group from groups where id = new.group_id;
  if target_group.id is null or target_group.created_by = new.user_id then
    return new;
  end if;

  select username into joiner_username from profiles where id = new.user_id;

  insert into notifications (user_id, title, body, group_id)
  values (
    target_group.created_by,
    'New member joined your group',
    coalesce(joiner_username, 'Someone') || ' joined ' || target_group.name,
    target_group.id
  );
  return new;
end;
$$;

drop trigger if exists group_memberships_notify_on_join on group_memberships;
create trigger group_memberships_notify_on_join
  after insert on group_memberships
  for each row execute function notify_on_group_join();
