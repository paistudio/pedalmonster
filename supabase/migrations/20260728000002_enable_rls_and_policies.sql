-- Row Level Security policies replacing what Rails controllers used to enforce in application
-- code — see docs/19-supabase-only-backend-plan.md's "Row Level Security — Policy Design Per
-- Table" for the rationale behind each one.

-- cities: read-only reference data, no client writes
alter table cities enable row level security;
create policy "cities are publicly readable" on cities for select using (true);

-- profiles: public read, self-only update. No insert/delete policy — rows are created only by
-- the handle_new_user trigger (SECURITY DEFINER, bypasses RLS), never directly by a client.
alter table profiles enable row level security;
create policy "profiles are publicly readable" on profiles for select using (true);
create policy "users can update their own profile" on profiles for update
  using (auth.uid() = id) with check (auth.uid() = id);

-- posts: public read (comments included — client filters type != 'comment' for feed views),
-- owner-only write. A comment is just a post row, so this same policy set covers both.
alter table posts enable row level security;
create policy "posts are publicly readable" on posts for select using (true);
create policy "users can create their own posts" on posts for insert
  with check (auth.uid() = user_id);
create policy "users can update their own posts" on posts for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users can delete their own posts" on posts for delete
  using (auth.uid() = user_id);

-- post_likes: public read, self-only like/unlike. Unique constraint on (post_id, user_id)
-- (already in place from the original migration) prevents double-liking.
alter table post_likes enable row level security;
create policy "post_likes are publicly readable" on post_likes for select using (true);
create policy "users can like as themselves" on post_likes for insert
  with check (auth.uid() = user_id);
create policy "users can unlike their own like" on post_likes for delete
  using (auth.uid() = user_id);

-- groups: public read, any authenticated user can create (becoming owner), owner-only edit/delete.
alter table groups enable row level security;
create policy "groups are publicly readable" on groups for select using (true);
create policy "users can create groups they own" on groups for insert
  with check (auth.uid() = created_by);
create policy "owners can update their group" on groups for update
  using (auth.uid() = created_by) with check (auth.uid() = created_by);
create policy "owners can delete their group" on groups for delete
  using (auth.uid() = created_by);

-- group_memberships: public read; join is self-only AND blocked from rejoining once blocked
-- (docs/10-groups.md's "join silently no-ops for a blocked user" — the actual no-op UX still
-- needs the group-join Edge Function, this policy is the hard backstop); leave is self-only,
-- or the group owner removing a member (block).
alter table group_memberships enable row level security;
create policy "group_memberships are publicly readable" on group_memberships for select using (true);
create policy "users can join groups unless blocked" on group_memberships for insert
  with check (
    auth.uid() = user_id
    and not exists (
      select 1 from groups g
      where g.id = group_id and auth.uid() = any (g.blocked_user_ids)
    )
  );
create policy "members can leave, owners can remove members" on group_memberships for delete
  using (
    auth.uid() = user_id
    or auth.uid() = (select created_by from groups where id = group_id)
  );

-- reports: write-only from the client — no select policy, reviewing reports is an
-- admin/dashboard concern outside this app.
alter table reports enable row level security;
create policy "users can submit reports as themselves" on reports for insert
  with check (auth.uid() = user_id);

-- tag_follows: fully self-scoped.
alter table tag_follows enable row level security;
create policy "users can read their own tag follows" on tag_follows for select
  using (auth.uid() = user_id);
create policy "users can follow tags as themselves" on tag_follows for insert
  with check (auth.uid() = user_id);
create policy "users can unfollow their own tag follow" on tag_follows for delete
  using (auth.uid() = user_id);

-- Follower counts (docs/02-data-model.md: "count(TagFollow where tag_name = :tag)") need to be
-- readable across users even though individual follow rows are self-scoped above — a SECURITY
-- DEFINER function bypasses RLS for this one aggregate read without exposing whose follow it is.
create or replace function tag_follower_count(p_tag_name text)
returns bigint
language sql
security definer
set search_path = public
as $$
  select count(*) from tag_follows where tag_name = p_tag_name;
$$;

-- notifications: fully self-scoped read + mark-read; no insert policy — only triggers/Edge
-- Functions (SECURITY DEFINER) create these, never the client directly.
alter table notifications enable row level security;
create policy "users can read their own notifications" on notifications for select
  using (auth.uid() = user_id);
create policy "users can mark their own notifications read" on notifications for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- chat_threads / chat_thread_reads / chat_messages: participant-only on all sides. The
-- chat-send-message Edge Function is the primary write path (it runs the find-or-create
-- canonical-pair logic), but these policies are the backstop / allow direct reads.
alter table chat_threads enable row level security;
create policy "participants can read their threads" on chat_threads for select
  using (auth.uid() in (user_one_id, user_two_id));
create policy "participants can create their threads" on chat_threads for insert
  with check (auth.uid() in (user_one_id, user_two_id));

alter table chat_thread_reads enable row level security;
create policy "users can read their own read-state" on chat_thread_reads for select
  using (auth.uid() = user_id);
create policy "users can upsert their own read-state" on chat_thread_reads for insert
  with check (auth.uid() = user_id);
create policy "users can update their own read-state" on chat_thread_reads for update
  using (auth.uid() = user_id) with check (auth.uid() = user_id);

alter table chat_messages enable row level security;
create policy "participants can read their thread's messages" on chat_messages for select
  using (
    exists (
      select 1 from chat_threads t
      where t.id = chat_thread_id and auth.uid() in (t.user_one_id, t.user_two_id)
    )
  );
create policy "participants can send messages as themselves" on chat_messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from chat_threads t
      where t.id = chat_thread_id and auth.uid() in (t.user_one_id, t.user_two_id)
    )
  );
