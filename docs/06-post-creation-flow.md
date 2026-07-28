# Post Creation Flow

Shared entry point for creating any of the 3 post types, triggered by the "+" slot in the bottom nav.

## Flow
1. Tap "+" → the nav pill morphs into a menu with 3 options: **Sell / Post / Group Post** (see `04-navigation-mobile-shell.md`)
2. User selects a type → routes to a type-specific creation form
3. Form fields vary by type (see below) but share common UI patterns: photo upload step, text fields, submit
4. On submit → new post appears at top of Home feed, user gains activity points per `02-data-model.md`

## Form Fields by Type

### Sell (Listing)
- Photos (1–5, camera or gallery picker)
- Title
- Category (bike / part — with sub-category if part)
- Condition (new / used)
- Price
- Location — set via the shared location picker (city search + optional "Use my location" GPS button), not free text, see `17-regional-location.md`
- Description

### Post (Community)
- Description — the post body, free-form text; this is the only required field, and there is no title field. A user can ask a question here, but doesn't have to — a plain update or tip posts the same way
- Optional photo (useful for troubleshooting-style posts)

### Group Post
- Requires selecting which group to post in (only groups user is a member of) — the only field that differs from Post (Community)
- Otherwise identical to Post (Community): same description field/placeholder, no title field, optional photo. (Fixed a drift from this spec where the form had grown its own required Title field and a different placeholder — removed to match.)

## Mobile UX Notes
- Use bottom sheet for the type picker, full-screen step-by-step form (not a single long scroll) for the actual creation form — keeps it feeling lightweight on mobile
- Camera-first photo picker (open camera as default option, gallery as secondary) — do not build a desktop-style file browser UI
- Show a simple progress indicator if the form has multiple steps
- Validate required fields before allowing submit; keep error messages inline and short
