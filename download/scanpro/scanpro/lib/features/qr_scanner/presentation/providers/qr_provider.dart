import 'package:flutter_riverpod/flutter_riverpod.dart';

enum QrType { url, text, contact, wifi, email, phone, sms, barcode }

class QrScanResult {
  final String id;
  final String rawValue;
  final QrType type;
  final DateTime scannedAt;
  final String? title;
  final String? subtitle;

  const QrScanResult({
    required this.id,
    required this.rawValue,
    required this.type,
    required this.scannedAt,
    this.title,
    this.subtitle,
  });
}

class QrState {
  final bool isScanning;
  final bool hasCameraPermission;
  final QrScanResult? lastResult;
  final List<QrScanResult> history;
  final String errorMessage;
  final bool isFlashOn;

  const QrState({
    this.isScanning = false,
    this.hasCameraPermission = false,
    this.lastResult,
    this.history = const [],
    this.errorMessage = '',
    this.isFlashOn = false,
  });

  QrState copyWith({
    bool? isScanning,
    bool? hasCameraPermission,
    QrScanResult? lastResult,
    List<QrScanResult>? history,
    String? errorMessage,
    bool? isFlashOn,
    bool clearLastResult = false,
  }) {
    return QrState(
      isScanning: isScanning ?? this.isScanning,
      hasCameraPermission: hasCameraPermission ?? this.hasCameraPermission,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
      isFlashOn: isFlashOn ?? this.isFlashOn,
    );
  }
}

class QrNotifier extends StateNotifier<QrState> {
  QrNotifier() : super(const QrState());

  Future<void> startScanning() async {
    state = state.copyWith(
      isScanning: true,
      errorMessage: '',
      clearLastResult: true,
    );
    // In production, use mobile_scanner or similar package
  }

  void stopScanning() {
    state = state.copyWith(isScanning: false);
  }

  void onScanDetected(String rawValue) {
    final type = _detectType(rawValue);
    final result = QrScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      rawValue: rawValue,
      type: type,
      scannedAt: DateTime.now(),
      title: _generateTitle(rawValue, type),
      subtitle: _generateSubtitle(rawValue, type),
    );
    state = state.copyWith(
      lastResult: result,
      isScanning: false,
      history: [result, ...state.history],
    );
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  void clearHistory() {
    state = state.copyWith(history: const []);
  }

  void deleteFromHistory(String id) {
    state = state.copyWith(
      history: state.history.where((r) => r.id != id).toList(),
    );
  }

  QrType _detectType(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return QrType.url;
    }
    if (value.startsWith('mailto:')) return QrType.email;
    if (value.startsWith('tel:')) return QrType.phone;
    if (value.startsWith('smsto:')) return QrType.sms;
    if (value.startsWith('WIFI:')) return QrType.wifi;
    if (value.startsWith('BEGIN:VCARD')) return QrType.contact;
    // If numeric only, treat as barcode
    if (RegExp(r'^\d+$').hasMatch(value)) return QrType.barcode;
    return QrType.text;
  }

  String _generateTitle(String value, QrType type) {
    switch (type) {
      case QrType.url:
        return Uri.tryParse(value)?.host ?? value;
      case QrType.email:
        return value.replaceFirst('mailto:', '');
      case QrType.phone:
        return value.replaceFirst('tel:', '');
      case QrType.contact:
        return 'Contact Card';
      case QrType.wifi:
        return 'WiFi Network';
      case QrType.sms:
        return 'SMS';
      case QrType.barcode:
        return 'Barcode';
      case QrType.text:
        return value.length > 30 ? '${value.substring(0, 30)}...' : value;
    }
  }

  String? _generateSubtitle(String value, QrType type) {
    switch (type) {
      case QrType.url:
        return value;
      case QrType.contact:
        return 'vCard';
      case QrType.wifi:
        return 'Tap to connect';
      default:
        return null;
    }
  }
}

final qrProvider = StateNotifierProvider<QrNotifier, QrState>(
  (ref) => QrNotifier(),
);
