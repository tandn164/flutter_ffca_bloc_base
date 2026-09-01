import 'dart:async';

import 'package:api_client/api_client.dart';

class SyncCoordinator {
  SyncCoordinator({
    required this.connectivity,
    required this.outbox,
    required this.send,
  });

  final ConnectivityHint connectivity;
  final Outbox outbox;
  final Future<ApiResponse> Function(ApiRequest request) send;

  bool _started = false;
  Timer? _retryTimer;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    connectivity.addListener(_onConnectivityChanged);
    if (!connectivity.isSureOffline) await syncNow();
  }

  Future<void> syncNow() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (connectivity.isSureOffline) return;
    await outbox.drain(send);
    if (_started) _scheduleRetry();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final retryAt = outbox.nextRetryAt;
    if (retryAt == null || connectivity.isSureOffline) return;
    final delay = retryAt.difference(DateTime.now());
    _retryTimer = Timer(
      delay.isNegative ? Duration.zero : delay,
      () => unawaited(syncNow()),
    );
  }

  void _onConnectivityChanged() {
    if (!connectivity.isSureOffline) unawaited(syncNow());
  }

  void dispose() {
    if (!_started) return;
    _retryTimer?.cancel();
    _retryTimer = null;
    connectivity.removeListener(_onConnectivityChanged);
    _started = false;
  }
}
