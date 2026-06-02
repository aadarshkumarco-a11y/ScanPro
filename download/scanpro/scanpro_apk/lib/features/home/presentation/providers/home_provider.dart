import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/utils/file_utils.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';
import 'package:scanpro/features/documents/presentation/providers/document_provider.dart';

// ═══════════════════════════════════════════════════════════════════
//  Recent Documents Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the list of recently accessed documents (max 5).
///
/// Sorted by [updatedAt] descending – the most recently modified
/// documents appear first.
final recentDocumentsProvider = Provider<List<ScannedDocument>>((ref) {
  final documents = ref.watch(documentsListProvider);
  final sorted = List<ScannedDocument>.from(documents)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(5).toList();
});

// ═══════════════════════════════════════════════════════════════════
//  Quick Actions
// ═══════════════════════════════════════════════════════════════════

/// Data class representing a quick-action shortcut on the home screen.
class QuickAction {
  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
    this.gradientColors = const [Color(0xFF4D2DAB), Color(0xFF7B5FC7)],
  });

  final String id;
  final String label;
  final String icon;
  final String route;
  final List<Color> gradientColors;
}

/// Provides the list of quick-action buttons for the home dashboard.
final quickActionsProvider = Provider<List<QuickAction>>((ref) {
  return const [
    QuickAction(
      id: 'scan',
      label: 'Scan',
      icon: 'document_scanner',
      route: '/scanner',
      gradientColors: [Color(0xFF4D2DAB), Color(0xFF7B5FC7)],
    ),
    QuickAction(
      id: 'ocr',
      label: 'OCR',
      icon: 'text_fields',
      route: '/ocr',
      gradientColors: [Color(0xFF00BFA6), Color(0xFF5DF2D6)],
    ),
    QuickAction(
      id: 'pdf_tools',
      label: 'PDF Tools',
      icon: 'picture_as_pdf',
      route: '/pdf-tools',
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    ),
    QuickAction(
      id: 'qr',
      label: 'QR Code',
      icon: 'qr_code_scanner',
      route: '/qr-scanner',
      gradientColors: [Color(0xFF42A5F5), Color(0xFF80D8FF)],
    ),
  ];
});

// ═══════════════════════════════════════════════════════════════════
//  Storage Info
// ═══════════════════════════════════════════════════════════════════

/// Storage usage information for the home dashboard.
class StorageInfo {
  const StorageInfo({
    required this.usedBytes,
    required this.totalBytes,
    required this.documentCount,
  });

  final int usedBytes;
  final int totalBytes;
  final int documentCount;

  /// Human-readable used space.
  String get usedFormatted => FileUtils.formatBytes(usedBytes);

  /// Human-readable total space.
  String get totalFormatted => FileUtils.formatBytes(totalBytes);

  /// Usage ratio between 0.0 and 1.0.
  double get usageRatio => FileUtils.storageUsageRatio(usedBytes, totalBytes);

  /// Usage percentage string (e.g. "45.2%").
  String get usagePercentage =>
      FileUtils.storageUsagePercentage(usedBytes, totalBytes);
}

/// Provides storage usage information.
///
/// Calculates the total size of all documents and compares it
/// against a configurable maximum storage quota.
final storageInfoProvider = Provider<StorageInfo>((ref) {
  final documents = ref.watch(documentsListProvider);
  final usedBytes = documents.fold<int>(
    0,
    (sum, doc) => sum + doc.fileSize,
  );
  const totalBytes = 2 * 1024 * 1024 * 1024; // 2 GB free tier
  return StorageInfo(
    usedBytes: usedBytes,
    totalBytes: totalBytes,
    documentCount: documents.length,
  );
});

// ═══════════════════════════════════════════════════════════════════
//  Greeting Provider
// ═══════════════════════════════════════════════════════════════════

/// Returns a time-of-day greeting string.
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
});
