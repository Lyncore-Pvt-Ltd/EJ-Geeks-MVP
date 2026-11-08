# AutoFlow UI audit

_Audit date: 2026-10-31._ Checked against `DESIGN.md` and the project design skills (`review-animations`, `improve-animations`, `emil-design-eng`, `apple-design`, `mobile-native`, `app-store-screenshots` in `.agents/skills/`). Every finding has a `file:line` anchor. Each item is sized to fit a single PR.

## Status (2026-10-31)

**Fixed:**

- **§2 P0 defects:** all nine are done.
- **§3 design-system migration:** the theme is built from `AutoFlowTokens`, `AppPallete`, `GradientOutlineButton` and `DashedDivider` are gone, and the `Af*` widgets now live in `lib/core/presentation/widgets/af/`. Dialogs use `DialogActions`, which settles the dialog-button decision in favour of `DESIGN.md`. Radii and spacing come from `AfRadius`/`AfSpace`.
- **§4 motion:** done. Durations go through `afDuration`, and the fake waits are removed.
- **§5 accessibility:** done.
- **§6 onboarding spec gaps:** done.
- **Layout tests:** they now cover the dashboard, the invoice list, both tabs of the invoice sheet and the three shared dialogs, as well as onboarding. They are in `test/features/{dashboard,invoice}/` and `test/core/dialogs_layout_test.dart`. A few cases are skipped because of known overflows at 1.3× text: StatCard, InvoiceCard/AfStatusChip, the invoice-tab totals row, and the ShowDeleteDialog/AboutInfoDialog content. Each skip gives its reason in the test name.

**Remaining:**

- **§7 store screenshots:** not started. Everything is on-brand now, so the full set can be captured once the skipped overflows above are fixed.
- **Logo swap (design decision pending):** the splash and drawer still show `assets/icon/EJG.png`. Replacing it with the AutoFlow logo mark (`AfLogoMark`) needs sign-off.

## 1. Summary

The app has two visual languages:

- **Onboarding** (`lib/features/onboarding/`) is built on `AutoFlowTokens` and follows `DESIGN.md` closely: white, navy and orange; Satoshi and Fragment Mono; spec curves; reduced-motion support; responsive helpers; and a layout test.
- **Everything else** (dashboard, invoice, inspection, search, `lib/core/presentation/`) still uses the older `AppPallete` design. Across those areas there are:
  - about 240 `AppPallete` references and **0** `AutoFlowTokens` uses;
  - about 190 inline `Theme.of(context).brightness == Brightness.dark` checks;
  - 12 different font sizes in the invoice feature alone;
  - 11 different corner radii, from 0 to 28;
  - about five different button styles;
  - pink, red, teal and gold accents instead of orange on navy.

**Biggest change needed:** move the rest of the app onto the AutoFlow design system (section 3). Fix the P0 defects first.

## 2. P0: bugs and visible defects (do first, one PR)

| # | Where | Problem | Fix |
|---|---|---|---|
| 1 | `lib/core/theme/app_pallete.dart:5` | `Color(0xff0000000)` has 9 hex digits and becomes `0xF0000000`, a slightly see-through black used for the dark scaffold and app bar. | `Color(0xFF000000)`. |
| 2 | `lib/features/invoice/presentation/pages/invoice_screen.dart:87` | The list has only `bottom: 20` of padding, but the dashboard sets `extendBody: true` (`dashboard_screen.dart:34`) with a floating nav bar, so the last invoice card is hidden under it. | Use the same clearance as `home_screen.dart:81`: `100 + MediaQuery.of(context).padding.bottom`. |
| 3 | `invoice_tab.dart:419` | While busy, `onTap` is `() {}`, so the Generate button never looks disabled. | Pass `null` while busy. |
| 4 | `invoice_line_item_card.dart:58-75` | Edit/delete are bare `InkWell`s around 18px icons, about 18px to tap. | `IconButton` (48px), or pad to 44×44. |
| 5 | `inspection_image_picker.dart:156-170` | The remove-photo button is a `GestureDetector` around a 14px icon, about 18px to tap. | A 44×44 target with the icon centred. |
| 6 | `search_bar.dart:214` | "Clear search history" is 12px text with no padded tap area. | `TextButton`, or at least 44px tall. |
| 7 | `onboarding/.../common/af_page_dots.dart:36` | Each inactive dot's tap area is 24×44 (`minWidth: 24`); the spec says 44×44. | `minWidth: 44`. |
| 8 | `onboarding/.../pages/intro_page.dart:59` | `Timer.periodic` keeps rebuilding the whole intro screen every 1.4s, even when Log in is on top and under reduced motion. | Pause it when the route is covered (`RouteAware`, or check `TickerMode.of`), and rebuild only the illustration through a `ValueNotifier<int>`. |
| 9 | `onboarding/.../common/af_text_field.dart:84` | `focusedBorder` is always the orange accent, so the red error border (`#AF3D36`) disappears when the user taps back into an invalid field. | Use the error colour for the focused border when `errorText != null`. |

