import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

/// Contract for optional ComposableCore packages.
abstract interface class ComposableCoreModule {
  String get id;
  bool get isEnabled;
  Future<void> register(GetIt sl);
  Future<void> bootstrap(GetIt sl) async {}
}

@immutable
class ComposableCoreModuleDescriptor {
  const ComposableCoreModuleDescriptor({
    required this.id,
    required this.enabled,
    required this.register,
    this.bootstrap,
  });

  final String id;
  final bool enabled;
  final Future<void> Function(GetIt sl) register;
  final Future<void> Function(GetIt sl)? bootstrap;

  Future<void> apply(GetIt sl) async {
    if (!enabled) return;
    await register(sl);
    await bootstrap?.call(sl);
  }
}
