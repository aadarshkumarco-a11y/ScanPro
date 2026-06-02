/// Animated capture button with pulse effect for the scanner camera.
///
/// Shows a large circular button with an inner circle that scales on tap.
/// A pulsing ring animation plays when auto-capture is counting down.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/core/theme/color_schemes.dart';

/// A styled capture button used on the camera screen.
///
/// [onTap] fires when the user presses the button.
/// [isProcessing] disables interaction and shows a spinner.
/// [autoCaptureCountdown] when > 0 shows a countdown and pulse ring.
class CaptureButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isProcessing;
  final int autoCaptureCountdown;

  const CaptureButton({
    super.key,
    required this.onTap,
    this.isProcessing = false,
    this.autoCaptureCountdown = 0,
  });

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _scaleController.reverse();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    _scaleController.forward();
    setState(() => _isPressed = false);
    if (!widget.isProcessing) widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.forward();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: widget.isProcessing ? null : _onTapDown,
      onTapUp: widget.isProcessing ? null : _onTapUp,
      onTapCancel: widget.isProcessing ? null : _onTapCancel,
      child: SizedBox(
        width: 76,
        height: 76,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring when auto-capture countdown
            if (widget.autoCaptureCountdown > 0)
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 3,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.35, 1.35),
                    duration: 900.ms,
                  )
                  .fadeIn(duration: 450.ms)
                  .then()
                  .fadeOut(duration: 450.ms),

            // Outer circle
            ScaleTransition(
              scale: _scaleController,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    width: 4,
                  ),
                ),
                alignment: Alignment.center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isPressed ? 50 : 58,
                  height: _isPressed ? 50 : 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isProcessing
                        ? colorScheme.onSurfaceVariant
                        : AppColors.scannerAccent,
                  ),
                  child: widget.isProcessing
                      ? Padding(
                          padding: const EdgeInsets.all(14),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.surface,
                          ),
                        )
                      : widget.autoCaptureCountdown > 0
                          ? Center(
                              child: Text(
                                '${widget.autoCaptureCountdown}',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
