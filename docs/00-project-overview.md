# Pedal Monster — Project Overview

## What This Is
Pedal Monster is a mobile-first PWA community platform for bike enthusiasts. Users can sell bikes/parts, post to the community (questions, tips, updates — anything, not just Q&A), and create community groups — all surfaced through **one unified scrollable feed** where every content type appears as a "post" with a shared card format.

Built with the intent to later wrap into a native app (Capacitor or similar) once the PWA is stable.

## Tech Stack
- **Frontend:** Vue 3 (Composition API)
- **Backend:** Ruby (Rails API mode)
- **Database:** Supabase Postgres — Rails/ActiveRecord owns the schema via its own migrations; the frontend never talks to Supabase directly for data, only through the Rails API
- **Auth:** Supabase Auth — the one exception to the line above; the frontend authenticates directly against Supabase Auth (register/login/session/password reset), and Rails verifies the resulting JWT rather than issuing its own. See `18-backend-build-plan.md`
- **Connection:** REST API between frontend and backend
- **Hosting (suggested):** Vercel (frontend) + any Rails-friendly host for backend
- **PWA:** manifest.json + service worker for installability, offline shell caching, push notifications (evaluate iOS Safari support at build time)

## Build Workflow (in order)
This project is built in **3 phases**, and these docs are split to match:

1. **Prototype Phase** — Vue frontend only, mock/static data. Get UI/UX reviewed and approved before touching backend.
2. **Backend Phase** — Ruby/Rails API + database, built and tested independently of frontend (RSpec/request specs).
3. **Integration Phase** — Connect Vue frontend to real API, replace mock data layer.

**Do not skip ahead.** Each doc in this set assumes the prior phase is approved before moving on.

## Document Index (build/read in this order)
| # | File | Purpose |
|---|------|---------|
| 01 | `01-brand-style-guide.md` | Colors, typography, tone — reference for every screen |
| 02 | `02-data-model.md` | Core entities + API contract — reference for both prototype mocks and real backend |
| 03 | `03-auth-user-profile.md` | Auth, user profile, rank/popularity system |
| 04 | `04-navigation-mobile-shell.md` | App shell, bottom nav, PWA setup |
| 05 | `05-home-feed.md` | Unified feed — the core UX pattern |
| 06 | `06-post-creation-flow.md` | The "+" button flow, shared across all post types |
| 07 | `07-marketplace.md` | Sell bike/parts feature |
| 09 | `09-community-post.md` | Community Post feature (formerly "Q&A" — any post, not just questions) |
| 10 | `10-groups.md` | Groups feature |
| 11 | `11-build-sequence.md` | Step-by-step instructions for feeding this into Claude Code |
| 12 | `12-top-app-shell-and-menu.md` | Top app bar, burger drawer, inbox icon state |
| 13 | `13-tags-and-topic-discovery.md` | Tag/topic detail flow and follow state |
| 14 | `14-inbox-notifications-and-chat.md` | Inbox notifications + chat tabs |
| 15 | `15-global-search.md` | Global multi-type search |
| 16 | `16-app-preloader-splash.md` | Logo build animation shown on every load/refresh |
| 17 | `17-regional-location.md` | Location capture + nearby/popular-nearby algorithm layer across Home, Marketplace, Groups |
| 18 | `18-backend-build-plan.md` | Phase 2 backend plan — Rails + Supabase Postgres architecture, migration order, build sequence |

> `08` is intentionally vacant — it held the Events feature, which was cut from the product. Numbers are not reused, so later docs keep their existing filenames and references stay stable.

## Brand Quick Reference
- **Primary colors:** White (base) + Brown (anchor/brand color)
- **Feel:** Rugged, earthy, community-first — not corporate, not overly playful
- **Monetization (post-MVP):** Sponsor placements — not built in MVP, but data model should not block adding it later. (Rekber/escrow monetization is no longer planned — the feature itself was cut from the product, see MVP Scope Boundary below.)

## MVP Scope Boundary
**In scope for MVP:**
- Marketplace, Community Post, Groups — all as unified feed post types
- Basic rank/popularity system (Cub → Scout → Rider → Alpha → Pedal Monster)
- Mobile-first PWA, single-column layout, bottom nav

**Explicitly out of scope for MVP** (do not build yet):
- Rekber/escrow in any form — cut from the product entirely (not deferred), same treatment as Events below; no badge, toggle, or field anywhere
- Sponsor banner system
- Boosted/featured listings
- Private groups, group roles/moderation tools
- Community post reputation badges beyond the rank system, pinned/best-comment marking
- Events of any kind — the feature was cut from the product entirely (not deferred); there is no event post type, route, or entity
- Leaderboard page
