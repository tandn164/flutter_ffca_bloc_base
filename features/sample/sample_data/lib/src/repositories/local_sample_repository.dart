import 'package:app_result/app_result.dart';
import 'package:sample_domain/sample_domain.dart';

/// Self-contained data source used by the sample app to exercise the feature.
///
/// Product apps should bind [SampleRepository] to their own server or database
/// implementation. This implementation deliberately has no HTTP dependency.
class LocalSampleRepository implements SampleRepository {
  LocalSampleRepository({
    this.latency = const Duration(milliseconds: 250),
    Iterable<SampleItem>? initialItems,
  }) : _items = List.of(initialItems ?? _seedItems());

  final Duration latency;
  final List<SampleItem> _items;
  var _nextId = 1000;

  @override
  Future<Result<SampleChunk>> getSample({
    int page = 1,
    bool forceNetwork = false,
  }) async {
    await _wait();
    if (page < 1) {
      return const Err(ValidationFailure('Page must be greater than zero'));
    }
    final start = (page - 1) * SampleRepository.pageSize;
    if (start >= _items.length) {
      return const Ok(SampleChunk(items: [], hasMore: false));
    }
    final candidate = start + SampleRepository.pageSize;
    final end = candidate < _items.length ? candidate : _items.length;
    return Ok(
      SampleChunk(
        items: List.unmodifiable(_items.sublist(start, end)),
        hasMore: end < _items.length,
      ),
    );
  }

  @override
  Future<Result<SampleItem>> createItem({required String title}) async {
    await _wait();
    final value = title.trim();
    if (value.isEmpty) {
      return const Err(ValidationFailure('Title is required'));
    }
    final item = SampleItem(id: '${_nextId++}', title: value);
    _items.insert(0, item);
    return Ok(item);
  }

  @override
  Future<Result<SampleItem>> updateItem({
    required String id,
    String? title,
    bool? done,
  }) async {
    await _wait();
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return const Err(UnknownFailure('Item not found'));
    final value = title?.trim();
    if (value != null && value.isEmpty) {
      return const Err(ValidationFailure('Title is required'));
    }
    final previous = _items[index];
    final item = previous.copyWith(
      title: value ?? previous.title,
      done: done ?? previous.done,
    );
    _items[index] = item;
    return Ok(item);
  }

  @override
  Future<Result<SampleItem>> deleteItem({required String id}) async {
    await _wait();
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return const Err(UnknownFailure('Item not found'));
    return Ok(_items.removeAt(index));
  }

  Future<void> _wait() => Future<void>.delayed(latency);

  static Iterable<SampleItem> _seedItems() sync* {
    for (var index = 1; index <= 24; index++) {
      yield SampleItem(
        id: '$index',
        title: 'Sample task $index',
        done: index % 4 == 0,
      );
    }
  }
}
