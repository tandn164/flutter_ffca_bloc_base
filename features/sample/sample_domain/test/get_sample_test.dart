import 'package:app_result/app_result.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:test/test.dart';

class _Repo implements SampleRepository {
  int calls = 0;
  int lastPage = 0;
  bool lastForce = false;

  @override
  Future<Result<SampleChunk>> getSample(
      {int page = 1, bool forceNetwork = false}) async {
    calls++;
    lastPage = page;
    lastForce = forceNetwork;
    return const Ok(
        SampleChunk(items: [SampleItem(id: '1', title: 'A')], hasMore: false));
  }

  @override
  Future<Result<SampleItem>> createItem({required String title}) async {
    return Ok(SampleItem(id: 'n', title: title));
  }

  @override
  Future<Result<SampleItem>> updateItem(
      {required String id, String? title, bool? done}) async {
    return Ok(SampleItem(id: id, title: title ?? 'A', done: done ?? false));
  }

  @override
  Future<Result<SampleItem>> deleteItem({required String id}) async {
    return Ok(SampleItem(id: id, title: 'gone'));
  }
}

void main() {
  test('GetSample talks only to the abstract repository', () async {
    final repo = _Repo();
    final result = await GetSample(repo).execute(page: 2, forceNetwork: true);
    expect(repo.calls, 1);
    expect(repo.lastPage, 2);
    expect(repo.lastForce, isTrue);
    expect(result.valueOrNull?.items.single.title, 'A');
  });
}
