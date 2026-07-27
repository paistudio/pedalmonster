# Feature: Marketplace

## Purpose
Users sell bikes and bike parts to other community members.

## Screens

### Market Browse (dedicated tab)
- **2-column grid** of compact listing tiles (reuse base PostCard's `layout="grid"` variant, filtered to type=listing) — see `design.md`'s "Market Browse is a 2-column grid, not seamless rows" exception. Each tile: square cover thumbnail (first photo only, no swipe gallery in-tile), a like button overlaid top-right, a "Sold" chip overlaid top-left when applicable, and below the image — title, price, then location (map-pin icon + city). Title reads as the dominant line via size (14px) and full `{colors.ink}` color, not font-weight — price is `{colors.body}`, location is `{colors.body-mid}` at 11px; all three stay at weight 400 per design.md's "never bolds" rule. Tapping anywhere on the tile — thumbnail included — opens Listing Detail; there is no separate lightbox at this level.
- Search and filter live in the **global top app bar** while on this screen (see `12-top-app-shell-and-menu.md`) — not a page-level bar: center slot is a live search input, right slot is a filter icon that opens the filter/sort bottom sheet (category, price range, condition, location, sort by newest/price/nearest)
- Location filter is the shared location picker (exact city match), not free text; sort options gain "Nearest first" (distance from the viewer's resolved location, ascending — only meaningful once a location is set) — see `17-regional-location.md`

### Listing Detail
- Full photo gallery (swipeable) with a thumbnail strip beneath it when the listing has more than one photo — tapping any thumbnail opens the same fullscreen image preview the main gallery already uses (scrolled to that photo), rather than a separate viewer
- Title, price, condition, category, description, location — shows "X km away" next to location when the viewer has a resolved location too, see `17-regional-location.md`
- Seller info: avatar, username, rank badge, "member since" — tapping this card opens the seller's Public User Profile (`03-auth-user-profile.md`), same as tapping any other user's avatar/username elsewhere in the app
- Primary CTA: "Chat Seller" → opens the in-app chat thread with the seller. Styled as the floating grey-glass pill shared with the bottom nav bar (`design.md`'s `nav-bar-blur` material), not the solid white `button-primary` fill used elsewhere — same treatment applies to "Mark as Sold" below.
- Comments: listings can be commented on like any other post type (public Q&A on the item — "does this still have the original box?" etc.), separate from the private "Chat Seller" thread. Same universal comment icon/count and composer as the feed card, see `05-home-feed.md`.

### Chat (User ↔ User)
- **The chat room is keyed by the other user, not by listing.** Two people have exactly one running conversation regardless of how many different listings they discuss across it — there is no separate thread per listing. Route is `/chat/:userId`; the header shows the other user's avatar + username like a normal DM, not a product.
- Basic text messages, optional photo share
- No group chat needed here — 1:1 only
- **Product mention**: tapping "Chat Seller" from a listing opens that seller's thread and attaches a product-card message (thumbnail, title, price, tappable to jump back to Listing Detail) at the point it was tapped — not just once ever, but every time, so re-visiting the same seller about a *different* listing drops a fresh card into the same ongoing conversation. Tapping "Chat Seller" again for the *same* listing while it's already the most recent message in the thread does not duplicate the card.
- A thread can also be started with **no** listing attached at all, from a user's Public User Profile "Chat" button (`03-auth-user-profile.md`) — a plain conversation with nothing to mention.

## States
- **Available** — default, shows in feed/browse
- **Sold** — seller can mark as sold; sold listings show a "Sold" overlay/badge, filtered out of default browse but still viewable via profile/history

## Mobile Layout Notes
- Listing detail: sticky bottom CTA bar with "Chat Seller" always visible while scrolling description
- Browse page: the filter icon in the top app bar opens a bottom sheet (not inline dropdowns) to save vertical space on mobile; the icon itself is `iconoir:filter` (the funnel glyph) — not `iconoir:control-slider`, which reads as an ambiguous hook shape at 20px
- Browse page has no separate in-page header row — search and filter are the top app bar itself while on this screen (see `12-top-app-shell-and-menu.md`), so the 2-column grid starts right below it

## Explicitly NOT in MVP
- Rekber/escrow in any form — the feature was cut from the product entirely (not deferred); no badge, toggle, or field for it anywhere, listing or data model
- Boosted/featured listings
- Price offer/negotiation feature
