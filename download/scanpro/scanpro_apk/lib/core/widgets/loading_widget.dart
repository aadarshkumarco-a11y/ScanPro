import 'package:flutter/material.dart';

/// A full-screen or inline loading indicator with an optional shimmer effect.
///
/// Use [LoadingWidget.overlay] for a blocking modal spinner and
/// [LoadingWidget.shimmer] for placeholder skeleton loading.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget._({
    super.key,
    required this.isOverlay,
    required this.message,
    required this.showShimmer,
    required this.shimmerChild,
  });

  /// Inline centered spinner with an optional [message].
  const LoadingWidget.inline({
    super.key,
    this.message,
  })  : isOverlay = false,
        showShimmer = false,
        shimmerChild = null;

  /// Full-screen overlay spinner with an optional [message].
  const LoadingWidget.overlay({
    super.key,
    this.message,
  })  : isOverlay = true,
        showShimmer = false,
        shimmerChild = null;

  /// Placeholder that wraps the supplied [child] with a simple
  /// loading indicator (replaces previous shimmer implementation).
  const LoadingWidget.shimmer({
    super.key,
    required Widget child,
  })  : isOverlay = false,
        showShimmer = true,
        shimmerChild = child,
        message = null;

  final bool isOverlay;
  final String? message;
  final bool showShimmer;
  final Widget? shimmerChild;

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return _buildShimmerReplacement(context);
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return _buildOverlay(context, content);
    }

    return Center(child: content);
  }

  // ── Overlay ─────────────────────────────────────────────────────

  Widget _buildOverlay(BuildContext context, Widget content) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: content,
          ),
        ),
      ),
    );
  }

  // ── Shimmer replacement ─────────────────────────────────────────

  Widget _buildShimmerReplacement(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF3C3850) : const Color(0xFFE0E0E0);

    return Stack(
      children: [
        shimmerChild ?? const SizedBox.shrink(),
        Container(
          color: baseColor.withValues(alpha: 0.4),
        ),
        const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ],
    );
  }
}

// ── Pre-built shimmer skeletons ───────────────────────────────────

/// A shimmer placeholder that mimics a list tile.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget.shimmer(
      child: ListTile(
        leading: _ShimmerBox(width: 48, height: 48, shape: BoxShape.circle),
        title: _ShimmerBox(height: 14, widthFraction: 0.7),
        subtitle: _ShimmerBox(height: 12, widthFraction: 0.5),
      ),
    );
  }
}

/// A shimmer placeholder that mimics a grid card.
class ShimmerGridCard extends StatelessWidget {
  const ShimmerGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget.shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(height: 120, widthFraction: 1, borderRadius: 12),
          SizedBox(height: 8),
          _ShimmerBox(height: 14, widthFraction: 0.8),
          SizedBox(height: 4),
          _ShimmerBox(height: 12, widthFraction: 0.5),
        ],
      ),
    );
  }
}

/// A shimmer placeholder for a full page of list content.
class ShimmerListPage extends StatelessWidget {
  final int itemCount;

  const ShimmerListPage({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerListTile(),
    );
  }
}

/// A shimmer placeholder for a full page of grid content.
class ShimmerGridPage extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const ShimmerGridPage({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => const ShimmerGridCard(),
    );
  }
}

// ── Private helper ────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double widthFraction;
  final double borderRadius;
  final BoxShape shape;

  const _ShimmerBox({
    required this.height,
    this.width = double.infinity,
    this.widthFraction = 1.0,
    this.borderRadius = 4,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFraction,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(borderRadius)
              : null,
          shape: shape,
        ),
      ),
    );
  }
}
