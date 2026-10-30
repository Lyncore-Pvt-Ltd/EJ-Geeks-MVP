---
version: 1.1
name: AutoFlow — Mobile
description: Visual system for the AutoFlow mobile app (inspection, invoicing and multi-branch workshop management). Navy ink on white, one orange accent for actions, slight-radius controls, soft tinted shadows, light and dark themes. Codified from "AutoFlow Intro and Login v3".

colors:
  accent: "#FCA311"          # primary CTA fill, active indicators, glows, focus ring
  on-accent: "#000000"       # label colour on accent (white fails contrast)
  ink: "#14213D"             # headings, body, icons, active chips (light theme)
  black: "#000000"           # dark-theme ground
  line: "#E5E5E5"            # borders, dividers, inactive dots, thumbnails
  surface: "#FFFFFF"
  accent-wash:               # tints of accent used as fills, never as text
    secondary-fill: "rgba(252,163,17,0.05)"
    secondary-border: "rgba(252,163,17,0.16)"
    chip: "rgba(252,163,17,0.16)"     # "Global blueprint" chip
    row-highlight: "rgba(252,163,17,0.14)"
    key-highlight: "rgba(252,163,17,0.24)"
  status:
    success: { fg: "#007F35", bg: "#E4FBE7" }   # Good, Paid
    warning: { fg: "#945A00", bg: "#FFF0D6" }   # Fair, Awaiting approval
    error:   { fg: "#AF3D36", bg: "#FFECE9" }   # Repair Required, field errors

themes:
  light:
    page: "linear-gradient(180deg,#E5E5E5 0%,#FFFFFF 420px)"
    screen: "linear-gradient(180deg,#E5E5E5 0%,#FFFFFF 320px)"
    panel: "linear-gradient(180deg,#E5E5E5 0%,#FFFFFF 100%)"
    card: "#FFFFFF"
    ink: "#14213D"
    navy: "#14213D"
    line: "#E5E5E5"
    soft: "#F4F4F4"
    hot: "#FFF7EA"
    mute: "rgba(20,33,61,0.64)"
    mute2: "rgba(20,33,61,0.72)"
  dark:
    page: "linear-gradient(180deg,#14213D 0%,#000000 420px)"
    screen: "linear-gradient(180deg,#14213D 0%,#000000 320px)"
    panel: "linear-gradient(180deg,#14213D 0%,#0A1120 100%)"
    card: "#0F1A30"
    ink: "#FFFFFF"
    navy: "#1F3260"
    line: "rgba(229,229,229,0.14)"
    soft: "rgba(229,229,229,0.08)"
    hot: "rgba(252,163,17,0.12)"
    mute: "rgba(229,229,229,0.64)"
    mute2: "rgba(229,229,229,0.78)"
  celebration: "radial-gradient(120% 45% at 50% 0%, #FCA311 0%, #14213D 50%, #000000 100%)"   # success screen, both themes

typography:
  family: Satoshi            # one family; weights 400 + 500 only
  mono: Fragment Mono        # numbers, counters, codes, plates, rating keys, tags
  scale:                     # exactly four sizes
    headline: { size: 28px, weight: 500, lineHeight: 1.1, letterSpacing: -0.03em }   # also the intro "Next →" CTA
    title:    { size: 17px, weight: 500, letterSpacing: -0.01em }   # buttons, card titles, values
    body:     { size: 16px, weight: 400, lineHeight: 1.4 }          # paragraphs, inputs (16px prevents iOS zoom)
    caption:  { size: 13px, weight: 400-500 }                       # labels, chips, meta, links
  emphasis: none             # no italics, highlighter bars or coloured words in headlines

spacing:
  grid: 8                    # all values divisible by 8 (4 allowed for tight pairs)
  scale: [4, 8, 12, 16, 24, 32, 48]
  screen-gutter: 16px
  footer: "16px 16px 32px"   # intro footer: "8px 0 32px" inside the 16px gutter
  section-gap: 24px          # between unrelated groups (2x the related gap)

