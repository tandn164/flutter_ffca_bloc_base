class CacheEntry {
  const CacheEntry(
      {required this.body, required this.storedAt, required this.ttl});

  final String body;
  final DateTime storedAt;
  final Duration ttl;

  bool isFresh(DateTime now) => now.difference(storedAt) < ttl;
}

abstract class CacheStore {
  CacheEntry? get(String key);
  void put(String key, CacheEntry entry);
  void invalidate(String key);
  void invalidateWhere(bool Function(String key) test);
}

class MemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> _data = {};

  @override
  CacheEntry? get(String key) => _data[key];

  @override
  void put(String key, CacheEntry entry) => _data[key] = entry;

  @override
  void invalidate(String key) => _data.remove(key);

  @override
  void invalidateWhere(bool Function(String key) test) {
    _data.removeWhere((key, _) => test(key));
  }

  void clear() => _data.clear();
}

/// Canonical query: sorted keys so `?b=2&a=1` and `?a=1&b=2` share a cache entry.
String canonicalQuery(Map<String, String> query) {
  if (query.isEmpty) return '';
  final keys = query.keys.toList()..sort();
  return [for (final k in keys) '$k=${query[k]}'].join('&');
}

String cacheKey({
  required String userId,
  required String method,
  required String path,
  Map<String, String> query = const {},
}) {
  final q = canonicalQuery(query);
  return q.isEmpty ? '$userId|$method|$path' : '$userId|$method|$path?$q';
}
