import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/autoflow_tokens.dart';
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
    final tokens = AutoFlowTokens.of(context);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AfRadius.controlAll,
          borderSide: BorderSide(color: color, width: width),
        );
    const iconConstraints = BoxConstraints(
      minWidth: AfSpace.controlHeight,
      minHeight: AfSpace.controlHeight,
    );

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        height: AfSpace.controlHeight,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onQueryChanged,
          onSubmitted: _submit,
          textInputAction: TextInputAction.search,
          cursorColor: AutoFlowTokens.accent,
          style: AutoFlowTokens.body.copyWith(color: tokens.ink, height: 1.2),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            hintText: widget.hintText,
            hintStyle: AutoFlowTokens.body.copyWith(
              color: tokens.mute2,
              height: 1.2,
            ),
            prefixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner_rounded, color: tokens.mute2),
              iconSize: 20,
              tooltip: 'Scan invoice QR code',
              onPressed: _scanQr,
            ),
            prefixIconConstraints: iconConstraints,
            suffixIcon: IconButton(
              icon: Icon(Icons.tune_rounded, color: tokens.mute2),
              iconSize: 20,
              tooltip: 'Filter',
              onPressed: widget.onFilterTap,
            ),
            suffixIconConstraints: iconConstraints,
            filled: true,
            fillColor: tokens.soft,
            border: border(tokens.line),
            enabledBorder: border(tokens.line),
            focusedBorder: border(AutoFlowTokens.accent, 1.5),
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
    final tokens = AutoFlowTokens.of(context);
    final textColor = tokens.ink;
    final mutedColor = tokens.mute2;

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
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: tokens.card,
                  borderRadius: AfRadius.controlAll,
                  border: Border.all(color: tokens.line),
                  boxShadow: AutoFlowTokens.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AfSpace.m16,
                        AfSpace.xs4,
                        AfSpace.xs4,
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent searches',
                            style: AutoFlowTokens.caption.copyWith(
                              fontWeight: FontWeight.w500,
                              color: mutedColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.read<SearchBloc>().add(
                              const SearchHistoryCleared(),
                            ),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(
                                AfSpace.minTap,
                                AfSpace.minTap,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AfSpace.s12,
                              ),
                              foregroundColor: tokens.ink,
                              shape: const RoundedRectangleBorder(
                                borderRadius: AfRadius.smallAll,
                              ),
                            ),
                            child: Text(
                              'Clear search history',
                              style: AutoFlowTokens.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: tokens.ink,
                                decoration: TextDecoration.underline,
                                decorationColor: tokens.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.recentSearches.map(
                      (term) => ListTile(
                        minTileHeight: AfSpace.minTap,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AfSpace.m16,
                        ),
                        horizontalTitleGap: AfSpace.s12,
                        leading: Icon(
                          Icons.history,
                          size: 18,
                          color: mutedColor,
                        ),
                        title: Text(
                          term,
                          style: AutoFlowTokens.body.copyWith(color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => onSelect(term),
                      ),
                    ),
                    const SizedBox(height: AfSpace.xs4),
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
