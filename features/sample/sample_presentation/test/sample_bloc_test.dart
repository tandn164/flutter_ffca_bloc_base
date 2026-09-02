import 'package:app_result/app_result.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:sample_presentation/sample_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements SampleRepository {
  _Repo(this.pages);
  final Map<int, Result<SampleChunk>> pages;
  final calls = <int>[];
  final created = <String>[];
  final updated = <String>[];
  final deleted = <String>[];

  @override
  Future<Result<SampleChunk>> getSample(
      {int page = 1, bool forceNetwork = false}) async {
    calls.add(page);
    return pages[page] ?? const Err(NetworkFailure('missing page'));
  }

  @override
  Future<Result<SampleItem>> createItem({required String title}) async {
    created.add(title);
    return Ok(SampleItem(id: 'new', title: title));
  }

  @override
  Future<Result<SampleItem>> updateItem(
      {required String id, String? title, bool? done}) async {
    updated.add(id);
    return Ok(SampleItem(id: id, title: title ?? 'A', done: done ?? false));
  }

  @override
  Future<Result<SampleItem>> deleteItem({required String id}) async {
    deleted.add(id);
    return Ok(SampleItem(id: id, title: 'gone'));
  }
}

SampleBloc _bloc(_Repo repo) {
  return SampleBloc(
    getSample: GetSample(repo),
    createItem: CreateSampleItem(repo),
    updateItem: UpdateSampleItem(repo),
    deleteItem: DeleteSampleItem(repo),
  );
}

void main() {
  test('SampleStarted emits SampleData from GetSample — no Session', () async {
    final bloc = _bloc(
      _Repo({
        1: const Ok(SampleChunk(
            items: [SampleItem(id: '1', title: 'A')], hasMore: true)),
      }),
    );
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const SampleLoading(),
        const SampleData([SampleItem(id: '1', title: 'A')],
            hasMore: true, generation: 1),
      ]),
    );
    bloc.add(const SampleStarted());
    await states;
    await bloc.close();
  });

  test('SampleStarted failure emits SampleError with notice', () async {
    final bloc = _bloc(_Repo({1: const Err(NetworkFailure('down'))}));
    final states = expectLater(
      bloc.stream,
      emitsInOrder([
        const SampleLoading(),
        const SampleError(
          'down',
          notice: SampleNotice(
              message: 'down', kind: SampleNoticeKind.error, id: 1),
        ),
      ]),
    );
    bloc.add(const SampleStarted());
    await states;
    await bloc.close();
  });

  test('SampleLoadMore appends the next page', () async {
    final repo = _Repo({
      1: const Ok(
          SampleChunk(items: [SampleItem(id: '1', title: 'A')], hasMore: true)),
      2: const Ok(SampleChunk(
          items: [SampleItem(id: '2', title: 'B')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const SampleStarted());
    await bloc.stream.firstWhere((s) => s is SampleData);
    bloc.add(const SampleLoadMore());
    await bloc.stream.firstWhere((s) => s is SampleData && s.items.length == 2);
    final data = bloc.state as SampleData;
    expect(data.items.map((e) => e.id), ['1', '2']);
    expect(data.hasMore, isFalse);
    expect(repo.calls, [1, 2]);
    await bloc.close();
  });

  test('SampleCreated prepends the new task', () async {
    final repo = _Repo({
      1: const Ok(SampleChunk(
          items: [SampleItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const SampleStarted());
    await bloc.stream.firstWhere((s) => s is SampleData);
    bloc.add(const SampleCreated('Buy milk'));
    await bloc.stream.firstWhere((s) => s is SampleData && s.items.length == 2);
    final data = bloc.state as SampleData;
    expect(data.items.first.title, 'Buy milk');
    expect(repo.created, ['Buy milk']);
    expect(data.notice?.message, 'Task added');
    await bloc.close();
  });

  test('SampleToggled updates done on the item', () async {
    final repo = _Repo({
      1: const Ok(SampleChunk(
          items: [SampleItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const SampleStarted());
    await bloc.stream.firstWhere((s) => s is SampleData);
    bloc.add(const SampleToggled('1'));
    await bloc.stream.firstWhere((s) => s is SampleData && s.items.single.done);
    await pumpEventQueue();
    expect(repo.updated, ['1']);
    await bloc.close();
  });

  test('SampleDeleted removes the item', () async {
    final repo = _Repo({
      1: const Ok(SampleChunk(
          items: [SampleItem(id: '1', title: 'A')], hasMore: false)),
    });
    final bloc = _bloc(repo);
    bloc.add(const SampleStarted());
    await bloc.stream.firstWhere((s) => s is SampleData);
    bloc.add(const SampleDeleted('1'));
    await bloc.stream.firstWhere((s) => s is SampleData && s.items.isEmpty);
    await pumpEventQueue();
    expect(repo.deleted, ['1']);
    await bloc.close();
  });
}
