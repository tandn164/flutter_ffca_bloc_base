import 'package:app_result/app_result.dart';

import '../entities/feed_chunk.dart';
import '../entities/feed_item.dart';

abstract class FeedRepository {
  static const pageSize = 10;

  Future<Result<FeedChunk>> getFeed({int page = 1, bool forceNetwork = false});

  Future<Result<FeedItem>> createItem({required String title});

  Future<Result<FeedItem>> updateItem({
    required String id,
    String? title,
    bool? done,
  });

  Future<Result<FeedItem>> deleteItem({required String id});
}
