import 'package:flutter/material.dart';

import '../../../../core/theme/autoflow_tokens.dart';

/// A single selectable option in a [FilterBottomSheet].
class FilterOption<T> {
  const FilterOption({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final T value;
}

/// A reusable, generic single-select filter sheet: a floating card with a
/// grabber handle and grouped [ListTile]s with dividers (the active option
/// sits on the `hot` fill with an accent icon). Has no knowledge of
/// what [T] represents; callers supply the options, the current selection,
/// and what to do when one is picked.
class FilterBottomSheet<T> extends StatelessWidget {
  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.activeValue,
    required this.onSelected,
  });

  final String title;
  final List<FilterOption<T>> options;
  final T activeValue;
  final ValueChanged<T> onSelected;

  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<FilterOption<T>> options,
    required T activeValue,
    required ValueChanged<T> onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet<T>(
        title: title,
        options: options,
        activeValue: activeValue,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AfSpace.gutter,
          0,
          AfSpace.gutter,
          AfSpace.l24,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: AfRadius.cardAll,
          border: Border.all(color: tokens.line),
          boxShadow: AutoFlowTokens.heroShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  top: AfSpace.s12,
                  bottom: AfSpace.s8,
                ),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.line,
                  borderRadius: AfRadius.chipAll,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AfSpace.l24,
                AfSpace.xs4,
                AfSpace.l24,
                AfSpace.s12,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: AutoFlowTokens.title.copyWith(color: tokens.ink),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AfSpace.s12,
                0,
                AfSpace.s12,
                AfSpace.s12,
              ),
              // A Material (not a decorated Container) so the active tile's
              // `tileColor` and ink splashes paint above the group fill.
              child: Material(
                color: tokens.soft,
                borderRadius: AfRadius.controlAll,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < options.length; i++) ...[
                      if (i > 0)
                        Divider(
                          color: tokens.line,
                          height: 1,
                          indent: AfSpace.m16,
                          endIndent: AfSpace.m16,
                        ),
                      _FilterTile<T>(
                        option: options[i],
                        isActive: options[i].value == activeValue,
                        onSelected: onSelected,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTile<T> extends StatelessWidget {
  const _FilterTile({
    required this.option,
    required this.isActive,
    required this.onSelected,
  });

  final FilterOption<T> option;
  final bool isActive;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    return Semantics(
      selected: isActive,
      child: ListTile(
        minTileHeight: AfSpace.controlHeight,
        tileColor: isActive ? tokens.hot : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: AfSpace.m16),
        onTap: () {
          Navigator.pop(context);
          onSelected(option.value);
        },
        leading: Icon(
          option.icon,
          color: isActive ? AutoFlowTokens.accent : tokens.mute2,
        ),
        title: Text(
          option.label,
          style: AutoFlowTokens.body.copyWith(
            color: tokens.ink,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
        trailing: isActive
            ? Icon(Icons.check_rounded, color: tokens.ink)
            : null,
      ),
    );
  }
}
