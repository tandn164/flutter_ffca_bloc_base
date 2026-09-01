import 'package:app_result/app_result.dart';
import 'package:feed_domain/feed_domain.dart';
import 'package:test/test.dart';

class _Repo implements FeedRepository {
  int calls = 0;
  int lastPage = 0;
  bool lastForce = false;

  @override
  Future<Result<FeedChunk>> getFeed({int page = 1, bool forceNetwork = false}) async {
    calls++;
    lastPage = page;
    lastForce = forceNetwork;
    return const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: false));
  }

  @override
  Future<Result<FeedItem>> createItem({required String title}) async {
    return Ok(FeedItem(id: 'n', title: title));
  }

  @override
  Future<Result<FeedItem>> updateItem({required String id, String? title, bool? done}) async {
    return Ok(FeedItem(id: id, title: title ?? 'A', done: done ?? false));
  }

  @override
  Future<Result<FeedItem>> deleteItem({required String id}) async {
    return Ok(FeedItem(id: id, title: 'gone'));
  }
}

void main() {
  test('GetFeed talks only to the abstract repository', () async {
    final repo = _Repo();
    final result = await GetFeed(repo).execute(page: 2, forceNetwork: true);
    expect(repo.calls, 1);
    expect(repo.lastPage, 2);
    expect(repo.lastForce, isTrue);
    expect(result.valueOrNull?.items.single.title, 'A');
  });
}
