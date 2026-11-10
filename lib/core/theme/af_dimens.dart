import 'package:flutter/painting.dart';

/// Corner radii from DESIGN.md `radius:`. Slight radius for controls — never
/// pill, except [chip] (status chips, section chips, dots only).
abstract final class AfRadius {
  /// Checkbox and rating keys.
  static const double key = 6;

  /// Chips-as-buttons, icon tiles, note blocks.
  static const double small = 8;

  /// Buttons and inputs.
  static const double control = 10;

  /// Camera preview, large logo mark.
  static const double viewfinder = 12;

  /// Cards, panels, photo thumbnails, dialogs.
  static const double card = 16;

  /// Intro illustration panel, bottom-sheet top corners.
  static const double panel = 24;

  /// Status chips, section chips, dots.
  static const double chip = 9999;

  static const BorderRadius keyAll = BorderRadius.all(Radius.circular(key));
  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius controlAll = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius viewfinderAll = BorderRadius.all(
    Radius.circular(viewfinder),
  );
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius panelAll = BorderRadius.all(Radius.circular(panel));
  static const BorderRadius chipAll = BorderRadius.all(Radius.circular(chip));

  /// Bottom-sheet top corners.
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(panel),
  );
}

/// Spacing from DESIGN.md `spacing:` (8pt grid, 4 allowed for tight pairs).
abstract final class AfSpace {
  static const double xs4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double m16 = 16;
  static const double l24 = 24;
  static const double xl32 = 32;
  static const double xxl48 = 48;

  /// Horizontal screen gutter.
  static const double gutter = 16;

  /// Gap between unrelated groups (2x the related gap).
  static const double sectionGap = 24;

  /// Minimum control height (buttons, inputs).
  static const double controlHeight = 48;

  /// Minimum tap target.
  static const double minTap = 44;
}
