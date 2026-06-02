import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:scanpro/di/app_module.dart';
import 'package:scanpro/features/qr_scanner/data/datasources/qr_local_datasource.dart';
import 'package:scanpro/features/qr_scanner/data/repositories/qr_repository_impl.dart';
import 'package:scanpro/features/qr_scanner/domain/entities/qr_result.dart';
import 'package:scanpro/features/qr_scanner/domain/repositories/qr_repository.dart';

// ═══════════════════════════════════════════════════════════════════
//  Repository Provider
// ═══════════════════════════════════════════════════════════════════

/// Provides the [QrRepository] implementation.
final qrRepositoryProvider = Provider<QrRepository>((ref) {
  final qrResultsBox = ref.watch(qrResultsBoxProvider);

  final localDatasource = QrLocalDatasource(
    qrResultsBox: qrResultsBox,
  );

  return QrRepositoryImpl(localDatasource: localDatasource);
});

// ═══════════════════════════════════════════════════════════════════
//  QR Scanner State
// ═══════════════════════════════════════════════════════════════════

/// Possible states for the QR scanner.
enum QrScannerStatus {
  initial,
  scanning,
  scanned,
  saving,
  saved,
  error,
}

/// State holder for the QR scanner feature.
class QrScannerState {
  const QrScannerState({
    this.status = QrScannerStatus.initial,
    this.lastScannedResult,
    this.history = const [],
    this.errorMessage,
  });

  final QrScannerStatus status;
  final QrResult? lastScannedResult;
  final List<QrResult> history;
  final String? errorMessage;

  QrScannerState copyWith({
    QrScannerStatus? status,
    QrResult? lastScannedResult,
    List<QrResult>? history,
    String? errorMessage,
  }) {
    return QrScannerState(
      status: status ?? this.status,
      lastScannedResult: lastScannedResult ?? this.lastScannedResult,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  QR Scanner Notifier
// ═══════════════════════════════════════════════════════════════════

/// State notifier for the QR scanner feature.
class QrScannerNotifier extends StateNotifier<QrScannerState> {
  QrScannerNotifier({required QrRepository repository})
      : _repository = repository,
        super(const QrScannerState());

  final QrRepository _repository;
  static const _uuid = Uuid();

  /// Handles a newly scanned QR code.
  ///
  /// Detects the type, saves the result, and refreshes the history.
  Future<void> onQrCodeScanned(String rawData) async {
    if (rawData.trim().isEmpty) return;

    state = state.copyWith(status: QrScannerStatus.scanning);

    final type = QrLocalDatasource.detectQrType(rawData);
    final result = QrResult(
      id: _uuid.v4(),
      data: rawData,
      type: type,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      status: QrScannerStatus.saving,
      lastScannedResult: result,
    );

    final saveResult = await _repository.scanQr(result);
    saveResult.fold(
      (failure) => state = state.copyWith(
        status: QrScannerStatus.error,
        errorMessage: failure.message,
      ),
      (savedResult) {
        state = state.copyWith(
          status: QrScannerStatus.saved,
          lastScannedResult: savedResult,
        );
        loadHistory();
      },
    );
  }

  /// Loads the QR scan history from storage.
  Future<void> loadHistory() async {
    final result = await _repository.getQrHistory();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (history) => state = state.copyWith(history: history),
    );
  }

  /// Deletes a QR scan result by [id].
  Future<void> deleteQrResult(String id) async {
    final result = await _repository.deleteQrResult(id);
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) {
        final updatedHistory =
            state.history.where((r) => r.id != id).toList();
        state = state.copyWith(history: updatedHistory);
      },
    );
  }

  /// Resets the scanner to allow scanning a new code.
  void resetScanner() {
    state = state.copyWith(
      status: QrScannerStatus.initial,
      lastScannedResult: null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Provider
// ═══════════════════════════════════════════════════════════════════

/// Provider for the [QrScannerNotifier].
final qrScannerProvider =
    StateNotifierProvider<QrScannerNotifier, QrScannerState>((ref) {
  return QrScannerNotifier(
    repository: ref.watch(qrRepositoryProvider),
  );
});

/// Provider for the QR scan history list.
final qrHistoryProvider = Provider<List<QrResult>>((ref) {
  return ref.watch(qrScannerProvider).history;
});
