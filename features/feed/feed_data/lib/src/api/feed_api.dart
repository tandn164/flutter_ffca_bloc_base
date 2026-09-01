import 'package:chopper/chopper.dart';

part 'feed_api.chopper.dart';

@ChopperApi()
abstract class FeedApi extends ChopperService {
  static const feedPath = '/demo/feed';

  static String itemPath(String id) => '$feedPath/$id';

  static FeedApi create([ChopperClient? client]) => _$FeedApi(client);

  @GET(path: feedPath)
  Future<Response<dynamic>> getFeed();

  @POST(path: feedPath)
  Future<Response<dynamic>> createFeed(@Body() Map<String, dynamic> body);

  @PATCH(path: '$feedPath/{id}')
  Future<Response<dynamic>> updateFeed(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: '$feedPath/{id}')
  Future<Response<dynamic>> deleteFeed(@Path('id') String id);
}
