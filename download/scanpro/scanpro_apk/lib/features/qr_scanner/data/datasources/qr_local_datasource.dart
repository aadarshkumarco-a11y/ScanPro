import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/qr_result.dart';
import '../models/qr_result_model.dart';

/// Local data source for QR code scan results using Hive.
///
/// Provides CRUD operations for scanned QR codes and automatic
/// type detection from raw QR data. All methods throw
/// [CacheException] on failure so the repository implementation
/// can convert them to [Failure]s.
class QrLocalDatasource {
  QrLocalDatasource({
    required Box<dynamic> qrResultsBox,
  }) : _qrResultsBox = qrResultsBox;

  final Box<dynamic> _qrResultsBox;
  static const _uuid = Uuid();

  // ═══════════════════════════════════════════════════════════════════
  //  QR Results CRUD
  // ═══════════════════════════════════════════════════════════════════

  /// Saves a scanned QR code result to the Hive box.
  Future<QrResultModel> saveQrResult(QrResult result) async {
    try {
      final model = QrResultModel.fromEntity(result);
      await _qrResultsBox.put(result.id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to save QR result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Creates and saves a QR result from raw scanned data.
  ///
  /// Automatically detects the [QrDataType] from the content.
  Future<QrResultModel> createQrResult(String rawData) async {
    try {
      final id = _uuid.v4();
      final type = detectQrType(rawData);
      final model = QrResultModel(
        id: id,
        data: rawData,
        type: type,
        createdAt: DateTime.now(),
      );
      await _qrResultsBox.put(id, model.toHive());
      return model;
    } catch (e) {
      throw CacheException(
        message: 'Failed to create QR result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  /// Retrieves all QR scan results, most recent first.
  List<QrResultModel> getQrHistory() {
    try {
      final results = <QrResultModel>[];

      for (final key in _qrResultsBox.keys) {
        final value = _qrResultsBox.get(key);
        if (value is Map) {
          results.add(
            QrResultModel.fromHive(Map<dynamic, dynamic>.from(value)),
          );
        }
      }

      // Sort by most recently created.
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return results;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get QR history: ${e.toString()}',
        code: 1003,
      );
    }
  }

  /// Deletes a QR scan result by [id].
  Future<void> deleteQrResult(String id) async {
    try {
      await _qrResultsBox.delete(id);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete QR result: ${e.toString()}',
        code: 1002,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  //  QR Type Detection
  // ═══════════════════════════════════════════════════════════════════

  /// Detects the [QrDataType] from the raw QR code data.
  static QrDataType detectQrType(String data) {
    final trimmed = data.trim();

    // URL detection
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return QrDataType.url;
    }

    // Email detection (mailto: or email pattern)
    if (trimmed.startsWith('mailto:') ||
        RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
            .hasMatch(trimmed)) {
      return QrDataType.email;
    }

    // Phone detection (tel: or phone pattern)
    if (trimmed.startsWith('tel:') ||
        RegExp(r'^\+?\d[\d\s-]{6,}$').hasMatch(trimmed)) {
      return QrDataType.phone;
    }

    // SMS detection
    if (trimmed.startsWith('sms:') || trimmed.startsWith('SMSTO:')) {
      return QrDataType.sms;
    }

    // WiFi detection (WIFI: scheme)
    if (trimmed.startsWith('WIFI:')) {
      return QrDataType.wifi;
    }

    // Contact / vCard detection
    if (trimmed.startsWith('BEGIN:VCARD') || trimmed.startsWith('MECARD:')) {
      return QrDataType.contact;
    }

    // Default to plain text
    return QrDataType.text;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Smart Action Helpers
  // ═══════════════════════════════════════════════════════════════════

  /// Extracts the SSID from a WIFI: QR code string.
  static String? extractWifiSsid(String data) {
    if (!data.startsWith('WIFI:')) return null;
    final ssidMatch = RegExp(r'SSID:([^;]*)').firstMatch(data);
    return ssidMatch?.group(1);
  }

  /// Extracts the password from a WIFI: QR code string.
  static String? extractWifiPassword(String data) {
    if (!data.startsWith('WIFI:')) return null;
    final passMatch = RegExp(r'P:([^;]*)').firstMatch(data);
    return passMatch?.group(1);
  }

  /// Extracts the email address from a mailto: string.
  static String? extractEmail(String data) {
    if (data.startsWith('mailto:')) {
      return data.substring(7).split('?').first;
    }
    if (RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
        .hasMatch(data.trim())) {
      return data.trim();
    }
    return null;
  }

  /// Extracts the phone number from a tel: string.
  static String? extractPhone(String data) {
    if (data.startsWith('tel:')) {
      return data.substring(4);
    }
    return null;
  }
}
