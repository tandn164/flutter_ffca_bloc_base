import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Stream-based connectivity for offline queue and UI consumers.
abstract interface class ConnectivityService {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isConnected;
  bool get isConnectedSync;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({InternetConnectionChecker? checker})
      : _checker = checker ?? InternetConnectionChecker.createInstance() {
    _subscription = _checker.onStatusChange.listen(_emitFromStatus);
    _checker.hasConnection.then(_emit);
  }

  final InternetConnectionChecker _checker;
  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _lastConnected = true;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> get isConnected => _checker.hasConnection;

  @override
  bool get isConnectedSync => _lastConnected;

  void _emitFromStatus(InternetConnectionStatus status) {
    _emit(status == InternetConnectionStatus.connected);
  }

  void _emit(bool connected) {
    if (_lastConnected == connected) return;
    _lastConnected = connected;
    if (!_controller.isClosed) {
      _controller.add(connected);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
