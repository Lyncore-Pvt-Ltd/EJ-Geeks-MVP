import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:flutter/material.dart';

/// App-wide Material themes built from [AutoFlowTokens] (see DESIGN.md).
///
/// Stage 1 of the design-system migration: screens that rely on Material
/// defaults pick up the AutoFlow look from here. Widgets should still read
/// token values directly via `AutoFlowTokens.of(context)`.
class AppTheme {
  static final lightTheme = _build(Brightness.light, AutoFlowTokens.light);
  static final darkTheme = _build(Brightness.dark, AutoFlowTokens.dark);

  static ThemeData _build(Brightness brightness, AutoFlowTokens t) {
    final isDark = brightness == Brightness.dark;
    // Page ground: white (light) / black (dark) — the 60 in 60/30/10.
    final ground = isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
    const onInk = Color(0xFFFFFFFF);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AutoFlowTokens.accent,
      onPrimary: AutoFlowTokens.onAccent,
      primaryContainer: t.hot,
      onPrimaryContainer: t.ink,
      secondary: t.navy,
      onSecondary: onInk,
      secondaryContainer: t.soft,
      onSecondaryContainer: t.ink,
      tertiary: AutoFlowTokens.successFg,
      onTertiary: onInk,
      error: AutoFlowTokens.errorFg,
      onError: onInk,
      errorContainer: AutoFlowTokens.errorBg,
      onErrorContainer: AutoFlowTokens.errorFg,
      surface: t.card,
      onSurface: t.ink,
      onSurfaceVariant: t.mute2,
      surfaceContainerLowest: t.card,
      surfaceContainerLow: t.card,
      surfaceContainer: t.card,
      surfaceContainerHigh: t.card,
      surfaceContainerHighest: t.card,
      outline: t.line,
      outlineVariant: t.line,
      shadow: AutoFlowTokens.navyInk,
      scrim: const Color(0x8014213D),
      inverseSurface: t.ink,
      onInverseSurface: t.card,
      inversePrimary: AutoFlowTokens.accent,
      surfaceTint: Colors.transparent,
    );

    // The four-size Satoshi scale: headline 28 / title 17 / body 16 /
    // caption 13. Hierarchy comes from opacity (ink / mute2 / mute).
    final headline = AutoFlowTokens.headline.copyWith(color: t.ink);
    final title = AutoFlowTokens.title.copyWith(color: t.ink);
    final body = AutoFlowTokens.body.copyWith(color: t.ink);
    final caption = AutoFlowTokens.caption.copyWith(color: t.mute);
    final label = AutoFlowTokens.caption.copyWith(
      color: t.ink,
      fontWeight: FontWeight.w500,
    );

    final textTheme = TextTheme(
      headlineLarge: headline,
      headlineMedium: headline,
      headlineSmall: headline,
      titleLarge: title,
      titleMedium: title,
      titleSmall: title,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: title,
      labelMedium: label,
      labelSmall: label,
    );

    const controlShape = RoundedRectangleBorder(
      borderRadius: AfRadius.controlAll,
    );
    const controlMinSize = Size(64, AfSpace.controlHeight);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AfRadius.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AutoFlowTokens.fontFamily,
      textTheme: textTheme,
      // No Material ink: tappables give feedback through AfPressable's
      // press scale + colour change instead (flutter-motion-design rule 4).
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: ground,
      canvasColor: ground,
      dividerColor: t.line,
      iconTheme: IconThemeData(color: t.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: ground,
        foregroundColor: t.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: title,
        iconTheme: IconThemeData(color: t.ink),
        actionsIconTheme: IconThemeData(color: t.ink),
      ),
      cardTheme: CardThemeData(
        color: t.card,
        surfaceTintColor: Colors.transparent,
        shadowColor: AutoFlowTokens.navyInk.withValues(alpha: 0.18),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AfRadius.cardAll,
          side: BorderSide(color: t.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AfSpace.m16,
          vertical: AfSpace.s12,
        ),
        labelStyle: label.copyWith(color: t.mute),
        floatingLabelStyle: label.copyWith(color: t.ink),
        hintStyle: body.copyWith(color: t.mute),
        helperStyle: caption,
        errorStyle: AutoFlowTokens.caption.copyWith(
          color: AutoFlowTokens.errorFg,
        ),
        prefixIconColor: t.mute,
        suffixIconColor: t.mute,
        border: inputBorder(t.line),
        enabledBorder: inputBorder(t.line),
        disabledBorder: inputBorder(t.line.withValues(alpha: t.line.a * 0.5)),
        focusedBorder: inputBorder(AutoFlowTokens.accent, 1.5),
        errorBorder: inputBorder(AutoFlowTokens.errorFg),
        focusedErrorBorder: inputBorder(AutoFlowTokens.errorFg, 1.5),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AutoFlowTokens.accent,
        selectionColor: AutoFlowTokens.accent.withValues(alpha: 0.24),
        selectionHandleColor: AutoFlowTokens.accent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AfRadius.cardAll),
        titleTextStyle: title,
        contentTextStyle: body.copyWith(color: t.mute2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.card,
        modalBackgroundColor: t.card,
        modalBarrierColor: AutoFlowTokens.scrim,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AfRadius.sheetTop),
        dragHandleColor: t.line,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AutoFlowTokens.accent,
          foregroundColor: AutoFlowTokens.onAccent,
          minimumSize: controlMinSize,
          shape: controlShape,
          textStyle: AutoFlowTokens.title,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AutoFlowTokens.accent,
          foregroundColor: AutoFlowTokens.onAccent,
          surfaceTintColor: Colors.transparent,
          shadowColor: AutoFlowTokens.accent.withValues(alpha: 0.55),
          elevation: 0,
          minimumSize: controlMinSize,
          shape: controlShape,
          textStyle: AutoFlowTokens.title,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          // Orange is never text on light grounds; text buttons use ink.
          foregroundColor: t.ink,
          minimumSize: controlMinSize,
          shape: controlShape,
          textStyle: AutoFlowTokens.title,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.ink,
          side: BorderSide(color: t.line),
          minimumSize: controlMinSize,
          shape: controlShape,
          textStyle: AutoFlowTokens.title,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.ink,
          minimumSize: const Size(AfSpace.minTap, AfSpace.minTap),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AutoFlowTokens.accent,
        linearTrackColor: t.line,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: t.card,
      ),
      // Save success uses the AfSaveStatus pill; SnackBars are left for
      // errors not tied to one field, styled as a floating card.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.card,
        elevation: 0,
        contentTextStyle: body.copyWith(color: t.ink),
        actionTextColor: AutoFlowTokens.errorFg,
        shape: RoundedRectangleBorder(
          borderRadius: AfRadius.controlAll,
          side: BorderSide(color: t.line),
        ),
      ),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.card,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        textColor: t.ink,
        iconColor: t.ink,
        selectedColor: t.ink,
        selectedTileColor: t.hot,
        titleTextStyle: body,
        subtitleTextStyle: caption,
        shape: const RoundedRectangleBorder(borderRadius: AfRadius.controlAll),
      ),
      extensions: [isDark ? AutoFlowTokens.dark : AutoFlowTokens.light],
    );
  }
}
