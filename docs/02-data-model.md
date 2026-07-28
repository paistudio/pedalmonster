# Data Model & API Contract

This is the reference for BOTH the Vue prototype's mock data shape AND the real Supabase schema — keep them in sync so integration (Phase 3) is a drop-in swap. There is no custom backend API — the frontend talks to Supabase directly (`supabase-js`), gated by Row Level Security. See `19-supabase-only-backend-plan.md` for the RLS/trigger/Edge Function design; table/column names below are exactly what's queried.

## Core Entities

### User
Authentication (credential storage, login, session/refresh tokens, password reset) is owned entirely by **Supabase Auth**, not this table — see `19-supabase-only-backend-plan.md`. This entity is a `profiles` row whose `id` is a foreign key to Supabase's `auth.users.id` (created via a DB trigger on sign-up), holding only the app-specific fields below. `email` lives on `auth.users`, not `profiles` — shown here because the frontend still surfaces it (joined in) for the mock data shape and for display on Account Settings, but changing it goes through Supabase Auth directly (`supabase.auth.updateUser({ email })`), never a `profiles` update.
| Field | Type | Notes |
|---|---|---|
| id | uuid | FK to Supabase `auth.users.id` in the real backend; a plain generated id in the Phase 1 mock |
| username | string | |
| email | string | owned by Supabase Auth; used for login + shown (read-only via this API) on Account Settings, see `03-auth-user-profile.md` |
| avatar_url | string | |
| bio | string | optional |
| location | string | city-level, display label only |
| location_city_id | uuid | FK to City — source of truth for nearby/distance algorithms, see `17-regional-location.md` |
| points | integer | drives rank |
| rank | enum | Cub / Scout / Rider / Alpha / Pedal Monster — derived from points |
| created_at | datetime | |

### City
Canonical reference list backing `location_city_id` on User, Post, and Group — see `17-regional-location.md`. City-level granularity only, no per-record raw coordinates.
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| name | string | e.g. "Bandung" |
| province | string | e.g. "Jawa Barat" |
| lat | float | |
| lng | float | |

### Post (single entity for ALL user-authored content, including comments)
**Concept: there is only one content table.** A "comment" is not a separate entity — it's a `Post` row with `type: comment` and `parent_id` pointing at the post (or, for future nested-reply support, another comment) it replies to. This is a deliberate unification: likes, `@mentions`, edit/delete, and moderation/reporting logic all live in one place instead of being duplicated between a `Post` model and a parallel `Comment` model. What used to be documented as separate `Comment` and `CommentLike` entities are now just `Post` and `PostLike` rows filtered by `type=comment` — see the migration note at the end of this section.

| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | FK to User |
| type | enum | `listing` / `community_post` / `group_post` / `comment` — a comment is a post whose `type` is `comment` |
| parent_id | uuid | FK to Post, nullable — set only when `type=comment`; the post (or another comment, once nested replies are supported) this one is a reply to. Always null for `listing`/`community_post`/`group_post` |
| title | string | optional, only meaningful for `listing`/`group_post` — never used for `community_post` or `comment`, see `06-post-creation-flow.md` |
| description | text | the body text: post caption for `listing`/`community_post`/`group_post`, or the comment text when `type=comment` (may contain `@username` mention tokens; may be blank for a comment if `media_urls` is non-empty) |
| media_urls | array\<string\> | 1–5 photos for a top-level post; 0–4 for a comment, see `05-home-feed.md` |
| tags | array\<string\> | topic/tag labels shown as `#tagname` chips on the post; freeform strings, not a normalized FK — see Tag below for the follow-side of this |
| mentioned_user_ids | array\<uuid\> | derived, populated for `type=comment` only — FK to User, extracted from `@username` tokens in `description` at creation time (only usernames matching a real account count); not yet wired to a push/inbox notification |
| location | string | optional, `listing`/`group_post` only, display label only |
| location_city_id | uuid | FK to City, nullable — populated for listings in MVP, null otherwise, see `17-regional-location.md` |
| like_count | integer | derived — aggregate like count for this row (top-level post **or** comment), backed by the single `PostLike` relation below |
| comment_count | integer | derived — count of Post rows where `parent_id` = this row's `id` and `type=comment`; applies to every top-level type. Always `0` for a `type=comment` row itself in MVP (no nested-reply UI yet, though the schema doesn't prevent it later) |
| created_at | datetime | |
| type_data | object | polymorphic, see below — empty object for `community_post` and `comment` |

Author can edit `description`/`media_urls` or delete their own row in place (no edit history kept in MVP), whether it's a top-level post or a comment — see `05-home-feed.md`.

**Migration note:** if you're looking for the old `Comment`/`CommentLike` entities from an earlier version of this doc — they're gone. A comment is now `Post` + `type=comment` + `parent_id`; a comment like is now a `PostLike` row same as a post like.

