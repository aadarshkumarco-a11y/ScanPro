import 'package:flutter/material.dart';

/// A reusable custom app bar that wraps [AppBar] with ScanPro styling
/// and convenience constructors for common patterns.
///
/// Features:
/// - Optional back button with custom navigation
/// - Configurable title and subtitle
/// - Flexible actions list
/// - Optional bottom widget (e.g. search bar, tab bar)
/// - Consistent styling across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.showBackButton = true,
    this.onBack,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
  })  : _isSearchBar = false,
        searchController = null,
        searchHint = null,
        onSearchChanged = null,
        onSearchSubmitted = null,
        showSearchBar = false;

  /// Constructor for an app bar with an embedded search field.
  const CustomAppBar.search({
    super.key,
    this.title,
    this.searchController,
    this.searchHint = 'Search…',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.showSearchBar = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  })  : subtitle = null,
        leading = null,
        bottom = null,
        centerTitle = false,
        showBackButton = false,
        onBack = null,
        elevation = 0,
        scrolledUnderElevation = 1,
        _isSearchBar = true;

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;

  // Search-specific fields
  final bool _isSearchBar;
  final TextEditingController? searchController;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final bool showSearchBar;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    final searchHeight = (_isSearchBar && showSearchBar) ? 56.0 : 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight + searchHeight);
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchBar) return _buildSearchAppBar(context);
    return _buildStandardAppBar(context);
  }

  // ── Standard App Bar ────────────────────────────────────────────

  Widget _buildStandardAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: _buildTitle(theme),
      leading: _buildLeading(context),
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? theme.appBarTheme.elevation,
      scrolledUnderElevation:
          scrolledUnderElevation ?? theme.appBarTheme.scrolledUnderElevation,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;
    if (!showBackButton) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return IconButton(
      onPressed: onBack ?? () => Navigator.of(context).pop(),
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }

  Widget? _buildTitle(ThemeData theme) {
    if (title == null) return null;
    if (subtitle == null) {
      return Text(title!, style: theme.appBarTheme.titleTextStyle);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title!, style: theme.appBarTheme.titleTextStyle),
        Text(
          subtitle!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ── Search App Bar ──────────────────────────────────────────────

  Widget _buildSearchAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? 0,
      scrolledUnderElevation:
          scrolledUnderElevation ?? theme.appBarTheme.scrolledUnderElevation,
      bottom: showSearchBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: searchHint ?? 'Search…',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    suffixIcon: searchController != null
                        ? ValueListenableBuilder<TextEditingValue>(
                            valueListenable: searchController!,
                            builder: (_, value, __) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                onPressed: () {
                                  searchController!.clear();
                                  onSearchChanged?.call('');
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color:
                                      colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              );
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// ── Convenience Builders ──────────────────────────────────────────

/// Builds a sliver app bar equivalent for use in [CustomScrollView]s.
class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.pinned = true,
    this.floating = false,
    this.expandedHeight,
    this.flexibleSpace,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool pinned;
  final bool floating;
  final double? expandedHeight;
  final Widget? flexibleSpace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);

    return SliverAppBar(
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : Text(title),
      leading: showBackButton && Navigator.of(context).canPop()
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: localizations.backButtonTooltip,
            )
          : null,
      actions: actions,
      pinned: pinned,
      floating: floating,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
    );
  }
}
