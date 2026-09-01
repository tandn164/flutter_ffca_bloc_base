import 'package:api_client/api_client.dart';
import 'package:app_result/app_result.dart';
import 'package:chopper/chopper.dart';
import 'package:profile_data/profile_data.dart';
import 'package:test/test.dart';

class _Transport implements ApiTransport {
  @override
  int get httpCount => 1;

  @override
  Future<ApiResponse> send(ApiRequest request) async {
    expect(request.path, ProfileApi.mePath);
    return const ApiResponse(
      statusCode: 200,
      body: '{"id":"1","name":"A","email":"a@b.c"}',
    );
  }
}

void main() {
  test('ProfileRepositoryImpl me goes through ProfileApi', () async {
    final client = ApiClient(transport: _Transport());
    final chopper = ChopperClient(
      baseUrl: Uri.parse('http://local'),
      client: ApiHttpClient(client),
      converter: const JsonConverter(),
      errorConverter: const JsonConverter(),
      services: [ProfileApi.create()],
    );
    try {
      final repo = ProfileRepositoryImpl(chopper.getService<ProfileApi>());
      final result = await repo.me();
      expect(result, isA<Ok>());
      expect(result.valueOrNull?.name, 'A');
    } finally {
      chopper.dispose();
    }
  });
}
