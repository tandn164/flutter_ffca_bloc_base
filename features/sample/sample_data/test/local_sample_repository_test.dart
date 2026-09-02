import 'package:sample_data/sample_data.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:test/test.dart';

void main() {
  late LocalSampleRepository repository;

  setUp(() {
    repository = LocalSampleRepository(latency: Duration.zero);
  });

  test('paginates the bundled sample data', () async {
    final first = (await repository.getSample()).valueOrNull!;
    final second = (await repository.getSample(page: 2)).valueOrNull!;
    final third = (await repository.getSample(page: 3)).valueOrNull!;

    expect(first.items, hasLength(SampleRepository.pageSize));
    expect(second.items, hasLength(SampleRepository.pageSize));
    expect(third.items, hasLength(4));
    expect(first.hasMore, isTrue);
    expect(third.hasMore, isFalse);
  });

  test('creates, updates, and deletes an item', () async {
    final created =
        (await repository.createItem(title: 'Created')).valueOrNull!;
    final updated = (await repository.updateItem(
      id: created.id,
      done: true,
    ))
        .valueOrNull!;
    final deleted = (await repository.deleteItem(id: created.id)).valueOrNull!;

    expect(updated.done, isTrue);
    expect(deleted.id, created.id);
  });
}
