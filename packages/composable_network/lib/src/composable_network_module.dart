import 'package:composable_core/composable_core.dart';
import 'package:get_it/get_it.dart';

import 'api/safe_response_parser.dart';
import 'connectivity/connectivity_service.dart';
import 'network/network_info.dart';

class ComposableNetworkModule implements ComposableCoreModule {
  const ComposableNetworkModule();

  @override
  String get id => 'network';

  @override
  bool get isEnabled => true;

  @override
  Future<void> register(GetIt sl) async {
    if (!sl.isRegistered<ConnectivityService>()) {
      sl.registerLazySingleton<ConnectivityService>(
        () => ConnectivityServiceImpl(),
      );
    }
    if (!sl.isRegistered<NetworkInfo>()) {
      sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(connectivityService: sl()),
      );
    }
    if (!sl.isRegistered<SafeResponseParser>()) {
      sl.registerLazySingleton<SafeResponseParser>(
        () => const SafeResponseParser(),
      );
    }
  }

  @override
  Future<void> bootstrap(GetIt sl) async {}
}
