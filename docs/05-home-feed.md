# Home Feed (Unified Feed)

This is the core UX pattern of Pedal Monster — build this carefully, everything else plugs into it.

## Behavior
- Single infinite-scroll feed, chronological by default ("For You" — see Location Toggle below). General algorithmic ranking of this default feed remains post-MVP.
- Mixes all 3 post types together: listing, community post, group post
- Pull-to-refresh at top
- Infinite scroll pagination (cursor or offset-based — decide in backend phase)

## Filter Chips
**Removed for now.** The Home feed no longer shows a *type*-filter tab bar above the feed — it always shows the mixed unified feed regardless of tab. Per-type browsing still exists via the dedicated Market/Groups screens and the drawer's topic/tag entries. (This is separate from the Location Toggle below, which doesn't filter by type.)

## For You / Nearby Toggle & Location Label
Full spec in `17-regional-location.md` — summary here since it's part of the core feed pattern:
- A two-option toggle (reuses `TabBar`, same pattern as Groups' My Groups/Discover) switches between **For You** (default, today's unfiltered chronological feed — no ranking) and **Nearby** (opt-in; the same feed filtered to posts within 50km of the user's location, sorted nearest-first under recency). This "Nearby" tab is the one exception to "chronological, no algorithmic ranking" above — it's explicitly opt-in, not the default.
- If the user has no resolved location and taps **Nearby**, the location picker opens directly instead of showing an empty tab.
- Once **Nearby** is active and a location is resolved, a plain-text location label ("📍 {city}") appears below the toggle — not pill-chrome, just icon + text, no border/background. Only shown while **Nearby** is the active tab; hidden on **For You**. Tapping it reopens the location picker to change city.
- No "Popular Near You" strip. Removed: the **Nearby** tab already sorts the whole feed nearest-first, so a separate top-5-by-engagement strip above it was redundant.

## Post Card — Shared Base Structure
Every card in the feed shows:
- Author avatar + username + timestamp (rank badge paused for now — see `03-auth-user-profile.md`)
- A like (heart) toggle, top-right of the card header — same control on every post type, independent of the type-specific footer CTA. Liking a post adds it to the user's Liked list, reachable from the drawer (`12-top-app-shell-and-menu.md` → Liked)
- A comment icon + count, immediately next to the like toggle — same universal placement, independent of the type-specific footer CTA. Present on **every** post type (listing, community post, group post): commenting is not a community-post-only feature. See Comments & Mentions below.
- Cover photo/media (swipeable if multiple)
- Title/caption text (truncated with "see more" if long) — community posts have no title, so this is just the body text for that type, see `06-post-creation-flow.md`
- **Post type badge** (icon + label): 🏷️ For Sale / 💬 Community / 👥 Group
- Type-specific footer (see below)

## Type-Specific Footer Actions
| Type | Footer shows | Primary CTA |
|---|---|---|
| Listing | Price | "Chat Seller" |
| Community post | — (comment count/action lives in the universal comment icon above, not duplicated here) | — |
| Group post | Group name — its own tap target, routes to Group Detail (`10-groups.md`), separate from tapping the rest of the card | "Join Group" (if not member) |

## Tap Targets — Card Body vs. Group-Name Row
A group post's card has two distinct tap targets, not one:
- **Tapping the card itself** (photo, title, description — anywhere except the footer's group-name row and the like/comment/CTA controls) opens **Post Detail** for that post, exactly like a community post. It does **not** open Group Detail — a group post is still a post first.
- **Tapping the footer's group-name row specifically** opens **Group Detail** for the group it belongs to.
- Inside Group Detail's own post list, the same `PostCard` is reused with its group-name footer row suppressed (`hide-group-footer`, see `10-groups.md`) — tapping a post there also opens Post Detail, consistent with every other place the card appears.

## Comments & Mentions
- Any post — listing, community post, or group post — can be commented on. This used to be a community-post-only capability; it's now universal, matching the unified feed's "all 3 types are first-class" principle.
- Under the hood a comment isn't a separate content type — it's the same `Post` entity with `type=comment` and `parent_id` pointing at the post it replies to, see `02-data-model.md`. This is why comments get edit/delete, likes, and `@mentions` for free instead of each being reimplemented per content type; it also leaves room for nested replies later (a comment's `parent_id` could point at another comment) without a schema change, though the UI only supports one level today.
- Every card shows a comment icon + live count next to the like toggle (see Post Card above). Tapping it:
  - **Community post / Group post** → opens the full Post Detail page (see Post Detail Management below), which has the full comment thread + composer inline. Group posts share this same page — see Tap Targets above.
  - **Listing** → opens a lightweight **Comments bottom sheet** directly over the feed (same comment list + composer pattern, reused rather than rebuilt) so commenting doesn't require leaving the Market context. The same sheet is also reachable from Listing Detail (`07-marketplace.md`) via a "Comments" row below the seller card. Listings don't get a Post Detail page of their own — see `07-marketplace.md`'s Listing Detail instead.
- Comment composer supports **@mentions**: typing "@" opens an inline autocomplete dropdown of matching usernames (max 5, filtered as you type, current user excluded); tapping one inserts `@username` into the comment text. Mentioned usernames render as a highlighted, non-interactive token in the posted comment (not yet a tappable link to the profile — nice-to-have for later).
- Mentioned users are recorded on the comment (`mentioned_user_ids`, see `02-data-model.md`) so a future pass can wire up a mention notification — **not yet connected to the inbox/push notification system** (`14-inbox-notifications-and-chat.md`) in this pass; that's a follow-up, not a blocker for shipping mentions in the composer.
- Comment count, like-on-comment, and chronological (not ranked) ordering all follow the existing rules in `09-community-post.md` — that doc's Interaction rules now apply regardless of the post's type, not just community posts.
- The comment composer supports attaching **up to 4 photos** to a comment (reuses the shared `PhotoPicker`, same component as post/listing creation); a comment can be photos-only with no text. This applies both on the Post Detail page (community/group posts — see Post Detail Management below) and in the Comments bottom sheet used for listings — one composer, one attach behavior, regardless of entry point.
- **Editing/deleting your own comment**: each comment shows "Edit"/"Delete" text actions next to its like button, visible only to that comment's author. Edit swaps the comment into an inline textarea with Save/Cancel. Delete asks for a lightweight inline confirm (Cancel/Delete), same guard-against-accidental-tap pattern as the Group members list's block action (`10-groups.md`) — deleting a single comment isn't destructive enough to warrant a full confirmation sheet the way deleting a whole post is.

## Post Detail Management (community posts and group posts)
Post Detail is shared by both community posts and group posts — one page, one comment thread, one owner-management pattern, rather than a separate detail page per type (see `10-groups.md`, which used to route a group post's card tap here instead of to Group Detail — that was a bug, fixed: see Tap Targets above).
- The Post Detail page's header (left = back button) gets a right-side control mirroring Group Detail's owner pattern (`10-groups.md`):
  - **Post creator**: a three-dot **more-menu** icon (`iconoir:more-horiz`) opening a bottom sheet with **"Edit post"** and, below it, **"Delete post"** (destructive, error-colored).
  - **Everyone else**: the same three-dot icon instead opens a bottom sheet with a single **"Report post"** action.
- **Edit post** routes to `/posts/:id/edit` — same description + photo fields as post creation (`06-post-creation-flow.md`), prefilled, with a single "Save changes" action that updates the post in place and returns to Post Detail. (Editing a group post's title isn't exposed on this form yet — same gap as post creation's fields, not new here.)
- **Delete post** asks for confirmation via a dedicated bottom sheet (not a lightweight inline confirm, since this is a heavier action than a comment delete) — "This removes the post and every comment on it. This can't be undone." with "Cancel" and a destructive "Delete post" action. Confirming removes the post and cascades to delete all of its comments, then returns to Home.
- **Report post** opens a bottom sheet with a short list of reason radio options (Spam / Inappropriate content / Harassment or bullying / Other) and a "Submit report" action — no free-text field, unlike the general "Report a problem" drawer form (`12-top-app-shell-and-menu.md`), since a post report just needs a reason to queue for moderation review. Submitting shows a brief inline "Report sent" confirmation.
- Post Detail also gets a **like (heart) toggle + count**, shown as its own row beneath the poster card (above the comments heading) — the like state/count is the same `PostLike` used by the feed card and the drawer's Liked list, just surfaced again here since the detail page doesn't show the feed card's header.
- When the post is a group post, a small **"Posted in {group name}"** link appears above the title (below the photo gallery) — the only way back to Group Detail from this page, since the feed card's group-name row isn't part of Post Detail. Tapping it opens Group Detail for that group.

## Mobile Layout Notes
- Cards are full-width, stacked vertically, comfortable tap spacing between cards
- Card image area should have a consistent aspect ratio across types for visual rhythm in the scroll
- Badge + CTA must be readable/tappable without zooming — test at 375px width minimum

## Component Build Note
Build ONE `PostCard.vue` component with a `type` prop that switches the footer/badge rendering — do not build 4 separate card components. This keeps the feed rendering logic simple and consistent.
