---
name: flutter-motion-design
description: Design language and motion system for Flutter mobile apps (Android/iOS) — tokens for type, spacing, radius, shadow geometry, curves and durations, plus specs and code for pressable controls, buttons with loading crossfade, staggered screen entrances, slide page routes, bottom sheets, inline errors, carousels with auto-advancing page indicators, spinners, live pings, progress steps and looping hero illustrations, all with reduced-motion support. Palette-agnostic: brings named colour roles, not colour values. Use whenever building or restyling Flutter screens, widgets, animations, transitions, onboarding/intro flows, forms, buttons, or setting up a theme / design tokens in a Flutter app, even if the user only says "make it look/feel like our other app".
---

# Flutter motion & design language

A calm, precise mobile UI: big left-aligned type, generous 8pt spacing, soft tinted
shadows, and short, decisive motion (fast ease-out, no bounce). This skill is
**palette-agnostic** — it defines colour *roles* that components use; the app
supplies the values.

Full copy-paste source for every token file and widget lives in
[`references/code.md`](references/code.md). Read it before writing a component;
this file is the spec and the rules.

## 1. Non-negotiable rules

1. **Tokens only.** Never write a raw duration, curve, padding, radius, font size or
   colour in a widget. Use `AppCurves`, `AppDurations`, `AppSpace`, `AppRadius`,
   `AppText`, `AppShadow`, `AppColors`. (Rename the `App` prefix per project, but keep one prefix.)
2. **8pt grid.** Spacing values: 4 (hairline gaps only), 8, 12, 16, 24, 32, 40, 64.
3. **Hit targets ≥ 44dp** (`AppSpace.hit`). Controls (buttons, fields) are **56dp** high (`AppSpace.controlHeight`).
4. **No Material ink.** `splashFactory: NoSplash.splashFactory`, `highlightColor: transparent`.
   Feedback comes from press-scale + colour change via `Pressable`.
5. **Every custom tappable is built on `Pressable`** (scale, hover, focus ring, keyboard, semantics).
6. **Respect reduced motion** everywhere (§5). Use `context.reduceMotion`.
7. **Shadows are tinted** with a dark brand ink (`AppColors.shadowTint`), never neutral grey/black.
8. **Semantics:** headings get `Semantics(header: true)`; errors and status changes are
   `liveRegion: true`; decorative illustrations are wrapped in `ExcludeSemantics`.
9. **Motion curve choice:** things *entering* or reacting to touch → `easeOut`;
   things *moving across the screen* → `easeInOut`; *pages and sheets* → `drawer`.
   Never use bounce/elastic curves.

## 2. Tokens

Create these in `lib/core/theme/` (code in references/code.md §1).

### Curves (`AppCurves`)
| Token | Value | Use |
|---|---|---|
| `easeOut` | `Cubic(0.23, 1, 0.32, 1)` | Enter, press, UI feedback, crossfades |
| `easeInOut` | `Cubic(0.77, 0, 0.175, 1)` | On-screen movement (indicator) |
| `drawer` | `Cubic(0.32, 0.72, 0, 1)` | Page slides, bottom sheets, `animateToPage` |
| (flow) | `Cubic(.65, 0, .35, 1)` | Decorative dots travelling along a line |

### Durations (`AppDurations`)
| Token | ms | Use |
|---|---|---|
| `color` | 150 | Background/border/text colour changes |
| `press` | 160 | Press scale |
| `crossfade` | 200 | Label swaps, error in/out, opacity states, AnimatedSize |
| `indicator` | 250 | Page-indicator pill width |
| `sheetClose` | 250 | Bottom sheet close |
| (route reverse) | 300 | Page pop |
| `sheetOpen` | 400 | Bottom sheet open |
| `pageSlide` | 450 | Page push, carousel page change |
| `spinner` | 600 | One spinner revolution (linear) |
| `autoAdvance` | 5000 | Carousel card dwell |

Other fixed timings used by patterns: entrance fade 300 / rise 400 / delay 120 + 60×i;
status-text swap 250; check pop 300; progress bar 400; ping 1600; caret 1000;
flow dots 1600; link fill 1000; colour-cycle demo 1600 tick / 600 transition.

### Spacing & size (`AppSpace`)
`s4 s8 s12 s16 s24 s32 s40 s64`, `hit = 44`, `controlHeight = 56`.
Screen gutters: 24 (forms) or 32 (hero/marketing panels). Bottom action area sits
`s40 + safe-area` from the bottom.