### Listing (type_data for type=listing)
| Field | Type | Notes |
|---|---|---|
| category | enum | bike / part |
| condition | enum | new / used |
| price | integer | |
| status | enum | available / sold |

### Community Post (type_data for type=community_post)
Formerly "Question" — renamed because a community post no longer has to be phrased as a question, see `09-community-post.md`. Has no type-specific fields of its own.

### Group
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| name | string | |
| photo_url | string | |
| description | text | |
| visibility | enum | public only in MVP |
| member_count | integer | derived |
| created_by | uuid | FK to User — the group owner; the only user who can edit group info or block/remove members, see `10-groups.md` |
| location_city_id | uuid | FK to City, nullable, optional at creation — see `17-regional-location.md` |
| blocked_user_ids | array\<uuid\> | FK to User, owner-only — a blocked user is removed from `GroupMembership` and cannot rejoin (checked before every join attempt); does not affect their visibility elsewhere in the app (posts, profile, chat) |

### GroupMembership
| Field | Type | Notes |
|---|---|---|
| group_id | uuid | FK |
| user_id | uuid | FK |
| joined_at | datetime | |

### Group Post (type_data for type=group_post)
| Field | Type | Notes |
|---|---|---|
| group_id | uuid | FK |

### PostLike
A simple like on any `Post` row — top-level post **or** comment, since a comment is just a `Post` with `type=comment` (this single entity replaces what used to be documented as two separate relations, `PostLike` and `CommentLike`). Backs both the drawer's "Liked" screen (`12-top-app-shell-and-menu.md`, which only ever queries `type != comment` rows) and the comment like toggle (`09-community-post.md`). Prevents a user from liking the same row twice.
| Field | Type | Notes |
|---|---|---|
| post_id | uuid | FK to Post — the row being liked, top-level post or comment |
| user_id | uuid | FK |
| created_at | datetime | |

### Report
Backs both the drawer's general "Report a problem" form (`12-top-app-shell-and-menu.md`) and the per-post "Report post" action on any post's three-dot menu (`05-home-feed.md`) — same entity, `post_id` is null for the former and set for the latter.
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | FK, reporter |
| post_id | uuid | FK, nullable — set when reported from a post's three-dot menu, null for the general "Report a problem" drawer form |
| category | enum | bug / content / spam / harassment / account / other — spam/harassment are post-report-specific reasons, bug/account are general-report-specific |
| description | text | optional when `post_id` is set (post reports are reason-only in MVP, no free-text field), required for the general form |
| created_at | datetime | |

### Tag
Not a separate table backing `Post.tags` (those stay freeform strings on the post) — this entity exists only to back the **follow** relationship and its derived counts, see `13-tags-and-topic-discovery.md`. `name` is the same string that appears in `Post.tags`; there's no admin-curated tag list in MVP, a tag row is implicitly "created" the first time someone follows or a post uses that string.
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| name | string | unique, e.g. "MTB" — matched case-insensitively against `Post.tags` |

### TagFollow
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | FK to User |
| tag_name | string | matched against `Tag.name` / `Post.tags`, not a hard FK (avoids a migration step to backfill `Tag` rows for every string already in use) |
| created_at | datetime | |

