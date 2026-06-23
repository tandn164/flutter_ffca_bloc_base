import 'package:meta/meta.dart';

@immutable
class CacheEntry<T> {
  const CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  final T value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

abstract interface class CacheStore {
  Future<void> write(String key, Object value, DateTime expiresAt);
  Future<Object?> read(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class InMemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry<Object>> _entries = {};

  @override
  Future<void> clear() async => _entries.clear();

  @override
  Future<void> delete(String key) async => _entries.remove(key);

  @override
  Future<Object?> read(String key) async {
    final entry = _entries[key];
    if (entry == null || entry.isExpired) {
      _entries.remove(key);
      return null;
    }
    return entry.value;
  }

  @override
  Future<void> write(String key, Object value, DateTime expiresAt) async {
    _entries[key] = CacheEntry<Object>(value: value, expiresAt: expiresAt);
  }
}
