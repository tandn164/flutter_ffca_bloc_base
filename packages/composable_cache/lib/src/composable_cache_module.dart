import 'package:composable_core/composable_core.dart';
import 'package:get_it/get_it.dart';

import 'cache_manager.dart';
import 'cache_store.dart';

class ComposableCacheModule implements ComposableCoreModule {
  ComposableCacheModule({required this.config});

  final ComposableCoreConfig config;

  @override
  String get id => 'cache';

  @override
  bool get isEnabled => config.isPackageEnabled('cache');

  @override
  Future<void> register(GetIt sl) async {
    if (!isEnabled) return;

    final engine = config.packages['cache']?['engine'] as String? ?? 'memory';

    sl.registerLazySingleton<CacheStore>(() {
      switch (engine) {
        case 'hive':
          // Hive engine can be wired when dependency is added.
          return InMemoryCacheStore();
        case 'memory':
        default:
          return InMemoryCacheStore();
      }
    });

    sl.registerLazySingleton<CacheManager>(
      () => CacheManager(store: sl<CacheStore>()),
    );
  }

  @override
  Future<void> bootstrap(GetIt sl) async {}
}
