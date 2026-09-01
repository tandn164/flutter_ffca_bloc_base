import 'package:api_client/api_client.dart';
import 'package:chopper/chopper.dart';

import '../../features/sample_features.dart';

ChopperClient createChopperClient(ApiClient api) {
  return ChopperClient(
    baseUrl: Uri.parse('http://local'),
    client: ApiHttpClient(api),
    converter: const JsonConverter(),
    errorConverter: const JsonConverter(),
    services: createDemoApiServices(),
  );
}
