/// Reusable custom app bar widget for ScanPro.
///
/// Provides a consistent app bar with optional leading action,
/// title, subtitle, and trailing actions across all screens.
library;

import 'package:flutter/material.dart';

import '../theme/dimensions.dart';

/// A customizable app bar that wraps [AppBar] with ScanPro defaults.
///
/// Features:
/// - Automatic back button when [showBackButton] is true and can pop
/// - Optional leading icon button override
/// - Title and optional subtitle
/// - Flexible trailing actions list
/// - Bottom widget slot (e.g., search bar, tab bar)
///
/// Example:
/// ```dart
/// CustomAppBar(
///   title: 'Documents',
///   actions: [IconButton(icon: Icon(Icons.search), onPressed: _onSearch)],
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text.
  final String? title;

  /// Optional subtitle text below the title.
  final String? subtitle;

  /// Optional leading widget (overrides default back button).
  final Widget? leading;

  /// Whether to show the back button when the route can pop.
  final bool showBackButton;

  /// Trailing action widgets.
  final List<Widget> actions;

  /// Optional bottom widget (e.g., TabBar, search field).
  final PreferredSizeWidget? bottom;

  /// Background color override.
  final Color? backgroundColor;

  /// Foreground color override (icons and text).
  final Color? foregroundColor;

  /// Whether to center the title.
  final bool centerTitle;

  /// Elevation value.
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.showBackButton = true,
    this.actions = const [],
    this.bottom,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
    this.elevation = Dimensions.appBarElevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && showBackButton && canPop) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    Widget? titleWidget;
    if (title != null) {
      if (subtitle != null) {
        titleWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: centerTitle
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(title!, style: theme.appBarTheme.titleTextStyle),
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      } else {
        titleWidget = Text(title!);
      }
    }

    return AppBar(
      leading: effectiveLeading,
      title: titleWidget,
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    final subtitleExtra = subtitle != null ? 20.0 : 0.0;
    return Size.fromHeight(Dimensions.appBarHeight + bottomHeight + subtitleExtra);
  }
}