radius:
  control: 10px              # buttons, inputs (slight radius — never pill)
  small: 8px                 # chips-as-buttons, icon tiles, note blocks; checkbox + rating keys 6px
  card: 16px                 # cards, panels, photo thumbnails
  viewfinder: 12px           # camera preview, large logo mark
  panel: 24px                # intro illustration panel
  chip: 9999px               # status chips, section chips, dots only

elevation:
  card: "0 16px 32px -16px rgba(20,33,61,0.18)"
  hero: "0 16px 32px -12px rgba(20,33,61,0.35)"
  accent: "inset 0 1px 0 rgba(255,255,255,0.28), 0 8px 16px -8px rgba(252,163,17,0.55)"
  hot-tile: "0 12px 24px -12px rgba(252,163,17,0.55)"
  success-tick: "inset 0 1px 0 rgba(255,255,255,0.3), 0 16px 32px -12px rgba(252,163,17,0.7)"
  footer: "0 1px 10px rgba(20,33,61,0.10)"
  rule: shadows are always tinted navy or orange — never neutral grey/black

motion:
  ease-out: "cubic-bezier(0.23,1,0.32,1)"     # default for enter, move, press
  ease-spring: "cubic-bezier(0.34,1.56,0.64,1)" # pops: chips, badges, success tick, hot-tile dot
  press: "scale(0.97), 160ms"                 # every button; inline icon buttons 0.9
  enter: "opacity 0→1 + translateY 8–12px, 300–450ms, 60–70ms stagger"
  busy-swap: "label ↔ loading: opacity + blur 2px + translateY ∓6px, 200ms ease-out"
  error: "error line slides in from -4px, 200ms; form shakes -6/5/-3px, 360ms"
  loops: "1.4s tick drives intro illustrations; glows breathe 3–4s; spinners 600–700ms"
  reduced-motion: all durations collapse to 1ms (spinners keep turning)
---

# AutoFlow mobile design system

## Principles
- One job per screen, one accent action per screen, placed in the bottom third (thumb zone).
- 60 / 30 / 10: white (or black in dark) ground, navy ink, orange accent.
- Hierarchy comes from size and opacity (100% headings, 72% body, 64% secondary), not from extra weights.
- Values beat labels: numbers in mono at 17px, labels at 13px muted.

## Components

**Primary button**: 48px tall, full width, radius 10px, `#FCA311` fill, 1px `rgba(20,33,61,0.07)` border (`rgba(255,255,255,0.12)` on the celebration ground), black 17px/500 label with an optional trailing arrow, accent elevation (inner white highlight + orange drop). Press: scale 0.97. Busy: the label swaps to a busy label plus an 18px spinner (black on `rgba(0,0,0,0.25)` track) and the button is disabled.

**Secondary button**: 48px, radius 10px, accent secondary-fill and secondary-border, ink 17px/500 label, optional 18px leading icon. Press deepens the fill to 10%. Busy: busy label + 18px ink spinner on a line track.

**Text CTA (intro only)**: headline-size (28px/500) ink label + 28px square-cap arrow, at least 56px tall, right-aligned in the footer. Press/hover turns accent. On the last slide the arrow nudges 4px right. Busy: "Opening…" + 24px accent spinner (2.5px stroke).

**Busy-label swap**: idle and busy labels share one grid cell. The one leaving fades out, blurs 2px and shifts 6px (idle up, busy down) over 200ms ease-out. The busy label is announced with `aria-live="polite"`.

**Icon button**: minimum 44×44, radius 10px, 1px line border, card fill (Back). Press: line fill + scale 0.97. Inline icon buttons inside fields: 48px wide, transparent, muted → ink on hover, press scale 0.9.

**Text field**: 48px, radius 10px, 1px line border, card fill, 16px text, 13px/500 muted label above (16px inset), 8px gap. Focus: accent border + 0.5px accent ring. Error: border `#AF3D36` and a 13px error line with a 14px alert icon (16px inset), and the whole form shakes once.

**Password field**: a text field with a trailing eye / eye-off icon toggle (no text button). The aria-label switches between "Show password" and "Hide password".

