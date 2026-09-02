import 'package:chopper/chopper.dart';

part 'sample_api.chopper.dart';

@ChopperApi()
abstract class SampleApi extends ChopperService {
  static const samplePath = '/sample/items';

  static String itemPath(String id) => '$samplePath/$id';

  static SampleApi create([ChopperClient? client]) => _$SampleApi(client);

  @GET(path: samplePath)
  Future<Response<dynamic>> getSample();

  @POST(path: samplePath)
  Future<Response<dynamic>> createSample(@Body() Map<String, dynamic> body);

  @PATCH(path: '$samplePath/{id}')
  Future<Response<dynamic>> updateSample(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: '$samplePath/{id}')
  Future<Response<dynamic>> deleteSample(@Path('id') String id);
}
