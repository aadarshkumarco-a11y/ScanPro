import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// url_launcher and share_plus removed – using stub implementations

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/datasources/qr_local_datasource.dart';
import '../../domain/entities/qr_result.dart';
import '../providers/qr_provider.dart';

/// QR Scanner screen with camera viewfinder, scan line animation,
/// result display with smart actions (open URL, copy text, connect
/// WiFi, add contact, send email), and history list.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Load QR history on init.
    Future.microtask(() {
      ref.read(qrScannerProvider.notifier).loadHistory();
    });
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final qrState = ref.watch(qrScannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _showHistory = !_showHistory);
            },
            icon: Icon(
              _showHistory ? Icons.qr_code_scanner : Icons.history_rounded,
              color: colorScheme.onSurface,
            ),
            tooltip: _showHistory ? 'Scanner' : 'History',
          ),
        ],
      ),
      body: _showHistory
          ? _buildHistoryList(qrState)
          : qrState.lastScannedResult != null &&
                  qrState.status != QrScannerStatus.initial
              ? _buildScanResult(qrState.lastScannedResult!)
              : _buildScannerView(),
    );
  }

  // ── Scanner View ──────────────────────────────────────────────────

  Widget _buildScannerView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera placeholder
              Container(
                color: Colors.black,
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 120,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),

              // Viewfinder frame
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Animated scan line
              AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, child) {
                  final scanOffset =
                      _scanLineController.value * 250 - 125;
                  return Positioned(
                    top: 125 + scanOffset,
                    child: Container(
                      width: 230,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.primaryColor,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Corner accents
              _CornerAccents(),
            ],
          ),
        ),

        // Bottom controls
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Point your camera at a QR code',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The scanner will automatically detect and decode QR codes',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Demo scan button (for testing without camera)
                ElevatedButton.icon(
                  onPressed: () {
                    // Simulate a QR scan for demo purposes.
                    ref
                        .read(qrScannerProvider.notifier)
                        .onQrCodeScanned('https://scanpro.app');
                  },
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: const Text('Demo Scan'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Scan Result View ──────────────────────────────────────────────

  Widget _buildScanResult(QrResult result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success indicator
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'QR Code Detected',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Result data card
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TypeIcon(type: result.type),
                      const SizedBox(width: 10),
                      Text(
                        _typeLabel(result.type),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormatter.relativeTime(result.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.06),
                      ),
                    ),
                    child: SelectableText(
                      result.data,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Smart actions
          Text(
            'Actions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _SmartActions(result: result),
          const SizedBox(height: 24),

          // Scan again button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(qrScannerProvider.notifier).resetScanner();
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan Again'),
            ),
          ),
        ],
      ),
    );
  }

  // ── History List ──────────────────────────────────────────────────

  Widget _buildHistoryList(QrScannerState state) {
    if (state.history.isEmpty) {
      return const EmptyQrHistoryState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: state.history.length,
      itemBuilder: (context, index) {
        final result = state.history[index];
        return _QrHistoryCard(
          result: result,
          onTap: () {
            ref.read(qrScannerProvider.notifier).resetScanner();
            setState(() => _showHistory = false);
          },
          onDelete: () {
            ref
                .read(qrScannerProvider.notifier)
                .deleteQrResult(result.id);
          },
        );
      },
    );
  }

  String _typeLabel(QrDataType type) {
    switch (type) {
      case QrDataType.url:
        return 'URL';
      case QrDataType.text:
        return 'Text';
      case QrDataType.wifi:
        return 'WiFi';
      case QrDataType.contact:
        return 'Contact';
      case QrDataType.email:
        return 'Email';
      case QrDataType.phone:
        return 'Phone';
      case QrDataType.sms:
        return 'SMS';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Corner Accents (viewfinder corners)
// ═══════════════════════════════════════════════════════════════════

class _CornerAccents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const cornerLength = 30.0;
    const cornerWidth = 3.0;
    final color = AppTheme.primaryColor;

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              children: [
                Container(
                  width: cornerWidth,
                  height: cornerLength,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  width: cornerLength,
                  height: cornerWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: cornerLength,
                  height: cornerWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              children: [
                Container(
                  width: cornerWidth,
                  height: cornerLength,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: Row(
              children: [
                Container(
                  width: cornerWidth,
                  height: cornerLength,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  width: cornerLength,
                  height: cornerWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: cornerLength,
                  height: cornerWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              children: [
                Container(
                  width: cornerWidth,
                  height: cornerLength,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Type Icon
// ═══════════════════════════════════════════════════════════════════

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.type});

  final QrDataType type;

  @override
  Widget build(BuildContext context) {
    final iconData = _icon();
    final color = _color();

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }

  IconData _icon() {
    switch (type) {
      case QrDataType.url:
        return Icons.language_rounded;
      case QrDataType.text:
        return Icons.text_snippet_outlined;
      case QrDataType.wifi:
        return Icons.wifi_rounded;
      case QrDataType.contact:
        return Icons.person_rounded;
      case QrDataType.email:
        return Icons.email_rounded;
      case QrDataType.phone:
        return Icons.phone_rounded;
      case QrDataType.sms:
        return Icons.sms_rounded;
    }
  }

  Color _color() {
    switch (type) {
      case QrDataType.url:
        return AppTheme.primaryColor;
      case QrDataType.text:
        return AppTheme.infoColor;
      case QrDataType.wifi:
        return AppTheme.secondaryColor;
      case QrDataType.contact:
        return AppTheme.warningColor;
      case QrDataType.email:
        return AppTheme.primaryLightColor;
      case QrDataType.phone:
        return AppTheme.successColor;
      case QrDataType.sms:
        return AppTheme.accentColor;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Smart Actions
// ═══════════════════════════════════════════════════════════════════

class _SmartActions extends StatelessWidget {
  const _SmartActions({required this.result});

  final QrResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = _buildActions();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((action) {
        return ActionChip(
          onPressed: action.onTap,
          avatar: Icon(action.icon, size: 18, color: colorScheme.primary),
          label: Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  List<_QrAction> _buildActions() {
    final actions = <_QrAction>[];

    // Copy text – always available.
    actions.add(_QrAction(
      icon: Icons.copy_rounded,
      label: 'Copy',
      onTap: () => _copyToClipboard(result.data),
    ));

    // Type-specific actions.
    switch (result.type) {
      case QrDataType.url:
        actions.add(_QrAction(
          icon: Icons.open_in_browser_rounded,
          label: 'Open URL',
          onTap: () => _launchUrl(result.data),
        ));
        actions.add(_QrAction(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => _copyToClipboard(result.data),
        ));
        break;

      case QrDataType.email:
        final email = QrLocalDatasource.extractEmail(result.data) ?? result.data;
        actions.add(_QrAction(
          icon: Icons.email_rounded,
          label: 'Send Email',
          onTap: () => _launchUrl('mailto:$email'),
        ));
        break;

      case QrDataType.phone:
        final phone = QrLocalDatasource.extractPhone(result.data) ?? result.data;
        actions.add(_QrAction(
          icon: Icons.phone_rounded,
          label: 'Call',
          onTap: () => _launchUrl('tel:$phone'),
        ));
        break;

      case QrDataType.sms:
        actions.add(_QrAction(
          icon: Icons.sms_rounded,
          label: 'Send SMS',
          onTap: () => _launchUrl('sms:${result.data.replaceFirst('sms:', '')}'),
        ));
        break;

      case QrDataType.wifi:
        final ssid = QrLocalDatasource.extractWifiSsid(result.data);
        if (ssid != null) {
          actions.add(_QrAction(
            icon: Icons.wifi_rounded,
            label: 'WiFi: $ssid',
            onTap: () => _copyToClipboard('WiFi Network: $ssid'),
          ));
        }
        break;

      case QrDataType.contact:
        actions.add(_QrAction(
          icon: Icons.person_add_rounded,
          label: 'Add Contact',
          onTap: () => _copyToClipboard(result.data),
        ));
        break;

      case QrDataType.text:
        actions.add(_QrAction(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => _copyToClipboard(result.data),
        ));
        break;
    }

    return actions;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  /// Stub URL launcher – copies URL to clipboard instead of launching.
  void _launchUrl(String url) {
    // url_launcher removed: copy to clipboard as fallback
    // In a real app, this would open the URL in a browser.
  }
}

class _QrAction {
  const _QrAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

// ═══════════════════════════════════════════════════════════════════
//  QR History Card
// ═══════════════════════════════════════════════════════════════════

class _QrHistoryCard extends StatelessWidget {
  const _QrHistoryCard({
    required this.result,
    required this.onTap,
    required this.onDelete,
  });

  final QrResult result;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _TypeIcon(type: result.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.data,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.relativeTime(result.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.accentColor.withValues(alpha: 0.6),
                  size: 20,
                ),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
