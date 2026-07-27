# Brand & Style Guide

> **Superseded by `design.md`** (repo root) as of 2026-07-24. The palette/typography below (warm off-white + brown, rugged/earthy tone) is no longer in effect — `design.md`'s near-black canvas + white-pill system is now the single source of truth for all visual decisions. Kept here for history only; see `CLAUDE.md` for the current rule.

## Color Palette
- **Primary:** White / warm off-white (base/canvas) — e.g. `#FAF7F2`
- **Brand anchor:** Brown — e.g. `#5C3A21` (dark leather brown) for headers, nav, key brand moments
- **Secondary accent (for CTAs, avoid overusing brown on buttons):** Rust-orange or olive — e.g. `#B5551D` or `#6B7A4F`
- **Text:** Near-black/dark brown for body text (avoid pure `#000` — softer, warmer black e.g. `#2B211A`)
- **Semantic colors:** Standard success/error/warning greens/reds, kept desaturated to not clash with the earthy palette

> Note: exact hex values are placeholders — finalize during prototype phase with real visual comps, not guessed in isolation.

## Typography
- Suggest one strong display/headline font with character (not a generic system font) for headers/logo, paired with a clean, highly legible sans-serif for body text and UI labels.
- Avoid anything overly playful/rounded — brand feel is rugged/earthy, not cute.

## Tone & Visual Feel
- Rugged, warm, community-first — like a well-used bike garage, not a corporate marketplace
- Photography-forward: bike/part photos should be the visual hero on every card, brand color frames but doesn't compete
- Avoid generic "AI-generated" gradient/glassmorphism aesthetics — favor solid colors, real photography, simple iconography

## Component Principles (for Vue prototype)
- **Base "Post Card" component** — single shared shell used by all 3 post types (listing, question, group post), with a type-based badge/icon and type-specific footer. Build this as ONE component with variants, not separate card components per type.
- **Bottom sheets, not modals** — for post creation, filters, chat — mobile-native feel
- **No hover states required** — mobile-first, tap/press states only
- **Rank badges** — small, consistent badge component used next to username across posts, comments, chat, and profile

## Iconography
- Simple line icons for post-type badges (🏷️ Market, 💬 Community, 👥 Group) — replace emoji placeholders with a proper icon set during prototype build
- **Icon library: Iconoir** (superseded from an earlier Lucide/Feather placeholder — see `design.md`'s "Icon Library — Iconoir" section, the authoritative reference for setup and usage)
