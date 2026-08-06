import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_pallete.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../pages/qr_scanner_page.dart';

/// A reusable search field: free text input, a leading QR-scan action, a
/// trailing filter action, and a dropdown of up to 5 recent searches shown
/// on focus. Has no knowledge of what is being searched — callers interpret
/// the submitted/changed query strings themselves.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.hintText = 'Search',
    required this.onQueryChanged,
    required this.onSubmitted,
    required this.onFilterTap,
  });

  final String hintText;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onFilterTap;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_handleFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? MediaQuery.of(context).size.width;
    _overlayEntry = OverlayEntry(
      builder: (_) => _RecentSearchesDropdown(
        layerLink: _layerLink,
        width: width,
        onSelect: _selectTerm,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectTerm(String term) {
    _controller.text = term;
    widget.onQueryChanged(term);
    widget.onSubmitted(term);
    context.read<SearchBloc>().add(SearchTermSubmitted(term));
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _submit(String term) {
    widget.onSubmitted(term);
    if (term.trim().isNotEmpty) {
      context.read<SearchBloc>().add(SearchTermSubmitted(term));
    }
    _removeOverlay();
    _focusNode.unfocus();
  }

  Future<void> _scanQr() async {
    _removeOverlay();
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScannerPage()));
    if (result != null && result.isNotEmpty) {
      _selectTerm(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onQueryChanged,
        onSubmitted: _submit,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          hintText: widget.hintText,
          hintStyle: GoogleFonts.inter(color: Colors.grey),
          prefixIcon: IconButton(
            icon: const Icon(
              Icons.qr_code_scanner,
              color: Color(0xFF07172B),
              size: 20,
            ),
            tooltip: 'Scan invoice QR code',
            onPressed: _scanQr,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, size: 20, color: Color(0xFF07172B)),
            tooltip: 'Filter',
            onPressed: widget.onFilterTap,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _RecentSearchesDropdown extends StatelessWidget {
  const _RecentSearchesDropdown({
    required this.layerLink,
    required this.width,
    required this.onSelect,
  });

  final LayerLink layerLink;
  final double width;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppPallete.dynamicBlack
        : AppPallete.whiteout;
    final borderColor = isDark
        ? AppPallete.forgedSteel
        : AppPallete.nebulousWhite;
    final textColor = isDark
        ? AppPallete.cascadingWhite
        : AppPallete.tricornBlack;
    final mutedColor = isDark ? AppPallete.boatAnchor : AppPallete.hypnotic;

    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 52),
        child: Material(
          color: Colors.transparent,
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state.recentSearches.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent searches',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: mutedColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.read<SearchBloc>().add(
                              const SearchHistoryCleared(),
                            ),
                            child: Text(
                              'Clear search history',
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.recentSearches.map(
                      (term) => ListTile(
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        leading: Icon(
                          Icons.history,
                          size: 18,
                          color: mutedColor,
                        ),
                        title: Text(
                          term,
                          style: TextStyle(fontSize: 14, color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelect(term),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