- Surfaced in the drawer's Topics list (`12-top-app-shell-and-menu.md`) and drives the follow/unfollow toggle + follower count on Topic Detail (`13-tags-and-topic-discovery.md`).
- **Follower count** on Topic Detail = `count(TagFollow where tag_name = :tag)`.
- **"N new" badge** next to a followed topic in the drawer = `count(Post where :tag in tags and created_at >= now - 3 days)` — a fixed 3-day rolling window in MVP, not a per-user `last_viewed_at` watermark (no such field exists yet; don't add one without a doc update first).

### Notification
Backs the inbox's Notifications tab (`14-inbox-notifications-and-chat.md`). One row per event; `post_id`/`group_id` are mutually exclusive depending on what triggered it.
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_id | uuid | FK to User — the recipient |
| title | string | e.g. "New comment on your post" |
| body | string | short preview text |
| post_id | uuid | FK to Post, nullable — set when the notification refers to a post (a comment reply, a like, a mention) |
| group_id | uuid | FK to Group, nullable — set when the notification refers to a group event (e.g. a new member) |
| read_at | datetime | nullable — null means unread; the inbox icon's red dot reflects `exists(Notification where user_id = me and read_at is null)` OR unread chat activity |
| created_at | datetime | |

- `@mention` notifications are a planned consumer of this table (`mentioned_user_ids` on a comment, see Post above) but are **not wired up yet** — mentions don't currently create a Notification row.

### ChatThread
A DM-style conversation between exactly two users, keyed by the participant pair — not per-listing (a listing can be *mentioned* inside a thread, see ChatMessage below, but doesn't own it). See `14-inbox-notifications-and-chat.md`, `07-marketplace.md` ("Chat Seller" CTA).
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| user_one_id | uuid | FK to User — unordered pair with `user_two_id`; enforce one row per unordered pair at the DB level |
| user_two_id | uuid | FK to User |
| created_at | datetime | |

### ChatThreadRead
Tracks each participant's read position in a thread, so unread state can be computed per user without mutating every message row. One row per `(thread_id, user_id)`.
| Field | Type | Notes |
|---|---|---|
| thread_id | uuid | FK to ChatThread |
| user_id | uuid | FK to User |
| last_read_at | datetime | a thread is unread for a user when `ChatMessage.created_at > last_read_at` for any message not sent by them |

### ChatMessage
| Field | Type | Notes |
|---|---|---|
| id | uuid | |
| thread_id | uuid | FK to ChatThread |
| sender_id | uuid | FK to User |
| type | enum | `text` / `product` — a `product` message is an auto-inserted listing mention (sent when a thread is opened via "Chat Seller"), see `useChatStore`'s `sendProductMention` |
| body | text | message text; may be blank if `media_urls` is non-empty (photo-only message) |
| media_urls | array\<string\> | 0–4 photos attached to the message, same shared `PhotoPicker` component as post/comment creation; empty for `type=product` |
| listing_id | uuid | FK to Post, nullable — set only for `type=product`, the listing being referenced |
| created_at | datetime | |

## Activity Points (for rank calculation)
| Action | Points |
|---|---|
| Post a listing | +2 |
| Create a community post | +2 |
| Comment on a post | +3 |
| Comment receives a like | +1 (per like) |
| Join or create a group | +1 |

## Rank Tiers
| Tier | Points range |
|---|---|
| Cub | 0–19 |
| Scout | 20–49 |
| Rider | 50–149 |
| Alpha | 150–349 |
| Pedal Monster | 350+ |

## Data Access Pattern (Supabase — no custom REST API)
No backend server — the frontend calls Supabase directly via `supabase-js`, gated by Row Level Security (policy design in `19-supabase-only-backend-plan.md`). Since a comment is just a `Post` row (`type=comment`, `parent_id` set), "comments" below are just `posts` queries filtered/scoped accordingly, not a separate table.

**Plain table queries** (`supabase.from(table)...`, RLS-gated):
- Feed: `posts` select where `type != 'comment'`, ordered by `created_at desc`
- Post detail + its comments: `posts` select by `id`, plus a second `posts` select where `parent_id = :id`
- Create/edit/delete a post or comment: `posts` insert/update/delete — RLS enforces `user_id = auth.uid()` for update/delete
- Listings browse: `posts` select where `type = 'listing'`, with `.eq()`/`.gte()`/`.lte()` filters for category/condition/price/location
- Likes: `post_likes` insert/delete — unique constraint on `(post_id, user_id)` prevents double-like; `like_count` maintained by a trigger, not the client
- Groups: `groups` select/insert/update/delete; `group_memberships` insert/delete for join/leave (owner block goes through the `group-join`-adjacent moderation flow, see below)
- Profile: `profiles` select by `id`; update — RLS restricts to `id = auth.uid()` and excludes `email`/password (those go through Supabase Auth directly, see below)
- Cities: `cities` select — read-only reference table, powers the location picker (`17-regional-location.md`)
- Reports: `reports` insert only — no read access from the client
- Tags: `tag_follows` insert/delete for follow/unfollow; `tag_follows`/`posts` select-with-count queries for follower count and the topic detail post list; `tag_follows` select where `user_id = auth.uid()` for the drawer's Topics list
- Notifications: `notifications` select/update (mark-read) where `user_id = auth.uid()` — inserts only ever come from triggers/Edge Functions, never the client

**Edge Function calls** (`supabase.functions.invoke(name, { body })`) — used where the logic needs to touch more than RLS/a single insert can express, see `19-supabase-only-backend-plan.md` for why each one exists:
- `chat-send-message` — finds-or-creates the thread for `(auth.uid(), other_user_id)`, then inserts the message; body may omit `body` if `media_urls` is non-empty
- `group-join` — joins a group, silently no-oping (not erroring) if the current user is blocked
- `submit-report` — validates the description-required-unless-post_id rule before inserting a report (may end up as a plain `CHECK` constraint instead — see the open note in `19-supabase-only-backend-plan.md`)

**Auth.** Registration, login, logout, session refresh, and password reset are all handled by **Supabase Auth**'s client SDK directly from the frontend — there is nothing else to call for these.

**Storage.** `supabase.storage.from('media').upload(...)` directly from the browser for post/comment/chat photos and avatars — no upload proxy. Public URL is `{SUPABASE_URL}/storage/v1/object/public/media/{path}`, not the S3-gateway path (see the confirmed gotcha in `19-supabase-only-backend-plan.md`).
