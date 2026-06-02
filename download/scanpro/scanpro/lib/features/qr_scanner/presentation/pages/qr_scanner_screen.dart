import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/qr_provider.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/scan_result_sheet.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrProvider.notifier).startScanning();
    });
  }

  @override
  void dispose() {
    ref.read(qrProvider.notifier).stopScanning();
    super.dispose();
  }

  void _simulateScan() {
    // For demo purposes - in production, use camera scanner
    ref.read(qrProvider.notifier).onScanDetected('https://scanpro.app/download');
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(qrProvider);
    final theme = Theme.of(context);

    // Show result sheet when a scan is detected
    ref.listen<QrState>(qrProvider, (prev, next) {
      if (next.lastResult != null && prev?.lastResult != next.lastResult) {
        _showResultSheet(next.lastResult!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            onPressed: () => ref.read(qrProvider.notifier).toggleFlash(),
            icon: Icon(
              qrState.isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: qrState.isFlashOn ? Colors.yellow : Colors.white,
            ),
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            onPressed: () => _showHistory(context),
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'History',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            color: Colors.black87,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Colors.white30,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scan overlay
          const ScanOverlay(),
          // Error message
          if (qrState.errorMessage.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  qrState.errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Bottom controls
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Point your camera at a QR code or barcode',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                // Demo button - remove in production
                FilledButton.tonal(
                  onPressed: _simulateScan,
                  child: const Text('Simulate Scan (Demo)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResultSheet(QrScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultSheet(
        result: result,
        onDismiss: () {
          Navigator.of(context).pop();
          ref.read(qrProvider.notifier).startScanning();
        },
      ),
    );
  }

  void _showHistory(BuildContext context) {
    final history = ref.read(qrProvider).history;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scan History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (history.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            ref.read(qrProvider.notifier).clearHistory();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No scan history yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final result = history[index];
                            return ListTile(
                              leading: Icon(_typeIcon(result.type)),
                              title: Text(result.title ?? result.rawValue),
                              subtitle: Text(
                                _formatDate(result.scannedAt),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () {
                                  ref.read(qrProvider.notifier).deleteFromHistory(result.id);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _typeIcon(QrType type) {
    switch (type) {
      case QrType.url:
        return Icons.language;
      case QrType.text:
        return Icons.text_fields;
      case QrType.contact:
        return Icons.person;
      case QrType.wifi:
        return Icons.wifi;
      case QrType.email:
        return Icons.email;
      case QrType.phone:
        return Icons.phone;
      case QrType.sms:
        return Icons.sms;
      case QrType.barcode:
        return Icons.barcode_reader;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
