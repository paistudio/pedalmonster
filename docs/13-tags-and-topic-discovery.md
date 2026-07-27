# Tags / Topics Discovery & Follow Flow

## Goal
Allow users to tap tags or topics from posts and follow them, then view a dedicated topic detail screen.

## Required Feature
- Tags or topics should be tappable from posts and other content cards
- Tapping a tag should open a tag/topic detail screen
- The detail screen should show:
  - tag or topic name
  - short description or context
  - follower count
  - follow / unfollow action
  - a list of related posts filtered to that tag

## Interaction Rules
- The follow state should toggle instantly in the UI
- The follow state should be visually clear with a primary CTA and a secondary unfollow state
- The tag detail screen should be reachable from the feed and other relevant content surfaces
- Followed tags should be surfaced in the left drawer menu for quick access

## UX Notes
- Use the same tag pill style already used in the feed or a compact chip style
- Keep the detail screen focused on one topic and its related content only
- Make the follow CTA sticky or easy to reach near the top of the screen
- Topic detail header: back icon (left) · "Topic: #tagname" title, same font size for both parts (center) · follow/unfollow icon only, no text label (right) — no border-bottom on the header, no hairline border on either icon button, matching the global header treatment in `12-top-app-shell-and-menu.md`

## Acceptance Criteria
- Tapping a tag navigates to a dedicated detail screen
- Users can follow and unfollow a tag from that screen
- Followed topics appear in the drawer menu
- The experience works with mock data in Phase 1

## Best-Practice Decisions
- Use a single reusable tag chip component so the same interaction works in feed cards, post detail views, and topic detail screens
- For MVP, keep follow state local in mock state and do not introduce a full backend relationship model yet
- If the topic has no dedicated description, show a short fallback copy and a “Recent posts” section instead of a blank state
