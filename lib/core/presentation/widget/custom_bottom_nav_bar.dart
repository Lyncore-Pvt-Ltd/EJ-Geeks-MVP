import 'package:auto_flow/core/presentation/widgets/af/af_motion.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_bloc.dart';
import 'package:auto_flow/features/invoice/presentation/bloc/invoice_event.dart';
import 'package:auto_flow/features/invoice/presentation/widgets/invoice_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavBarTab {
  final IconData icon;
  final String text;

  const NavBarTab({required this.icon, required this.text});
}

/// Floating bottom bar: a card of icon + caption tabs (active = ink with an
/// accent underline, inactive = mute) beside the accent "New invoice" button.
/// Works with `Scaffold.extendBody: true` — content scrolls behind it.
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final List<NavBarTab> tabs;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.tabs,
  });

  static const double _barHeight = 60;

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AfSpace.gutter,
        0,
        AfSpace.gutter,
        AfSpace.m16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: _barHeight,
              padding: const EdgeInsets.symmetric(horizontal: AfSpace.s8),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: AfRadius.cardAll,
                border: Border.all(color: tokens.line),
                boxShadow: AutoFlowTokens.footerShadow,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: _NavItem(
                        tab: tabs[i],
                        selected: i == selectedIndex,
                        onTap: () {
                          if (i != selectedIndex) onTabChange(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AfSpace.s12),
          const _NewInvoiceButton(size: _barHeight),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavBarTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AutoFlowTokens.of(context);
    final duration = afDuration(context, 200);
    final color = selected ? tokens.ink : tokens.mute;

    return Semantics(
      button: true,
      selected: selected,
      label: tab.text,
      excludeSemantics: true,
      child: AfPressable(
        onTap: onTap,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: color),
                duration: duration,
                curve: AutoFlowTokens.easeOut,
                builder: (context, value, _) =>
                    Icon(tab.icon, size: 22, color: value),
              ),
              const SizedBox(height: AfSpace.xs4),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: AutoFlowTokens.easeOut,
                style: AutoFlowTokens.caption.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
                child: Text(
                  tab.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AfSpace.xs4),
              AnimatedContainer(
                duration: duration,
                curve: AutoFlowTokens.easeOut,
                height: 2,
                width: selected ? 16 : 0,
                color: AutoFlowTokens.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewInvoiceButton extends StatelessWidget {
  final double size;

  const _NewInvoiceButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'New invoice',
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: 'New invoice',
        excludeSemantics: true,
        child: AfPressable(
          onTap: () async {
            final invoiceBloc = context.read<InvoiceBloc>();
            await InvoiceBottomSheet.show(context);
            invoiceBloc.add(const InvoiceListRequested());
          },
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AutoFlowTokens.accent,
              borderRadius: AfRadius.controlAll,
              boxShadow: AutoFlowTokens.accentShadow,
            ),
            child: const Icon(
              Icons.add,
              size: 26,
              color: AutoFlowTokens.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}
