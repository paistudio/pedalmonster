# Backend Build Plan v2 (Supabase-only — supersedes `18-backend-build-plan.md`)

## Why This Changed
`18-backend-build-plan.md` planned a Ruby on Rails API in front of Supabase Postgres. That was fully built and verified (50 passing RSpec tests, live against the real Supabase project). This doc **replaces that plan**: no custom backend server at all — the Vue frontend talks to Supabase directly (Postgres via `supabase-js`, Auth, Storage, and Edge Functions for anything that needs server-side logic). Reason for the switch: deployment simplicity (one Vercel project, no separate Rails host to run/pay for/keep warm) outweighed keeping the already-working Rails layer, once it became clear Vercel can't host Rails and free Rails hosts all come with real tradeoffs (cold starts, credit-card requirements, etc.).

**`18-backend-build-plan.md` is kept for history, not deleted** — per this project's "numbers are not reused" convention (see `00-project-overview.md`). It's marked superseded at the top.

**The `backend/` Rails app in the repo is now dead code.** It isn't deleted as part of this doc — that's a separate decision to confirm before deleting a working, tested codebase.

## Architecture Decisions

- **No backend server.** The frontend is the only application codebase. It talks to Supabase using `@supabase/supabase-js` for everything: Postgres reads/writes (via Supabase's auto-generated PostgREST API), Auth, Storage, and Edge Function invocations.
- **Row Level Security (RLS) replaces Rails controller authorization.** Every table has RLS enabled; policies (written in SQL, using `auth.uid()`) enforce exactly what `Api::PostsController#require_ownership!` and friends did in Ruby — e.g. "update/delete only if `user_id = auth.uid()`". This is the security boundary now, not application code — a missing or wrong policy is a real data-exposure bug, not just a UX bug, so each one needs to be tested (see Testing below).
- **Postgres triggers/functions replace `counter_cache` and simple derived-field logic.** `comment_count`, `like_count`, `member_count` — same idea as the Rails `counter_cache` option, implemented as `AFTER INSERT/DELETE` triggers instead.
- **Supabase Edge Functions (Deno/TypeScript) replace anything that was a Rails controller action doing more than a single-table write.** Concretely: the chat "find-or-create thread by canonical participant pair" logic, and the group-join "silently no-op if blocked" logic (an RLS policy violation returns an error, not a silent 200 — matching the exact UX from `10-groups.md` needs an Edge Function, not just a policy). See Edge Functions below for the full list.
- **`rank` stays computed, not stored** — same as the Rails plan, but now computed client-side from `points` (a plain read, no write access needed) using the same tier table in `02-data-model.md`. No server enforcement needed since it's a pure display derivation with no write path.
- **`profiles` row creation on sign-up** — same `handle_new_user()` trigger on `auth.users` pattern already documented in the superseded plan; unchanged by this pivot.
- **Media uploads go straight from the browser to Supabase Storage** via `supabase.storage.from('media').upload(...)`, no upload-proxy endpoint needed (this replaces the whole `Api::UploadsController`/`MediaUpload`/Active Storage detour from the Rails plan — genuinely simpler now). **Confirmed gotcha carried over from the Rails build:** the public URL for a file is `{SUPABASE_URL}/storage/v1/object/public/{bucket}/{path}` — Supabase's S3-compatible gateway path requires signed requests and will 403 on a plain public bucket, so don't build a URL from that endpoint.
- **IDs, schema shape unchanged** — same 17-table schema documented in `02-data-model.md` and the superseded plan's Migration Order section; only *how* it's created changes (Supabase CLI migrations instead of Rails migrations — see Build Order).
- **Confirmed gotcha — timestamp defaults.** `created_at`/`updated_at`/`joined_at` were `NOT NULL` with no DB-level default on every table — Rails' ActiveRecord always set these at the application layer, so it was never a problem until there was no application layer. This broke the very first trigger-driven insert (`handle_new_user`) during testing. Fixed with a migration adding `DEFAULT now()` to every such column, plus a `set_updated_at()` trigger on `profiles`/`posts`/`groups` so `updated_at` keeps advancing on every `UPDATE` too (a default only fires on `INSERT`). Anyone porting another Rails-originated schema to Supabase should expect the same issue.
- **Confirmed gotcha — `handle_new_user()` username.** Don't derive the placeholder `profiles.username` from the email's local part — two different people can share an email prefix, and `username` is unique, so a collision fails the *entire* `auth.users` insert (the trigger runs in the same transaction as signup). Use a UUID-derived placeholder (`'rider_' || substr(id::text, 1, 8)`) instead; the user overwrites it during onboarding regardless (`03-auth-user-profile.md`'s "Basic profile setup on first login").
- **Added, not in the original design:** a `tag_follower_count(tag_name)` `SECURITY DEFINER` SQL function. The `tag_follows` RLS policy is fully self-scoped (`select` limited to `user_id = auth.uid()`), which is correct for "does anyone read whose follow this is" — but it also means a plain client query can't compute a cross-user follower count for Topic Detail's follower badge. The function bypasses RLS for just that one aggregate read.

## Row Level Security — Policy Design Per Table
One `select`/`insert`/`update`/`delete` policy set per table, mirroring what the Rails controllers enforced:

| Table | Policy shape |
|---|---|
| `profiles` | select: anyone (public profiles); update: `id = auth.uid()`, and only non-credential columns (email/password stay Supabase-Auth-owned, unreachable via this table regardless) |
| `posts` | select: anyone (comments included — client filters `type != comment` for feed views, same as Rails did); insert: `user_id = auth.uid()`; update/delete: `user_id = auth.uid()` |
| `post_likes` | select: anyone; insert: `user_id = auth.uid()` (unique constraint on `(post_id, user_id)` still enforces no double-like); delete: `user_id = auth.uid()` |
| `groups` | select: anyone; insert: anyone (creator becomes owner); update/delete: `created_by = auth.uid()` |
| `group_memberships` | select: anyone; insert: `user_id = auth.uid()` **and** `NOT (auth.uid() = ANY (SELECT blocked_user_ids FROM groups WHERE id = group_id))` — this is the "blocked user can't rejoin" check as a `WITH CHECK` clause; delete: `user_id = auth.uid()` (leave) OR the group's `created_by = auth.uid()` (owner block-removal) |
| `reports` | insert: `user_id = auth.uid()`; select: none (reports are write-only from the client — reviewing them is an admin/dashboard concern outside this app) |
| `tag_follows` | select/insert/delete: `user_id = auth.uid()` |
| `notifications` | select/update (mark-read): `user_id = auth.uid()`; insert: none from the client — only triggers/Edge Functions create these (`SECURITY DEFINER`) |
| `chat_threads`, `chat_thread_reads`, `chat_messages` | select/insert: `auth.uid() IN (user_one_id, user_two_id)` (or the thread's participants, joined) — a user can only see/act on their own threads |
| `cities` | select: anyone; insert/update/delete: none from the client (seeded once, reference data) |

## Postgres Functions & Triggers
- `handle_new_user()` — `AFTER INSERT` on `auth.users`, creates the matching `profiles` row (unchanged from the superseded plan).
- `bump_comment_count()` / `bump_like_count()` / `bump_member_count()` — `AFTER INSERT/DELETE` triggers maintaining the three derived counters, same fields the Rails `counter_cache` maintained.
- `extract_mentions()` — `BEFORE INSERT OR UPDATE` on `posts` where `type = 'comment'`, using `regexp_matches` to populate `mentioned_user_ids` from `@handle` tokens in `description`, matching only real usernames. Direct port of the Rails model callback's regex logic into PL/pgSQL.
- `cascade_group_post_delete()` — `BEFORE DELETE` on `groups`, deletes `posts` rows where `type = 'group_post' AND type_data->>'group_id' = OLD.id::text` (the same manual cascade the Rails `Group` model did, since `group_id` lives inside a jsonb column, not a real FK).

## Edge Functions
Only where plain RLS + a trigger can't express the needed behavior:
- **`chat-send-message`** — takes `(other_user_id, body?, media_urls?)`, finds-or-creates the canonical `chat_threads` row for the sorted `(auth.uid(), other_user_id)` pair (same logic as the Rails `ChatThread.between`), then inserts the message. Needs to be atomic across two tables in a way a single RLS policy can't express.
- **`group-join`** — takes `(group_id)`, checks `blocked_user_ids`, and either creates the membership or **silently returns success without creating one** if blocked — this exact "no-op, not an error" UX (per `10-groups.md`) is awkward to get right with RLS alone (a blocked insert attempt normally surfaces as a policy-violation error to the client, which is the wrong UX here).
- **`submit-report`** — thin wrapper enforcing the "description required unless `post_id` is set" validation from `02-data-model.md`'s `Report` entity before insert; could arguably be a `CHECK` constraint instead (simpler — revisit during implementation, may not need to be an Edge Function at all).

Everything else (feed reads, post CRUD, likes, tag follow/unfollow, notifications list/mark-read) is a plain `supabase-js` table call gated by RLS — no Edge Function needed.

## Storage
- Bucket `media` (already created on the real project, public read) — used for all post/comment/chat photos and avatars, uploaded directly from the browser.
- No size/type validation exists yet at the Storage layer — revisit adding a `storage.objects` policy restricting `content_type`/size if abuse becomes a concern; not blocking for MVP.

## Edge Functions — Implementation Notes
Built with `@supabase/server`'s `withSupabase({ auth: "user" }, handler)` wrapper (scaffolded via `supabase functions new`), not the older bare `Deno.serve` + manual `createClient` pattern — it's the current CLI default and handles credential extraction/CORS/context creation. Key API surface actually used: `ctx.userClaims.id` (caller's uid), `ctx.supabase` (RLS-scoped client using the caller's own JWT — sufficient for all three functions here, no `ctx.supabaseAdmin` escalation needed since the underlying RLS policies already permit what each function does). Deployed with `supabase functions deploy <name> --project-ref <ref>` — **don't** pass `--no-verify-jwt`; the platform-level JWT gate should stay on since every function here requires an authenticated caller anyway (defense in depth, not just the in-function check).

## Testing
- **Supabase CLI local dev** (`supabase start`) — would spin up a local Postgres + Auth + Storage stack for testing without touching the real project, mirroring what local Postgres did for the Rails RSpec suite. **Not available on this machine** (no Docker, same constraint hit during the Rails build) — `db pull`/`db diff`/local dev all need it.
- **What was actually done instead, against the real project:**
  - RLS policies + triggers: a single transactional `psql` script wrapped in `BEGIN; ... ROLLBACK;`, using `SET LOCAL ROLE authenticated; SET LOCAL request.jwt.claim.sub = '<uuid>';` to impersonate each test user and exercise `auth.uid()`-based policies exactly as Postgres would evaluate them for a real request — 13 cases covering every policy's allow and deny path plus all four triggers, all rolled back so nothing persisted. This is a reasonable substitute for pgTAP when Docker isn't available, though pgTAP remains the better-documented, more portable choice if Docker becomes available later.
  - Edge Functions: real end-to-end HTTP tests against the deployed functions — created two throwaway users via the Admin API (`POST /auth/v1/admin/users` with `email_confirm: true`, avoids Supabase's email-send rate limit which a normal `/auth/v1/signup` call hits fast in a test loop), signed in via password grant for real JWTs, called each deployed function, then fully cleaned up (deleted all dependent rows, then the auth users) afterward.
  - Both approaches need real Supabase credentials (DB password, anon key, service_role key) kept in a gitignored `.env.supabase-admin` at the repo root, never the frontend's own `.env` — service_role in particular bypasses RLS entirely and must never ship to a browser.
- **Frontend**: existing manual click-through verification (per `CLAUDE.md`'s UI verification step) once Phase 3 wiring lands.

## Build Order
1. ~~`supabase init` in the repo, link to the real project, pull the schema already live there~~ — done; `db pull`'s diffing needs Docker (unavailable here), so the baseline wasn't "pulled" — new migrations were written by hand instead and pushed directly with `supabase db push`, which doesn't need Docker
2. ~~Enable RLS on every table; write and test each table's policies~~ — done, all 12 tables, 13 passing test cases
3. ~~Write and test the four triggers/functions~~ — done (plus the timestamp-default fix and `tag_follower_count` helper, see Architecture Decisions)
4. ~~Write and test the three Edge Functions~~ — done, deployed and verified end-to-end against the real project
5. Rewrite `docs/02-data-model.md`'s "API Endpoints" section into a `supabase-js` call reference (table/column names stay identical, so this is a translation pass, not a redesign) — **not yet done**
6. Phase 3: wire the Vue frontend to real `supabase-js` calls, screen by screen, per `11-build-sequence.md` — **not yet done**
7. ~~Deploy frontend to Vercel~~ — done, live at https://pedalmonster.vercel.app (still on mock data pending step 6)

**Checkpoint reached:** every RLS policy has a passing allow-case and deny-case test, every trigger/function/Edge Function has a test — Phase 3 frontend wiring is next.

## Open Question — Not Resolved by This Doc
Whether to delete the `backend/` Rails app now or leave it in the repo as reference/fallback. Flagging rather than deciding — ask before deleting a working, tested codebase.
