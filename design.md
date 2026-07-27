---
version: alpha
name: xAI-design-analysis
description: An inspired interpretation of xAI's design language — Elon Musk's frontier-AI company whose web surface is a strict near-black canvas broken only by white pill outlines, occasional warm sunset / dusk gradient accents, a custom geometric sans (Universal Sans) for display, and an uppercase tracked monospace caption face; the whole system reads as engineered-cosmic, unmarketed.

colors:
  primary: "#ffffff"
  on-primary: "#0a0a0a"
  ink: "#ffffff"
  ink-hover: "#fafaf7"
  body: "#dadbdf"
  body-mid: "#7d8187"
  mute: "#7d8187"
  hairline: "#212327"
  canvas: "#0a0a0a"
  canvas-soft: "#1a1c20"
  canvas-card: "#191919"
  canvas-mid: "#363a3f"
  accent-sunset: "#ff7a17"
  accent-sunset-soft: "#ffc285"
  accent-dusk: "#7c3aed"
  accent-twilight: "#c4b5fd"
  accent-breeze: "#a0c3ec"
  accent-midnight: "#0d1726"

typography:
  display-xl:
    fontFamily: universalSans, Inter, system-ui, -apple-system, sans-serif
    fontSize: 96px
    fontWeight: 400
    lineHeight: 96px
    letterSpacing: -2.4px
  display-lg:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 72px
    fontWeight: 400
    lineHeight: 72px
    letterSpacing: -1.8px
  display-md:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 48px
    fontWeight: 400
    lineHeight: 48px
    letterSpacing: -1.2px
  display-sm:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 32px
    fontWeight: 400
    lineHeight: 36px
    letterSpacing: -0.6px
  display-xs:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 20px
    fontWeight: 400
    lineHeight: 28px
  body-lg:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 18px
    fontWeight: 400
    lineHeight: 28px
  body-md:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 16px
    fontWeight: 400
    lineHeight: 24px
  body-sm:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
  caption-mono:
    fontFamily: GeistMono, ui-monospace, SFMono-Regular, Menlo, Monaco, monospace
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 1.4px
  caption-mono-sm:
    fontFamily: GeistMono, ui-monospace, SFMono-Regular, Menlo, monospace
    fontSize: 12px
    fontWeight: 400
    lineHeight: 16px
    letterSpacing: 1.2px
  button-md:
    fontFamily: universalSans, Inter, system-ui, sans-serif
    fontSize: 14px
    fontWeight: 400
    lineHeight: 20px

rounded:
  none: 0px
  sm: 8px
  pill: 9999px
  full: 9999px

spacing:
  xxs: 2px
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 24px
  2xl: 32px
  3xl: 48px
  4xl: 64px

