import 'package:app_result/app_result.dart';
import 'package:feed_domain/feed_domain.dart';
import 'package:feed_presentation/feed_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements FeedRepository {
  _Repo(this.pages);
  final Map<int, Result<FeedChunk>> pages;
  final calls = <int>[];
  final created = <String>[];
  final updated = <String>[];
  final deleted = <String>[];

  @override
  Future<Result<FeedChunk>> getFeed({int page = 1, bool forceNetwork = false}) async {
    calls.add(page);
    return pages[page] ?? const Err(NetworkFailure('missing page'));
  }

  @override
  Future<Result<FeedItem>> createItem({required String title}) async {
    created.add(title);
    return Ok(FeedItem(id: 'new', title: title));
  }

  @override
  Future<Result<FeedItem>> updateItem({required String id, String? title, bool? done}) async {
    updated.add(id);
    return Ok(FeedItem(id: id, title: title ?? 'A', done: done ?? false));
  }

  @override
  Future<Result<FeedItem>> deleteItem({required String id}) async {
    deleted.add(id);
    return Ok(FeedItem(id: id, title: 'gone'));
  }
}

FeedBloc _bloc(_Repo repo) {
  return FeedBloc(
    getFeed: GetFeed(repo),
    createItem: CreateFeedItem(repo),
    updateItem: UpdateFeedItem(repo),
    deleteItem: DeleteFeedItem(repo),
  );
}

void main() {
  test('FeedStarted emits FeedData from GetFeed — no Session', () async {
    final bloc = _bloc(
      _Repo({
        1: const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: true)),
      }),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const FeedLoading(),
        const FeedData([FeedItem(id: '1', title: 'A')], hasMore: true, generation: 1),
      ]),
    );
    bloc.add(const FeedStarted());
    await states;
    await bloc.close();
  });

  test('FeedStarted failure emits FeedError with notice', () async {
    final bloc = _bloc(_Repo({1: const Err(NetworkFailure('down'))}));
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const FeedLoading(),
        const FeedError(
          'down',
          notice: FeedNotice(message: 'down', kind: FeedNoticeKind.error, id: 1),
        ),
      ]),
    );
    bloc.add(const FeedStarted());
    await states;
    await bloc.close();
  });

  test('FeedLoadMore appends the next page', () async {
    final repo = _Repo({
      1: const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: true)),
      2: const Ok(FeedChunk(items: [FeedItem(id: '2', title: 'B')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const FeedStarted());
    await bloc.stream.firstWhere((s) => s is FeedData);
    bloc.add(const FeedLoadMore());
    await bloc.stream.firstWhere((s) => s is FeedData && s.items.length == 2);
    final data = bloc.state as FeedData;
    expect(data.items.map((e) => e.id), ['1', '2']);
    expect(data.hasMore, isFalse);
    expect(repo.calls, [1, 2]);
    await bloc.close();
  });

  test('FeedCreated prepends the new task', () async {
    final repo = _Repo({
      1: const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const FeedStarted());
    await bloc.stream.firstWhere((s) => s is FeedData);
    bloc.add(const FeedCreated('Buy milk'));
    await bloc.stream.firstWhere((s) => s is FeedData && s.items.length == 2);
    final data = bloc.state as FeedData;
    expect(data.items.first.title, 'Buy milk');
    expect(repo.created, ['Buy milk']);
    expect(data.notice?.message, 'Task added');
    await bloc.close();
  });

  test('FeedToggled updates done on the item', () async {
    final repo = _Repo({
      1: const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const FeedStarted());
    await bloc.stream.firstWhere((s) => s is FeedData);
    bloc.add(const FeedToggled('1'));
    await bloc.stream.firstWhere((s) => s is FeedData && s.items.single.done);
    await pumpEventQueue();
    expect(repo.updated, ['1']);
    await bloc.close();
  });

  test('FeedDeleted removes the item', () async {
    final repo = _Repo({
      1: const Ok(FeedChunk(items: [FeedItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const FeedStarted());
    await bloc.stream.firstWhere((s) => s is FeedData);
    bloc.add(const FeedDeleted('1'));
    await bloc.stream.firstWhere((s) => s is FeedData && s.items.isEmpty);
    await pumpEventQueue();
    expect(repo.deleted, ['1']);
    await bloc.close();
  });
}