### Radius (`AppRadius`)
badge 8 · control 12 (buttons, fields, chips, code boxes) · tile 16 · card 20 ·
panel 24 (top corners only) · pill 999.

### Shadows (`AppShadow`) — geometry, tinted by `AppColors.shadowTint`
| Token | offset | blur | spread | alpha |
|---|---|---|---|---|
| `card` | (0, 24) | 48 | −16 | 20% |
| `tile` | (0, 12) | 24 | −12 | 20% |
| `panel` (upward) | (0, −8) | 24 | −12 | 14% |
| `primary` (primary button, tinted by `primary`) | (0, 8) | 16 | −8 | 55% |

### Type (`AppText`) — Geist (bundle Regular/SemiBold/Bold in `assets/fonts/`)
Letter-spacing is in logical px (= em × fontSize).

| Style | size/line | weight | tracking | default role |
|---|---|---|---|---|
| `display` | 44 / 1.0 | 700 | −1.76 | ink |
| `title` | 28 / 32 | 700 | −0.84 | ink |
| `heading` | 20 / 28 | 700 | −0.3 | ink |
| `action` | 20 / 28 | 600 | 0 | primaryHover |
| `body` | 16 / 24 | 400 | 0 | inkBody |
| `button` | 16 / 24 | 600 | 0 | ink |
| `label` | 14 / 20 | 600 | 0 | ink |
| `eyebrow` | 12 / 16 | 600 | +1.2, UPPERCASE | primaryHover |
| `caption` | 12 / 16 | 400 | 0 | inkMuted |
| `badge` | 12 / 16 | 600 | 0 | successText |

Icons: `lucide_icons_flutter`, 20–22dp in controls, 16dp inline.

### Colour roles (`AppColors`) — names only, supply your own values
| Role | Used for |
|---|---|
| `ink` | Headings, primary text, dark button bg |
| `inkBody` | Body copy |
| `inkMuted` | Secondary text, captions, chevrons |
| `inkFaint` | Placeholders, lock icons, idle underline |
| `inkHover` | Dark button hover/pressed |
| `surface` | Page background, cards, sheets |
| `surfaceAlt` | Field fill, empty code box, skeletons |
| `surfaceLocked` | Read-only field fill |
| `border` | Hairlines, card/field borders, progress track |
| `indicatorIdle` | Idle pager dots, filled-box border, spinner track |
| `primary` | Primary button, active borders, progress fill, done steps |
| `primaryHover` | Primary hover, errors, eyebrow, text actions |
| `primaryPressed` | Primary pressed, selected-chip text |
| `accent` | Focus ring, focused field border, hover border |
| `tint` | Selected chip bg, focus halo, secondary hover, "in progress" badge |
| `tintStrong` | Secondary pressed, active pager pill track |
| `success` / `successBg` / `successText` | Status badges, "operational" |
| `scrim` | Modal barrier (ink @ ~50%) |
| `shadowTint` | All elevation shadows |
| `white` | Text on brand-coloured surfaces |
| `heroGradient` | Background behind intro heroes (3-stop diagonal, TL→BR) |

## 3. Components (spec → code in references/code.md §2–3)

- **Pressable** — base for all tappables. `AnimatedScale` to `pressedScale`
  (0.97 default, 0.96 small text controls, 0.94 icon buttons) over `press`/`easeOut`.
  Hover only for pointers (`FocusableActionDetector.onShowHoverHighlight`). Enter/Space
  activate. Keyboard focus draws a 2dp `accent` ring inset −4 with radius = control radius + 4.
  Exposes `PressState(hovered, pressed)` to its builder.
- **AppButton** — 56dp, full width, radius 12, horizontal padding 24, label flush left
  (ellipsis), optional leading widget + 12 gap, trailing icon (default `arrowRight`) on the right.
  Variants: primary (shadow `primary`, 1dp inner top highlight white 22%), secondary
  (transparent, 1.5dp `primary` border; hover `tint`, pressed `tintStrong`), dark
  (`ink`, highlight white 14%), brand (runtime colour, hover = 8% darker).
  Disabled → whole button opacity 0.5 (200ms). Colours animate with `AnimatedContainer(color)`.
  **Loading:** idle layer slides up −0.25 & fades out; loading layer (`loadingLabel` + 18dp
  spinner on the right) slides in from +0.25 & fades in; 200ms easeOut; taps disabled.
