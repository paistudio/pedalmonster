# Feature: Groups

## Purpose
Users create and join community groups (by city, brand, riding style, etc.) with their own feed of posts. The "by city" part is implemented via an optional group location — see `17-regional-location.md`.

## Screens

### Groups List
- Accessible from Profile or a shortcut near the top of Home feed
- Grid or horizontal-scroll cards: group photo, name, member count
- "My Groups" (joined) vs "Discover" (not yet joined) — simple toggle or two sections
- Discover sorts nearest-first when the viewer has a resolved location (a group's optional `location_city_id` vs. the viewer's — see `17-regional-location.md`); falls back to its existing order when no location is set on either side. My Groups is unaffected.
- Title and create-group entry live in the **global top app bar** while on this screen (see `12-top-app-shell-and-menu.md`) — center slot shows "Groups", right slot is a "+" icon that routes to Create Group; there's no separate in-page header row

### Group Detail
- In-page header: left = back button, middle = group name, right = one control whose meaning depends on who's looking:
  - **Owner** (`created_by` matches the viewer): a three-dot **more-menu** icon (`iconoir:more-horiz`, borderless per `design.md`'s icon-button rule) that opens a bottom sheet with **"Edit group info"** (see Edit Group below) and, below it, **"Delete group"** (destructive, styled in the error color) — see Delete Group below. There is no join/leave control for the owner — they're always a member of their own group.
  - **Everyone else**: a text **pill button** reading "Join" or "Leave" (no icon) — accent-outlined when not joined (inviting the tap), muted outline once joined, disabled/greyed if the viewer has been blocked from this group (see Moderation below). This is the only join/leave control; there is no separate bottom CTA bar for it. Unlike the owner's more-menu, this is a labeled pill, not an icon-only button, so it keeps the standard outline border per the pill-button idiom.
- Group photo/banner, name, description, member count
- Group feed: posts made within this group (type=group_post), same PostCard component as Home feed — but with its group-name-and-Join-button footer row suppressed, since the viewer is already looking at that group and joining is one tap away in the header; showing it again per-post on this specific screen is redundant. The footer stays visible everywhere else the same group_post cards appear (Home feed, Public User Profile), since there it's the only nearby join affordance. Tapping a post here (or its comment icon/count) opens Post Detail, same as everywhere else the card appears — see `05-home-feed.md`'s Tap Targets and Post Detail Management sections.
- Members list (avatars, tap to view) — see Moderation below for the owner's block action inside this list

### Edit Group (owner only)
- Reached via the Group Detail header's three-dot menu → "Edit group info"
- Same three fields as Create Group: name, photo, description (location is not editable here — not requested, out of scope for now)
- A single "Save changes" action updates the existing group in place and returns to Group Detail; no draft/preview step
- Route guards against non-owners — if a non-owner somehow lands on the URL, it behaves as not-found rather than rendering the form

### Delete Group (owner only)
- Reached via the Group Detail header's three-dot menu → "Delete group"
- Because this is a heavier, less reversible action than a per-member block, it asks for confirmation via a dedicated bottom sheet (not the lightweight inline confirm used for blocking) — the sheet spells out the consequences ("This removes the group for everyone. All N members will be removed and every post in this group will be deleted. This can't be undone.") with "Cancel" and a destructive "Delete group" action
- Confirming permanently removes the group, every membership in it, and every post of type `group_post` belonging to it, then returns the viewer to the Groups List
- No soft-delete/undo — this is a hard delete in MVP, consistent with there being no unblock/ban-appeal flow either

### Create Group
- Name, photo, description
- Location — optional, set via the shared location picker, see `17-regional-location.md`
- Public only in MVP (no private/approval flow)
- Creator is automatically the first member and the sole owner (`created_by`) — see Moderation below for what ownership grants

## Moderation (owner only)
- The group owner (`created_by`) can **block** a member from the Members list (Group Detail → "N members · See all"): each row shows a "Block" action next to every member except the owner's own row; tapping it asks for a lightweight inline confirmation before removing them, to guard against an accidental tap on a real, consequence-bearing action.
- Blocking immediately removes that person's membership (member count updates live) and adds them to the group's block list, which prevents them from rejoining — the join action silently no-ops for a blocked user rather than erroring.
- Blocking is scoped to this one group only — it has no effect on that user's posts, profile, or ability to chat elsewhere in the app.
- No unblock flow, no ban-appeal flow, and no roles beyond the single owner in MVP — see Explicitly NOT in MVP below.

## Interaction
- Any user can create a group
- Any user (other than someone the owner has blocked) can join any group (public only, no approval step)
- Group posts only visible to feed if made by/within a group the viewing user can see (all groups are public in MVP, so all group posts are visible in Home feed too — the Home feed has no type-filter chip anymore, see `05-home-feed.md`, so group posts simply appear inline in the mixed feed)

## Mobile Layout Notes
- Group discovery cards work well as horizontal-scroll rows (like "Discover Groups Near You") rather than a long vertical list, for quick browsing
- Join request flow for private groups is NOT needed — public join only, keep this button a single tap

## Explicitly NOT in MVP
- Private groups / approval-to-join flow
- Roles/permissions beyond a single owner — no co-admins, no moderator tier; block/edit are owner-only actions with no delegation
- Unblock flow or a ban-appeal path — blocking is currently one-directional in the UI (the data model isn't blocked from adding it later)
- Group-specific events — there is no events feature in the product at all (cut entirely, see `00-project-overview.md`)
