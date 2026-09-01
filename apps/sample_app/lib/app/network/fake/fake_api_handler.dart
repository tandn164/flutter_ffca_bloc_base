import 'package:api_client/api_client.dart';

abstract interface class FakeApiHandler {
  ApiResponse? handle(ApiRequest request);
}
