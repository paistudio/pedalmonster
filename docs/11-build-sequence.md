# Build Sequence — How to Run This With Claude Code

This is the operational guide: run these docs through Claude Code one at a time, in this order, reviewing/approving at each checkpoint before moving on.

## Phase 1 — Prototype (Vue, mock data only)
Feed to Claude Code in this order:
1. `00-project-overview.md` + `01-brand-style-guide.md` — give Claude Code full context and visual direction first, before any component work
2. `02-data-model.md` — have Claude Code generate matching **mock data fixtures** in Vue (not a real API yet)
3. `04-navigation-mobile-shell.md` — build the app shell: bottom nav, floating "+" button, PWA manifest scaffold
   - `16-app-preloader-splash.md` — add the custom logo splash/preloader overlay shown on load/refresh
4. `12-top-app-shell-and-menu.md` — add the top app bar, burger menu drawer, and inbox icon state
5. `05-home-feed.md` — build the unified feed + shared PostCard component using mock data
6. `13-tags-and-topic-discovery.md` — add tag/topic chips, topic detail screens, and follow state
7. `06-post-creation-flow.md` — build creation forms (writing to mock/local state only, no backend yet)
8. `14-inbox-notifications-and-chat.md` — add inbox tabs for notifications and chat, including unread-state visuals
9. `15-global-search.md` — add global search that returns mixed content results across the app
10. `07-marketplace.md`, `09-community-post.md`, `10-groups.md` — build each dedicated browse/detail screen, one at a time, reviewing each before starting the next
11. `03-auth-user-profile.md` — build profile screen + rank badge UI (mock auth state for now)

**Checkpoint:** Full click-through prototype on mock data. Review UX end-to-end on an actual mobile device/viewport before Phase 2.

## Phase 2 — Supabase (schema, RLS, triggers, Edge Functions — no custom backend server)
Detailed plan lives in `19-supabase-only-backend-plan.md` — architecture decisions, RLS policy design per table, trigger/function list, Edge Function list, and the step-by-step build order. Feed that doc to Claude Code for this phase; the summary below is just the checkpoint shape. (`18-backend-build-plan.md` was the original Rails-based plan for this phase — superseded, kept for history.)
1. Re-feed `02-data-model.md` + `19-supabase-only-backend-plan.md` to Claude Code as the source of truth for schema + RLS/trigger/Edge Function design
2. Set up Supabase CLI local dev, pull the already-migrated schema as the baseline
3. Enable RLS and write/test policies per table
4. Write/test the derived-counter and mention-extraction triggers, and the `handle_new_user`/group-post-cascade functions
5. Write/test the `chat-send-message`, `group-join`, and `submit-report` Edge Functions
6. Rewrite `02-data-model.md`'s data-access section into concrete `supabase-js` call references as each piece lands

**Checkpoint:** every RLS policy has a passing allow-case and deny-case test, every trigger/function/Edge Function has a test, before touching the frontend.

## Phase 3 — Integration
1. Replace Vue mock data layer with real `supabase-js` calls, screen by screen, in the same order as Phase 1 (feed → creation flow → marketplace → community → groups → profile)
2. Wire real auth (login/register/session persistence) via Supabase Auth's client SDK
3. Test each screen against the real Supabase project before moving to the next
4. Final PWA checks: install prompt, offline shell caching, push notification setup (verify iOS Safari support at this point)
5. Deploy the frontend to Vercel — the only deployment target, since there's no separate backend to host

**Checkpoint:** Fully working end-to-end MVP, mobile-first, PWA-installable.

## General Rule While Running This
Do not let Claude Code jump ahead to a later doc/phase mid-session unless the current checkpoint is reviewed and approved — that's the whole point of keeping frontend/backend separate and documents split per feature.
