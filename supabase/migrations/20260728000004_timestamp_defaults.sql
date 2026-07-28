-- Every created_at/updated_at/joined_at column was originally populated by ActiveRecord at
-- the application layer, not a DB default — Rails always set these on insert. Now that there's
-- no application layer, every one of these NOT NULL columns needs a DB-level default, or every
-- insert (from handle_new_user, an Edge Function, or a direct supabase-js call) fails outright.
-- Caught by hand-testing the RLS policies/triggers in this same pass — see
-- docs/19-supabase-only-backend-plan.md's Testing section.

alter table profiles alter column created_at set default now();
alter table profiles alter column updated_at set default now();

alter table posts alter column created_at set default now();
alter table posts alter column updated_at set default now();

alter table post_likes alter column created_at set default now();

alter table groups alter column created_at set default now();
alter table groups alter column updated_at set default now();

alter table group_memberships alter column joined_at set default now();

alter table reports alter column created_at set default now();

alter table tag_follows alter column created_at set default now();

alter table notifications alter column created_at set default now();

alter table chat_threads alter column created_at set default now();

alter table chat_messages alter column created_at set default now();

-- updated_at columns also need to keep advancing on every UPDATE, which a default alone
-- doesn't do (a default only fires on INSERT) — Rails' `t.timestamps` used to touch this on
-- every save too.
create or replace function set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on profiles;
create trigger profiles_set_updated_at
  before update on profiles
  for each row execute function set_updated_at();

drop trigger if exists posts_set_updated_at on posts;
create trigger posts_set_updated_at
  before update on posts
  for each row execute function set_updated_at();

drop trigger if exists groups_set_updated_at on groups;
create trigger groups_set_updated_at
  before update on groups
  for each row execute function set_updated_at();
