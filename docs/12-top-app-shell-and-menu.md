# Top App Shell & Slide-over Menu

## Goal
Add a consistent top app bar and a slide-over left drawer for key navigation and account actions.

## Required UI
- Top bar with three areas. Left is always the hamburger menu icon; center/right are **context-aware per screen**:
  - **Default** (Home, Profile, and any screen without its own variant below): Left = burger menu · Center = app logo · Right = inbox icon
  - **Marketplace**: Left = burger menu · Center = search input (live-filters the listing browse) · Right = filter icon (opens the filter bottom sheet, see `07-marketplace.md`)
  - **Groups**: Left = burger menu · Center = "Groups" title · Right = "+" icon (routes to Create Group, see `10-groups.md`)
- Tapping the burger icon opens a **full-screen** drawer (100% viewport width/height, not a partial slide-over sidebar) from the left edge
- The drawer has its own top row with a close ("×") icon, left-aligned, that mirrors the burger icon's position/size so opening and closing feel like the same control toggling state
- Drawer content should follow this order:
  1. Global search entry (see `15-global-search.md`) — sits at the very top of the drawer, directly under the close row
  2. Followed topics / tags
  3. Divider
  4. Settings
  5. Liked
  6. Report a problem
  7. Logout — pinned to the very bottom of the drawer (pushed down with `margin-top: auto` inside the drawer's flex column), regardless of how much content is above it

## Search-in-Drawer Behavior
- The search field at the top of the drawer is a live, inline search — not a navigation trigger
- While the field is empty, the drawer shows its normal content (Topics / Settings / Liked / Report / Logout)
- As soon as the user types a non-empty query, the area below the search field swaps to a live unified result list (same cross-type search behavior as `15-global-search.md`) — Topics and the menu items are hidden while a query is present
- Clearing the query (or tapping the field's clear affordance) restores the normal drawer content
- Tapping a result closes the drawer and routes to that item's detail screen, same as tapping a global search result elsewhere
- Logout stays pinned at the bottom even while search results are showing, so the drawer's bottom anchor never disappears

## Followed Topics — List, Not Pills
- Followed topics render as a **vertical list of horizontal rows**, not wrapped pill chips (pills stay the pattern for tag mentions elsewhere — see `13-tags-and-topic-discovery.md`)
- Each row: `#tagname` on the left, a right-aligned count of new posts for that topic since last viewed
- Tapping a row behaves the same as before — closes the drawer and opens that topic's detail screen
- Empty state (no followed topics) is unchanged: a short "Follow a tag to see it here" message

## Menu Item Destinations
- **Settings** routes to the Account Settings screen (account info + change password) — see `03-auth-user-profile.md` → Account Settings
- **Liked** routes to a dedicated Liked Posts screen listing every post the user has liked, rendered with the same `PostCard` used in the feed — see `05-home-feed.md`
- **Report a problem** routes to a dedicated form screen (category + description, submit confirmation) — this is a standalone screen, not a bottom sheet
- All three are full-screen destinations (`hideShell: true`), reached by closing the drawer and pushing the route, consistent with how Settings/Liked/Report already behaved as drawer taps

## Interaction Rules
- The drawer should slide/fade in to cover the full screen
- It should close on:
  - tapping the close ("×") icon
  - swiping right
  - re-tapping the burger icon
- The top bar's burger icon flips to an "×" state while the drawer is open (already wired via `AppHeader`'s `drawer-open` prop) — the drawer's own close icon is a second, always-visible affordance now that the drawer covers the header
- The inbox icon should show a red unread dot whenever there is any unread notification or chat

## UX Notes
- Keep the header compact and consistent in height/position across every screen — only the center/right content swaps per the variants above, the left menu icon and the bar's floating treatment never change
- Header background is a vertical gradient, not a flat fill: `{colors.canvas}` (near-black) at 88% opacity at the top edge, fading to the same color at 0% opacity at the bar's bottom edge, so it blends into feed content underneath rather than showing a hard seam. No `backdrop-filter` blur is applied — the gradient alone provides separation from content underneath.
- The drawer should be lightweight for MVP; do not add nested submenus yet
- Use existing mobile-first patterns from the current app shell
- Logout is set in plain white (`{colors.ink}` / `--color-text`), the same as every other drawer item — it no longer uses the error/red accent, since sitting alone at the bottom of a full-screen drawer already gives it enough visual weight without a warning color. The destructive-confirmation step (tap once to arm, tap again to confirm) is unchanged.

## Acceptance Criteria
- A reusable top bar component is used across the app
- The burger menu opens a full-screen drawer with the expected sections and a close icon
- Typing in the drawer's search field swaps the drawer body to live search results; clearing it restores Topics/menu items
- Followed topics render as a list with a new-post count per row, not pills
- Settings, Liked, and Report a problem each route to their own dedicated screen
- Logout stays pinned to the bottom of the drawer and renders in white
- The inbox icon renders a red dot state for unread activity
- The shell remains usable at a 375px mobile width

## Best-Practice Decisions
- Because the request did not specify the exact logo asset or icon style, use a simple glyph-based burger icon and a centered logo mark with a fixed-height bar
- Keep the menu items tappable and route to either existing screens or placeholder screens for MVP
- Treat Logout as a confirmation action rather than an immediate sign-out to avoid accidental exits
- The header is borderless (no border-bottom) and its icon buttons are plain glyphs with no hairline circle border — the gradient bar itself provides enough separation from content underneath. This includes the Marketplace variant's filter icon — same borderless treatment as every other header icon, not the outlined pill style used elsewhere in the app
- "New posts" per followed topic is computed client-side for MVP (posts matching the tag created since the topic was last opened) rather than a dedicated backend counter — revisit once real read-state tracking exists server-side