## 3. P1: move to the design system (staged)

**Stage 1: theme (`lib/core/theme/theme.dart`).** Build `ColorScheme`, `TextTheme`, `AppBarTheme`, `CardTheme`, `InputDecorationTheme`, `DialogTheme` and `BottomSheetThemeData` from `AutoFlowTokens`. Most screens will pick up the new look without editing each widget.
- Drop `FontFamily.inter`/`montserrat` (`app_pallete.dart:51`) and `GoogleFonts.inter` (`search_bar.dart:122`).
- Drop the pink/teal gradients (`gradient1-3`, `selectionGradient`).
- Fix dark `bodyMedium: AppPallete.greyColor` (`theme.dart:32`), which is low contrast on near-black.
- Replace the light scaffold `#E0E0E0` with the token ground colour.

**Stage 2: per feature.** Replace each `AppPallete` reference and `isDark ? a : b` check with `AutoFlowTokens.of(context)`. Order:
1. core: app bar, drawer, nav bar, dialogs;
2. invoice;
3. inspection;
4. dashboard;
5. search.

Fix the places that ignore dark mode along the way:
- `search_bar.dart:126,133,138`: fixed navy icons on `grey[200]`;
- `custom_appbar.dart:12`: `Colors.black` title;
- `custom_appbar.dart:28`: `grey[300]` avatar.

**Stage 3: one set of shared widgets.** Move `AfPrimaryButton`, `AfSecondaryButton`, `AfIconButton`, `AfPressable`, `AfTextField` and `AfChip` from `features/onboarding/presentation/widgets/common/` to `lib/core/presentation/widgets/af/`. Then replace:
- `InspectionGradientButton`, which is 55px tall against the 48px spec (`inspection_gradient_button.dart:30`);
- `GradientOutlineButton`, which has a 10.5 radius;
- the gradient and red dialog action buttons in `confirm_dialog.dart`, `show_delete_dialog.dart` and `about_info_dialog.dart`;
- the GNav pill tabs (`custom_bottom_nav_bar.dart:43`, radius 28 and `tabBorderRadius: 20`). `DESIGN.md` says no pill buttons.

> ⚠ **Decision needed:** the CLAUDE.md section "Dialog action button styling" (40px tall, radius 5, dark or red pill) conflicts with `DESIGN.md` (48px controls, no pills, orange as the only accent). Choose one and update the other doc to match.

**Type scale.** Reduce the 12 sizes in invoice (11, 12, 13, 14, 15, 16, 18, 20, 24, 25, 26) to the `DESIGN.md` styles: headline, title, body, caption and mono. Show amounts and counts in Fragment Mono (`AutoFlowTokens.mono()`).

**Radii.** Reduce to the token set (8 / 12 / 16 / 24). Today there are 0, 2, 3, 5, 8, 10, 10.5, 12, 16, 20 and 28.

## 4. P1: motion

Assessed against the `review-animations`, `emil-design-eng` and `apple-design` skills.

| Where | Problem | Fix |
|---|---|---|
| `lib/core/presentation/pages/splash_screen.dart:51-126` | The icon uses `Curves.elasticOut` (800ms), fade-ins use `Curves.easeIn` (wrong direction for an entrance), and delays chained by hand add up to about 3.3s before the user can do anything. | Use `AutoFlowTokens.easeOut` and `easeSpring`, cut the total to about 1.2s, and pass durations through `afDuration`. |
| `invoice_details_bloc.dart:323` | `_minGenerateDuration = 700ms` is an artificial wait. | Remove it. |
| `invoice_bottom_sheet.dart:215` | The sheet waits a fixed 500ms before closing. | Close right after success. |
| `onboarding_success_page.dart:38` | `_ctaLatency = 1100ms` is a fake busy state. | Navigate immediately. |
| `invoice_success_dialog.dart:55` | A 2000ms decorative progress bar. | Remove it, or make it under 400ms. |
| `rating_selector.dart:31`, `invoice_page_dots.dart:27`, `onboarding/.../login/remember_checkbox.dart:30,39`, `onboarding/.../pages/login_page.dart:203` | Animations on frequently used controls fall back to a linear curve. | Pass `curve: AutoFlowTokens.easeOut`. |
| `onboarding/.../common/af_motion.dart:40-45` | `AfPressable` sets its pressed state in `onTapDown`, which fires about 100ms late, so quick taps show no scale. | Set it on pointer-down with a `Listener`, keep the tap on `GestureDetector`, and add focus and keyboard activation. |
| `af_secondary_button.dart:36`, `af_icon_button.dart:31`, `intro_footer.dart:78-103` | The spec's pressed fills are missing: the 10% fill on the secondary button, the line-colour fill on the icon button, and the accent colour on the intro CTA. | Add them. |
| `onboarding/.../intro/intro_slide_view.dart:126,130` | The inactive panel dims over 400ms and scales over 500ms, which is slow and unmatched. | Use the same value for both, ≤ 300ms. |
| `intro_slide_view.dart:163-185` | Text re-enters on every swipe and the body stays hidden for about 600ms. | Shorter `AfReveal` with smaller staggers. |
| `highlights_illustration.dart:35`, `photo_illustration.dart:256` | Decorative loops keep running on slides that aren't showing. | Gate them on `active`. |
| All areas outside onboarding | Nothing checks reduced motion. | Pass every duration through `afDuration` (move it to core). |
| `home_screen.dart:24`, `invoice_screen.dart:76` | `LiquidPullToRefresh` puts a decorative effect on an action users repeat often. | Use the plain `RefreshIndicator` styled with the accent colour. |