**Checkbox**: 20px, radius 6px. Checked = ink fill and border, and the tick scales 0.5 → 1 (200ms). Sits with its label in a 44px-tall tap target.

**Text link**: 13px ink, underlined with 3px offset, 44px minimum tap height.

**Status chip**: pill, 4px 12px, 13px/500, 6px dot, soft status background. Ratings: Good (green), Fair (amber), Repair Required (red), N/A and N/C (outline). Chips that appear mid-flow spring in (scale 0.4 → 1, 300ms).

**Section chip**: pill, 4px 12px, 13px/500. Active = ink fill with card text, inactive = soft fill with ink text. A chip row overflowing horizontally fades out at the right edge (mask 80% → transparent).

**Rating keys**: five 20px tiles G / F / R / – / ? (radius 6, line border, mono 13px muted). The key being chosen gets the key-highlight fill.

**Card**: radius 16px, 1px line border, card fill, card elevation. Lists inside cards use 1px line rules, and the last row has no rule.

**Page dots**: 8px dots; the active dot stretches to 24px and turns accent (300ms ease-out). Inactive dots use the line colour. Each dot sits in a 44px tap target with the label "Go to slide N".

**Logo mark**: navy rounded square with "af" in white (-0.04em). It's 28px with radius 8 and a 13px label in the header (next to the 17px/500 "AutoFlow" wordmark), and 56px with radius 12, a 17px label and hero elevation on Log in. Hero moments add a breathing orange glow behind it (blur 24px, 35% opacity, 4s).

**Spinner**: ring with a 2px track (line colour) and one coloured top segment, rotating linearly.

## Screens

**Intro (3 swipeable slides)**: header: wordmark + Skip (16px/500, mute2, 44px target). Each slide: panel (flexes, max 340px, radius 24px, panel gradient, line border) above the counter `0N / 03` (mono 13px), a 28px headline and a 16px mute2 body. On slide change the counter, headline and body re-enter with staggers of 80 / 140 / 200ms. Footer: page dots + text CTA (Next → Get started). Navigation: swipe with scroll-snap, mouse-drag past 40px, or tap a dot. Inactive slides dim the panel to 40% and scale it to 0.94. A 1.4s tick drives each illustration and resets to 0 whenever the slide changes.
1. *Drive Your Workshop's Efficiency and Profitability with AutoFlow*: a 2×2 grid of highlight tiles (min height 120, radius 16, padding 12): Digital Inspection Checklists · *Single-tap grading*, Photo Defect Evidence · *HD inspection photos*, Multi-Branch Operations · *Scoped RBAC*, Instant Accounting & Invoicing · *GST + PDF* (tags in mono, muted). Tiles enter staggered (150ms + 60ms each). Each tick, one tile goes "hot": it lifts 4px, gets the hot fill, an accent border and the hot-tile shadow, its icon tile turns accent with a black icon, and a corner dot springs in. A soft orange glow (160×96, blur 40, 30%) sits above the grid.
2. *Eliminate Paperwork and Upgrade to Mobile-First Digital Vehicle Inspections*: inspection card with "Inspection / Toyota Hilux" and a "Global blueprint" accent chip, then the section chips (Engine Bay active, Interior, Exterior, Tyres, Wheels & Brakes, Road Test). Three checklist rows are graded in sequence (Oil level & condition → Good, Coolant hoses → Fair, Drive belt → Repair Required) on a 5-step cycle. The row being graded gets the row highlight and 500 weight, and its matching rating key lights up. Graded rows swap their keys for a springing status chip. The technician note ("Engine Bay note: drive belt cracked, replace before next service.") fades in once all three are graded.
3. *Show, Don't Just Tell — High-Resolution Inspection Photos*: navy photo-inspection viewfinder (120px, radius 12, hero elevation) with the label "Photo inspection · Wheels & Brakes", an accent "HD" badge, four accent corner brackets and a pulsing accent shutter (ring scales to 2.2 and fades, 1.6s). Below it: "Inspection photos" with a mono `N / 4` counter. Four thumbnails (56px, radius 16) upload in turn on a 6-step cycle: the current one gets a 2px accent outline and a 3px progress bar (1.4s), and finished ones get a springing accent tick badge. Last comes a share card ("Shared with customer / Report with photo evidence", navy share icon tile) that shows a 16px spinner and then the "Awaiting approval" warning chip.

