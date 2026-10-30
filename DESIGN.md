---
version: 1.0
name: AutoFlow — Mobile
description: Visual system for the AutoFlow mobile app (inspection, invoicing and multi-branch workshop management). Navy ink on white, one orange accent for actions, slight-radius controls, soft tinted shadows, light and dark themes. Codified from "AutoFlow Intro and Login v3".

colors:
  accent: "#FCA311"          # primary CTA fill, active indicators, glows
  on-accent: "#000000"       # label colour on accent (white fails contrast)
  ink: "#14213D"             # headings, body, icons, active chips (light theme)
  black: "#000000"           # device bezel, dark-theme ground
  line: "#E5E5E5"            # borders, dividers, inactive dots, thumbnails
  surface: "#FFFFFF"
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
  celebration: "radial-gradient(120% 45% at 50% 0%, #FCA311 0%, #14213D 50%, #000000 100%)"

typography:
  family: Satoshi            # one family; weights 400 + 500 only
  mono: Fragment Mono        # numbers, counters, codes, plates, prices
  scale:                     # exactly four sizes
    headline: { size: 28px, weight: 500, lineHeight: 1.1, letterSpacing: -0.03em }
    title:    { size: 17px, weight: 500, letterSpacing: -0.01em }   # buttons, card titles, values
    body:     { size: 16px, weight: 400, lineHeight: 1.4 }          # paragraphs, inputs (16px prevents iOS zoom)
    caption:  { size: 13px, weight: 400-500 }                       # labels, chips, meta, links
  emphasis: none             # no italics, highlighter bars or coloured words in headlines

spacing:
  grid: 8                    # all values divisible by 8 (4 allowed for tight pairs)
  scale: [4, 8, 12, 16, 24, 32, 48]
  screen-gutter: 16px
  footer: "16px 16px 32px"
  section-gap: 24px          # between unrelated groups (2x the related gap)

radius:
  control: 10px              # buttons, inputs (slight radius — never pill)
  small: 8px                 # chips-as-buttons, icon tiles, checkbox 6px
  card: 16px                 # cards and panels
  panel: 24px                # intro illustration panel
  chip: 9999px               # status chips, dots only
  device: 56px / 46px        # bezel / screen

elevation:
  card: "0 16px 32px -16px rgba(20,33,61,0.18)"
  hero: "0 16px 32px -12px rgba(20,33,61,0.35)"
  accent: "inset 0 1px 0 rgba(255,255,255,0.28), 0 8px 16px -8px rgba(252,163,17,0.55)"
  footer: "0 1px 10px rgba(20,33,61,0.10)"
  rule: shadows are always tinted navy or orange — never neutral grey/black

motion:
  ease-out: "cubic-bezier(0.23,1,0.32,1)"     # default for enter, move, press
  ease-spring: "cubic-bezier(0.34,1.56,0.64,1)" # pops: chips, badges, success tick
  press: "scale(0.97), 160ms"                 # every button
  enter: "opacity 0→1 + translateY 8–12px, 300–450ms, 60–70ms stagger"
  loops: "1.4s tick drives intro illustrations; glows breathe 3–4s"
  reduced-motion: all durations collapse to 1ms
---

# AutoFlow mobile design system

## Principles
- One job per screen, one accent action per screen, placed in the bottom third (thumb zone).
- 60 / 30 / 10: white (or black in dark) ground, navy ink, orange accent.
- Hierarchy from size and opacity (100% headings, 72% body, 64% secondary) — not extra weights.
- Values beat labels: numbers in mono at 17px, labels at 13px muted.

## Components

**Primary button** — 48px tall, full width, radius 10px, `#FCA311` fill, black 17px/500 label, accent elevation (inner white highlight + orange drop). Press: scale 0.97. Loading: 18px spinner replaces label, button disabled.

**Secondary button** — 48px, radius 10px, 5% accent fill `rgba(252,163,17,0.05)`, 16% accent border, ink label, optional leading icon.

**Icon button** — 44×44 minimum, radius 10px, 1px line border, card fill (Back). Inline icon buttons inside fields: 48px wide, transparent, muted → ink on hover.

**Text field** — 48px, radius 10px, 1px line border, card fill, 16px text, 13px/500 muted label above (16px inset). Focus: accent border + 0.5px accent ring. Error: border `#AF3D36`, 13px error line with alert icon, form shakes once (360ms).

**Password field** — text field with trailing eye / eye-off icon toggle (no text button).

**Checkbox** — 20px, radius 6px; checked = ink fill, tick scales in (200ms).

**Status chip** — pill, 4px 12px, 13px/500, 6px dot, soft status background. Ratings: Good (green), Fair (amber), Repair Required (red), N/A and N/C (outline).

**Card** — radius 16px, 1px line border, card fill, card elevation. Lists inside cards use 1px line rules; last row has no rule.

**Page dots** — 8px dots, active stretches to 24px; each dot sits in a 44px tap target.

**Logo mark** — navy rounded square ("af"), with a soft blurred orange glow behind on hero moments.

## Screens

**Intro (3 swipeable slides)** — header: logo + Skip. Panel (flexes, max 340px, radius 24px, panel gradient) above counter `0N / 03`, 28px headline, 16px body. Footer: dots + primary (Next → Get started). Swipe, drag or tap dots; inactive slides dim to 40% and scale 0.94.
1. *Drive your workshop's efficiency* — four highlight tiles (Digital Inspection Checklists, Photo Defect Evidence, Multi-Branch Operations, Instant Accounting & Invoicing); tiles take turns lifting with an accent border.
2. *Eliminate paperwork* — inspection card: vehicle + plate, "Global blueprint" chip, section tabs (Engine Bay, Interior, Exterior, Tyres, Wheels & Brakes, Road Test), three items graded in sequence, technician note fades in.
3. *Show, don't just tell* — photo inspection viewfinder (HD, pulsing camera), four photo uploads counting 0→4, then "Shared with customer · Awaiting approval".

**Log in** — Back, glowing logo, "Welcome back", email, password (eye toggle), Keep me signed in, Forgot password? (44px target), "or", Email me a magic link, free-trial link. Primary "Log in" pinned in footer.

**Success (peak + end)** — celebration gradient, 72px orange tick that springs in, draws its check and bursts 8 sparks; headline + one line; glass summary card of today's numbers (mono values); primary CTA to the next task.

## Rules
- Tap targets ≥ 44×44.
- No pill buttons, no italic/serif accents, no highlighted headline words, no video features (photos only).
- Orange is never used for body text on light grounds; use ink.
- Every state is designed: default, focus, error, loading, success, empty.
- Light and dark themes share one set of variables; components only reference variables.
