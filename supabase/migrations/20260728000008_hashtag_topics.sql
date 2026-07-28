-- Closes the actual gap behind "every hashtag should be treated as a topic": PostCard.vue
-- already renders `post.tags` as clickable chips routing to Topic Detail
-- (docs/13-tags-and-topic-discovery.md), and TopicDetailView already supports follow/unfollow
-- with a real follower count — but nothing ever populated `posts.tags` for a real,
-- user-created post (every Create*View.vue form sends `tags: []`), so the whole feature was
-- silently dead for anything but seeded data. Fixed the same way `extract_mentions()` already
-- handles `@handle` tokens: extract `#word` tokens from the post's own text into `tags`.

-- BEFORE trigger so notify_followers_on_new_tagged_post() below (an AFTER trigger) sees the
-- final tags array. Scoped to type != 'comment' — hashtags are a top-level-post discovery
-- feature per 13-tags-and-topic-discovery.md, not a comment feature (comments already have
-- their own @mention extraction via extract_mentions()).
create or replace function extract_post_tags()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  hashtags text[];
begin
  if new.type = 'comment' then
    return new;
  end if;

  select coalesce(array_agg(distinct m[1]), '{}')
  into hashtags
  from regexp_matches(coalesce(new.description, ''), '#([a-zA-Z0-9_]+)', 'g') as m;

  select coalesce(array_agg(distinct t), '{}')
  into new.tags
  from unnest(coalesce(new.tags, '{}') || hashtags) as t;

  return new;
end;
$$;

drop trigger if exists posts_extract_tags on posts;
create trigger posts_extract_tags
  before insert or update on posts
  for each row execute function extract_post_tags();

-- Notifies everyone following a tag when a new post uses it (the "when follow, all new posts
-- with this hashtag will send notification" ask). One row per (follower, matched tag) — a post
-- matching two topics you follow sends two notifications, which is the simplest correct
-- behavior without inventing a "pick one" rule not specified anywhere.
create or replace function notify_followers_on_new_tagged_post()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  author_username text;
begin
  if new.type = 'comment' or new.tags is null or array_length(new.tags, 1) is null then
    return new;
  end if;

  select username into author_username from profiles where id = new.user_id;

  insert into notifications (user_id, title, body, post_id)
  select distinct tf.user_id,
    'New post in #' || tf.tag_name,
    coalesce(author_username, 'Someone') || ' posted in a topic you follow',
    new.id
  from tag_follows tf
  where tf.user_id != new.user_id
    and lower(tf.tag_name) in (select lower(t) from unnest(new.tags) as t);

  return new;
end;
$$;

drop trigger if exists posts_notify_tag_followers on posts;
create trigger posts_notify_tag_followers
  after insert on posts
  for each row execute function notify_followers_on_new_tagged_post();