components:
  nav-bar:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
    padding: "{spacing.md} {spacing.xl}"
  nav-link:
    textColor: "{colors.ink}"
    typography: "{typography.body-sm}"
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    borderColor: "{colors.primary}"
    typography: "{typography.button-md}"
    rounded: "{rounded.pill}"
    padding: "{spacing.xs} {spacing.md}"
  button-outline-on-dark:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.button-md}"
    rounded: "{rounded.pill}"
    padding: "{spacing.sm} {spacing.lg}"
  button-outline-sm:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.button-md}"
    rounded: "{rounded.pill}"
    padding: "{spacing.xs} {spacing.md}"
  text-input:
    backgroundColor: "{colors.canvas-soft}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md} {spacing.lg}"
  card-content:
    backgroundColor: "{colors.canvas-card}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  card-feature-product:
    backgroundColor: "{colors.canvas-card}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    typography: "{typography.body-md}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  hero-band:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.display-xl}"
    padding: "{spacing.4xl} {spacing.xl}"
  content-band:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.ink}"
    typography: "{typography.display-md}"
    padding: "{spacing.4xl} {spacing.xl}"
  eyebrow-mono:
    textColor: "{colors.ink}"
    typography: "{typography.caption-mono}"
  divider-hairline:
    borderColor: "{colors.hairline}"
  footer:
    backgroundColor: "{colors.canvas}"
    textColor: "{colors.body}"
    typography: "{typography.body-sm}"
    padding: "{spacing.3xl} {spacing.xl}"

  # ─── Pedal Monster product adaptations (mobile app, not on the marketing surface) ───
  tab-bar:
    description: "In-page view-switching tabs (e.g. Profile's My Posts/My Groups, Inbox's Notifications/Chat). Underline style, not pills — plain text labels in a row on a hairline base border; the active tab is ink-colored with a 2px white underline indicator, inactive tabs are body-mid. Distinct from option-chip, which remains pill-shaped and is reserved for filter/form choice selectors (category, condition, sort) rather than page-level navigation."
    borderColor: "{colors.hairline}"
    textColor: "{colors.body-mid}"
    activeTextColor: "{colors.ink}"
    activeIndicator: "{colors.primary}"
    rounded: "{rounded.none}"
  nav-bar-blur:
    description: "Bottom tab bar for the mobile app shell — a floating rounded pill (16px margin from the screen edges, not full-bleed), grey glass (translucent mid-grey + backdrop blur), sitting above the feed content. Same dark-canvas-only treatment as the rest of the app (no longer a light-mode exception). The create ('+') slot is a plain flat icon like the other four (Home, Market, [+], Groups, Profile) — not a separate solid circular button."
    backgroundColor: "rgba(54, 58, 63, 0.72)"
    backdropFilter: "blur(20px)"
    borderColor: "rgba(255, 255, 255, 0.14)"
    rounded: "{rounded.pill}"
    textColor: "rgba(255, 255, 255, 0.5)"
    activeTextColor: "#ffffff"
    createButton: "plain flat icon in the bar, same treatment as the other four slots"
  feed-post-row:
    description: "A single post in the unified feed / marketplace list. Seamless — no card fill, no border-radius, no box. Rows are separated only by a hairline bottom border; the last row in a list has none."
    backgroundColor: "transparent"
    borderColor: "{colors.hairline}"
    rounded: "{rounded.none}"
    padding: "{spacing.lg} 0"
  feed-image-bleed:
    description: "Post media inside a feed-post-row bleeds full-bleed to the screen edge (negative-margined out of the row's horizontal padding), breaking out of the text column. Tapping opens photo-lightbox."
    marginInline: "calc({spacing.lg} * -1)"
  photo-lightbox:
    description: "Fullscreen photo viewer opened by tapping any post image. Near-opaque canvas overlay, swipeable if multiple photos, dot indicator, single close affordance top-right."
    backgroundColor: "rgba(10, 10, 10, 0.95)"
    closeButton: "circular, hairline border, canvas-card translucent fill — same idiom as button-outline-on-dark"

  # ─── Examples (illustrative) — auto-derived; resolve any TO_FILL markers below ───
  ex-pricing-tier:
    description: "Default Pricing tier card. Re-uses feature-card chrome with brand canvas-soft surface."
    backgroundColor: "{colors.canvas-soft}"
    textColor: "{colors.ink}"
    borderColor: "{colors.hairline}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  ex-pricing-tier-featured:
    description: "Featured/highlighted tier — polarity-flipped surface (dark fill + light text in light mode, light fill + dark text in dark mode)."
    backgroundColor: "{colors.ink}"
    textColor: "{colors.on-primary}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  ex-product-selector:
    description: "What's Included summary card — re-purposed for SaaS / B2B verticals (NOT a literal product gallery)."
    backgroundColor: "{colors.canvas-soft}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  ex-cart-drawer:
    description: "Subscription summary — re-purposed for SaaS / B2B (line items per add-on, not literal cart)."
    backgroundColor: "{colors.canvas}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
    item-divider: "{colors.hairline}"
  ex-app-shell-row:
    description: "Sidebar nav row inside the App Shell example. Active state uses brand primary as the indicator."
    backgroundColor: "{colors.canvas}"
    activeIndicator: "{colors.primary}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md} {spacing.lg}"
  ex-data-table-cell:
    description: "Default data-table th + td chrome. Header uses mono-caps eyebrow typography; body uses body-sm."
    headerBackground: "{colors.canvas-soft}"
    headerTypography: "{typography.caption-mono}"
    bodyTypography: "{typography.body-sm}"
    cellPadding: "{spacing.md} {spacing.lg}"
    rowBorder: "{colors.hairline}"
  ex-auth-form-card:
    description: "Sign-in / sign-up card. Re-uses feature-card chrome with text-input primitives inside."
    backgroundColor: "{colors.canvas-soft}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  ex-modal-card:
    description: "Modal dialog surface — same chrome as feature-card with elevated shadow."
    backgroundColor: "{colors.canvas}"
    rounded: "{rounded.sm}"
    padding: "{spacing.xl}"
  ex-empty-state-card:
    description: "Empty-state illustration frame."
    backgroundColor: "{colors.canvas-soft}"
    rounded: "{rounded.sm}"
    padding: "{spacing.3xl}"
    captionTypography: "{typography.body-md}"
  ex-toast:
    description: "Toast notification surface — feature-card shape + medium shadow."
    backgroundColor: "{colors.canvas}"
    rounded: "{rounded.sm}"
    padding: "{spacing.md} {spacing.lg}"
    typography: "{typography.body-sm}"

