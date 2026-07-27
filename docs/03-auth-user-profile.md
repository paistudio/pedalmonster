# Auth, Profile & Rank System

## Auth (MVP scope)
- Email/password registration + login (keep simple for MVP — social login can come later)
- Session/token-based auth (JWT recommended for clean separation between Vue frontend and Rails API)
- Basic profile setup on first login: username, avatar, city/location — location is set via the shared location picker (city search + an optional "Use my location" GPS button), not free text, see `17-regional-location.md`

## Profile Screen
Fields displayed:
- Avatar, username, location
- Tabs or sections: "My Posts" (all types they've created), "My Groups"

**Rank UI paused (temporary):** the rank badge + current tier name, progress bar, and the "Rank & Activity" tab are hidden for now — see Display Rules below. Points/rank are still computed under the hood so the UI can be re-enabled later without a data migration.

**Logout lives only in the top-shell drawer menu** (see `12-top-app-shell-and-menu.md`) — do not duplicate a logout control on the Profile screen itself.

## Public User Profile (viewing someone else)
A separate, lighter screen from the Profile tab above — `/profile/:id`, reached by tapping any other user's avatar/username anywhere in the app (feed post author, listing seller card, group member list). Not a variant of the tabbed "My Posts/My Groups" screen; this is read-only and scoped to what's relevant about a stranger:
- Avatar, username, location, bio, "member since"
- Their active (non-sold) listings, shown in the same 2-column grid tile as Marketplace (`07-marketplace.md`) — lets a viewer browse everything else that user is selling
- A full-width **"Chat"** button pinned at the bottom (same grey-glass pill material as Listing Detail's CTA, see `design.md`'s `nav-bar-blur` reuse) — opens a plain 1:1 chat thread with that user, with no listing attached. This is the only way to start a chat that isn't triggered from a specific listing.
- Viewing your own id here isn't a normal path (nothing links to it) — if it happens, the Chat button is hidden rather than shown pointed at yourself

## Account Settings
Reached via the drawer's "Settings" item (`12-top-app-shell-and-menu.md`). A single screen, not a nested settings tree, with three sections:
- **Profile photo**: the only entry point in the app for changing the current user's own avatar — a tappable circular preview with a small camera-icon badge overlaid at its bottom-right corner, plus a "Change photo" text link beneath it. Tapping either opens the device's photo picker; the selected image replaces `currentUser.avatar_url` immediately (no separate save step, unlike the fields below). Mock-only in Phase 1 (object URL, not uploaded anywhere) — see the note below.
- **Account information**: username, email, location — editable fields, saved with a single "Save changes" action; location is set via the shared location picker (city search + optional "Use my location" GPS button), not a free-text field, see `17-regional-location.md`
- **Change password**: current password, new password, confirm new password — validated locally (new/confirm must match, current password required), submitted with its own "Update password" action separate from the account-info save

All three sections are mock-only in Phase 1 — they update `currentUser` in local state (the photo swap shows immediately with no confirmation toast, the two fields-based sections show a success confirmation after "Save"); there is no real auth/password/upload backend until Phase 2 (`11-build-sequence.md`).

## Rank & Popularity System

### Logic
- Every qualifying action (see `02-data-model.md` → Activity Points table) adds points to the user's `points` field
- Rank is **derived**, not stored independently — recalculate tier from points whenever points change (simple lookup against tier thresholds)
- No decay/point loss in MVP — points only go up

### Display Rules
- **Paused for now:** the rank badge is not rendered anywhere in the UI (feed posts, comments/answers, chat, group member list, profile) until re-enabled by a future decision. Keep the underlying points/rank calculation running so re-enabling is a UI-only change.
- When re-enabled: badge = small icon/color + tier name (keep visually lightweight, not a huge banner)
- No public leaderboard in MVP — rank is personal/contextual trust signal only, not competitive ranking against others

### Why It Matters
Rank quietly functions as a **trust signal** for marketplace transactions — an active, ranked user reads as more trustworthy than an anonymous new account. Keep this in mind when designing how prominently rank shows on listing cards specifically.

## Mobile Layout Notes
- Profile is accessible via bottom nav "Profile" tab
- Rank badge component should be small enough to sit inline in a feed card's author row without crowding the layout — test at actual mobile width (375–430px), not desktop
