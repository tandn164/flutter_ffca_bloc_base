import 'package:get_it/get_it.dart';

import 'composable_core_config.dart';
import 'composable_core_module.dart';

abstract final class ComposableCoreBootstrap {
  static Future<ComposableCoreConfig> initialize({
    required ComposableCoreConfig config,
    required Future<void> Function(GetIt sl) registerAppDependencies,
    List<ComposableCoreModuleDescriptor> moduleDescriptors = const [],
    List<ComposableCoreModule> modules = const [],
    GetIt? serviceLocator,
  }) async {
    final sl = serviceLocator ?? GetIt.instance;

    for (final descriptor in moduleDescriptors) {
      await descriptor.apply(sl);
    }

    for (final module in modules) {
      if (module.isEnabled) {
        await module.register(sl);
      }
    }

    await registerAppDependencies(sl);

    for (final module in modules) {
      if (module.isEnabled) {
        await module.bootstrap(sl);
      }
    }

    return config;
  }
}
