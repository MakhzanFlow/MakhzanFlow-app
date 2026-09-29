import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity source behind an interface (DIP) so sync logic is testable
/// without platform channels.
abstract class ConnectivityMonitor {
  /// Emits true when any usable connection appears, false when all drop.
  Stream<bool> get onStatusChanged;

  Future<bool> get isOnline;
}

class ConnectivityPlusMonitor implements ConnectivityMonitor {
  final Connectivity _connectivity;

  ConnectivityPlusMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<bool> get onStatusChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  @override
  Future<bool> get isOnline async =>
      _hasConnection(await _connectivity.checkConnectivity());

  static bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
