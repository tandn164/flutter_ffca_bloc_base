import 'package:api_client/api_client.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:app_logging/app_logging.dart';
import 'package:app_push/app_push.dart';
import 'package:chopper/chopper.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:local_storage/local_storage.dart';
import 'package:local_storage_shared_preferences/local_storage_shared_preferences.dart';
import 'package:offline_sync/offline_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interceptor/interceptor.dart';
import 'package:tutorial_engine/tutorial_engine.dart';

import 'config/app_config.dart';
import 'config/app_env.dart';
import 'features/sample_features.dart';
import 'network/api/app_chopper.dart';
import 'network/fake/fake_api_transport.dart';
import 'router/app_router.dart';

final sl = GetIt.instance;

Future<void> register() async {
  final prefs = await SharedPreferences.getInstance();
  final localStore = SharedPreferencesKeyValueStore(prefs);
  final outbox = PersistentOutbox(store: localStore);
  await outbox.initialize();

  sl
    ..registerLazySingleton(
      () => AppConfig(
        guestAllowed: AppEnv.guestAllowed,
        flavor: AppEnv.flavor,
        apiBaseUrl: AppEnv.apiBaseUrl,
      ),
    )
    ..registerLazySingleton(() => prefs)
    ..registerSingleton<KeyValueStore>(localStore)
    ..registerLazySingleton<ConnectivityHint>(FakeConnectivity.new)
    ..registerLazySingleton<CacheStore>(MemoryCacheStore.new)
    ..registerSingleton<Outbox>(outbox)
    ..registerLazySingleton<ApiTransport>(() {
      final url = sl<AppConfig>().apiBaseUrl;
      if (url.isEmpty) {
        return FakeApiTransport(
          connectivity: sl(),
          handlers: createDemoFakeHandlers(),
          latency: const Duration(milliseconds: 400),
        );
      }
      return HttpApiTransport(baseUrl: url);
    });

  _registerLogAndPush();
  registerDemoFeatureDependencies(sl);
  await _registerNetwork();
  _registerOverlay();
}

void _registerLogAndPush() {
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final log =
      BufferedLogService(LogQueue(max: 500), alsoPrint: flavor != 'prod');
  sl
    ..registerSingleton<LogSink>(log)
    ..registerSingleton<LogReader>(log)
    ..registerSingleton<PushService>(StubPushService());
}

Future<void> _registerNetwork() async {
  sl
    ..registerLazySingleton<ApiClient>(
      () => ApiClient(
        transport: sl(),
        interceptors: [
          ApiLogInterceptor(sl()),
          IdempotencyInterceptor(),
          AuthInterceptor(
            session: sl(),
            connectivity: sl(),
            handshakePaths: demoHandshakePaths,
          ),
        ],
      ),
    )
    ..registerLazySingleton<ChopperClient>(() => createChopperClient(sl()))
    ..registerLazySingleton<DataGateway>(
      () => DataGateway(
        client: sl(),
        cache: sl(),
        connectivity: sl(),
        outbox: sl(),
      ),
    );

  final client = sl<ApiClient>();
  final sync = SyncCoordinator(
    connectivity: sl(),
    outbox: sl(),
    send: client.send,
  );
  sl.registerSingleton(sync);
  await sync.start();
}

void _registerOverlay() {
  sl
    ..registerLazySingleton<TutorialStore>(() {
      final prefs = sl<SharedPreferences>();
      return CallbackTutorialStore(
        read: (key) => prefs.getBool(key) ?? false,
        write: (key, value) async {
          await prefs.setBool(key, value);
        },
      );
    })
    ..registerLazySingleton(
      () => OverlayController(
        connectivity: sl(),
        defaultPageConfig: PageConfig(
          noInternet: sl<AppConfig>().defaultNoInternet,
        ),
        tutorialController: TutorialController(store: sl()),
      ),
    )
    ..registerLazySingleton<OverlayFeedback>(() => sl<OverlayController>())
    ..registerLazySingleton<GoRouter>(createRouter);
}
