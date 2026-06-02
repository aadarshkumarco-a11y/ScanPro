import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanpro/features/ocr/presentation/providers/ocr_provider.dart';

class SmartActionChip extends StatelessWidget {
  final SmartAction action;

  const SmartActionChip({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, label, color) = _actionMetadata();

    return ActionChip(
      onPressed: () => _handleAction(context),
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      labelStyle: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color.withOpacity(0.4)),
      backgroundColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    )
        .animate()
        .scale(duration: 200.ms, begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
        .fadeIn(duration: 200.ms);
  }

  (IconData, String, Color) _actionMetadata() {
    switch (action.type) {
      case SmartActionType.phone:
        return (Icons.phone_outlined, action.label, Colors.blue);
      case SmartActionType.email:
        return (Icons.email_outlined, action.label, Colors.red);
      case SmartActionType.url:
        return (Icons.language, action.label, Colors.teal);
      case SmartActionType.address:
        return (Icons.location_on_outlined, action.label, Colors.orange);
      case SmartActionType.date:
        return (Icons.calendar_today_outlined, action.label, Colors.purple);
    }
  }

  void _handleAction(BuildContext context) async {
    switch (action.type) {
      case SmartActionType.phone:
        final uri = Uri(scheme: 'tel', path: action.value.replaceAll(RegExp(r'[^\d+]'), ''));
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showFallback(context, 'Unable to make call');
        }
        break;
      case SmartActionType.email:
        final uri = Uri(scheme: 'mailto', path: action.value);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showFallback(context, 'Unable to open email');
        }
        break;
      case SmartActionType.url:
        final uri = Uri.tryParse(action.value);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showFallback(context, 'Unable to open URL');
        }
        break;
      case SmartActionType.address:
        final encoded = Uri.encodeComponent(action.value);
        final uri = Uri.parse('https://maps.google.com/?q=$encoded');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showFallback(context, 'Unable to open maps');
        }
        break;
      case SmartActionType.date:
        _showCalendarAction(context, action.value);
        break;
    }
  }

  void _showCalendarAction(BuildContext context, String dateStr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add "$dateStr" to calendar'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Add',
          onPressed: () {
            final uri = Uri.parse('calshow://');
            launchUrl(uri);
          },
        ),
      ),
    );
  }

  void _showFallback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