- **Text action** ("Next", "Get started") — no container, `AppText.action` + 22dp arrow, 44dp tall.
- **Text link** — underlined `label`, decoration thickness 1.5, underline colour `inkFaint` → `primaryHover` on hover.
- **Icon button** — 44×44, icon 22, scale 0.94. Back button is translated −10dp so the
  arrow aligns with the 24dp gutter.
- **Text field** — label (14/600) + 8 gap + 56dp field; fill `surfaceAlt`, radius 12,
  padding 16; border `border` 1dp; focused `accent` 2dp; error `primaryHover` (2dp when focused).
  "(optional)" suffix in label at w400 `inkMuted`.
- **Locked field** — 56dp, `surfaceLocked`, value in `inkMuted`, trailing lock 18dp `inkFaint`.
- **Choice chips** — 44dp tall, radius 12, padding 16, gap 8 wrap; selected = `tint` bg +
  `primary` border + `primaryPressed` text; hover border `accent`; tap selected to deselect;
  semantics `inMutuallyExclusiveGroup`.
- **Code boxes** (OTP-style) — N boxes 52dp tall, 6dp gaps, a 12dp "–" separator at the midpoint.
  One invisible `TextField` (opacity 0, `Positioned.fill`) drives them so paste/autofill/keyboard
  work. Empty = `surfaceAlt` + `border`; filled = `surface` + `indicatorIdle`; active =
  2dp `primary` border + 4dp `tint` halo + blinking 2×24 caret (1s square wave; stops on
  reduced motion); error = 2dp `primaryHover`. Colour changes 150ms.
- **Inline error** — 16dp alert icon + 8 gap + `label` text in `primaryHover`.
  `AnimatedSwitcher` 200ms: fade + slide from y −0.2 (fade only on reduced motion);
  keyed by message so a new message re-animates; `Semantics(liveRegion)`.
- **Status badge** — pill, `successBg`, padding 8×2, 6dp dot + 8 gap + `badge` text.
  "Live" variant pings: a duplicate dot scales 1 → 2.6 and fades 0.6 → 0 over 1600ms easeOut, repeating.
- **Spinner** — 18dp ring, stroke 2, track = colour @ 35%, quarter-arc head starting at −135°,
  `RotationTransition` 600ms linear repeat.
- **Bottom sheet (help)** — `showModalBottomSheet` with `sheetAnimationStyle`
  (open 400 / close 250 / drawer), barrier `scrim`, top radius 24, padding 24/32/24/40:
  eyebrow → 16 → title (28, tracking −0.42) → 16 → body → 24 → dark button "Got it".
- **Screen heading** — eyebrow (uppercase) → 12 → title (header semantics) → 12 → body.
- **Overlapping panel** — `surface`, top radius 24, `panel` shadow, padding 32/32/32/0;
  sits 24dp over a hero so the hero background shows behind its corners.
- **Monogram tile** — square, radius 12, centred 14/700 initials; animates colour over 600ms.
- **Page indicator** — row of pills, each a 44dp-tall tap target with 8dp side padding.
  Idle 8×8 `indicatorIdle`; active widens to 32 (`indicator` 250ms easeOut), track `tintStrong`,
  filled left→right in `primary` by an `Animation<double> progress`.
- **Progress bar** — 4dp, track `border`, fill `primary`, `TweenAnimationBuilder` 400ms easeOut
  to `done/total`; semantics value as a percentage.
- **Step row** — 56dp, bottom hairline; 28dp badge (radius 8): pending `surfaceAlt` (row opacity 0.45),
  active `tint` + 14dp spinner, done `primary` + 16dp check. Transitions 200ms.
- **Saving pill** — 24dp pill crossfading `tint`/"Saving…" ↔ `successBg`/"Saved" (200ms, liveRegion).

## 4. Motion patterns (code in references/code.md §3–4)

- **Page route** (`PageRouteBuilder`): incoming slides from `Offset(1,0)` with `drawer`
  over 450ms; the outgoing page shifts to `Offset(-0.25,0)` (parallax via `secondaryAnimation`);
  reverse 300ms with `easeOut`. Reduced motion → `FadeTransition` only.
