# Pending Manual Testing

Areas that were not covered in the last emulator test pass. They could still hide problems.

## Not tested

### Invoice list (needs at least one saved invoice)
- [ ] Invoice card press feedback
- [ ] Invoice list entrance animation (`AfStaggerIn`)
- [ ] Pull-to-refresh

### Bottom sheets
- [ ] Photo-picker sheet (camera / gallery)
- [ ] Invoice card long-press sheet

### Platform
- [ ] Everything on iOS (device or simulator)

## Known issue found in the same pass

- **Save pill covers controls on the Invoice tab.** For about 1.5s after a save, "Saved" sits on top of the Quantity "+" button and the price field.
  - Planned fix: move the pill just under the sheet header (below the Inspection/Invoice tabs). Change is in `invoice_bottom_sheet.dart`.

## Not bugs (no action)

- No animation in the debug build: the emulator draws too slowly in debug. Animations play in a profile build, so test motion with `flutter run --profile`.
- Holding an icon for ~700ms shows its tooltip instead of tapping. This is normal Flutter long-press behaviour.