## 5. P2: accessibility

- There are no `Semantics` widgets outside onboarding. These icon-only controls have no label:
  - sheet save and close: `invoice_bottom_sheet.dart:587`, `:614`;
  - notifications, which also does nothing: `custom_appbar.dart:17`;
  - the nav "+" button: `custom_bottom_nav_bar.dart:105`;
  - line-item edit and delete;
  - remove photo;
  - field show/hide toggles: `inspection_text_field.dart:81,89`.

  Add a `tooltip` or `Semantics(label:)` to each, and hide or remove the notifications button that does nothing.
- **Onboarding:**
  - Add `excludeSemantics: true` on labelled buttons so labels aren't read twice: `af_primary_button.dart:38`, `af_secondary_button.dart:28`, `intro_footer.dart:75`.
  - Add `liveRegion` and `enabled: !busy` for busy labels.
  - Connect each field to its label and error text, and expose `autocorrect: false` / `enableSuggestions: false` for email (`af_text_field.dart:49-70`).
  - Mark headlines with `header: true`.
  - Announce success and give the tick a label.
  - Add keyboard focus and activation to `AfPressable`.
  - Close the keyboard on submit and on taps outside the fields.
- **Contrast:**
  - white text on the `#FF8A80` end of the confirm gradient;
  - `Colors.grey` hint on `grey[200]` (`search_bar.dart:122,138`);
  - `#6d6a6b` on `#1d1c1d` in dark mode (`search_bar.dart:170`).

## 6. P2: onboarding gaps against the spec

- `lib/core/theme/autoflow_tokens.dart:47`: the `celebration` gradient is circular (`radius: 1.2`); the spec calls for an ellipse (`120% 45%`). Use a `GradientTransform` to scale it vertically.
- `autoflow_tokens.dart:128,134,156,162`: the page and screen gradients end at a percentage of screen height; the spec fixes them at 420px and 320px.
- `intro_header.dart:18`: the left padding is 24px; the gutter is 16px.
- `af_motion.dart:207`: `AfReveal` is fixed at 400ms, while the spec says 200ms for the error line. Add a `duration` parameter.
- `login_page.dart:233`: the password eye uses a Material `IconButton` with a ripple; the spec wants an inline toggle that scales to 0.9 and goes from muted to ink.
- `success_tick.dart:88-95`: the tick's shadow is missing its inset highlight.

## 7. Store-screenshot readiness (`app-store-screenshots` skill)

- **Capture now:** only the onboarding screens are on-brand today, so the 3 intro slides, Log in and Success can be captured from the 1.0× layouts that `onboarding_layout_test.dart` checks.
- **Wait:** hold the inspection checklist, invoice list and sheet, and PDF until P0 and migration stage 1 are done. Otherwise the store set mixes two visual languages.
- **Suggested styles:** `14-orange-frame-clean-showcase` (it already uses orange) or `05-floating-ui`. Avoid the mascot and sticker styles, which don't fit a professional workshop tool.
- **Process:** follow the skill's steps in order, and get the copy storyboard approved before any design.

## 8. What's working (keep as the pattern)

- **Onboarding tokens:** colours, type and shadows match `DESIGN.md`, including both mute colours and the navy-tinted shadows.
- **Curves and timings:** curves come from `easeOut`/`easeSpring` only. The login entrance staggers, the -6/5/-3px shake and the success-tick timeline match the spec.
- **Reduced motion:** `afDuration` handles it, and spinners keep turning as the spec requires.
- **Responsive helpers:** `AfLayout`, `afBottomInset`, `AfContentWidth`, and `AfOnboardingFrame` (portrait lock plus 1.3× text cap).
- **Layout test:** `onboarding_layout_test.dart` covers 7 sizes × 2 text scales.
- **Lazy lists:** the invoice list and sheet tabs build lazily (`ListView.builder` and slivers).
- **Double-submit guard:** in the login bloc (`login_bloc.dart:52,84`), plus press blocking while busy.

## 9. Suggested order

1. P0 fixes (section 2), one PR.
2. Theme stage 1.
3. Move the `Af*` widgets to core and decide the dialog-button style.
4. Migrate each feature (core → invoice → inspection → dashboard → search). Add a layout test for each screen, following the onboarding test.
5. Motion cleanup (section 4).
6. Accessibility pass (section 5).
7. Store screenshots (section 7).
