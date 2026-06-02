import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiLoadingShimmer extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const AiLoadingShimmer({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  State<AiLoadingShimmer> createState() => _AiLoadingShimmerState();
}

class _AiLoadingShimmerState extends State<AiLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2), 0),
              end: Alignment(1.0 + (_controller.value * 2), 0),
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainerHighest,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 200.ms);
  }
}
