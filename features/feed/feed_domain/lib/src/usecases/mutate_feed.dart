import 'package:app_result/app_result.dart';

import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class CreateFeedItem {
  CreateFeedItem(this._repository);

  final FeedRepository _repository;

  Future<Result<FeedItem>> execute({required String title}) {
    return _repository.createItem(title: title);
  }
}

class UpdateFeedItem {
  UpdateFeedItem(this._repository);

  final FeedRepository _repository;

  Future<Result<FeedItem>> execute({
    required String id,
    String? title,
    bool? done,
  }) {
    return _repository.updateItem(id: id, title: title, done: done);
  }
}

class DeleteFeedItem {
  DeleteFeedItem(this._repository);

  final FeedRepository _repository;

  Future<Result<FeedItem>> execute({required String id}) {
    return _repository.deleteItem(id: id);
  }
}
