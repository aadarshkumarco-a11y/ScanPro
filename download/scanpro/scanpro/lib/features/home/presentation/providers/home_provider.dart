import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentInfo {
  final String id;
  final String name;
  final String thumbnailPath;
  final int pageCount;
  final DateTime lastModified;
  final int sizeBytes;
  final bool isFavorite;
  final String type;

  const DocumentInfo({
    required this.id,
    required this.name,
    required this.thumbnailPath,
    this.pageCount = 1,
    required this.lastModified,
    this.sizeBytes = 0,
    this.isFavorite = false,
    this.type = 'pdf',
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class StorageInfoModel {
  final int usedBytes;
  final int totalBytes;
  final int documentCount;
  final int scanCount;
  final int ocrCount;

  const StorageInfoModel({
    this.usedBytes = 3221225472,
    this.totalBytes = 5368709120,
    this.documentCount = 47,
    this.scanCount = 128,
    this.ocrCount = 35,
  });

  double get usageFraction => totalBytes > 0 ? usedBytes / totalBytes : 0;
  String get usedFormatted => _formatBytes(usedBytes);
  String get totalFormatted => _formatBytes(totalBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class QuickAction {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const QuickAction({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

final recentDocumentsProvider = Provider<List<DocumentInfo>>((ref) {
  return const [
    DocumentInfo(
      id: '1',
      name: 'Meeting Notes',
      thumbnailPath: '',
      pageCount: 3,
      lastModified: DateTime(2024, 3, 4, 14, 30),
      sizeBytes: 245760,
      isFavorite: true,
    ),
    DocumentInfo(
      id: '2',
      name: 'Invoice March',
      thumbnailPath: '',
      pageCount: 1,
      lastModified: DateTime(2024, 3, 3, 9, 0),
      sizeBytes: 102400,
    ),
    DocumentInfo(
      id: '3',
      name: 'Contract Draft',
      thumbnailPath: '',
      pageCount: 8,
      lastModified: DateTime(2024, 3, 2, 16, 45),
      sizeBytes: 512000,
      isFavorite: true,
    ),
    DocumentInfo(
      id: '4',
      name: 'Receipt #1042',
      thumbnailPath: '',
      pageCount: 1,
      lastModified: DateTime(2024, 3, 1, 11, 20),
      sizeBytes: 81920,
    ),
    DocumentInfo(
      id: '5',
      name: 'Project Proposal',
      thumbnailPath: '',
      pageCount: 12,
      lastModified: DateTime(2024, 2, 28, 10, 0),
      sizeBytes: 1048576,
    ),
  ];
});

final favoriteDocumentsProvider = Provider<List<DocumentInfo>>((ref) {
  final allDocs = ref.watch(recentDocumentsProvider);
  return allDocs.where((doc) => doc.isFavorite).toList();
});

final storageInfoProvider = Provider<StorageInfoModel>((ref) {
  return const StorageInfoModel();
});

final quickActionProvider = Provider<List<QuickAction>>((ref) {
  return const [
    QuickAction(
      id: 'scan',
      label: 'Scan',
      icon: Icons.document_scanner,
      color: Color(0xFF4D2DAB),
    ),
    QuickAction(
      id: 'import',
      label: 'Import',
      icon: Icons.file_upload,
      color: Color(0xFF00897B),
    ),
    QuickAction(
      id: 'qr',
      label: 'QR Code',
      icon: Icons.qr_code_scanner,
      color: Color(0xFFE65100),
    ),
    QuickAction(
      id: 'pdf_tools',
      label: 'PDF Tools',
      icon: Icons.picture_as_pdf,
      color: Color(0xFF1565C0),
    ),
  ];
});
