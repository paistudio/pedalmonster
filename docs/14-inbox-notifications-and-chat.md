# Inbox: Notifications & Chat

## Goal
Create an inbox experience that combines notifications and chat threads in one place, with unread state reflected in the top-right inbox icon.

## Required Feature
- The inbox is opened from the top-right inbox icon
- The inbox view has two tabs:
  - Notifications
  - Chat
- Each tab should show a list of items with empty state handling
- Any new notification or chat should trigger a red unread dot on the inbox icon

## Interaction Rules
- The inbox icon should show a red dot whenever there is unread notification or chat activity
- Tapping a notification item marks it read and opens the entity it refers to — the source post (listing/community post/group post) or the group, matching whatever triggered the notification
- Tapping a chat item marks it read and opens the thread with that user (`/chat/:userId`) — chat rooms are keyed by the other participant, not by listing (`07-marketplace.md`), so a chat row's avatar/username is that user, not a product. There is no group-chat destination.
- The active tab should be visually clear and easy to switch

## Mobile Layout Notes
- The inbox is a **full-width** sheet (same edge-to-edge pattern as the left burger drawer), not a partial-width panel sliding in from the right
- Header has no bottom border — title and close button sit directly above the tab switcher with no divider line
- Close button is the same `iconoir:xmark` "×" icon as the left drawer's close button (not a right-pointing arrow), for a consistent close affordance between the two full-screen overlays

## UX Notes
- Use a simple tab switcher at the top of the inbox view
- Notification rows should be concise and scannable
- Chat rows show the other user's avatar (not a generic chat-bubble icon) and username as the row title, plus last message preview text and activity time — same DM-list convention as any messaging app
- Keep the experience fast and lightweight for the MVP

## Chat Thread Composer
- The chat thread composer supports attaching **up to 4 photos** per message (reuses the shared `PhotoPicker`, same component as post/listing creation and the comment composer); a message can be photos-only with no text.
- Photo messages render as image thumbnails in the bubble stream, left/right-aligned by sender the same way text bubbles are; a photo-only message drops the bubble background/border so the image isn't boxed twice.

## Acceptance Criteria
- Inbox opens from the top app bar
- Users can switch between Notifications and Chat
- The inbox icon shows a red dot for unread state
- Both tabs work with mock data in Phase 1

## Best-Practice Decisions
- Keep the inbox as a single screen with two tabs rather than splitting it into separate routes for MVP
- Use a simple unread count state instead of complex notification categories at first
- If there is no unread activity, the inbox icon should return to its neutral state with no dot
