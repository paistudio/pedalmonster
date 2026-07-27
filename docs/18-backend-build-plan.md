# Backend Build Plan (Phase 2 — Ruby/Rails + Supabase Postgres)

## Goal
Stand up the Rails API described in `00-project-overview.md`/`02-data-model.md`, built and tested **independently of the frontend** (no frontend changes in this phase — see Phase Discipline in `CLAUDE.md`). Database is hosted on the project's Supabase instance, used as a plain managed Postgres — Rails/ActiveRecord owns the schema via its own migrations, not Supabase Studio's table editor.

## Architecture Decisions
These are the concrete choices this plan commits to. Flagged with rationale so they're easy to revisit if wrong.

- **Database:** Supabase Postgres, connected via a standard `DATABASE_URL` (Supabase's connection-pooling string, port 6543, for app traffic — use the direct 5432 string only for running migrations, per Supabase's pooler docs). Rails talks to it exactly like any other Postgres instance; no `supabase-rb` gem, no PostgREST layer in between. The frontend never talks to Supabase directly — all reads/writes go through the Rails API, per `00-project-overview.md`'s REST contract.
- **Auth:** Rails-owned, not Supabase Auth. `users` table lives in our own schema with a `password_digest` (bcrypt via `has_secure_password`) and Rails issues its own JWTs. This matches `03-auth-user-profile.md`'s "JWT recommended for clean separation between Vue frontend and Rails API" — Supabase's `auth.users` is not used, avoiding a split-brain user model between two systems.
- **File storage (photos):** Active Storage with an S3-compatible service pointed at **Supabase Storage** (Supabase Storage exposes an S3-compatible API). This reuses Supabase for both concerns the frontend already assumed it would (per `00-project-overview.md`'s "Supabase-adjacent stack if preferred later") without introducing a third vendor. `media_urls` on `Post`/`ChatMessage` store the public Supabase Storage URLs Active Storage generates.
- **`type_data` (polymorphic post fields):** stored as a `jsonb` column on `posts` rather than separate tables per type — matches how `02-data-model.md` already documents it (`type_data: object, polymorphic`) and avoids a join per post type for what's a handful of small, non-relational fields (`category`/`condition`/`price`/`status` for listings, `group_id` for group posts).
- **IDs:** UUID primary keys throughout (matches `02-data-model.md`'s `id: uuid` on every entity) — enable `pgcrypto`'s `gen_random_uuid()` in the initial migration.

## Environment & Config
- `DATABASE_URL` — Supabase pooled connection string (app runtime)
- `DATABASE_URL_MIGRATE` — Supabase direct connection string (used only for `db:migrate`, since long-lived pooled connections aren't ideal for DDL)
- `JWT_SECRET` — Rails-generated, separate from Supabase's own keys
- `SUPABASE_STORAGE_ENDPOINT`, `SUPABASE_STORAGE_BUCKET`, `SUPABASE_STORAGE_ACCESS_KEY_ID`, `SUPABASE_STORAGE_SECRET_ACCESS_KEY` — Active Storage's S3 service block
- `CORS_ORIGINS` — the Vue dev server origin (and later, the deployed frontend origin) for `rack-cors`
- All secrets via `.env`/Rails credentials, never committed — `.env` stays gitignored same as any other Rails app

## Gems
- `pg` — Postgres adapter
- `bcrypt` — `has_secure_password` for User
- `jwt` — token issuing/verification
- `rack-cors` — allow the Vue frontend origin
- `aws-sdk-s3` — Active Storage's S3-compatible service driver (works against Supabase Storage's S3 endpoint)
- `rspec-rails`, `factory_bot_rails`, `faker` — test suite + seed/fixture data matching the mock shapes already in `frontend/src/mocks`

## Migration Order
Mirrors `02-data-model.md` entity-by-entity, respecting FK dependencies:
1. `cities` (no dependencies — reference table, seed from `frontend/src/mocks/cities.js`)
2. `users` (FK → cities)
3. `posts` (FK → users, self-referential FK → posts for `parent_id`; `type_data` jsonb; `tags` as a Postgres `text[]` array column)
4. `post_likes` (FK → posts, users; unique index on `[post_id, user_id]`)
5. `groups` (FK → users for `created_by`, → cities; `blocked_user_ids` as `uuid[]`)
6. `group_memberships` (FK → groups, users; unique index on `[group_id, user_id]`)
7. `reports` (FK → users, posts nullable)
8. `tag_follows` (FK → users; `tag_name` string, no hard FK to a `tags` table per `02-data-model.md`'s note — a `Tag` row is implicit)
9. `notifications` (FK → users, posts nullable, groups nullable)
10. `chat_threads` (FK → users x2; unique index on the unordered pair — enforce via a `CHECK (user_one_id < user_two_id)` + unique index so the pair can't be inserted in either order twice)
11. `chat_thread_reads` (FK → chat_threads, users; unique index on `[chat_thread_id, user_id]`)
12. `chat_messages` (FK → chat_threads, users, posts nullable for `listing_id`; `media_urls` as `text[]`)

`comment_count` and `like_count` on `posts`: computed via DB triggers or `counter_cache` updated on create/destroy of the dependent row, not recalculated per-request — matches the "derived" note in `02-data-model.md` while keeping read endpoints cheap.

## API Surface
Build controllers/routes matching the endpoint list at the bottom of `02-data-model.md` 1:1 — that list is the contract, this plan doesn't repeat it. Group into these controllers:
- `Api::SessionsController` / `Api::RegistrationsController` — auth
- `Api::PostsController` — feed, CRUD, comments (nested under `/posts/:id/comments`), likes
- `Api::ListingsController` — filtered browse (`GET /api/listings`)
- `Api::GroupsController`, `Api::GroupMembershipsController`
- `Api::UsersController` — profile, account settings, liked posts, followed tags
- `Api::CitiesController` — read-only reference list
- `Api::ReportsController`
- `Api::TagsController`, `Api::TagFollowsController`
- `Api::NotificationsController`
- `Api::ChatsController`, nested `messages` — matches `/chat/:userId` keying in the frontend, i.e. look up/create the thread by participant pair rather than by thread id

## Points/Rank Logic
Server-side, triggered on the actions listed in `02-data-model.md`'s Activity Points table (`AfterCreate`-style callbacks or a small `PointsService` called from each controller action) — never trust a client-supplied points delta. Rank is a computed method on `User` (points → tier lookup), not a stored column, matching the "derived" note in `03-auth-user-profile.md`.

## Testing
RSpec request specs per controller, covering: happy path, owner-only edit/delete authorization (posts, comments, groups), the comment-cascade-delete behavior, like idempotency (can't double-like), and JWT auth rejection on protected routes. Run against a local/test Postgres, not the Supabase dev database — a `DATABASE_URL_TEST` env var pointing at a disposable local Postgres (or Supabase branching, if we want to use the `branching` feature already enabled on the connected MCP server, for a throwaway test branch per CI run).

## Build Order (feed this plan through in this sequence)
1. Rails new (`--api`), gems, `.env`/credentials wiring, CORS config, connect to Supabase (`rails db:migrate` against `DATABASE_URL_MIGRATE`, confirm connection)
2. `cities` + `users` models/migrations, seed cities, auth (register/login/JWT), request specs
3. `posts` model/migration (incl. `type_data`, `tags`, self-referential comments), feed/CRUD/comment endpoints, request specs
4. `post_likes`, like/unlike endpoints + derived `like_count`, request specs
5. `groups` + `group_memberships`, group CRUD/join/block endpoints, request specs
6. `reports`, report submission endpoint, request specs
7. `tag_follows`, tag detail/follow endpoints, request specs
8. `notifications`, list/mark-read endpoints, request specs
9. `chat_threads` + `chat_thread_reads` + `chat_messages`, thread list/messages/read endpoints (incl. photo attachments via Active Storage), request specs
10. Active Storage + Supabase Storage wiring for all photo upload paths (post/comment/chat media, avatar) — do this after the models exist so it's one pass across every `media_urls`/`avatar_url` field rather than piecemeal
11. Full RSpec suite green + manual Postman/curl pass across every endpoint in `02-data-model.md`

**Checkpoint (per `11-build-sequence.md`):** all API endpoints tested and working in isolation before Phase 3 touches the frontend.

## Explicitly Not Doing Yet
- No Supabase Auth, Realtime, or Edge Functions — Postgres + Storage only, per the Architecture Decisions above
- No background job runner (Sidekiq/etc.) — nothing in the current feature set needs async processing yet; add only if a real need shows up (e.g. push notifications in a later phase)
- No API versioning scheme beyond `/api/*` — add `/api/v1/*` if/when a breaking change is needed post-launch, not preemptively
