import 'dart:async';

import 'package:composable_core/composable_core.dart';
import 'package:composable_network/composable_network.dart';
import 'package:get_it/get_it.dart';

import 'offline_queue_manager.dart';

class ComposableOfflineModule implements ComposableCoreModule {
  ComposableOfflineModule({required this.config});

  final ComposableCoreConfig config;

  @override
  String get id => 'offline';

  @override
  bool get isEnabled => config.isPackageEnabled('offline');

  @override
  Future<void> register(GetIt sl) async {
    if (!isEnabled) return;

    final offlineNode = config.packages['offline'];
    final retryOnReconnect = offlineNode is Map &&
            offlineNode['retryOnReconnect'] is bool
        ? offlineNode['retryOnReconnect'] as bool
        : true;

    sl.registerLazySingleton<OfflineQueueManager>(
      () => OfflineQueueManager(
        executor: (_) async {
          // App wires real HTTP replay via bootstrap hook when needed.
        },
      ),
    );

    sl.registerLazySingleton<_OfflineQueueBootstrap>(
      () => _OfflineQueueBootstrap(
        connectivityService: sl<ConnectivityService>(),
        queueManager: sl<OfflineQueueManager>(),
        retryOnReconnect: retryOnReconnect,
      ),
    );
  }

  @override
  Future<void> bootstrap(GetIt sl) async {
    if (!isEnabled) return;
    await sl<_OfflineQueueBootstrap>().start();
  }
}

class _OfflineQueueBootstrap {
  _OfflineQueueBootstrap({
    required ConnectivityService connectivityService,
    required OfflineQueueManager queueManager,
    required this.retryOnReconnect,
  })  : _connectivityService = connectivityService,
        _queueManager = queueManager;

  final ConnectivityService _connectivityService;
  final OfflineQueueManager _queueManager;
  final bool retryOnReconnect;

  StreamSubscription<bool>? _subscription;

  Future<void> start() async {
    if (!retryOnReconnect) return;

    _subscription ??= _connectivityService.onConnectivityChanged.listen(
      (connected) async {
        if (connected) {
          await _queueManager.flush();
        }
      },
    );

    if (await _connectivityService.isConnected) {
      await _queueManager.flush();
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}
