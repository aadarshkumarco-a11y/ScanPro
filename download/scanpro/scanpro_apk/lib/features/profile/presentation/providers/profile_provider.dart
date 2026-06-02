import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanpro/core/utils/file_utils.dart';
import 'package:scanpro/features/documents/presentation/providers/document_provider.dart';
import 'package:scanpro/features/scanner/domain/entities/scanned_document.dart';

// ═══════════════════════════════════════════════════════════════════
//  User Profile
// ═══════════════════════════════════════════════════════════════════

/// Simple user profile model for the profile screen.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isPremium = false,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final bool isPremium;
}

/// Provides the current user profile.
///
/// In a production app this would come from an auth repository.
/// For now it returns a placeholder that can be replaced later.
final userProfileProvider = Provider<UserProfile>((ref) {
  return const UserProfile(
    name: 'ScanPro User',
    email: 'user@scanpro.app',
    avatarUrl: null,
    isPremium: false,
  );
});

// ═══════════════════════════════════════════════════════════════════
//  User Stats
// ═══════════════════════════════════════════════════════════════════

/// Aggregate statistics shown on the profile screen.
class UserStats {
  const UserStats({
    required this.totalDocuments,
    required this.totalScans,
    required this.totalOcr,
    required this.storageUsedBytes,
  });

  final int totalDocuments;
  final int totalScans;
  final int totalOcr;
  final int storageUsedBytes;

  /// Human-readable storage used.
  String get storageUsedFormatted => FileUtils.formatBytes(storageUsedBytes);
}

/// Provides aggregate user statistics computed from document data.
final statsProvider = Provider<UserStats>((ref) {
  final documents = ref.watch(documentsListProvider);
  final totalSize = documents.fold<int>(
    0,
    (sum, doc) => sum + doc.fileSize,
  );
  final ocrCount =
      documents.where((d) => d.ocrText != null && d.ocrText!.isNotEmpty).length;

  return UserStats(
    totalDocuments: documents.length,
    totalScans: documents.fold<int>(
      0,
      (sum, doc) => sum + doc.pages.length.clamp(1, doc.pages.length),
    ),
    totalOcr: ocrCount,
    storageUsedBytes: totalSize,
  );
});
