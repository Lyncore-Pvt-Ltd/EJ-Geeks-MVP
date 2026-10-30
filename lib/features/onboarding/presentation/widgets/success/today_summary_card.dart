import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/autoflow_tokens.dart';

/// Frosted card listing today's numbers (label left, mono value right).
class TodaySummaryCard extends StatelessWidget {
  final List<(String, String)> rows;
  final double rowHeight;

  const TodaySummaryCard({super.key, required this.rows, this.rowHeight = 48});

  @override
  Widget build(BuildContext context) {
    const rule = Color(0x1AFFFFFF);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x0FFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: rule),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                Container(
                  constraints: BoxConstraints(minHeight: rowHeight),
                  decoration: BoxDecoration(
                    border: i == rows.length - 1
                        ? null
                        : const Border(bottom: BorderSide(color: rule)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          rows[i].$1,
                          style: AutoFlowTokens.caption.copyWith(
                            color: const Color(0xB8E5E5E5),
                          ),
                        ),
                      ),
                      Text(
                        rows[i].$2,
                        style: AutoFlowTokens.mono(
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
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
