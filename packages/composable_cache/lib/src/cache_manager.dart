import 'dart:async';

import 'cache_store.dart';

/// Cache change event for reactive updates
class CacheChangeEvent {
  const CacheChangeEvent({
    required this.key,
    required this.type,
    this.value,
  });

  final String key;
  final CacheChangeType type;
  final Object? value;
}

enum CacheChangeType { put, invalidate, clear }

class CacheManager {
  CacheManager({required CacheStore store}) : _store = store;

  final CacheStore _store;
  final StreamController<CacheChangeEvent> _changeController = StreamController<CacheChangeEvent>.broadcast();

  /// Stream of cache changes for reactive updates
  Stream<CacheChangeEvent> get changes => _changeController.stream;

  /// Stream of specific key changes
  Stream<T?> watch<T>(String key) {
    return changes
        .where((event) => event.key == key || event.type == CacheChangeType.clear)
        .asyncMap((_) => get<T>(key));
  }

  Future<T?> get<T>(String key) async {
    final value = await _store.read(key);
    return value as T?;
  }

  Future<void> put<T>(
    String key,
    T value, {
    Duration ttl = const Duration(minutes: 5),
  }) async {
    await _store.write(key, value as Object, DateTime.now().add(ttl));
    _changeController.add(CacheChangeEvent(
      key: key,
      type: CacheChangeType.put,
      value: value,
    ));
  }

  Future<void> invalidate(String key) async {
    await _store.delete(key);
    _changeController.add(CacheChangeEvent(
      key: key,
      type: CacheChangeType.invalidate,
    ));
  }

  Future<void> clear() async {
    await _store.clear();
    _changeController.add(const CacheChangeEvent(
      key: '',
      type: CacheChangeType.clear,
    ));
  }

  void dispose() {
    _changeController.close();
  }
}