**Log in**: Back icon button, then a centred glowing 56px logo, "Welcome back" (28px, line-height 1.2) and "Log in to your workshop." (16px, mute2). Then the form: **Work email** (placeholder `sam@northsideauto.com`), **Password** (placeholder "Your password", eye toggle), then a row with Keep me signed in (checked by default) and Forgot password?. Below that: "or" divider, **Email me a magic link** (secondary, mail icon), and "New to AutoFlow? **Start your free 14-day trial**" (link 500). Content enters at 0 / 60 / 120 / 150 / 180ms and the footer at 200ms. The primary "Log in →" is pinned in the footer with the footer shadow, and the body scrolls under it.
- Validation: email must match `^\S+@\S+\.\S+$` ("Enter a valid email address."), and the password must be at least 8 characters ("Password is at least 8 characters."). A magic link without a valid email shows "Enter your email to get a magic link.". Any error shakes the form.
- While submitting, the form drops to 55% opacity and stops taking input. Busy labels: "Signing in…" / "Sending link…".

**Success (peak + end)**: celebration gradient (white text in both themes). A 72px orange tick springs in (scale 0.85 → 1, 500ms), draws its check (400ms, 250ms delay) and bursts 8 sparks: 8px dots alternating accent and `#E5E5E5`, flying 56 / 72px out on alternating spokes over 900ms with a 200ms + 30ms stagger. A breathing glow sits behind it (blur 32, 60%, 3s). Headline + one line (`#E5E5E5`), then a CTA in the footer and a "Replay intro" link (`rgba(229,229,229,0.72)`).
- *Password sign-in*: "Welcome back." · "Here's your workshop at a glance." Then a frosted summary card (`rgba(255,255,255,0.06)` fill, 10% white border, 12px backdrop blur, padding 8px 24px) with 48px rows: Inspections today **7**, Vehicles in progress **4**, Awaiting authorization **2** (13px labels at 72%, 17px mono values in white, 10% white rules between rows). CTA "Go to today's jobs" (busy "Loading jobs…").
- *Magic link*: "Check your inbox." · "We sent a magic link to {email}." No summary card. CTA "Open mail app" (busy "Opening mail…").

## Rules
- Tap targets ≥ 44×44.
- No pill buttons, no italic/serif accents, no highlighted headline words, no video features (photos only).
- Orange is never used for body text on light grounds; use ink.
- Every state is designed: default, focus, error, loading, success, empty.
- Light and dark themes share one set of variables; components only reference variables. (In the source prototype, the light `mute`/`mute2` variables reference themselves. The explicit rgba values above are the intended ones.)

## Flutter implementation
- Tokens live in `lib/core/theme/autoflow_tokens.dart` as `AutoFlowTokens` (a `ThemeExtension` registered on `AppTheme.lightTheme`/`darkTheme`). Theme-dependent values are read with `AutoFlowTokens.of(context)`, and theme-independent ones (accent, status colours, shadows, celebration gradient, text styles) are statics.
- Curves: `AutoFlowTokens.easeOut = Cubic(0.23, 1, 0.32, 1)`, `AutoFlowTokens.easeSpring = Cubic(0.34, 1.56, 0.64, 1)`. Reduced motion follows `MediaQuery.disableAnimations` (`afDuration`).
- Fonts: Satoshi 400/500 is bundled from `assets/fonts/` (fontshare.com). Fragment Mono comes through `google_fonts` (`AutoFlowTokens.mono()`, with tabular figures).
- The onboarding flow is `lib/features/onboarding/`. Reusable primitives (buttons, text field, chips, dots, logo mark, motion helpers) are in `presentation/widgets/common/`.
