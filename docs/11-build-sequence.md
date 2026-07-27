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

## Phase 2 — Backend (Ruby/Rails, built independently)
Detailed plan lives in `18-backend-build-plan.md` — architecture decisions (Supabase Postgres as the database, JWT auth, Active Storage on Supabase Storage), migration order, and the step-by-step build sequence. Feed that doc to Claude Code for this phase; the summary below is just the checkpoint shape.
1. Re-feed `02-data-model.md` + `18-backend-build-plan.md` to Claude Code as the source of truth for database schema + models
2. Build models, migrations, associations against the Supabase-hosted Postgres database
3. Build API endpoints per the endpoint list in `02-data-model.md`
4. Build Supabase JWT verification (not Rails-issued auth) per `03-auth-user-profile.md`/`18-backend-build-plan.md` — Supabase Auth owns registration/login/password reset, Rails only verifies tokens
5. Build rank/points calculation logic (server-side, triggered on relevant actions)
6. Write request specs (RSpec) covering each endpoint — test independently of the frontend, using tools like Postman/curl or specs

**Checkpoint:** All API endpoints tested and working in isolation (e.g. via RSpec + manual Postman checks) before touching the frontend.

## Phase 3 — Integration
1. Replace Vue mock data layer with real API calls, screen by screen, in the same order as Phase 1 (feed → creation flow → marketplace → community → groups → profile)
2. Wire real auth (login/register/session persistence)
3. Test each screen against the real backend before moving to the next
4. Final PWA checks: install prompt, offline shell caching, push notification setup (verify iOS Safari support at this point)

**Checkpoint:** Fully working end-to-end MVP, mobile-first, PWA-installable.

## General Rule While Running This
Do not let Claude Code jump ahead to a later doc/phase mid-session unless the current checkpoint is reviewed and approved — that's the whole point of keeping frontend/backend separate and documents split per feature.
