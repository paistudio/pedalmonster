# Backend Build Plan (Phase 2 — Ruby/Rails + Supabase Postgres)

## Goal
Stand up the Rails API described in `00-project-overview.md`/`02-data-model.md`, built and tested **independently of the frontend** (no frontend changes in this phase — see Phase Discipline in `CLAUDE.md`). Database is hosted on the project's Supabase instance, used as a plain managed Postgres — Rails/ActiveRecord owns the schema via its own migrations, not Supabase Studio's table editor.

## Architecture Decisions
These are the concrete choices this plan commits to. Flagged with rationale so they're easy to revisit if wrong.

- **Database:** Supabase Postgres, connected via a standard `DATABASE_URL` (Supabase's connection-pooling string, port 6543, for app traffic — use the direct 5432 string only for running migrations, per Supabase's pooler docs). Rails talks to it exactly like any other Postgres instance; no `supabase-rb` gem, no PostgREST layer in between. **Exception: auth** (see below) — everything else (feed, posts, groups, chat, etc.) is Rails-API-only, the frontend never queries Supabase directly for data.
- **Auth: Supabase Auth**, not Rails-owned. Registration, login, session/refresh-token handling, and password reset are handled by Supabase Auth's own client SDK (`@supabase/supabase-js`) directly from the Vue frontend in Phase 3 — this is the one deliberate exception to "frontend never talks to Supabase directly," because Supabase Auth already solves session refresh, password reset emails, and secure credential storage, and reimplementing that in Rails would just be worse and duplicate work. Rails' job is narrower: **verify the Supabase-issued JWT** on every protected request (signature check against the Supabase project's JWT secret/JWKS, per its configured signing algorithm — confirm HS256-shared-secret vs the newer JWKS-based signing keys in Supabase project settings during implementation) and resolve `payload["sub"]` (the Supabase `auth.users.id`) to our own profile row. Rails never sees or stores a password.
  - `auth.users` is a Supabase-managed table Rails does not create, migrate, or own — our own schema has a `profiles` table with `id` as a FK to `auth.users.id` (not our own generated UUID) holding the app-specific fields (`username`, `avatar_url`, `bio`, `location`, `location_city_id`, `points`, `rank`... i.e. everything `02-data-model.md`'s `User` entity has beyond auth credentials).
  - A `profiles` row is created on first sign-up via a Postgres trigger on `auth.users` insert (the standard Supabase pattern: a `handle_new_user()` function + `AFTER INSERT` trigger) — this is one-time SQL set up directly in Supabase (via the SQL editor or the connected Supabase MCP server), not a Rails migration, since it has to fire on inserts into a table Rails doesn't own.
  - **Email changes** go through Supabase Auth (it owns the credential + triggers its own confirmation email) — Rails' `PATCH /api/users/:id` only ever touches profile fields (username, bio, location), never `email`.
- **File storage (photos):** Active Storage with an S3-compatible service pointed at **Supabase Storage** (Supabase Storage exposes an S3-compatible API). This reuses Supabase for both concerns the frontend already assumed it would (per `00-project-overview.md`'s "Supabase-adjacent stack if preferred later") without introducing a third vendor. `media_urls` on `Post`/`ChatMessage` store the public Supabase Storage URLs Active Storage generates.
- **`type_data` (polymorphic post fields):** stored as a `jsonb` column on `posts` rather than separate tables per type — matches how `02-data-model.md` already documents it (`type_data: object, polymorphic`) and avoids a join per post type for what's a handful of small, non-relational fields (`category`/`condition`/`price`/`status` for listings, `group_id` for group posts).
- **IDs:** UUID primary keys throughout (matches `02-data-model.md`'s `id: uuid` on every entity) — enable `pgcrypto`'s `gen_random_uuid()` in the initial migration.

## Environment & Config
- `DATABASE_URL` — Supabase pooled connection string (app runtime)
- `DATABASE_URL_MIGRATE` — Supabase direct connection string (used only for `db:migrate`, since long-lived pooled connections aren't ideal for DDL)
- `SUPABASE_JWT_SECRET` (or `SUPABASE_JWKS_URL`, depending on which signing scheme the project uses) — for verifying incoming Supabase Auth tokens; **not** used to issue tokens, Rails never mints its own
- `SUPABASE_STORAGE_ENDPOINT`, `SUPABASE_STORAGE_BUCKET`, `SUPABASE_STORAGE_ACCESS_KEY_ID`, `SUPABASE_STORAGE_SECRET_ACCESS_KEY` — Active Storage's S3 service block
- `CORS_ORIGINS` — the Vue dev server origin (and later, the deployed frontend origin) for `rack-cors`
- All secrets via `.env`/Rails credentials, never committed — `.env` stays gitignored same as any other Rails app

## Gems
- `pg` — Postgres adapter
- `jwt` — verifying Supabase-issued tokens (decode + signature check only, Rails never issues its own)
- `rack-cors` — allow the Vue frontend origin
- `aws-sdk-s3` — Active Storage's S3-compatible service driver (works against Supabase Storage's S3 endpoint)
- `rspec-rails`, `factory_bot_rails`, `faker` — test suite + seed/fixture data matching the mock shapes already in `frontend/src/mocks`

## Migration Order
Mirrors `02-data-model.md` entity-by-entity, respecting FK dependencies:
0. **(One-time, in Supabase directly, not a Rails migration)** the `handle_new_user()` trigger function on `auth.users` that inserts a matching `profiles` row on sign-up
1. `cities` (no dependencies — reference table, seed from `frontend/src/mocks/cities.js`)
2. `profiles` (id is a FK to `auth.users.id`, not a Rails-generated UUID; FK → cities for `location_city_id`) — this is the `User` entity from `02-data-model.md` minus auth credentials
3. `posts` (FK → profiles, self-referential FK → posts for `parent_id`; `type_data` jsonb; `tags` as a Postgres `text[]` array column)
4. `post_likes` (FK → posts, profiles; unique index on `[post_id, profile_id]`)
5. `groups` (FK → profiles for `created_by`, → cities; `blocked_user_ids` as `uuid[]`)
6. `group_memberships` (FK → groups, profiles; unique index on `[group_id, profile_id]`)
7. `reports` (FK → profiles, posts nullable)
8. `tag_follows` (FK → profiles; `tag_name` string, no hard FK to a `tags` table per `02-data-model.md`'s note — a `Tag` row is implicit)
9. `notifications` (FK → profiles, posts nullable, groups nullable)
10. `chat_threads` (FK → profiles x2; unique index on the unordered pair — enforce via a `CHECK (user_one_id < user_two_id)` + unique index so the pair can't be inserted in either order twice)
11. `chat_thread_reads` (FK → chat_threads, profiles; unique index on `[chat_thread_id, profile_id]`)
12. `chat_messages` (FK → chat_threads, profiles, posts nullable for `listing_id`; `media_urls` as `text[]`)

`comment_count` and `like_count` on `posts`: computed via DB triggers or `counter_cache` updated on create/destroy of the dependent row, not recalculated per-request — matches the "derived" note in `02-data-model.md` while keeping read endpoints cheap.

## API Surface
Build controllers/routes matching the endpoint list at the bottom of `02-data-model.md` 1:1 — that list is the contract, this plan doesn't repeat it. No `SessionsController`/`RegistrationsController` — there's no Rails-side register/login/password endpoint, Supabase Auth's client SDK handles all of that directly from the frontend (see Architecture Decisions). Instead, every protected route runs through a shared `Authenticatable` concern/`before_action` that verifies the Supabase JWT and loads `current_profile`. Group the rest into these controllers:
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
RSpec request specs per controller, covering: happy path, owner-only edit/delete authorization (posts, comments, groups), the comment-cascade-delete behavior, like idempotency (can't double-like), and JWT auth rejection on protected routes. Since Rails no longer issues tokens itself, specs need a way to produce a valid Supabase-signed JWT for a test user — either mint one locally signed with the same test-env secret (fastest, no network calls), or create a real throwaway user via Supabase Auth's Admin API in a `before(:each)` (slower, but exercises the real verification path end-to-end at least once). Run against a local/test Postgres, not the Supabase dev database — a `DATABASE_URL_TEST` env var pointing at a disposable local Postgres (or Supabase branching, using the `branching` feature already enabled on the connected MCP server, for a throwaway test branch per CI run).

## Build Order (feed this plan through in this sequence)
1. Rails new (`--api`), gems, `.env`/credentials wiring, CORS config, connect to Supabase (`rails db:migrate` against `DATABASE_URL_MIGRATE`, confirm connection); set up the `handle_new_user()` trigger on `auth.users` directly in Supabase
2. `cities` + `profiles` models/migrations, seed cities, Supabase JWT verification middleware (`current_profile` resolution), request specs proving auth rejection/acceptance
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
- No Supabase Realtime or Edge Functions — Auth, Postgres, and Storage only, per the Architecture Decisions above
- No background job runner (Sidekiq/etc.) — nothing in the current feature set needs async processing yet; add only if a real need shows up (e.g. push notifications in a later phase)
- No API versioning scheme beyond `/api/*` — add `/api/v1/*` if/when a breaking change is needed post-launch, not preemptively
- No Rails-side password reset/email-confirmation flow — Supabase Auth's client SDK handles those screens entirely in Phase 3; Rails has nothing to build here
