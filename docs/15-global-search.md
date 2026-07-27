# Global Search Across All Post Types

## Goal
Add a global search experience that searches across marketplace posts, community posts, and groups from one entry point.

## Required Feature
- Users can search from a dedicated search entry point
- Search results should come from multiple post types in one unified result list
- Results should route to the relevant detail screen for each item type

## Interaction Rules
- Search should start as soon as the user types, or after a short debounce for smoother UX
- Results should be grouped by content type or shown in a unified list with clear type labels
- Empty search state and no-results state should be handled clearly
- Search should support post title, description/body, and relevant tag terms — community posts have no title (see `06-post-creation-flow.md`), so their match is body + tags only

## UX Notes
- Keep the search experience mobile-first and fast
- Each result row should show enough context to distinguish its type quickly
- The search entry point lives at the top of the left drawer menu (one tap from the burger icon, above Followed Topics) — see `12-top-app-shell-and-menu.md`
- Search is inline within the drawer, not a separate screen: typing swaps the drawer body to the result list in place; there is no intermediate navigation away from the drawer

## Acceptance Criteria
- A search screen or search sheet is reachable from the app shell
- Searching returns mixed results from multiple content types
- Tapping a result opens the relevant detail view
- The experience works with existing mock data in Phase 1

## Best-Practice Decisions
- Search entry placement: top of the left drawer menu, above Followed Topics (supersedes the earlier Home-screen placement)
- Keep results unified but clearly labeled by type for fast scanning
- For MVP, search should cover title, tags, and a short excerpt rather than implementing advanced ranking