- **StaggerIn** (screen entrance) — wrap each content block with an `index`.
  Delay = 120 + 60×index ms; opacity 0→1 over 300ms (`Curves.ease`); translateY 12→0 over
  400ms (`easeOut`), or `scale: true` → 0.9→1 anchored bottom-left (for logos/heroes).
  `play` flag replays when it flips to true (use for carousel pages becoming active).
  Typical order: eyebrow 0, title 1, body 2, form 3, actions 4; heroes take 0–1 and the
  panel text 2–4.
- **Status text swap** — `AnimatedSwitcher` 250ms easeOut, fixed-height slot, custom
  `layoutBuilder` stacking previous+current left-aligned; incoming rises from +8dp,
  outgoing lifts to −8dp while fading.
- **Form busy state** — wrap the form in `AnimatedOpacity(0.55 while saving, 200ms)` +
  `IgnorePointer`. Reveal conditional fields with `AnimatedSize(200ms, easeOut, topCenter)`.
- **Intro carousel** — hero background gradient is a fixed layer *behind* the `PageView`
  (so overscroll shows it). An `AnimationController _fill` drives the pager pill: cards
  1..n−1 fill over 5s then auto-advance; the last card fills in 400ms and stops.
  Stop the fill on user drag (`ScrollStartNotification` with `dragDetails`), restart on
  `ScrollEndNotification` and `onPageChanged`. `animateToPage(450ms, drawer)`. Skip at
  top-right (pressedScale 0.96). Hero height = `min(464, screenHeight × 0.52)`.
- **Looping hero illustrations** (decorative; all stop under reduced motion):
  - *Colour cycle* — `Timer.periodic(1600ms)` steps through sample brand colours;
    `AnimatedContainer(600ms)` recolours a card header; swatches show the active one with
    a 2dp surface ring + 4dp colour ring (200ms).
  - *Staggered bars* — one controller (65 ticks × 70ms) repeats; bar i grows when
    tick ≥ i over 250ms: `scaleY 0.15→1` (easeOut, bottom-anchored), opacity 0.25→1;
    when all bars are grown, a status-text swap flips "Checking…" → "All systems operational".
    Reduced motion: controller.value = 1 (final state).
  - *Connector link* — two tiles joined by a 56dp line. Idle: two 6dp dots (phase 0 and 0.5)
    travel 0→50dp on a 1600ms loop with the flow curve, fading in/out over the first/last 15%.
    Working: a fill bar grows over 1000ms easeOut. Done: a 24dp check circle fades + scales
    0.9→1 (300ms) and both tiles scale to 1.04 (300ms).
- **Skeleton blocks** — rounded rectangles (radius 5 for lines at 10dp tall, 10 for blocks)
  in `border` / `surfaceAlt` to suggest content in previews.

## 5. Reduced motion (`context.reduceMotion` = `MediaQuery.disableAnimationsOf`)

| Keep | Drop |
|---|---|
| Opacity fades, colour changes, crossfades | Translate, slide, scale (press scale too) |
| Spinners (they signal progress) | Looping decoration (pings, flow dots, colour cycles, caret blink) |
| Determinate progress | Auto-advance (show the pager pill full) |

Show the *end state* of anything you drop (bars fully grown, check visible). On a splash/launch
screen, hide the spinner entirely under reduced motion. Read `reduceMotion` in
`didChangeDependencies` for controllers so toggling the OS setting starts/stops loops.

## 6. Theme setup

`ThemeData(useMaterial3: true, fontFamily: 'Geist', scaffoldBackgroundColor: surface,
colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, surface: surface,
onSurface: ink, error: primaryHover))` + text selection (cursor/handle `primary`,
selection `tint`), `focusColor: accent @ 12%`, `NoSplash`, transparent highlight,
bottom-sheet bg `surface` + barrier `scrim`. For runtime re-branding (white-label tenants)
add a `ThemeExtension` with a `brand` colour and lerp it (references/code.md §1).

## 7. Testing animated UI

- Never `pumpAndSettle` on screens with loops (it times out). Use a `settle()` helper that
  pumps 10 × 100ms.
- Phone viewport: `tester.view.physicalSize = Size(390, 844) * 3; devicePixelRatio = 3`.
- To test reduced motion, wrap in `MediaQuery(data: ...copyWith(disableAnimations: true))`.
- Dispose every `AnimationController` and cancel every `Timer` in `dispose`.
