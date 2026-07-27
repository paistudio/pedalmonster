# CLAUDE.md

This file is read automatically by Claude Code at the start of every session in this repo. Follow it before starting any work.

## Project
**Pedal Monster** — a mobile-first PWA community platform for bike enthusiasts (marketplace, community posts, groups), unified into a single scrollable feed. Full spec lives in `/docs`.

## Read First, Every Session
Before writing any code, read:
1. `docs/00-project-overview.md` — project scope, tech stack, MVP boundaries
2. `design.md` — the authoritative design system (colors, typography, components, do's/don'ts). **This supersedes `docs/01-brand-style-guide.md` for all visual/design decisions** — the rugged/earthy brown palette in `01` is superseded; `design.md`'s near-black canvas + white-pill system is the current source of truth for every screen, existing or new.
3. `docs/02-data-model.md` — entities and API contract (source of truth for both mock data and real backend)

Then check `docs/11-build-sequence.md` to determine which phase and which doc to work from next.

## Design System — Critical Rule
`design.md` (repo root) is always in effect. Every screen, component, and future addition must use its tokens (colors, typography, spacing, radius) and components (pill buttons, hairline cards, no shadows, no bold display text). Do not invent colors/spacing/shapes outside it. If a feature doc's UX notes conflict with `design.md` on a purely visual matter (e.g. a suggested color), `design.md` wins — flag the conflict, don't silently blend the two.

## Tech Stack (do not deviate)
- **Frontend:** Vue 3, Composition API
- **Backend:** Ruby (Rails API mode)
- **Connection:** REST API between the two — kept as separate, independently testable codebases
- **PWA:** installable manifest + service worker, mobile-first only (no desktop layout work)

## Phase Discipline — Critical Rule
This project is built in 3 strict phases. **Do not skip ahead or blend phases unless explicitly told to.**

1. **Phase 1 — Prototype:** Vue frontend only, using mock/static data matching `docs/02-data-model.md`. No backend code yet.
2. **Phase 2 — Backend:** Ruby/Rails API + database, built and tested independently (RSpec/request specs). No frontend changes during this phase.
3. **Phase 3 — Integration:** Wire the Vue frontend to the real API, replacing mock data.

If asked to build something that belongs to a later phase than the one currently active, stop and flag it rather than proceeding.

## Feature Docs
Each feature has its own doc in `/docs` — build one at a time, in the order listed in `docs/11-build-sequence.md`:
- `03-auth-user-profile.md` — auth, profile, rank/popularity system
- `04-navigation-mobile-shell.md` — app shell, bottom nav, PWA
- `12-top-app-shell-and-menu.md` — top app bar, burger drawer, inbox icon state
- `05-home-feed.md` — unified feed (core pattern, build carefully)
- `13-tags-and-topic-discovery.md` — tag/topic detail flow and follow state
- `06-post-creation-flow.md` — shared "+" creation flow
- `14-inbox-notifications-and-chat.md` — inbox notifications + chat tabs
- `15-global-search.md` — global multi-type search
- `07-marketplace.md`, `09-community-post.md`, `10-groups.md` — one feature each
- `17-regional-location.md` — location capture + nearby/popular-nearby layer across Home, Marketplace, Groups

## Key Architectural Rule
All content types (listing, community post, group post) share ONE base `PostCard` component with type-based variants — do not build separate card components per type. See `docs/05-home-feed.md`.

## MVP Boundaries — Do Not Build These Yet
- Rekber/escrow in any form — cut from the product entirely, not even a static badge
- Sponsor banner system
- Boosted/featured listings
- Private groups, group roles/moderation tools
- Community post reputation badges beyond rank, pinned/best-comment marking
- Events in any form — the feature was cut from the product entirely; no event post type, route, or entity
- Public leaderboard

If unsure whether something is in scope, check `docs/00-project-overview.md`'s MVP Scope Boundary section before building it.

## Working Style
- Mobile-first only — design/test at ~375–430px viewport, no hover states, no desktop layouts
- One feature doc per work session where possible — stop for review before moving to the next doc
- If output conflicts with a doc, the doc wins — flag the conflict rather than silently deviating

## Docs-First Rule — Critical
For every user request that changes behavior, UI, scope, or structure, update the relevant doc(s) in `/docs` (and `design.md` if it's a visual/component change) **before or alongside implementing** — never leave a shipped change undocumented.
- Figure out which doc(s) the request touches (feature doc, `03`/`04`/`05`/etc., or `design.md`) and edit them first.
- If the request adds something new with no existing doc, create one (follow the existing doc format/style) rather than skipping documentation.
- If a request reverses or supersedes a previous doc decision (e.g. moving a feature, removing something), edit the doc in place to reflect the new reality — don't leave stale/contradictory instructions for the next session to trip over.
- Small pure-bugfixes with no behavior/scope change (e.g. fixing a CSS double-scroll bug) don't need a doc update — use judgment, but default to updating docs when in doubt.
