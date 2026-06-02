/// Network connectivity checker using connectivity_plus.
///
/// Provides a Riverpod-based interface for observing and checking
/// the device's network state throughout the application.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the [Connectivity] singleton.
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider that streams the current connectivity results.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return ref.watch(connectivityProvider).onConnectivityChanged;
});

/// Provider that returns the current connectivity state as a boolean.
///
/// Returns `true` when the device has any network connection
/// (wifi, mobile, ethernet, vpn), `false` otherwise.
final isConnectedProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.when(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider that returns whether the device is on Wi-Fi.
final isWifiProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.when(
    data: (results) => results.contains(ConnectivityResult.wifi),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider that returns whether the device is on mobile data.
final isMobileProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  return connectivityAsync.when(
    data: (results) => results.contains(ConnectivityResult.mobile),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Concrete network info checker used by repository implementations.
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo({required Connectivity connectivity}) : _connectivity = connectivity;

  /// Checks whether the device currently has network connectivity.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Checks whether the device is connected via Wi-Fi.
  Future<bool> get isWifi async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.wifi);
  }

  /// Checks whether the device is connected via mobile data.
  Future<bool> get isMobile async {
    final results = await _connectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile);
  }

  /// Returns a stream of connectivity result lists.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

/// Provider for the [NetworkInfo] utility class.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(connectivity: ref.watch(connectivityProvider));
});
