import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:test/test.dart';

class _CountingTransport implements ApiTransport {
  int calls = 0;
  String body = '{"v":1}';
  int? statusCode;
  Object? throwOn;
  bool failAlways = false;
  String? lastIdempotencyKey;

  @override
  int get httpCount => calls;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    calls++;
    lastIdempotencyKey = request.headers['Idempotency-Key'];
    if (failAlways) {
      // ignore: only_throw_errors
      throw throwOn ?? Exception('down');
    }
    if (throwOn != null && calls == 1) {
      final err = throwOn!;
      throwOn = null;
      // ignore: only_throw_errors
      throw err;
    }
    return ApiResponse(statusCode: statusCode ?? 200, body: body);
  }
}

DataGateway _gw({
  required _CountingTransport transport,
  CacheStore? cache,
  Outbox? outbox,
  FakeConnectivity? net,
  List<ApiInterceptor> interceptors = const [],
}) {
  return DataGateway(
    client: ApiClient(transport: transport, interceptors: interceptors),
    cache: cache,
    connectivity: net ?? FakeConnectivity(),
    outbox: outbox,
  );
}

void main() {
  late _CountingTransport transport;
  late MemoryCacheStore store;
  late FakeConnectivity net;
  late MemoryOutbox outbox;

  setUp(() {
    transport = _CountingTransport();
    store = MemoryCacheStore();
    net = FakeConnectivity();
    outbox = MemoryOutbox();
  });

  test('cacheFirst fresh: second call does not hit HTTP', () async {
    final gw = _gw(transport: transport, cache: store, net: net);
    final a = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    final b = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(a, isA<Ok>());
    expect(b, isA<Ok>());
    expect(transport.calls, 1);
  });

  test('cacheFirst stale + online: 1 HTTP and cache is updated', () async {
    var now = DateTime(2024);
    final gw = DataGateway(
      client: ApiClient(transport: transport),
      cache: store,
      connectivity: net,
      now: () => now,
    );
    await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(
          read: ReadStrategy.cacheFirst, ttl: Duration(seconds: 1)),
    );
    now = now.add(const Duration(seconds: 2));
    transport.body = '{"v":2}';
    final result = await gw.read(
      path: '/x',
      decode: (j) => j as Map,
      policy: const RequestPolicy(
          read: ReadStrategy.cacheFirst, ttl: Duration(seconds: 1)),
    );
    expect(result.valueOrNull?['v'], 2);
    expect(transport.calls, 2);
  });

  test('cacheFirst stale + offline: returns stale, 0 extra HTTP', () async {
    var now = DateTime(2024);
    final gw = DataGateway(
      client: ApiClient(transport: transport),
      cache: store,
      connectivity: net,
      now: () => now,
    );
    await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(
          read: ReadStrategy.cacheFirst, ttl: Duration(seconds: 1)),
    );
    now = now.add(const Duration(seconds: 2));
    net.setOffline(true);
    final before = transport.calls;
    final result = await gw.read(
      path: '/x',
      decode: (j) => j as Map,
      policy: const RequestPolicy(
          read: ReadStrategy.cacheFirst, ttl: Duration(seconds: 1)),
    );
    expect(result, isA<Ok>());
    expect(result.valueOrNull?['v'], 1);
    expect(transport.calls, before);
  });

  test('SWR emits local then remote', () async {
    store.put(
      cacheKey(userId: 'anon', method: 'GET', path: '/x'),
      CacheEntry(
          body: '{"v":0}',
          storedAt: DateTime.now(),
          ttl: const Duration(minutes: 5)),
    );
    transport.body = '{"v":9}';
    Result<Map>? refreshed;
    final gw = _gw(transport: transport, cache: store, net: net);
    final local = await gw.read(
      path: '/x',
      decode: (j) => j as Map,
      policy: const RequestPolicy(read: ReadStrategy.staleWhileRevalidate),
      onRevalidate: (r) => refreshed = r,
    );
    expect(local.valueOrNull?['v'], 0);
    await pumpEventQueue();
    expect(refreshed?.valueOrNull?['v'], 9);
  });

  test('networkFirst HTTP fail falls back to cache', () async {
    store.put(
      cacheKey(userId: 'anon', method: 'GET', path: '/x'),
      CacheEntry(
          body: '{"v":3}',
          storedAt: DateTime.now(),
          ttl: const Duration(minutes: 5)),
    );
    transport.failAlways = true;
    transport.throwOn = Exception('down');
    final gw = _gw(transport: transport, cache: store, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j as Map,
      policy: const RequestPolicy(read: ReadStrategy.networkFirst),
    );
    expect(result.valueOrNull?['v'], 3);
  });

  test('networkOnly never reads cache', () async {
    store.put(
      cacheKey(userId: 'anon', method: 'GET', path: '/x'),
      CacheEntry(
          body: '{"v":1}',
          storedAt: DateTime.now(),
          ttl: const Duration(minutes: 5)),
    );
    transport.body = '{"v":8}';
    final gw = _gw(transport: transport, cache: store, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j as Map,
      policy: const RequestPolicy(read: ReadStrategy.networkOnly),
    );
    expect(result.valueOrNull?['v'], 8);
    expect(transport.calls, 1);
  });

  test('offline + GET + cache: no HTTP', () async {
    store.put(
      cacheKey(userId: 'anon', method: 'GET', path: '/x'),
      CacheEntry(
          body: '{"v":1}',
          storedAt: DateTime.now(),
          ttl: const Duration(minutes: 5)),
    );
    net.setOffline(true);
    final gw = _gw(transport: transport, cache: store, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(result, isA<Ok>());
    expect(transport.calls, 0);
  });

  test('offline + write without retry/key: no HTTP, NetworkFailure', () async {
    net.setOffline(true);
    final gw =
        _gw(transport: transport, cache: store, outbox: outbox, net: net);
    final result = await gw.write(
      request: const ApiRequest(method: 'POST', path: '/w', body: {}),
      decode: (j) => j,
    );
    expect(result, isA<Err>());
    expect(transport.calls, 0);
    expect(outbox.length, 0);
  });

  test('POST without idempotency key is not queued on drop', () async {
    transport.throwOn = Exception('drop');
    final gw = _gw(transport: transport, outbox: outbox, net: net);
    await gw.write(
      request: const ApiRequest(
        method: 'POST',
        path: '/w',
        body: {},
        policy: RequestPolicy(retryOnReconnect: true),
      ),
      decode: (j) => j,
    );
    expect(outbox.length, 0);
  });

  test('POST with key is queued on drop; drain sends the same Idempotency-Key',
      () async {
    transport.throwOn = Exception('drop');
    final gw = _gw(
      transport: transport,
      outbox: outbox,
      net: net,
      interceptors: [IdempotencyInterceptor()],
    );
    await gw.write(
      request: const ApiRequest(
        method: 'POST',
        path: '/w',
        body: {},
        policy: RequestPolicy(retryOnReconnect: true, idempotencyKey: 'k1'),
      ),
      decode: (j) => j,
    );
    expect(outbox.length, 1);
    // App drains through ApiClient.send so IdempotencyInterceptor re-applies.
    await outbox.drain(gw.client.send);
    expect(transport.lastIdempotencyKey, 'k1');
  });

  test('JSON bad → DecodeFailure, 0 retry, not cached', () async {
    transport.body = 'not-json';
    final gw = _gw(transport: transport, cache: store, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.networkOnly),
    );
    expect(result.failureOrNull, isA<DecodeFailure>());
    expect(transport.calls, 1);
    expect(
        store.get(cacheKey(userId: 'anon', method: 'GET', path: '/x')), isNull);
  });

  test('4xx is not retried', () async {
    transport.statusCode = 400;
    final gw = _gw(transport: transport, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.networkOnly),
    );
    expect(result, isA<Err>());
    expect(transport.calls, 1);
  });

  test('GET mid-drop retries once', () async {
    transport.throwOn = Exception('drop');
    final gw = _gw(transport: transport, net: net);
    final result = await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.networkOnly),
    );
    expect(result, isA<Ok>());
    expect(transport.calls, 2);
  });

  test('in-flight GET same cache key shares one HTTP', () async {
    final gw = _gw(transport: transport, cache: store, net: net);
    final futures = [
      gw.read(
          path: '/x',
          decode: (j) => j,
          policy: const RequestPolicy(read: ReadStrategy.cacheFirst)),
      gw.read(
          path: '/x',
          decode: (j) => j,
          policy: const RequestPolicy(read: ReadStrategy.cacheFirst)),
    ];
    await Future.wait(futures);
    expect(transport.calls, 1);
  });

  test('canonical query shares a cache key; different query does not',
      () async {
    final gw = _gw(transport: transport, cache: store, net: net);
    await gw.read(
      path: '/x',
      query: {'b': '2', 'a': '1'},
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    await gw.read(
      path: '/x',
      query: {'a': '1', 'b': '2'},
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(transport.calls, 1);
    await gw.read(
      path: '/x',
      query: {'a': '9'},
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(transport.calls, 2);
  });

  test('write invalidates listed GET paths', () async {
    final gw = _gw(transport: transport, cache: store, net: net);
    await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(store.get(cacheKey(userId: 'anon', method: 'GET', path: '/x')),
        isNotNull);
    await gw.write(
      request: const ApiRequest(method: 'POST', path: '/w', body: {}),
      decode: (j) => j,
      invalidatePaths: ['/x'],
    );
    expect(
        store.get(cacheKey(userId: 'anon', method: 'GET', path: '/x')), isNull);
  });

  test('FR-09: no cache injected → cacheFirst still hits HTTP every time',
      () async {
    final gw = _gw(transport: transport, net: net);
    await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    await gw.read(
      path: '/x',
      decode: (j) => j,
      policy: const RequestPolicy(read: ReadStrategy.cacheFirst),
    );
    expect(transport.calls, 2);
  });

  test('FR-09: no outbox injected → retryable write is not queued', () async {
    transport.throwOn = Exception('drop');
    final gw = _gw(transport: transport, net: net);
    final result = await gw.write(
      request: const ApiRequest(
        method: 'POST',
        path: '/w',
        body: {},
        policy: RequestPolicy(retryOnReconnect: true, idempotencyKey: 'k'),
      ),
      decode: (j) => j,
    );
    expect(result, isA<Err>());
  });
}
