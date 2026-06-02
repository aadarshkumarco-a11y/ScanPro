import 'package:flutter/material.dart';
import '../providers/signature_provider.dart';

class SignatureCard extends StatelessWidget {
  final SignatureModel signature;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const SignatureCard({
    super.key,
    required this.signature,
    this.isActive = false,
    required this.onTap,
    required this.onDelete,
  });

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(signature.color);

    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      signature.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Active',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: _SignaturePreviewPainter(
                    color: color,
                    strokeWidth: signature.strokeWidth,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Created ${_formatDate(signature.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _SignaturePreviewPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _SignaturePreviewPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final baselineY = size.height * 0.7;
    final path = Path();

    // Draw a representative signature curve
    path.moveTo(size.width * 0.1, baselineY);
    path.quadraticBezierTo(
      size.width * 0.2,
      baselineY - size.height * 0.4,
      size.width * 0.3,
      baselineY - size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.35,
      baselineY + size.height * 0.1,
      size.width * 0.4,
      baselineY - size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      baselineY + size.height * 0.15,
      size.width * 0.6,
      baselineY,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      baselineY - size.height * 0.2,
      size.width * 0.85,
      baselineY - size.height * 0.05,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePreviewPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
