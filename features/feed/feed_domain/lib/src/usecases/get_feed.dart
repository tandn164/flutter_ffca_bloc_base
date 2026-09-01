import 'package:app_result/app_result.dart';

import '../entities/feed_chunk.dart';
import '../repositories/feed_repository.dart';

class GetFeed {
  GetFeed(this._repository);

  final FeedRepository _repository;

  Future<Result<FeedChunk>> execute({int page = 1, bool forceNetwork = false}) {
    return _repository.getFeed(page: page, forceNetwork: forceNetwork);
  }
}
