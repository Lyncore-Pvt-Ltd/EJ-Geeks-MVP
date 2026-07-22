import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/inspection_tab.dart';
import 'package:ej_geek/features/invoice/presentation/widgets/invoice_screens/invoice_tab.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class InvoiceBottomSheet extends StatelessWidget {
  InvoiceBottomSheet({super.key});

  /// Ties this invoice-creation session's inspection, images and (later) PDF
  /// together under one id, until a real invoice-id system exists.
  final String invoiceId = const Uuid().v4();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: InvoiceBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppPallete.forgedSteel
                      : AppPallete.nebulousWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Create Invoice',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppPallete.cascadingWhite
                          : AppPallete.tricornBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SegmentedTabControl(
                  height: 40,
                  squeezeIntensity: 2,
                  tabTextColor: isDark
                      ? AppPallete.cascadingWhite
                      : AppPallete.tricornBlack,
                  selectedTabTextColor: AppPallete.whiteColor,
                  tabPadding: const EdgeInsets.symmetric(horizontal: 5),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  barDecoration: BoxDecoration(
                    color: isDark
                        ? AppPallete.warmOnyx
                        : AppPallete.nebulousWhite,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  indicatorDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF3D3D),
                        Color(0xFFFF6060),
                        Color(0xFFFF8A80),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  tabs: const [
                    SegmentTab(label: 'Inspection'),
                    SegmentTab(label: 'Invoice'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    InspectionTab(invoiceId: invoiceId),
                    const InvoiceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
