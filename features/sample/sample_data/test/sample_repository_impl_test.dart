import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:sample_data/sample_data.dart';
import 'package:test/test.dart';

class _CountingTransport implements ApiTransport {
  int calls = 0;
  String body = '{"items":[{"id":"1","title":"A"}]}';

  @override
  int get httpCount => calls;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    calls++;
    return ApiResponse(statusCode: 200, body: body);
  }
}

void main() {
  late _CountingTransport transport;
  late MemoryCacheStore store;
  late MutableConnectivityHint net;
  late SampleRepositoryImpl repo;

  setUp(() {
    transport = _CountingTransport();
    store = MemoryCacheStore();
    net = MutableConnectivityHint();
    repo = SampleRepositoryImpl(
      gateway: DataGateway(
        client: ApiClient(transport: transport),
        cache: store,
        connectivity: net,
      ),
      policy: const RequestPolicy(
        read: ReadStrategy.cacheFirst,
        ttl: Duration(minutes: 5),
      ),
    );
  });

  test('cache miss calls network then writes cache', () async {
    final result = await repo.getSample();
    expect(result, isA<Ok>());
    expect(result.valueOrNull?.items.single.title, 'A');
    expect(transport.calls, 1);
    expect(
      store.get(
        cacheKey(
          userId: 'anon',
          method: 'GET',
          path: SampleApi.samplePath,
          query: {'page': '1', 'limit': '10'},
        ),
      ),
      isNotNull,
    );
  });

  test('cache hit does not call network', () async {
    await repo.getSample();
    await repo.getSample();
    expect(transport.calls, 1);
  });
}