---


## Overview

xAI is Elon Musk's frontier-AI lab and the website wears that posture with engineered restraint: a near-black canvas `{colors.canvas}` (`#0a0a0a`) edge-to-edge, white outline pills as every interactive element, and a single proprietary geometric sans `Universal Sans` carrying every display headline at weight 400. There is no gradient hero, no atmospheric backdrop, no product screenshot. The brand reads as confidently sparse — a research lab announcing its work rather than a SaaS marketing site.

Type is the second decisive voice. `Universal Sans` carries every display at weight 400 (regular) with aggressive negative tracking (`-2.4 px` at 96 px, scaling down through the display ladder). For technical labels, eyebrows, and metric counters, the brand pairs `Geist Mono` (uppercase, 1.4 px positive tracking) — every section eyebrow reads as a code comment more than a marketing label.

Every interactive element is a pill (`{rounded.pill}` 9999 px) with 1 px white-translucent border `rgba(255, 255, 255, 0.25)`. The button shape never varies — the same translucent-white pill carries "Try Grok", "Read announcement", "Custom Voices", "Sign up now", and every "Read" anchor. The pill is the entire shape system.

**Key Characteristics:**
- A single near-black canvas (`{colors.canvas}` `#0a0a0a`) with white outline pills as the entire interactive vocabulary.
- Universal Sans weight 400 for display, Geist Mono uppercase tracked for labels — the two-face contrast IS the brand voice.
- Every button is a `{rounded.pill}` outline with translucent-white border. The brand never uses filled CTAs except for one variant (white-filled pill on Sign Up).
- Cards are tight `{rounded.sm}` 8 px rectangles in a slightly-lighter `{colors.canvas-card}` (`#191919`) fill with hairline border. No shadows.
- A muted accent palette of sunset-orange / dusk-purple / twilight-violet / breeze-blue lives in the design tokens but appears rarely on the main marketing surface — reserved for product illustrations / icons.
- Massive negative letter-spacing on display headlines (`-2.4 px` at 96 px) gives the typography a precise, gathered look.

## Colors

### Brand & Accent
- **White** (`{colors.primary}` — `#ffffff`): The brand's primary "color" — used as button outline, button-primary fill, all display text. The brand's signature is white-on-near-black.
- **Sunset Orange** (`{colors.accent-sunset}` — `#ff7a17`): A warm orange used inside product illustrations and accent moments.
- **Sunset Soft** (`{colors.accent-sunset-soft}` — `#ffc285`): The lighter variant of the sunset accent.
- **Dusk Purple** (`{colors.accent-dusk}` — `#7c3aed`): Deep purple used inside product illustrations.
- **Twilight** (`{colors.accent-twilight}` — `#c4b5fd`): Soft violet — illustrative accent.
- **Breeze Blue** (`{colors.accent-breeze}` — `#a0c3ec`): Soft blue — illustrative accent.
- **Midnight** (`{colors.accent-midnight}` — `#0d1726`): Deep blue-black for illustrative backgrounds.

### Surface
- **Canvas** (`{colors.canvas}` — `#0a0a0a`): The default near-black page background. The brand's only true surface.
- **Canvas Soft** (`{colors.canvas-soft}` — `#1a1c20`): A slightly lighter dark fill used for hovered nav items and tooltips.
- **Canvas Card** (`{colors.canvas-card}` — `#191919`): The charcoal card fill used inside product-feature cards.
- **Canvas Mid** (`{colors.canvas-mid}` — `#363a3f`): A mid-dark used for nested surfaces and code mockup backgrounds.
- **Hairline** (`{colors.hairline}` — `#212327`): 1 px solid dividers on dark surfaces.

### Text
- **Ink** (`{colors.ink}` — `#ffffff`): Default text on canvas — pure white.
- **Ink Hover** (`{colors.ink-hover}` — `#fafaf7`): Slightly off-white used for hover states (filtered out per no-hover policy in component specs).
- **Body** (`{colors.body}` — `#dadbdf`): Secondary body text — supporting copy in lighter weight.
- **Body Mid / Mute** (`{colors.body-mid}` — `#7d8187`): Mid-emphasis body and mute text — captions, fine print.

