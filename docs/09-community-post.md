# Feature: Community Post

## Purpose
Users share a post with the community — a question, a maintenance tip, a trip recap, general bike talk, anything. This used to be framed strictly as "ask a question and get answers"; it's now a regular post type so a user who just wants to post something doesn't have to force it into question shape. Other members reply with comments; there's no requirement that a post be phrased as a question or that a comment "answer" it.

Commenting itself is no longer specific to this post type — see `05-home-feed.md`'s "Comments & Mentions" section. The Interaction rules below (one like per user per comment, chronological ordering, no pinned/best-comment) apply to comments on any post type; this doc is kept as the canonical spec for comment behavior since community posts are the most comment-centric type.

## Screens

### Community Browse (accessed via feed filter chip, not a separate bottom-nav tab)
- List of community post cards (reuse base PostCard, filtered to type=community_post)
- Sort: newest / most commented
- No tags/category system in MVP — keep it a flat, chronological list

### Post Detail
- Description (body text), optional photo — there is no title field, see `06-post-creation-flow.md`
- Poster info: avatar, username, rank badge
- List of comments below, sorted oldest-first (chronological, matches a normal conversation thread)
- Each comment shows: commenter avatar/username/rank badge, comment text (with any `@mention` tokens highlighted), a simple like (heart) toggle + count
- "Comment" input at bottom of screen, with `@mention` autocomplete — see `05-home-feed.md`

## Interaction
- Any member can comment
- Any member can like a comment (one like per user per comment — prevent duplicate likes); this replaces the old per-answer upvote/ranking mechanic — comments are not re-sorted by like count
- Commenters can `@mention` another user in their comment text; the mention is stored and highlighted but does not yet trigger a notification (see `05-home-feed.md`)
- No "pinned" or "best comment" marking in MVP — that's a nice-to-have for later

## Mobile Layout Notes
- Post detail: comment input should be a sticky bottom text field (like a comment box), not buried at the bottom of a long scroll
- Collapse very long comment threads if needed (e.g. "show more comments") to keep initial load light

## Explicitly NOT in MVP
- Tags/categories
- Reputation/badges beyond the existing rank system
- Pinned/best-comment marking
- Comment ranking by like count (comments stay chronological)
