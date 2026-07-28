# Navigation, App Shell & PWA Setup

## Bottom Navigation (4 destinations + create slot)
1. **Home** — unified feed (all post types mixed)
2. **Market** — dedicated marketplace browse/filter page
3. **Groups** — groups list / browse page
4. **Profile** — user profile, rank, my posts, my groups

The create ("+") slot sits between Market and Groups as a fifth, non-destination slot — see below.

Community Post does NOT get its own nav slot — it surfaces as a post type within the Home feed and via search/topics.

Location/"Nearby" also does NOT get its own nav slot — per `17-regional-location.md`, it's a filter/sort/algorithm layer woven into Home, Marketplace, and Groups (a location pill, a For You/Nearby toggle, sort options), never a standalone screen. Don't add a "Nearby" tab here without an explicit decision to change this 4-destination nav.

**Icons**: the app's default icon set is Iconoir (see `design.md` → Icon Library). As an explicit exception, the bottom nav's 4 destination glyphs (Home, Market, Groups, Profile) are rendered from Font Awesome 6 Solid instead, for a bolder glyph weight at tab size — the "+" create icon in the same bar stays Iconoir. See `design.md`'s "Exception — bottom nav tab icons use Font Awesome Solid" for the exact icon slugs and setup; don't extend Font Awesome beyond those 4 tab icons.

## Create Slot ("+")
- Not a separate floating button — it is the centre slot of the bottom nav pill, styled as a plain flat icon like the four destinations (see `design.md` → Bottom Navigation)
- Tapping it morphs the pill into a vertical menu of 3 choices: **Sell (Listing) / Post (Community) / Group Post**, rendered in the same grey glass material as the bar
- The menu closes on an outside tap or by re-tapping "+", which rotates 45° into an "×" while open
- Each choice routes to its respective creation flow (see `06-post-creation-flow.md`)

## App Shell Requirements
- Top app bar centre slot: the `pedalmonster_logo_text.svg` wordmark (white, ~20px tall), not the "Pedal Monster" text string — see `12-top-app-shell-and-menu.md` for the rest of the top bar.
- Single column layout, no sidebars, no multi-column grids — mobile viewport only (~375–430px design target)
- No hover states needed anywhere — design for tap/press states only
- Bottom sheets preferred over modals/dialogs for: filters, post creation, chat actions
- Pull-to-refresh on Home feed
- Swipeable photo galleries on any post/listing with multiple images

## PWA Setup
- `manifest.json`: app name, icons (multiple sizes), theme color and background color both `#0A0A0A` (the near-black canvas — the old brown/off-white pairing from `01-brand-style-guide.md` is superseded by `design.md`), `display: standalone`
- Favicon (`frontend/public/favicon.svg`) and every home-screen/install icon (`frontend/public/icons/icon-{180,192,512}.png`, referenced by the `apple-touch-icon` link tag and the PWA manifest respectively) are the `pedalmonster-logo-icon.svg` mark centered on a `#0A0A0A` square — same mark as the app preloader (`16-app-preloader-splash.md`) and the avatar placeholder (`design.md`'s Avatar Placeholder). The PNGs were rasterized from that same source at each exact pixel size, not scaled from one single size, so they stay crisp at iOS's home-screen icon size in particular.
- Service worker: cache app shell + static assets for offline resilience (useful since this is a community used outdoors/on rides where connectivity may be spotty)
- "Add to Home Screen" prompt handling
- Splash/loading screen: the OS-level PWA splash comes from the manifest above, but the app also has its own in-page logo preloader that covers every load and refresh (browser tab included) — see `16-app-preloader-splash.md`. Don't build a second loading overlay.
- Push notifications: plan for new answers, group activity, chat messages — verify current iOS Safari Web Push support at build time since it has historically been limited
- Design with Capacitor wrapping in mind for future native app — stick to standard web APIs, avoid PWA-only APIs that won't translate to a native wrapper later