### Semantic
The brand doesn't surface a separate semantic palette on the marketing site. Validation cues use the white-on-canvas hierarchy.

## Typography

### Font Family
Two faces ladder the system:
1. **universalSans** — proprietary geometric sans used for every display, body, button, and link role. Weight 400 only on the marketing surface (the brand's restraint is part of the voice). Negative letter-spacing at display sizes is the visual signature.
2. **GeistMono** — used for uppercase section eyebrows, label captions, and metric counters. Positive tracking (1.2 – 1.4 px) at 12 – 14 px.

### Hierarchy

| Token | Size | Weight | Line Height | Letter Spacing | Use |
|---|---|---|---|---|---|
| `{typography.display-xl}` | 96px | 400 | 96px | -2.4px | Maximum hero scale. |
| `{typography.display-lg}` | 72px | 400 | 72px | -1.8px | Sub-hero displays. |
| `{typography.display-md}` | 48px | 400 | 48px | -1.2px | Section headlines. |
| `{typography.display-sm}` | 32px | 400 | 36px | -0.6px | Card-cluster headings. |
| `{typography.display-xs}` | 20px | 400 | 28px | 0 | Inline displays. |
| `{typography.body-lg}` | 18px | 400 | 28px | 0 | Lead paragraphs. |
| `{typography.body-md}` | 16px | 400 | 24px | 0 | Default body. |
| `{typography.body-sm}` | 14px | 400 | 20px | 0 | Secondary body. |
| `{typography.caption-mono}` | 14px | 400 | 20px | 1.4px | Section eyebrow (GeistMono uppercase). |
| `{typography.caption-mono-sm}` | 12px | 400 | 16px | 1.2px | Small mono labels. |
| `{typography.button-md}` | 14px | 400 | 20px | 0 | Button label. |

### Principles
- **Weight 400 for everything.** The brand never bolds. Negative tracking + size hierarchy do the emphasis work.
- **Tight negative tracking on display sizes.** Reverting to neutral tracking loses the precision feel.
- **GeistMono uppercase for eyebrows.** Tracked positively (1.4 px) to make the mono read as a code comment.

### Note on Font Substitutes
universalSans is proprietary. Open-source substitutes:
- **Display + body** — *Inter* weight 400 with `-0.04em` to `-0.02em` letter-spacing at display sizes comes closest. *Geist* is the second-best option.
- **Mono** — *Geist Mono* is the documented brand companion; *JetBrains Mono* or *IBM Plex Mono* are alternates.

## Layout

### Spacing System
- **Base unit**: 4 px.
- **Tokens**: `{spacing.xxs}` 2 px · `{spacing.xs}` 4 px · `{spacing.sm}` 8 px · `{spacing.md}` 12 px · `{spacing.lg}` 16 px · `{spacing.xl}` 24 px · `{spacing.2xl}` 32 px · `{spacing.3xl}` 48 px · `{spacing.4xl}` 64 px.
- **Section padding**: hero / content bands at `{spacing.4xl}` 64 px on desktop.
- **Card interior padding**: `{spacing.xl}` 24 px.

### Grid & Container
- Marketing content centres at ~1200 px.
- Product / announcement card grid: 2-up at desktop, 1-up at mobile.

### Responsive Strategy

#### Breakpoints

| Name | Width | Key Changes |
|---|---|---|
| Mobile | < 768px | Hero scales 96 → 48 px; grids 1-up; hamburger nav. |
| Desktop | ≥ 768px | Full hero + 2-up grids. |

#### Touch Targets
Buttons render ~32 – 40 px tall (8 vertical padding + 20 line). Mobile inflates touch area to meet WCAG 44 × 44 px.

#### Image Behavior
The brand uses sparse SVG illustrations for product moments (Grok, Voice, API). No photography on the marketing surface.

## Elevation & Depth

| Level | Treatment | Use |
|---|---|---|
| Level 0 — Flat | No shadow, no border. | Default. |
| Level 1 — Hairline | 1 px solid `{colors.hairline}` border. | Card chrome, button outlines (with translucent white). |

The brand uses no shadows. Hairline borders carry all elevation cues.

## Shapes

### Border Radius Scale

| Token | Value | Use |
|---|---|---|
| `{rounded.none}` | 0px | Full-bleed bands. |
| `{rounded.sm}` | 8px | Card chrome (the brand's `--radius` value). |
| `{rounded.pill}` | 9999px | Every button — the brand's universal interactive shape. |
| `{rounded.full}` | 9999px | Circular icon containers. |

## Components

### Buttons

**`button-primary`** — the rare white-filled pill (used on a single Sign Up CTA).
- Background `{colors.primary}` white, text `{colors.on-primary}` near-black, 1 px solid white border, label `{typography.button-md}`, padding `{spacing.xs} {spacing.md}`, shape `{rounded.pill}` 9999 px.

**`button-outline-on-dark`** — the canonical white-outline pill, used for every non-primary CTA.
- Background `{colors.canvas}` (transparent in practice — `rgba(0,0,0,0)`), text `{colors.ink}` white, 1 px solid `{colors.hairline}` border (translucent white at runtime), same typography / padding scale / shape.

**`button-outline-sm`** — the smaller outline pill used in card-cluster CTAs.
- Same as `button-outline-on-dark` with tighter padding `{spacing.xs} {spacing.md}`.

### Cards & Containers

**`card-content`** — the default content card.
- Background `{colors.canvas-card}` (`#191919`), text `{colors.ink}`, 1 px solid `{colors.hairline}` border, padding `{spacing.xl}`, shape `{rounded.sm}` 8 px.

**`card-feature-product`** — the product-feature card (Grok / Voice / API).
- Same chrome as `card-content`. Hosts an SVG illustration + headline + body + outline pill CTA.

### Inputs & Forms

**`text-input`** — the standard text input on dark.
- Background `{colors.canvas-soft}`, text `{colors.ink}`, 1 px solid `{colors.hairline}`, body in `{typography.body-md}`, padding `{spacing.md} {spacing.lg}`, shape `{rounded.sm}` 8 px.

### Navigation

**`nav-bar`** — the sticky top nav.
- Background `{colors.canvas}`, text `{colors.ink}`, padding `{spacing.md} {spacing.xl}`.

**`nav-link`** — link items inside nav.
- Text `{colors.ink}`, set in `{typography.body-sm}`.

**`footer`** — the footer band.
- Background `{colors.canvas}`, text `{colors.body}`, padding `{spacing.3xl} {spacing.xl}`. Body in `{typography.body-sm}`.

### Signature Components

**`hero-band`** — the dark hero with massive display headline.
- Background `{colors.canvas}`, text `{colors.ink}`, padding `{spacing.4xl} {spacing.xl}`. Headline in `{typography.display-xl}` (96 px weight 400 with `-2.4 px` tracking).

**`content-band`** — the standard content section.
- Background `{colors.canvas}`, text `{colors.ink}`, padding `{spacing.4xl} {spacing.xl}`. Section headline in `{typography.display-md}` preceded by a `{typography.caption-mono}` UPPERCASE GeistMono eyebrow.

**`eyebrow-mono`** — the uppercase tracked GeistMono label above every section headline.
- Text `{colors.ink}`, set in `{typography.caption-mono}`. The brand's signature label style.

**`divider-hairline`** — the 1 px line between section bands.
- 1 px solid `{colors.hairline}`.

### Examples (illustrative)

> Auto-derived kit-mirror demonstration surfaces (`scripts/derive-examples-block.mjs`). Each `ex-*` entry references brand-native primitives so downstream consumers (`/preview-design`, `/generate-kit`) re-skin the same 10 surfaces consistently. `TO_FILL` markers indicate missing primitives — resolve in the LLM judgment pass.

**`ex-pricing-tier`** — Default Pricing tier card. Re-uses feature-card chrome with brand canvas-soft surface.
- Properties: `backgroundColor`, `textColor`, `borderColor`, `rounded`, `padding`

**`ex-pricing-tier-featured`** — Featured/highlighted tier — polarity-flipped surface (dark fill + light text in light mode, light fill + dark text in dark mode).
- Properties: `backgroundColor`, `textColor`, `rounded`, `padding`

**`ex-product-selector`** — What's Included summary card — re-purposed for SaaS / B2B verticals (NOT a literal product gallery).
- Properties: `backgroundColor`, `rounded`, `padding`

**`ex-cart-drawer`** — Subscription summary — re-purposed for SaaS / B2B (line items per add-on, not literal cart).
- Properties: `backgroundColor`, `rounded`, `padding`, `item-divider`

**`ex-app-shell-row`** — Sidebar nav row inside the App Shell example. Active state uses brand primary as the indicator.
- Properties: `backgroundColor`, `activeIndicator`, `rounded`, `padding`

**`ex-data-table-cell`** — Default data-table th + td chrome. Header uses mono-caps eyebrow typography; body uses body-sm.
- Properties: `headerBackground`, `headerTypography`, `bodyTypography`, `cellPadding`, `rowBorder`

**`ex-auth-form-card`** — Sign-in / sign-up card. Re-uses feature-card chrome with text-input primitives inside.
- Properties: `backgroundColor`, `rounded`, `padding`

**`ex-modal-card`** — Modal dialog surface — same chrome as feature-card with elevated shadow.
- Properties: `backgroundColor`, `rounded`, `padding`

**`ex-empty-state-card`** — Empty-state illustration frame.
- Properties: `backgroundColor`, `rounded`, `padding`, `captionTypography`

**`ex-toast`** — Toast notification surface — feature-card shape + medium shadow.
- Properties: `backgroundColor`, `rounded`, `padding`, `typography`


## Product Adaptations — Pedal Monster

The base system above is derived from xAI's marketing surface. The Pedal Monster mobile app is a product, not a marketing site, so a few patterns extend the system for actual UI density and interaction needs. These are additive, not overrides of the core tokens.

### Icon Library — Iconoir
All icons in the product use **[Iconoir](https://iconoir.com)** (MIT, ~1,700 icons), rendered via `@iconify/vue`'s `<Icon>` component backed by the offline `@iconify-json/iconoir` icon data (no network calls, no CDN dependency — bundled at build time).

- **Setup**: `addCollection(iconoirIcons)` is called once in `main.js` (importing `@iconify-json/iconoir/icons.json`), so every `<Icon icon="iconoir:xxx" />` anywhere in the app resolves offline.
- **Usage**: `<Icon icon="iconoir:home" width="20" height="20" />` — size via `width`/`height` props (not a `size` shorthand), color inherited from CSS `color` on the element or an ancestor (icons use `currentColor`).
- **Naming**: icon names are Iconoir's own kebab-case slugs (e.g. `iconoir:arrow-left`, `iconoir:nav-arrow-right` for chevrons — Iconoir has no `chevron-*` family, `nav-arrow-*` is the equivalent). When adding a new icon, check the exact slug at [iconoir.com](https://iconoir.com) or in `node_modules/@iconify-json/iconoir/icons.json` before using it — don't guess.
- **No other icon library** should be added to this project beyond the one documented exception below (no Lucide, no inline hand-drawn SVGs for anything Iconoir already covers). If a needed icon has no close Iconoir equivalent, ask before substituting or adding a one-off asset.
- **Icon buttons never have an outline/border, full stop.** This applies everywhere — header-row actions (back, more-menu, join/leave), overlay-dismiss actions (`{components.photo-lightbox}` close button, inbox/drawer close), and any future icon-only control. A translucent background fill is still fine where a glyph needs contrast against unpredictable photo content underneath it (the lightbox close chip, an avatar overlay), but that fill never gets a hairline stroke around it — same "hairline carries elevation, borders are earned" logic as everywhere else in the system, just resolved as "icon buttons don't earn one."

**Exception — bottom nav tab icons use Font Awesome Solid.** The four destination glyphs in `{components.nav-bar-blur}` (Home, Market, Groups, Profile) are rendered from **Font Awesome 6 Solid** (`fa6-solid:house`, `fa6-solid:store`, `fa6-solid:users`, `fa6-solid:circle-user`) instead of Iconoir, for a bolder/heavier glyph weight at that small tab size. Same `<Icon>` component and offline-bundling pattern as Iconoir — `addCollection(fa6SolidIcons)` in `main.js` importing `@iconify-json/fa6-solid/icons.json`, usage `<Icon icon="fa6-solid:house" width="20" height="20" />`. This is scoped to those 4 tab-bar destination icons only — the "+" create glyph in the same bar stays Iconoir (`iconoir:plus`), and every other icon in the product (headers, cards, forms, overlays) stays Iconoir. Don't extend Font Awesome to any other screen without an explicit decision to do so.

### Tabs Are Underlined, Not Pills
`{components.tab-bar}` — page-level view-switching tabs (e.g. Profile's My Posts/My Groups, Inbox's Notifications/Chat) use an underline style, not the pill treatment. The Home feed no longer uses a tab-bar filter (removed — see `docs/05-home-feed.md`). Plain text labels sit in a row on a shared hairline base border (`{colors.hairline}`); the active tab is `{colors.ink}` with a 2px `{colors.primary}` (white) underline sitting on the border, inactive tabs are `{colors.body-mid}` with no indicator. No background fill, no border-radius, no border around each tab — the row reads as one continuous strip, not a cluster of buttons.

This is a deliberate exception to "every interactive element is a pill": pills are reserved for actions and filter/form choice chips (`option-chip` — category, condition, sort selectors inside forms and the filter sheet), while `tab-bar` is for navigational, mutually-exclusive view switches. Don't apply the underline treatment to `option-chip` contexts (compact multi-row selectors in a sheet or form) — it only reads correctly as a single horizontal row pinned at the top of a view.

### Bottom Navigation — Floating Grey Glass
`{components.nav-bar-blur}` — the app's bottom tab bar is a floating rounded pill (16px inset from the screen edges, not full-bleed) with a translucent mid-grey fill (`rgba(54, 58, 63, 0.72)` — `{colors.canvas-mid}` at 72%) and `backdrop-filter: blur(20px)` (with `-webkit-backdrop-filter` for Safari), bordered in `rgba(255, 255, 255, 0.14)`. Same glass idiom as the top app bar (`{components.nav-bar}`), just floating, pill-shaped, and a step lighter than the header's near-black. Feed content is visible, softened, sliding underneath it as the user scrolls. Icon colors follow the usual dark-canvas pairing: inactive `rgba(255, 255, 255, 0.5)`, active `#ffffff`. The create-choices popup menu uses the identical fill/blur/border so the two surfaces read as one material.

**The fill must stay dark-tinted, not white-tinted.** A light glass (e.g. `rgba(255, 255, 255, 0.10)`) has no darkness floor: when the bar floats over blown-out photo content in the feed, the pill dissolves into the image and the active white icon disappears entirely. The mid-grey at 72% keeps enough opacity to guarantee white icons stay legible over any backdrop while still reading as grey rather than black. Verify any future change to this fill against a white/near-white backdrop, not just the dark canvas.

The create ("+") slot is a plain flat icon like the other four — Home, Market, **create**, Groups, Profile — not a separate solid filled button. Tapping it morphs the same pill into a vertical list of create choices (Sell / Ask / Group Post), closing on an outside tap or re-tapping "+" (now rotated 45° into an "×" shape).

**Same glass material reused on Listing Detail's primary CTA.** The full-width "Chat Seller" / "Mark as Sold" button in the Listing Detail sticky footer (`docs/07-marketplace.md`) uses this identical fill/blur/border (`rgba(54, 58, 63, 0.72)`, `blur(20px)`, `rgba(255, 255, 255, 0.14)` border) instead of the solid white `button-primary` fill used elsewhere — a deliberate pairing with the nav bar so the two floating surfaces read as one material on screen at the same time.

### Preloader / Splash Overlay
`{components.app-preloader}` — a full-viewport overlay in `{colors.canvas}` (#0a0a0a), shown on every hard page load/refresh while resources load, covering the app until it's ready. Centered on screen at ~150px wide: the `pedalmonster-logo-icon.svg` mark (inlined SVG, white/`{colors.ink}`), playing a **build animation that assembles the logo from its two halves** — the bicycle pedal fades and rises into place first, then the three monster-claw fingers sweep down from the upper-left in a 90ms stagger and clamp onto it, finishing with a single quick grip-impact pulse. ~1050ms to a formed mark. No spinner, no progress bar, no loading text — the logo's own motion is the only indicator, per the brand's no-clutter direction. On completion the overlay fades out (opacity, ~250–350ms) and is removed from the DOM.

The animation is pure CSS transforms on the original path geometry, split into pedal/claw subpath groups — no morphing library, no redrawn artwork. See `docs/16-app-preloader-splash.md` for the subpath index map, exact timings/easings, reduced-motion fallback, and dismissal conditions.

This is a one-time-per-full-load element, not a route-transition loader — it must not reappear on in-app client-side navigation between routes.

### Feed Rows Are Seamless, Not Cards
`{components.feed-post-row}` — posts in the Home feed do **not** use `{components.card-content}` chrome (no fill, no border-radius, no box border). Each post is a full-bleed row separated from the next only by a 1px `{colors.hairline}` bottom border (`{spacing.lg}` vertical padding, no border on the last row in a list). This reads as a continuous timeline rather than a stack of boxes — closer to the brand's "unmarketed, engineered" restraint than a card-heavy feed would be.

**Exception — Market Browse is a 2-column grid, not seamless rows.** Unlike the Home feed, Market browse (`docs/07-marketplace.md`) uses `{components.market-grid-tile}`: a 2-up CSS grid of compact tiles, each a hairline-bordered `{rounded.sm}` (8px) box (no fill, matching the brand's "hairline carries elevation, no shadows" rule) containing a square cover thumbnail, a like button overlay, a "Sold" chip when applicable, and a single-line title + price below. This departs from the seamless-row pattern deliberately — browsing a visual, price-driven marketplace reads better as a scannable image grid (closer to a shopping surface) than as a text-first timeline. Tapping anywhere on the tile (including the thumbnail) opens Listing Detail; there is no in-tile swipe gallery or lightbox, only the single cover image.

Within a row:
- Avatar + username sit on one line; the timestamp and the post-type label (e.g. "For Sale", "Community") sit directly beneath on a second line, tight together (no gap between the two lines) and separated from each other by a middle dot (`·`). Both the timestamp and the type label are set at the same small size (11px) and `{colors.body-mid}` color — the type label has no pill/border chrome here, unlike a standalone badge.
- Rank badges are **paused product-wide for now** — not shown anywhere (feed rows, Listing Detail seller card, profile, chat), pending a future decision to re-enable. See `docs/03-auth-user-profile.md`.

### Post Images Bleed Full-Width
`{components.feed-image-bleed}` — when a post has media, the photo gallery breaks out of the row's horizontal inset and spans the full screen width edge-to-edge (negative-margined by `{spacing.lg}` on each side), rather than sitting inset like the text content above and below it. A `{spacing.md}`-ish gap separates the image from the title/description text that follows.

### Photo Lightbox
`{components.photo-lightbox}` — tapping a post image (anywhere it appears, feed or detail) opens a fullscreen viewer: `rgba(10, 10, 10, 0.95)` overlay, swipeable horizontally if the post has multiple photos (scroll-snap, synced dot indicator), single circular close button top-right — translucent dark fill for contrast, **no border** (icon buttons never have one, see Icon Library above). Tapping the backdrop (not the image) closes it.

## Do's and Don'ts

### Do
- Reserve `{colors.canvas}` (`#0a0a0a`) as the only page surface. The brand is dark-canvas only.
- Set hero headlines in `{typography.display-xl}` Universal Sans weight 400 with `-2.4 px` tracking. The precision IS the voice.
- Use `{rounded.pill}` 9999 px on every interactive element. The pill is the brand.
- Pair Universal Sans (sentence-case) with GeistMono UPPERCASE (eyebrows, labels, metric counters).
- Use white-translucent borders for outline buttons — the brand never uses solid white borders on its outline pill.
- In feed/list contexts, separate posts with a `{colors.hairline}` bottom border, not card chrome — see `{components.feed-post-row}`.
- Let post images bleed full-bleed to the screen edge and open a `{components.photo-lightbox}` on tap.
- Icon buttons are always borderless — no exceptions, no hairline circle around any icon-only control anywhere (header-row actions like the top app bar and screen-level back/join-leave/more-menu icons, and overlay-dismiss actions like `{components.photo-lightbox}`'s close button alike). A translucent fill for contrast against photo content is fine; a border around it is not.
- Use underline `{components.tab-bar}` (not pills) for page-level view-switching tabs.
- Use a grey glass blurred fill (`{components.nav-bar-blur}`) for the bottom tab bar, floating with margin from the screen edges, not full-bleed or solid. Keep the fill dark-tinted — a white/light tint washes out over bright photo content and swallows the active icon.

### Don't
- Don't introduce a light-mode surface anywhere. Every surface, including the bottom tab bar, stays dark-canvas only — there is no light-mode exception in this system.
- Don't bold display headlines. Weight 400 is the entire scale.
- Don't use filled buttons broadly. The brand uses outline pills almost exclusively; one Sign Up white-filled pill is the rare exception.
- Don't drop a drop-shadow on cards. Hairline borders carry elevation.
- Don't substitute Universal Sans with a generic geometric sans without adjusting letter-spacing. The negative tracking is part of the brand.
- Don't wrap feed posts in bordered/rounded card boxes — that's `{components.card-content}`, reserved for standalone surfaces (sheets, forms), not list rows.
- Don't show rank badges anywhere for now — the feature is paused product-wide, not just hidden from feed rows.
