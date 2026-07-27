# Regional / Location-Based Layer

## Purpose
Location is a core, cross-cutting layer across the app — not a feature that owns its own screen. It answers two questions everywhere it shows up: "where is this?" and "what's near me?" It drives filtering, sorting, and a couple of small discovery affordances inside Home, Marketplace, and Groups. There is no dedicated "Nearby" tab or page — the bottom nav stays Home / Market / + / Groups / Profile, unchanged.

## Location Model
- **City-level granularity only.** Every location in the app — a user's home base, a listing's location, a group's location — resolves to one entry in a small canonical city list, not a free address or raw coordinates.
- **Canonical city list**: a fixed set of ~12-15 Indonesian cities, each with `id`, `name`, `province`, `lat`, `lng`. Lives in `frontend/src/mocks/cities.js` in Phase 1 (would become a seeded reference table in Phase 2, not a user-editable list).
- **Distance**: real straight-line (haversine) distance in km between two cities' coordinates — not a boolean same-city/same-province check. This is what powers "X km away" labels and nearest-first sorting.
- **"Nearby" radius**: a fixed constant, **50km**, used everywhere "nearby" filtering happens (Home feed's Nearby tab). Not user-configurable in MVP.

## Capture & Storage
- A user's location is captured one of two ways, both landing on the same canonical city:
  1. **GPS** — the browser's Geolocation API, requested **only** when the user taps an explicit "Use my location" button. Never auto-prompted on page load or route change. The raw coordinates returned are immediately resolved to the *nearest* city in the canonical list (via haversine) and only that city reference is kept — raw GPS coordinates are not stored.
  2. **Manual** — the user picks a city from a searchable list. Always available, and is the automatic fallback if GPS is denied, unsupported, or errors out.
- Storage: `location_city_id` is the source of truth for every algorithm (User, Post, Group — see Data Model below). Existing free-text `location` string fields are kept as the human-readable display label shown on profile/listing/etc., but no longer drive filtering or sorting.
- A user's resolved location is optional — someone who has never set one simply sees the unfiltered default everywhere (Home's "For You" feed, Marketplace with no location filter, Groups' Discover in its existing order).

## Location Picker Component
One shared component, `frontend/src/components/LocationPickerSheet.vue`, wraps the existing `BottomSheet.vue` (same pattern as `FilterSheet.vue`). Contents:
- "Use my location" button — shows a loading state while the GPS request is in flight, and an inline error row ("Couldn't get your location — pick a city below") if it's denied, unsupported, or errors, without leaving the user stuck.
- A search input filtering the city list by name/province.
- A scrollable list of cities; tapping one sets it as the resolved location and closes the sheet.

This single component is reused at five call sites — do not build a per-screen picker:
1. Register (city is required to create an account, same as today)
2. Account Settings (change location any time)
3. Create Listing (a listing's location)
4. Create Group (a group's location — optional)
5. Marketplace filter sheet (filter listings by city)

## Home Feed Integration
Supersedes part of `05-home-feed.md`'s "chronological for MVP, no tab bar" language — see that doc's Behavior section for the precise wording. Summary:
- **For You / Nearby toggle** (reuses the `TabBar` component, same pattern as Groups' My Groups/Discover toggle):
  - **For You** (default) — today's feed, completely unchanged: chronological, unfiltered, mixed post types. No algorithmic ranking.
  - **Nearby** — the same mixed feed, filtered to posts whose resolved city is within 50km of the user's location, sorted nearest-first (recency as the tiebreaker). This is the only algorithmic/filtered view in the app, and it's opt-in.
  - If the user has no resolved location, tapping "Nearby" opens the location picker instead of showing an empty tab.
- **Location label** — shown only while the **Nearby** tab is active, below the toggle: plain text "📍 {city}", no pill/border chrome (unlike the picker entry points elsewhere, which stay button-styled). Tapping it reopens the location picker to change city. Not shown on **For You** — with no active proximity sort there, there's nothing for it to label.
- No "Popular Near You" strip. The **Nearby** tab already sorts the full feed nearest-first starting from the user's location, which makes a separate top-5-by-engagement strip redundant — removed from Home entirely. `like_count`/`comment_count` scoring is no longer used anywhere in the Home feed.

## Marketplace Integration
- The filter sheet's free-text "Location" field is replaced by a trigger button that opens the location picker; the filter becomes an **exact city match** (not a substring match) against each listing's `location_city_id`.
- A new **"Nearest first"** sort option sits alongside Newest/Price — sorts listings by distance from the user's resolved location (ascending); listings with no resolvable city sort last. Only meaningful once the user has a location set.
- Listing detail may show "X km away" next to the location label when both the viewer and the listing have a resolved city.

## Groups Integration
- Groups can optionally set a `location_city_id` at creation (via the shared picker) — this was aspirationally mentioned in `10-groups.md`'s Purpose line ("by city, brand, riding style") but never actually implemented until now.
- The Groups list's **Discover** tab sorts nearest-first by default once the viewer has a resolved location; falls back to its existing order (creation order) when no location is set or a group has none. This does not change the **My Groups** tab.

## Data Model Additions
Mirrored in full in `02-data-model.md`. Summary:
- **New `City` entity**: `id`, `name`, `province`, `lat`, `lng`.
- **User**: `location_city_id` (FK, nullable) — algorithm source of truth, alongside the existing `location` display string.
- **Post (base entity)**: `location_city_id` (FK, nullable) — populated for listings in MVP; community/group posts leave it null, same as the existing `location` string today. Also: `like_count` (integer, derived) — new field, since likes were previously only tracked per-user via `PostLike` with no aggregate on the post itself. Needed to define "popular" consistently across post types.
- **Group**: `location_city_id` (FK, nullable), optional.

## Explicitly NOT in MVP
- No live/interactive map view anywhere (no embedded map SDK) — city list + distance math only
- No user-configurable search radius — the 50km "nearby" radius is a fixed constant
- No reverse-geocoding of arbitrary street addresses — GPS resolves only to the nearest entry in the fixed city list, never to a free-form address
- No proximity-based push notifications or location alerts
- No background or continuous location tracking — GPS is a single one-shot request triggered by an explicit button tap, never watched/persisted as a live position
- No per-post or per-listing precise GPS pin — city-level granularity only, everywhere
- No location-based visibility or access control — distance only ever affects sort/filter order, it never hides a post from anyone
- No distance-based pricing, shipping estimation, or logistics integration
- No new bottom-nav tab or standalone "Nearby" screen — the 5-slot nav (Home/Market/+/Groups/Profile) is unchanged
